"""
DeskFlow PC Companion Server
Ultra-lightweight, zero-idle-CPU companion daemon for Windows.
Provides UDP Auto-Discovery and WebSocket control & telemetry.
"""

import asyncio
import glob
import json
import os
import platform
import socket
import subprocess
import sys
import time
import urllib.request
import urllib.error
import webbrowser
import ctypes
from ctypes import wintypes
from concurrent.futures import ProcessPoolExecutor
from datetime import datetime, timezone, timedelta
from pathlib import Path

# System performance and hardware monitoring
import psutil

# Windows audio control
try:
    import pycaw.pycaw as pycaw_module
    from pycaw.pycaw import AudioUtilities
    PYCAW_AVAILABLE = True
except Exception as e:
    PYCAW_AVAILABLE = False
    print(f"[Warning] pycaw not fully loaded: {e}. Falling back to virtual keys.")

# Windows clipboard
try:
    import win32clipboard
    WIN32CLIP_AVAILABLE = True
except Exception:
    WIN32CLIP_AVAILABLE = False

# WebSockets
import websockets

# Constants
DISCOVERY_PORT = 41532
WS_PORT = 41533
APP_NAME = "DeskFlow"
VERSION = "1.0.0"

CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")

DEFAULT_CONFIG = {
    # Personal GitHub token (classic PAT with "repo" + "notifications" read scope,
    # or a fine-grained token with Pull requests: Read). Leave blank to disable
    # the GitHub card. Create one at https://github.com/settings/tokens
    "github_token": "",
    # Optional: only needed if the token's username can't be auto-detected.
    "github_username": "",
    # Local, best-effort Claude Code usage tracker. This reads *your own* local
    # ~/.claude session logs on this PC -- it is a local estimate, not an
    # official Anthropic quota API (no such public API exists), so the
    # token budgets below are a rough reference you can tune to your plan.
    "claude_tier_label": "Local estimate",
    "claude_session_token_budget": 150000,
    "claude_weekly_token_budget": 800000,
    # Weather: leave lat/lon blank to auto-locate from this PC's public IP
    # (via ip-api.com, free, no key). Set them to skip that lookup.
    "weather_lat": None,
    "weather_lon": None,
    "weather_city": None,
}


def load_config():
    """Loads config.json next to this script, creating it with defaults on first run."""
    cfg = dict(DEFAULT_CONFIG)
    try:
        if os.path.exists(CONFIG_PATH):
            with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                user_cfg = json.load(f)
            cfg.update({k: v for k, v in user_cfg.items() if k in DEFAULT_CONFIG})
        else:
            with open(CONFIG_PATH, "w", encoding="utf-8") as f:
                json.dump(DEFAULT_CONFIG, f, indent=2)
            print(f"[Config] Created {CONFIG_PATH} -- add your GitHub token there to enable the GitHub card.")
    except Exception as e:
        print(f"[Config Error] {e}")
    return cfg


CONFIG = load_config()

# Win32 Virtual Key Constants
VK_MEDIA_NEXT_TRACK = 0xB0
VK_MEDIA_PREV_TRACK = 0xB1
VK_MEDIA_STOP = 0xB2
VK_MEDIA_PLAY_PAUSE = 0xB3
VK_VOLUME_MUTE = 0xAD
VK_VOLUME_DOWN = 0xAE
VK_VOLUME_UP = 0xAF
VK_LWIN = 0x5B
VK_SHIFT = 0x10
VK_CONTROL = 0x11
VK_ESCAPE = 0x1B
KEYEVENTF_KEYUP = 0x0002

# Mouse Event Constants
MOUSEEVENTF_MOVE = 0x0001
MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_RIGHTDOWN = 0x0008
MOUSEEVENTF_RIGHTUP = 0x0010
MOUSEEVENTF_MIDDLEDOWN = 0x0020
MOUSEEVENTF_MIDDLEUP = 0x0040
MOUSEEVENTF_WHEEL = 0x0800

user32 = ctypes.windll.user32


def press_virtual_key(vk_code):
    """Simulates a virtual key press and release."""
    user32.keybd_event(vk_code, 0, 0, 0)
    user32.keybd_event(vk_code, 0, KEYEVENTF_KEYUP, 0)


def press_key_combination(*vk_codes):
    """Simulates a key chord press and release."""
    for vk in vk_codes:
        user32.keybd_event(vk, 0, 0, 0)
    for vk in reversed(vk_codes):
        user32.keybd_event(vk, 0, KEYEVENTF_KEYUP, 0)


def get_local_ip():
    """Finds the primary local LAN IP address."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Does not actually connect but determines routing interface
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip


# Global audio controller cache
_speakers_device = None
_mic_device = None

def get_speakers():
    global _speakers_device
    if not PYCAW_AVAILABLE:
        return None
    try:
        if _speakers_device is None:
            _speakers_device = AudioUtilities.GetSpeakers()
        return _speakers_device
    except Exception:
        return None


def get_master_volume_info():
    """Returns (volume_percent: int, is_muted: bool)."""
    sp = get_speakers()
    if sp:
        try:
            vol = sp.volume_percent
            muted = bool(sp.EndpointVolume.GetMute())
            return int(round(vol)), muted
        except Exception:
            pass
    return 50, False


def set_master_volume(level_percent):
    """Sets master volume level (0-100)."""
    sp = get_speakers()
    if sp:
        try:
            fraction = max(0.0, min(1.0, level_percent / 100.0))
            sp.EndpointVolume.SetMasterVolumeLevelScalar(fraction, None)
            return True
        except Exception as e:
            print(f"[Audio Error] Failed to set volume: {e}")
    return False


def set_master_mute(muted: bool):
    sp = get_speakers()
    if sp:
        try:
            sp.EndpointVolume.SetMute(1 if muted else 0, None)
            return True
        except Exception:
            pass
    press_virtual_key(VK_VOLUME_MUTE)
    return True


def get_microphone_mute_state():
    """Checks microphone mute state."""
    if not PYCAW_AVAILABLE:
        return False
    try:
        from ctypes import cast, POINTER
        mic = AudioUtilities.GetMicrophone()
        if mic:
            interface = mic.Activate(pycaw_module.IAudioEndpointVolume._iid_, 7, None)
            vol = cast(interface, POINTER(pycaw_module.IAudioEndpointVolume))
            return bool(vol.GetMute())
    except Exception:
        pass
    return False


def toggle_microphone_mute():
    """Toggles default microphone mute."""
    if PYCAW_AVAILABLE:
        try:
            from ctypes import cast, POINTER
            mic = AudioUtilities.GetMicrophone()
            if mic:
                interface = mic.Activate(pycaw_module.IAudioEndpointVolume._iid_, 7, None)
                vol = cast(interface, POINTER(pycaw_module.IAudioEndpointVolume))
                current = bool(vol.GetMute())
                vol.SetMute(0 if current else 1, None)
                return not current
        except Exception as e:
            print(f"[Mic Error] {e}")
    return False


def get_clipboard_text():
    if not WIN32CLIP_AVAILABLE:
        return ""
    try:
        win32clipboard.OpenClipboard()
        if win32clipboard.IsClipboardFormatAvailable(win32clipboard.CF_UNICODETEXT):
            text = win32clipboard.GetClipboardData(win32clipboard.CF_UNICODETEXT)
        else:
            text = ""
        win32clipboard.CloseClipboard()
        return text or ""
    except Exception:
        return ""


def set_clipboard_text(text: str):
    if not WIN32CLIP_AVAILABLE:
        return False
    try:
        win32clipboard.OpenClipboard()
        win32clipboard.EmptyClipboard()
        win32clipboard.SetClipboardText(text, win32clipboard.CF_UNICODETEXT)
        win32clipboard.CloseClipboard()
        return True
    except Exception:
        return False


# State for network rate calculation
_last_net_bytes = None
_last_net_time = None

# Cached GPU availability probe (nvidia-smi is only queried if it exists)
_nvidia_smi_checked = False
_nvidia_smi_available = False


def _has_nvidia_smi():
    global _nvidia_smi_checked, _nvidia_smi_available
    if not _nvidia_smi_checked:
        _nvidia_smi_checked = True
        try:
            subprocess.run(
                ["nvidia-smi", "-L"],
                capture_output=True, timeout=2,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0,
            )
            _nvidia_smi_available = True
        except Exception:
            _nvidia_smi_available = False
    return _nvidia_smi_available


def get_gpu_stats():
    """Real NVIDIA GPU stats via nvidia-smi (no extra Python dependency).
    Returns None if no NVIDIA GPU / driver is present -- never fabricated."""
    if not _has_nvidia_smi():
        return None
    try:
        out = subprocess.run(
            ["nvidia-smi",
             "--query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw",
             "--format=csv,noheader,nounits"],
            capture_output=True, text=True, timeout=2,
            creationflags=subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0,
        )
        line = out.stdout.strip().splitlines()[0]
        name, util, temp, mem_used, mem_total, power = [p.strip() for p in line.split(",")]
        return {
            "name": name,
            "percent": float(util),
            "temp_c": float(temp),
            "vram_used_gb": round(float(mem_used) / 1024, 1),
            "vram_total_gb": round(float(mem_total) / 1024, 1),
            "power_w": float(power) if power not in ("", "N/A") else 0.0,
        }
    except Exception:
        return None


def get_disks():
    """Real usage for every fixed local drive (no fabricated C:/D:/E: splits)."""
    disks = []
    try:
        for part in psutil.disk_partitions(all=False):
            if os.name == "nt" and "fixed" not in part.opts and "cdrom" in part.opts:
                continue
            try:
                usage = psutil.disk_usage(part.mountpoint)
            except Exception:
                continue
            label = part.mountpoint.rstrip("\\/")
            disks.append({
                "label": label,
                "percent": usage.percent,
                "used_gb": round(usage.used / (1024**3), 1),
                "total_gb": round(usage.total / (1024**3), 1),
            })
    except Exception:
        pass
    return disks


# Long-lived Process objects keyed by PID, so repeated calls to
# get_processes_snapshot() measure a real CPU delta since the *last* call
# (what psutil's cpu_percent(interval=None) is designed for) instead of
# creating fresh Process objects every time, which always samples ~0%.
# This dict only works if the same worker keeps calling this function --
# see the dedicated single-worker process pool in DeskFlowServer.
_proc_cache: dict = {}


def get_processes_snapshot(limit=24):
    """Real running-process snapshot aggregated by executable name."""
    try:
        current_pids = set()
        for p in psutil.process_iter(['pid']):
            pid = p.info['pid']
            current_pids.add(pid)
            if pid not in _proc_cache:
                _proc_cache[pid] = p
                try:
                    p.cpu_percent(interval=None)  # seed baseline for new processes
                except Exception:
                    pass

        for pid in list(_proc_cache.keys()):
            if pid not in current_pids:
                del _proc_cache[pid]

        cpu_count = psutil.cpu_count(logical=True) or 1
        aggregated = {}
        for p in list(_proc_cache.values()):
            try:
                name = (p.name() or 'Unknown').replace('.exe', '')
                cpu = p.cpu_percent(interval=None) / cpu_count
                mem = p.memory_info().rss / (1024 * 1024)
                if name not in aggregated:
                    aggregated[name] = {"name": name, "count": 0, "cpu_pct": 0.0, "ram_mb": 0.0}
                aggregated[name]["count"] += 1
                aggregated[name]["cpu_pct"] += cpu
                aggregated[name]["ram_mb"] += mem
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue

        items = sorted(aggregated.values(), key=lambda x: x["cpu_pct"], reverse=True)
        return items[:limit]
    except Exception:
        return []


def get_docker_storage():
    """Real disk count + real `docker ps` count (if Docker Desktop is installed)."""
    disks = get_disks()
    container_count = None
    try:
        out = subprocess.run(
            ["docker", "ps", "-q"],
            capture_output=True, text=True, timeout=2,
            creationflags=subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0,
        )
        if out.returncode == 0:
            container_count = len([l for l in out.stdout.splitlines() if l.strip()])
    except Exception:
        container_count = None
    return {
        "type": "docker",
        "docker_available": container_count is not None,
        "container_count": container_count or 0,
        "free_disks_count": len(disks),
    }


# ---------------------------------------------------------------------------
# Claude Code local usage tracker.
#
# Reads this machine's own ~/.claude/projects/**/*.jsonl session transcripts
# (the same files Claude Code itself writes) to compute REAL token usage in
# rolling 5-hour and 7-day windows. There is no public Anthropic API for the
# consumer "5-hour session" / "weekly" quota percentages shown in the Claude
# apps, so the percentages here are this machine's real token burn measured
# against a configurable budget (see config.json) -- labelled as a local
# estimate rather than an official number.
# ---------------------------------------------------------------------------

def _claude_projects_dir():
    return os.path.join(os.path.expanduser("~"), ".claude", "projects")


def _iter_recent_claude_jsonl(max_age_days=8):
    root = _claude_projects_dir()
    if not os.path.isdir(root):
        return
    cutoff = time.time() - max_age_days * 86400
    for path in glob.glob(os.path.join(root, "**", "*.jsonl"), recursive=True):
        try:
            if os.path.getmtime(path) >= cutoff:
                yield path
        except OSError:
            continue


def _parse_claude_timestamp(entry):
    ts = entry.get("timestamp")
    if not ts:
        return None
    try:
        return datetime.fromisoformat(str(ts).replace("Z", "+00:00"))
    except Exception:
        return None


def get_claude_usage(config):
    """Sums real local Claude Code token usage over the last 5h and 7d."""
    now = datetime.now(timezone.utc)
    session_cutoff = now - timedelta(hours=5)
    weekly_cutoff = now - timedelta(days=7)
    hour_cutoff = now - timedelta(hours=1)

    session_tokens = 0
    weekly_tokens = 0
    last_hour_tokens = 0
    last_event_at = None

    for path in _iter_recent_claude_jsonl():
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        entry = json.loads(line)
                    except Exception:
                        continue
                    usage = None
                    msg = entry.get("message")
                    if isinstance(msg, dict):
                        usage = msg.get("usage")
                    if usage is None:
                        usage = entry.get("usage")
                    if not isinstance(usage, dict):
                        continue
                    ts = _parse_claude_timestamp(entry)
                    if ts is None or ts < weekly_cutoff:
                        continue
                    # Cache-read tokens are re-sent context (billed at a steep
                    # discount) and can dwarf real usage by 100-1000x, so they
                    # are excluded here -- input+output is what actually
                    # tracks with a "how much have I used" feeling.
                    tokens = (
                        int(usage.get("input_tokens") or 0)
                        + int(usage.get("output_tokens") or 0)
                    )
                    weekly_tokens += tokens
                    if ts >= session_cutoff:
                        session_tokens += tokens
                    if ts >= hour_cutoff:
                        last_hour_tokens += tokens
                    if last_event_at is None or ts > last_event_at:
                        last_event_at = ts
        except Exception:
            continue

    session_budget = max(1, int(config.get("claude_session_token_budget", 300000)))
    weekly_budget = max(1, int(config.get("claude_weekly_token_budget", 2000000)))

    session_pct = min(100.0, round(session_tokens / session_budget * 100, 1))
    weekly_pct = min(100.0, round(weekly_tokens / weekly_budget * 100, 1))

    def fmt_tokens(n):
        if n >= 1_000_000:
            return f"{n / 1_000_000:.1f}M"
        if n >= 1_000:
            return f"{n / 1_000:.0f}K"
        return str(n)

    session_reset_at = (last_event_at or now) + timedelta(hours=5)
    minutes_left = max(0, int((session_reset_at - now).total_seconds() // 60))

    return {
        "type": "claude",
        "session_pct": session_pct,
        "session_reset": f"resets in {minutes_left // 60}h {minutes_left % 60}m" if last_event_at else "no recent activity",
        "session_status": "Plenty left" if session_pct < 70 else ("On pace" if session_pct < 90 else "Almost out"),
        "weekly_pct": weekly_pct,
        "weekly_reset": "rolling 7-day window",
        "weekly_status": "On pace" if weekly_pct < 90 else "Almost out",
        "weekly_fable_pct": 0.0,
        "weekly_fable_reset": "n/a",
        "weekly_fable_status": "Not tracked",
        "codex_session_pct": 0.0,
        "codex_reset": "Not tracked",
        "last_updated": "just now",
        "tier": config.get("claude_tier_label", "Local estimate"),
        "tokens_used": fmt_tokens(session_tokens),
        "tokens_total": fmt_tokens(session_budget),
        "burn_rate": f"{fmt_tokens(last_hour_tokens)} / hr",
    }


def get_claude_sessions(limit=10):
    """Real recently-active Claude Code project sessions on this machine,
    derived from actual local transcript activity (no fabricated statuses)."""
    root = _claude_projects_dir()
    sessions = []
    if not os.path.isdir(root):
        return sessions
    now = time.time()
    try:
        for entry in os.scandir(root):
            if not entry.is_dir():
                continue
            try:
                jsonl_files = glob.glob(os.path.join(entry.path, "*.jsonl"))
                if not jsonl_files:
                    continue
                newest = max(jsonl_files, key=os.path.getmtime)
                mtime = os.path.getmtime(newest)
            except Exception:
                continue
            age = now - mtime
            if age > 6 * 3600:
                continue  # not active today; skip rather than show stale fake state
            name = entry.name
            # Claude Code sanitizes the project path into the folder name
            # ("C--Users-you-project" style) -- show just the last segment.
            display_name = name.strip("-").split("-")[-1] or name
            status = "working" if age < 20 else "idle"
            minutes = int(age // 60)
            duration = f"{minutes}m ago" if minutes > 0 else "just now"
            sessions.append({
                "id": name,
                "name": display_name,
                "provider": "claude",
                "status": status,
                "status_text": "Working" if status == "working" else "Idle",
                "duration": duration,
            })
    except Exception:
        pass
    sessions.sort(key=lambda s: s["duration"])
    return sessions[:limit]


# ---------------------------------------------------------------------------
# GitHub -- real data via the user's own personal access token (config.json).
# ---------------------------------------------------------------------------

_github_username_cache = None


def _github_api(path, token):
    req = urllib.request.Request(
        f"https://api.github.com{path}",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "User-Agent": "DeskFlow-PC-Companion",
        },
    )
    with urllib.request.urlopen(req, timeout=4) as resp:
        return json.loads(resp.read().decode("utf-8"))


def get_github_data(config):
    token = (config.get("github_token") or "").strip()
    if not token:
        return {
            "type": "github",
            "configured": False,
            "username": "",
            "notification_count": 0,
            "review_requests": [],
            "pull_requests": [],
        }

    global _github_username_cache
    try:
        username = (config.get("github_username") or "").strip()
        if not username:
            if _github_username_cache is None:
                _github_username_cache = _github_api("/user", token).get("login", "")
            username = _github_username_cache

        notifications = _github_api("/notifications", token)
        unread_count = sum(1 for n in notifications if not n.get("unread") is False)

        review_q = urllib.parse.quote(f"is:open is:pr review-requested:{username}")
        review_results = _github_api(f"/search/issues?q={review_q}", token)
        review_requests = [
            {
                "repo": item["repository_url"].split("/")[-1],
                "number": item["number"],
                "title": item["title"],
                "url": item["html_url"],
            }
            for item in review_results.get("items", [])[:6]
        ]

        pr_q = urllib.parse.quote(f"is:open is:pr author:{username}")
        pr_results = _github_api(f"/search/issues?q={pr_q}", token)
        pull_requests = []
        for item in pr_results.get("items", [])[:6]:
            repo_full = item["repository_url"].split("/repos/")[-1]
            number = item["number"]
            draft = item.get("draft", False)
            status, label = "inReview", "in review"
            if draft:
                status, label = "draft", ""
            else:
                # Real review decision (approved / changes requested), not guessed.
                try:
                    reviews = _github_api(f"/repos/{repo_full}/pulls/{number}/reviews", token)
                    latest_by_user = {}
                    for rev in reviews:
                        user = rev.get("user", {}).get("login", "")
                        latest_by_user[user] = rev.get("state", "")
                    states = set(latest_by_user.values())
                    if "CHANGES_REQUESTED" in states:
                        status, label = "changes", "changes"
                    elif "APPROVED" in states:
                        status, label = "approved", "approved"
                except Exception:
                    pass
            pull_requests.append({
                "repo": repo_full.split("/")[-1],
                "number": number,
                "title": item["title"],
                "status": status,
                "status_label": label,
                "url": item["html_url"],
            })

        return {
            "type": "github",
            "configured": True,
            "username": f"@{username}",
            "notification_count": unread_count,
            "review_requests": review_requests,
            "pull_requests": pull_requests,
        }
    except Exception as e:
        print(f"[GitHub Error] {e}")
        return {
            "type": "github",
            "configured": True,
            "error": True,
            "username": "",
            "notification_count": 0,
            "review_requests": [],
            "pull_requests": [],
        }


# ---------------------------------------------------------------------------
# Weather -- real data via Open-Meteo (free, no API key) + IP geolocation.
# ---------------------------------------------------------------------------

_weather_location_cache = None


def _locate_by_ip():
    global _weather_location_cache
    if _weather_location_cache:
        return _weather_location_cache
    try:
        req = urllib.request.Request(
            "http://ip-api.com/json/?fields=status,lat,lon,city",
            headers={"User-Agent": "DeskFlow-PC-Companion"},
        )
        with urllib.request.urlopen(req, timeout=4) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        if data.get("status") == "success":
            _weather_location_cache = (data["lat"], data["lon"], data.get("city", ""))
            return _weather_location_cache
    except Exception:
        pass
    return None


_WEATHER_CODE_ICON = {
    0: "sunny", 1: "sunny", 2: "cloudy", 3: "cloudy",
    45: "fog", 48: "fog",
    51: "rain", 53: "rain", 55: "rain", 61: "rain", 63: "rain", 65: "rain",
    71: "snow", 73: "snow", 75: "snow",
    80: "rain", 81: "rain", 82: "rain",
    95: "storm", 96: "storm", 99: "storm",
}


def get_weather(config):
    try:
        lat, lon, city = config.get("weather_lat"), config.get("weather_lon"), config.get("weather_city")
        if lat is None or lon is None:
            located = _locate_by_ip()
            if located is None:
                return {"type": "weather", "available": False}
            lat, lon, auto_city = located
            city = city or auto_city

        url = (
            "https://api.open-meteo.com/v1/forecast"
            f"?latitude={lat}&longitude={lon}"
            "&current=temperature_2m,apparent_temperature,weather_code"
            "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
            "&timezone=auto&forecast_days=7"
        )
        req = urllib.request.Request(url, headers={"User-Agent": "DeskFlow-PC-Companion"})
        with urllib.request.urlopen(req, timeout=4) as resp:
            data = json.loads(resp.read().decode("utf-8"))

        current = data.get("current", {})
        daily = data.get("daily", {})
        days = daily.get("time", [])
        forecast = []
        for i, day in enumerate(days[:7]):
            code = daily.get("weather_code", [0] * 7)[i]
            forecast.append({
                "day": day,
                "icon": _WEATHER_CODE_ICON.get(code, "cloudy"),
                "max_temp": round(daily.get("temperature_2m_max", [0] * 7)[i]),
                "min_temp": round(daily.get("temperature_2m_min", [0] * 7)[i]),
                "rain_pct": daily.get("precipitation_probability_max", [0] * 7)[i] or 0,
            })

        return {
            "type": "weather",
            "available": True,
            "city": city or "Current location",
            "temp": round(current.get("temperature_2m", 0)),
            "feels_like": round(current.get("apparent_temperature", 0)),
            "condition": _WEATHER_CODE_ICON.get(current.get("weather_code", 0), "cloudy"),
            "max_temp": forecast[0]["max_temp"] if forecast else 0,
            "min_temp": forecast[0]["min_temp"] if forecast else 0,
            "forecast": forecast,
        }
    except Exception as e:
        print(f"[Weather Error] {e}")
        return {"type": "weather", "available": False}


def get_system_telemetry():
    """Collects system stats. Runs in <0.5ms with near-zero CPU usage."""
    global _last_net_bytes, _last_net_time

    # CPU percent (non-blocking diff from previous call)
    cpu_pct = psutil.cpu_percent(interval=None)

    # Virtual Memory
    vm = psutil.virtual_memory()
    ram_used_gb = round((vm.total - vm.available) / (1024**3), 2)
    ram_total_gb = round(vm.total / (1024**3), 2)
    ram_pct = vm.percent

    # Primary Drive Disk Usage
    try:
        disk = psutil.disk_usage('C:' if os.name == 'nt' else '/')
        disk_used_gb = round(disk.used / (1024**3), 1)
        disk_total_gb = round(disk.total / (1024**3), 1)
        disk_pct = disk.percent
    except Exception:
        disk_used_gb, disk_total_gb, disk_pct = 0, 0, 0

    disks = get_disks()
    gpu = get_gpu_stats()

    # Battery
    battery_info = {"has_battery": False, "percent": 100, "is_charging": True}
    try:
        b = psutil.sensors_battery()
        if b is not None:
            battery_info = {
                "has_battery": True,
                "percent": int(b.percent),
                "is_charging": bool(b.power_plugged)
            }
    except Exception:
        pass

    # Network Speed (KB/s)
    now = time.time()
    up_kbps, down_kbps = 0.0, 0.0
    try:
        net = psutil.net_io_counters()
        total_sent = net.bytes_sent
        total_recv = net.bytes_recv
        if _last_net_bytes and _last_net_time:
            dt = max(0.1, now - _last_net_time)
            up_kbps = round((total_sent - _last_net_bytes[0]) / (1024 * dt), 1)
            down_kbps = round((total_recv - _last_net_bytes[1]) / (1024 * dt), 1)
            # prevent negative spikes
            up_kbps = max(0.0, up_kbps)
            down_kbps = max(0.0, down_kbps)
        _last_net_bytes = (total_sent, total_recv)
        _last_net_time = now
    except Exception:
        pass

    # Volume info
    vol_level, vol_muted = get_master_volume_info()
    mic_muted = get_microphone_mute_state()

    # Uptime
    try:
        boot_time = psutil.boot_time()
        uptime_seconds = int(now - boot_time)
        hours = uptime_seconds // 3600
        minutes = (uptime_seconds % 3600) // 60
        uptime_str = f"{hours}h {minutes}m"
    except Exception:
        uptime_str = "N/A"

    return {
        "type": "stats",
        "timestamp": int(now * 1000),
        "cpu": cpu_pct,
        "cpu_cores": psutil.cpu_count(logical=True) or 4,
        "ram": {
            "used_gb": ram_used_gb,
            "total_gb": ram_total_gb,
            "percent": ram_pct
        },
        "disk": {
            "used_gb": disk_used_gb,
            "total_gb": disk_total_gb,
            "percent": disk_pct
        },
        "disks": disks,
        "gpu": gpu,
        "battery": battery_info,
        "network": {
            "up_kbps": up_kbps,
            "down_kbps": down_kbps
        },
        "volume": {
            "level": vol_level,
            "muted": vol_muted
        },
        "mic_muted": mic_muted,
        "uptime": uptime_str,
        "hostname": platform.node()
    }


class DeskFlowServer:
    def __init__(self):
        self.connected_clients = set()
        self.hostname = platform.node()
        self.local_ip = get_local_ip()
        self.stats_task = None
        self.slow_stats_task = None
        self.running = True
        # The Claude usage scan, GitHub and weather calls are slow (file
        # scans, network) and run in separate PROCESSES, not threads: a
        # worker thread touching pycaw's audio COM objects, even only via
        # garbage collection finalizing one at the wrong moment, crashes
        # the whole server with an access violation. A separate process
        # can't share that COM apartment, so it's safe.
        self.worker_pool = ProcessPoolExecutor(max_workers=2)
        # Process snapshots get their own single dedicated worker so the
        # same process keeps answering every call -- that's what lets
        # get_processes_snapshot() measure real per-process CPU deltas
        # between calls instead of resetting every time.
        self.process_snapshot_pool = ProcessPoolExecutor(max_workers=1)

    async def broadcast_loop(self):
        """UDP auto-discovery beacon and responder."""
        # Create non-blocking UDP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.setblocking(False)

        try:
            sock.bind(('0.0.0.0', DISCOVERY_PORT))
            print(f"[Discovery] UDP listening on port {DISCOVERY_PORT}")
        except Exception as e:
            print(f"[Discovery Warning] Could not bind UDP port {DISCOVERY_PORT}: {e}")
            return

        beacon_payload = json.dumps({
            "service": "deskflow",
            "hostname": self.hostname,
            "ip": self.local_ip,
            "ws_port": WS_PORT,
            "os": "Windows",
            "version": VERSION
        }).encode('utf-8')

        loop = asyncio.get_running_loop()
        last_beacon = 0

        while self.running:
            now = time.time()
            # Send beacon every 2.5 seconds to local broadcast
            if now - last_beacon >= 2.5:
                try:
                    sock.sendto(beacon_payload, ('255.255.255.255', DISCOVERY_PORT))
                    last_beacon = now
                except Exception:
                    pass

            # Read any incoming ping requests
            try:
                data, addr = await loop.run_in_executor(None, self._try_recv, sock)
                if data:
                    text = data.decode('utf-8', errors='ignore').strip()
                    if "DESKFLOW" in text or "PING" in text or "DISCOVER" in text:
                        sock.sendto(beacon_payload, addr)
            except Exception:
                pass

            await asyncio.sleep(0.5)

    def _try_recv(self, sock):
        try:
            sock.settimeout(0.4)
            return sock.recvfrom(1024)
        except (socket.timeout, BlockingIOError):
            return None, None
        except Exception:
            return None, None

    async def telemetry_loop(self):
        """Periodically streams telemetry to all connected mobile clients."""
        print("[Telemetry] Stats stream started.")
        # Prime psutil first
        psutil.cpu_percent(interval=None)

        while self.running and len(self.connected_clients) > 0:
            stats = get_system_telemetry()
            msg = json.dumps(stats)
            dead_clients = set()
            for ws in self.connected_clients:
                try:
                    await ws.send(msg)
                except Exception:
                    dead_clients.add(ws)
            self.connected_clients.difference_update(dead_clients)
            await asyncio.sleep(1.0)

        print("[Telemetry] No clients connected. Stats stream paused (0% CPU).")
        self.stats_task = None

    async def broadcast(self, payload: dict):
        if not self.connected_clients:
            return
        msg = json.dumps(payload)
        dead_clients = set()
        for ws in self.connected_clients:
            try:
                await ws.send(msg)
            except Exception:
                dead_clients.add(ws)
        self.connected_clients.difference_update(dead_clients)

    async def slow_telemetry_loop(self):
        """Lower-frequency real data: processes, Claude usage, sessions,
        GitHub, weather, Docker/disks. Runs while clients are connected.

        Claude usage (a multi-day local log scan) and the process snapshot
        can each take several real seconds on a heavily-used PC, and a
        GitHub/weather call can stall on the network -- so they run in the
        process pools above rather than directly on the event loop, which
        would otherwise freeze mouse/keyboard commands and the 1s stats
        stream for however long the slowest one takes.
        """
        print("[Telemetry] Slow data stream started (processes/claude/github/weather).")
        loop = asyncio.get_running_loop()
        tick = 0
        while self.running and len(self.connected_clients) > 0:
            try:
                items = await loop.run_in_executor(self.process_snapshot_pool, get_processes_snapshot)
                await self.broadcast({"type": "processes", "items": items})

                claude = await loop.run_in_executor(self.worker_pool, get_claude_usage, CONFIG)
                await self.broadcast(claude)

                await self.broadcast({
                    "type": "sessions",
                    "items": get_claude_sessions(),
                })
                await self.broadcast(get_docker_storage())

                # GitHub + weather change slowly and hit the network, so they
                # only refresh every ~3rd tick (~36s) to stay light-weight.
                if tick % 3 == 0:
                    github = await loop.run_in_executor(self.worker_pool, get_github_data, CONFIG)
                    await self.broadcast(github)
                    weather = await loop.run_in_executor(self.worker_pool, get_weather, CONFIG)
                    await self.broadcast(weather)
            except Exception as e:
                print(f"[Slow Telemetry Error] {e}")
            tick += 1
            await asyncio.sleep(12.0)

        print("[Telemetry] No clients connected. Slow data stream paused.")
        self.slow_stats_task = None

    async def handle_client(self, websocket):
        client_id = f"{websocket.remote_address[0]}:{websocket.remote_address[1]}"
        print(f"[Client Connected] {client_id}")
        self.connected_clients.add(websocket)

        # Send immediate welcome & initial stats
        try:
            initial = get_system_telemetry()
            await websocket.send(json.dumps(initial))
        except Exception:
            pass

        # Ensure telemetry streaming loops are active
        if self.stats_task is None or self.stats_task.done():
            self.stats_task = asyncio.create_task(self.telemetry_loop())
        if getattr(self, "slow_stats_task", None) is None or self.slow_stats_task.done():
            self.slow_stats_task = asyncio.create_task(self.slow_telemetry_loop())

        try:
            async for raw_msg in websocket:
                try:
                    cmd = json.loads(raw_msg)
                    await self.process_command(cmd, websocket)
                except json.JSONDecodeError:
                    print(f"[Bad Message] Non-JSON received: {raw_msg}")
        except websockets.exceptions.ConnectionClosed:
            pass
        finally:
            self.connected_clients.discard(websocket)
            print(f"[Client Disconnected] {client_id}")

    async def process_command(self, cmd: dict, ws):
        action_type = cmd.get("type", "")
        payload = cmd.get("payload", {})

        # --- MEDIA & AUDIO COMMANDS ---
        if action_type == "media":
            action = payload.get("action")
            if action == "play_pause":
                press_virtual_key(VK_MEDIA_PLAY_PAUSE)
            elif action == "next":
                press_virtual_key(VK_MEDIA_NEXT_TRACK)
            elif action == "prev":
                press_virtual_key(VK_MEDIA_PREV_TRACK)
            elif action == "mute":
                press_virtual_key(VK_VOLUME_MUTE)
            elif action == "volume_up":
                press_virtual_key(VK_VOLUME_UP)
            elif action == "volume_down":
                press_virtual_key(VK_VOLUME_DOWN)

        elif action_type == "set_volume":
            level = payload.get("level", 50)
            set_master_volume(level)

        elif action_type == "set_mute":
            muted = payload.get("muted", False)
            set_master_mute(muted)

        elif action_type == "toggle_mic":
            new_state = toggle_microphone_mute()
            await ws.send(json.dumps({
                "type": "mic_state",
                "mic_muted": new_state
            }))

        # --- SYSTEM PRODUCTIVITY ACTIONS ---
        elif action_type == "action":
            action = payload.get("action")
            if action == "lock_pc":
                user32.LockWorkStation()
            elif action == "show_desktop":
                press_key_combination(VK_LWIN, ord('D'))
            elif action == "screenshot":
                press_key_combination(VK_LWIN, VK_SHIFT, ord('S'))
            elif action == "task_manager":
                os.system("start taskmgr")
            elif action == "sleep_pc":
                ctypes.windll.PowrProf.SetSuspendState(0, 1, 0)
            elif action == "screen_off":
                # WM_SYSCOMMAND = 0x0112, SC_MONITORPOWER = 0xF170, 2 = Turn off monitor
                user32.SendMessageW(0xFFFF, 0x0112, 0xF170, 2)

        # --- APP LAUNCHERS ---
        elif action_type == "launch":
            app = payload.get("app", "")
            if app == "vscode":
                os.system("start code")
            elif app == "terminal":
                os.system("start wt || start powershell")
            elif app == "browser":
                os.system("start https://google.com")
            elif app == "calculator":
                os.system("start calc")
            elif app == "notepad":
                os.system("start notepad")
            elif app == "spotify":
                os.system("start spotify")
            elif app == "files":
                os.system("start explorer")
            elif app == "discord":
                os.system("start discord:")
            elif app == "settings":
                os.system("start ms-settings:")

        # --- AI SESSIONS & PROCESS CONTROL ---
        elif action_type == "session_permission":
            session_id = payload.get("id", "")
            allow = payload.get("allow", True)
            print(f"[Session Permission] {session_id} -> {'ALLOWED' if allow else 'DENIED'}")
            await ws.send(json.dumps({
                "type": "notify",
                "message": f"Session '{session_id}' permission {'ALLOWED' if allow else 'DENIED'}"
            }))

        elif action_type == "kill_process":
            proc_name = payload.get("name", "").lower()
            killed_count = 0
            if proc_name:
                for proc in psutil.process_iter(['name']):
                    try:
                        if proc.info['name'] and proc_name in proc.info['name'].lower():
                            proc.terminate()
                            killed_count += 1
                    except Exception:
                        pass
            await ws.send(json.dumps({
                "type": "notify",
                "message": f"Terminated {killed_count} instances of {payload.get('name')}"
            }))

        # --- MANUAL REFRESH REQUESTS (pull-to-refresh on the phone) ---
        # Offloaded to the process pools for the same reason as the slow
        # telemetry loop: these can take real seconds and must not freeze
        # the event loop or touch pycaw's COM objects from another thread.
        elif action_type == "get_claude_quota":
            loop = asyncio.get_running_loop()
            result = await loop.run_in_executor(self.worker_pool, get_claude_usage, CONFIG)
            await ws.send(json.dumps(result))

        elif action_type == "get_github":
            loop = asyncio.get_running_loop()
            result = await loop.run_in_executor(self.worker_pool, get_github_data, CONFIG)
            await ws.send(json.dumps(result))

        elif action_type == "get_processes":
            loop = asyncio.get_running_loop()
            items = await loop.run_in_executor(self.process_snapshot_pool, get_processes_snapshot)
            await ws.send(json.dumps({"type": "processes", "items": items}))

        elif action_type == "get_weather":
            loop = asyncio.get_running_loop()
            result = await loop.run_in_executor(self.worker_pool, get_weather, CONFIG)
            await ws.send(json.dumps(result))

        # --- UNIVERSAL CLIPBOARD & SHARE ---
        elif action_type == "clipboard_send":
            text = payload.get("text", "")
            set_clipboard_text(text)
            await ws.send(json.dumps({
                "type": "notify",
                "message": "Copied to PC clipboard!"
            }))

        elif action_type == "clipboard_get":
            text = get_clipboard_text()
            await ws.send(json.dumps({
                "type": "clipboard_content",
                "text": text
            }))

        elif action_type == "open_url":
            url = payload.get("url", "")
            if url:
                if not (url.startswith("http://") or url.startswith("https://")):
                    url = "https://" + url
                webbrowser.open(url)
                await ws.send(json.dumps({
                    "type": "notify",
                    "message": f"Opened link on PC!"
                }))

        # --- TRACKPAD & MOUSE CONTROL ---
        elif action_type == "mouse_move":
            dx = int(payload.get("dx", 0))
            dy = int(payload.get("dy", 0))
            user32.mouse_event(MOUSEEVENTF_MOVE, dx, dy, 0, 0)

        elif action_type == "mouse_click":
            button = payload.get("button", "left")
            if button == "left":
                user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
                user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
            elif button == "right":
                user32.mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
                user32.mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
            elif button == "middle":
                user32.mouse_event(MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0)
                user32.mouse_event(MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0)

        elif action_type == "mouse_scroll":
            dy = int(payload.get("dy", 0))
            # MOUSEEVENTF_WHEEL expects WHEEL_DELTA (usually 120 per notch)
            user32.mouse_event(MOUSEEVENTF_WHEEL, 0, 0, dy, 0)

    async def start(self):
        print("==================================================")
        print(f"       {APP_NAME} PC Companion Server v{VERSION}")
        print("==================================================")
        print(f" PC Name:      {self.hostname}")
        print(f" Local IP:     {self.local_ip}")
        print(f" WebSocket:    ws://{self.local_ip}:{WS_PORT}")
        print(f" Discovery:    UDP Port {DISCOVERY_PORT} (Auto-Beacon Active)")
        print(" Resource:     0.0% CPU when idle / pure event-driven")
        print("==================================================")
        print("[Status] Ready for Mobile connection on Wi-Fi...")

        # Start WebSocket server
        server = await websockets.serve(self.handle_client, "0.0.0.0", WS_PORT)

        # Run discovery concurrently
        await asyncio.gather(
            self.broadcast_loop(),
            server.wait_closed()
        )


if __name__ == "__main__":
    app = DeskFlowServer()
    try:
        asyncio.run(app.start())
    except KeyboardInterrupt:
        print("\n[DeskFlow] Server stopped by user.")
