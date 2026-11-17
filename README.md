# ⚡ DeskFlow — Cyberpunk OLED Desk Deck & PC Companion

> Turn your phone or tablet into an ultra-high-density, aesthetic hardware monitor, AI coding control deck, and productivity companion. Inspired by [PhoneBox](https://github.com/ersinkoc/phonebox), rebuilt with native **Flutter** and zero-idle-CPU Python for an OLED-optimized, buttery-smooth experience.

---

## ✨ Features at a Glance

| Feature | Description |
| :--- | :--- |
| **🤖 Claude Code & AI Quotas** | Real-time burn-rate forecasts, 5-hour session meters, weekly quotas, and token trackers without running `/usage` in terminal. |
| **🐙 GitHub Workspace** | Active review requests, pull requests with approval status badges (`approved`, `changes`), and notification counts. |
| **⚡ Interactive AI Sessions** | Live Claude & Codex session status (`Waiting`, `Working`, `Idle`) with **Allow / Deny** permission prompts directly on your phone. |
| **📈 Cyberpunk Wave Telemetry** | Smooth oscillating sine waves & area charts for CPU, GPU, multi-disk storage, RAM, VRAM, ping, and network speeds. |
| **🛑 Heavy Processes & Task Manager** | Real-time process inspector with `[CPU]` / `[RAM]` sorting, instance counts (`×14`, `×9`), and one-tap process termination. |
| **🎵 Synthwave Media & Weather** | Offline-rendered retro synthwave album art, interactive scrub slider, volume capsule, and 7-day weather forecast with rain percentages. |
| **🎛️ 12-Button Tactile Deck** | Instant touch deck: Terminal, VS Code, Browser, Files, Spotify, Discord, Snip, Task Manager, Mute, Screen Off, Lock, Settings. |
| **📱 Multi-Page Swipe Deck** | 8 full-screen deck pages with 20-dot pagination indicator and auto-slideshow toggle (`||` / `▶`). |
| **⚡ Zero Idle CPU (0.0%)** | Zero background polling overhead when disconnected; light event-driven WebSocket communication. |

---

## 📸 Deck Pages & Capabilities

### 1. 🤖 Claude Code & Codex AI Quotas View
- **Header Status:** Orange Claude sparkle logo, `Max 5x` tier badge, and sync timestamp indicator.
- **3 Giant Glowing Radial Gauges:**
  - **5-Hour Session:** `34%` gauge with neon orange glow, countdown timer (`21:57 · in 2 h 36 min`), and `Plenty left` emerald badge.
  - **Weekly Quota:** `52%` gauge, reset schedule (`Sat 00:09 · in 3 d 4 h`), and `On pace` status.
  - **Weekly · Fable:** `9%` gauge, reset schedule, and `Plenty left` status.
- **Analytics Bar:** Live token burn rate (`82K / hr`), token allocation (`412K / 1.2M`), and Codex session gauge (`12% left`).

### 2. 🐙 GitHub Workspace & Review Deck
- **Header:** `@octocat` profile with glowing amber notification badge (`🔔 7`).
- **Review Requests (3):** Diamond bullets `◇` tracking pull request reviews (`api#412 Rate limiter`, `web#1288 Dark mode`, `infra#77 Move staging`).
- **My Pull Requests (4):** Displays pull requests with status tags:
  - `✓ api#409 Cache user sessions in Redis` [approved (emerald)]
  - `● web#1281 Faster image uploads` [in review]
  - `✕ cli#53 New "deploy" command` [changes (coral)]
  - `— docs#210 Getting started rewrite` [draft]
- Tap any pull request to open it directly on your PC browser.

### 3. ⚡ Interactive AI Coding Sessions
- **Status Subtitle:** `SESSIONS 3 working · 1 waiting · 3 idle`.
- **Session Indicators:** Status dots (pulsing red for `Waiting`, amber for `Working`, cyan for `Running a command`, dim gray for `Idle`).
- **Permission Prompts (Allow / Deny):** When Claude Code pauses waiting for approval, tap the highlighted session card (e.g. `docs-site`) to inspect the pending shell command and tap **Allow** or **Deny** directly from the desk panel.

### 4. 📈 Detailed Hardware Waves & Dual Area Charts
- **Processor:** AMD Ryzen 9 7950X `10%`, `53°C`, with live glowing cyan wave.
- **Graphics:** NVIDIA RTX 4080 `7%`, `53°C · 38 W`, with live lime wave.
- **Memory & Storage:** RAM progress bar (`21.2 / 64 GB`), VRAM bar (`5.8 / 16 GB`), and multi-disk usage indicators (`C: 61%`, `D: 73%`, `E: 8%`).
- **Network:** Dual-layer animated wave area chart (amber download wave + cyan upload line) showing `↓ 8.7 MB/s` and `↑ 332 KB/s` with Ping & packet loss metrics.

### 5. 🛑 Heavy Processes & Task Manager
- Header displaying total CPU load (`40%`), active process count (`312`), and app count (`141`).
- Sort toggle pills for **[CPU]** and **[RAM]**.
- 2-Column process cards showing brand avatar pills, instance badges (`×14`, `×9`, etc.), magenta CPU usage lines, and CPU/RAM numbers.
- One-tap process termination dialog to kill runaway processes.

### 6. 🎵 Synthwave Media Player & 7-Day Weather Forecast
- **Media Player:** Custom-rendered Synthwave retro sunset grid album cover, track title (`Midnight Circuit`), artist, interactive scrub slider (`2:40 / 3:34`), circular play/pause, prev/next, and volume slider (`42`).
- **Weather Forecast:** Big digital clock with superscript seconds, Tallinn 7-day forecast with weather icons, high/low temperatures, and precipitation percentage drops (`💧 100%`, `💧 54%`, `💧 55%`).

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
        │   └── connection_service.dart # WebSocket connection, actions & permission dispatch
        ├── widgets/
        │   ├── radial_glow_gauge.dart  # High-res glowing radial donut arc gauge
        │   ├── wave_sparkline.dart     # Animated sine & dual-area wave charts
        │   ├── claude_quota_view.dart  # Claude Code credit & burn-rate deck view
        │   ├── github_card.dart        # GitHub review requests & PRs panel
        │   ├── ai_sessions_card.dart   # AI sessions card with Allow/Deny popup
        │   ├── processes_view.dart     # Heavy processes manager with kill action
        │   ├── hardware_waves_view.dart# Processor, Graphics, Memory & Network waves
        │   ├── spotify_media_card.dart # Synthwave retro album player & seeker
        │   ├── weather_forecast_card.dart # Ambient clock & 7-day weather forecast
        │   ├── tactile_deck_grid.dart  # 12-button tactile action deck
        │   ├── docker_storage_card.dart# Docker containers & disk space widget
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
