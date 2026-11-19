# ⚡ DeskFlow — Cyberpunk OLED Desk Deck & PC Companion

> Turn your phone or tablet into an ultra-high-density, aesthetic hardware monitor, AI coding control deck, and productivity companion. Built with native **Flutter** and zero-idle-CPU Python for an OLED-optimized, buttery-smooth experience.

---

## ✨ Features at a Glance

| Feature | Description |
| :--- | :--- |
| **🤖 Claude Code Usage** | Real local token-usage estimate (5-hour & weekly rolling windows, burn rate) read straight from your own `~/.claude` session logs on that PC — not an official Anthropic quota API (none exists publicly), just your real local numbers against a budget you can tune in `config.json`. |
| **🐙 GitHub Workspace** | Your real open PRs, review requests, and notification count, pulled live from the GitHub API once you add a personal access token to `pc_companion/config.json`. Shown as "not configured" until you do — never fake data. |
| **🧭 Claude Code Sessions** | Shows which of your projects had real Claude Code activity in the last few hours, and whether the most recent one is still actively writing (`Working`) or has gone quiet (`Idle`) — detected from real local session file timestamps. |
| **📈 Hardware Wave Telemetry** | Live CPU, RAM, multi-disk and network graphs. GPU/VRAM shows real NVIDIA stats via `nvidia-smi` when present, or an honest "no dGPU detected" otherwise — never a fabricated number. |
| **🛑 Heavy Processes & Task Manager** | Real running-process snapshot (aggregated by executable, real CPU%/RAM), sortable by `[CPU]` / `[RAM]`, with one-tap process termination. |
| **🎵 Media Controls & Weather** | Real play/pause/skip/volume control of whatever is playing on the PC, plus a real 7-day weather forecast (via the free, keyless Open-Meteo API, auto-located from the PC's IP). |
| **🎛️ 12-Button Tactile Deck** | Instant touch deck: Terminal, VS Code, Browser, Files, Spotify, Discord, Snip, Task Manager, Mute, Screen Off, Lock, Settings. |
| **📱 Multi-Page Swipe Deck** | 8 full-screen deck pages with a pagination indicator and auto-slideshow toggle (`||` / `▶`), designed to sit on a desk like an iPhone StandBy display — the screen is kept awake while docked. |
| **⚡ Zero Idle CPU (0.0%)** | Zero background polling overhead when disconnected; light event-driven WebSocket communication. |

> **Setup note:** GitHub PRs and the Claude Code usage budget are configured in `pc_companion/config.json`, created automatically the first time you run the companion. Add your own [GitHub personal access token](https://github.com/settings/tokens) there to enable the GitHub card.

---

## 📸 Deck Pages & Capabilities

### 1. 🤖 Claude Code Usage View
- **Header Status:** Orange Claude sparkle logo and a tier badge you set yourself in `config.json` (default: `Local estimate`, since there is no public Anthropic quota API to query).
- **3 Radial Gauges:** 5-hour session usage and weekly usage, both computed from your real local `~/.claude` session logs against a token budget you can tune; a third slot reserved for future providers.
- **Analytics Bar:** Real token burn rate for the last hour, and real tokens-used vs. your configured budget.

### 2. 🐙 GitHub Workspace & Review Deck
- **Header:** Your real GitHub username and real unread-notification count (once a token is configured) — shows an honest "not configured" empty state otherwise.
- **Review Requests:** Your real open PRs where you're a requested reviewer, pulled live from the GitHub API.
- **My Pull Requests:** Your real open PRs, each tagged `approved` / `changes` / `in review` / `draft` based on the PR's actual review state.
- Tap any pull request to open it directly on your PC browser.

### 3. 🧭 Claude Code Sessions
- **Status Subtitle:** Real count of `working` vs `idle` Claude Code projects on that PC, based on actual session-log activity in the last few hours.
- **Session Indicators:** A status dot per project — amber/glowing for `Working` (log written in the last ~20s), dim for `Idle`.
- Shows an honest "no recent activity" empty state when nothing has run recently — no fabricated sessions.

### 4. 📈 Detailed Hardware Waves & Dual Area Charts
- **Processor:** Real CPU % and logical core count, with a live wave.
- **Graphics:** Real NVIDIA utilization/temp/power via `nvidia-smi` when a dGPU is present, or an honest "no dGPU detected" state otherwise.
- **Memory & Storage:** Real RAM bar, real VRAM bar (when a GPU is detected), and a bar per real fixed drive found on the PC (however many there are).
- **Network:** Real upload/download throughput and real ping to the PC.

### 5. 🛑 Heavy Processes & Task Manager
- Header showing real total CPU load and the real number of distinct apps reported.
- Sort toggle pills for **[CPU]** and **[RAM]**.
- 2-column process cards showing a real per-app CPU/RAM snapshot (aggregated by executable, with real instance counts).
- One-tap process termination that actually ends the selected app's processes on the PC.

### 6. 🎵 Media Controls & 7-Day Weather Forecast
- **Media Controls:** Real play/pause/skip/volume control of whatever is playing on the PC. There's no reliable, zero-setup way to read back the track title/artist, so this is controls-only rather than a now-playing display.
- **Weather Forecast:** Big digital clock with superscript seconds, plus a real 7-day forecast (via Open-Meteo, auto-located from the PC's IP) with real highs/lows and real rain probabilities.

### 7. 🎛️ 12-Tile Tactile Action Deck
- **Row 1:** Terminal, VS Code, Browser
- **Row 2:** Files, Spotify, Discord
- **Row 3:** Snip (Win+Shift+S), Task Manager, Mute (with active dot)
- **Row 4:** Screen Off (turns off PC display), Lock Workstation, Settings

---

## 🛠️ Getting Started

### Step 1: Start the PC Companion
The PC companion is an ultra-lean Python service that consumes **0.0% CPU** when idle and **<18 MB RAM**.

#### Option A: Automatic Silent Start on Windows Boot (Recommended)
You only need to run this **once**:
1. Double-click [enable_autostart.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/enable_autostart.bat).
2. DeskFlow will now start automatically in the background whenever your PC turns on.
   - Runs completely silently (no console window).
   - Consumes **0% CPU** when mobile app is not connected.
   - To disable at any time: run [disable_autostart.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/disable_autostart.bat).

#### Option B: Manual / Background Run
- To start silently in background: run [start_background.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/start_background.bat).
- To run with console visible (for logs): run [run_pc_companion.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/run_pc_companion.bat).
- To stop the server: run [stop_pc_companion.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/stop_pc_companion.bat).

---

### Step 2: Open the Mobile App
1. Make sure your phone and PC are connected to the **same Wi-Fi network** (or USB cable via `adb reverse`).
2. Run or install the Flutter mobile app:
   ```bash
   cd mobile_app
   flutter run
   ```
3. **Automatic Discovery**:
   - The app automatically scans your local network using UDP broadcast on port `41532`.
   - When detected, your PC will appear in the radar dialog—tap **Connect**!
   - DeskFlow **remembers your PC and reconnects automatically**.
4. **Desk Dock Mode**: Rotate your phone horizontally or tap the dock icon in the top bar to enter full-screen landscape Standby Deck mode!

---

## 📁 Project Structure

```
Phone pc widget/
├── .gitignore                    # Master root gitignore (clean repository)
├── README.md                     # Documentation & setup guide
│
├── pc_companion/                 # Zero-idle-CPU Windows companion
│   ├── deskflow_server.py        # UDP discovery + WebSocket telemetry, process kill & actions
│   ├── run_pc_companion.bat      # 1-click console launcher
│   ├── run_silent.vbs            # Silent background launcher
│   ├── start_background.bat      # Background starter
│   ├── stop_pc_companion.bat     # Background stopper
│   ├── enable_autostart.bat      # Boot autostart installer
│   ├── disable_autostart.bat     # Boot autostart remover
│   └── requirements.txt          # Minimal dependencies (psutil, websockets, pycaw)
│
└── mobile_app/                   # Flutter mobile application
    ├── pubspec.yaml
    └── lib/
        ├── main.dart             # App entrypoint & orientation handling
        ├── theme/
        │   └── app_theme.dart    # Cyberpunk OLED dark theme & glow palettes
        ├── models/
        │   ├── pc_device.dart    # Network PC discovery model
        │   ├── system_stats.dart # Hardware telemetry model
        │   ├── claude_quota.dart # Claude & Codex burn-rate and token quota model
        │   ├── ai_session.dart   # Interactive AI coding session model
        │   ├── github_data.dart  # GitHub PRs, review requests & notifications model
        │   ├── system_process.dart # Heavy app processes model
        │   └── weather_media.dart# 7-Day weather forecast & Spotify media model
        ├── services/
        │   ├── discovery_service.dart  # UDP broadcast radar scanner
        │   └── connection_service.dart # WebSocket connection, real-data parsing & actions
        ├── widgets/
        │   ├── radial_glow_gauge.dart  # High-res glowing radial donut arc gauge
        │   ├── wave_sparkline.dart     # Animated sine & dual-area wave charts
        │   ├── claude_quota_view.dart  # Claude Code credit & burn-rate deck view
        │   ├── github_card.dart        # GitHub review requests & PRs panel
        │   ├── ai_sessions_card.dart   # Real Claude Code session activity panel
        │   ├── processes_view.dart     # Heavy processes manager with kill action
        │   ├── hardware_waves_view.dart# Processor, Graphics, Memory & Network waves
        │   ├── spotify_media_card.dart # Real PC media controls (play/pause/skip/volume)
        │   ├── weather_forecast_card.dart # Ambient clock & real 7-day weather forecast
        │   ├── tactile_deck_grid.dart  # 12-button tactile action deck
        │   ├── docker_storage_card.dart# Real Docker container & drive count widget
        │   ├── desk_status_header.dart # Top desk status bar (USB, battery, quotas)
        │   └── desk_pagination_bar.dart# 20-dot pagination bar with auto-cycle
        └── screens/
            ├── home_screen.dart      # Navigation router (portrait vs landscape deck)
            ├── standby_screen.dart   # Multi-page landscape desk deck
            ├── dashboard_tab.dart    # Portrait dashboard with segmented filters
            ├── actions_tab.dart      # Macro shortcuts & launchers
            ├── trackpad_tab.dart     # Remote touchpad & mouse gestures
            ├── share_tab.dart        # Universal clipboard & link beam
            └── discovery_dialog.dart # Radar scanner & manual IP modal
```
