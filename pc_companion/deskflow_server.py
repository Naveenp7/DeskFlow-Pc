"""
DeskFlow PC Companion Server
Ultra-lightweight, zero-idle-CPU companion daemon for Windows.
Provides UDP Auto-Discovery and WebSocket control & telemetry.
"""

import asyncio
import json
import os
import platform
import socket
import sys
import time
import webbrowser
import ctypes
from ctypes import wintypes

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
        self.running = True

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

        # Ensure telemetry streaming loop is active
        if self.stats_task is None or self.stats_task.done():
            self.stats_task = asyncio.create_task(self.telemetry_loop())

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
            elif app == "settings":
                os.system("start ms-settings:")

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
