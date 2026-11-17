# ⚡ DeskFlow — Premium PC-to-Mobile Companion Deck

> A modern, ultra-lightweight, and aesthetic Flutter mobile app that connects seamlessly to your PC over local Wi-Fi. Built for everyday productivity, system monitoring, and hardware control without gimmicks or CPU-draining background processes.

---

## ✨ Why DeskFlow? (Better than PhoneBox)

| Feature | PhoneBox | **DeskFlow** |
| :--- | :--- | :--- |
| **PC Performance Impact** | High (Always-on heavy polling & web servers) | **Zero Idle CPU (0.0%)**: Polling only runs when mobile app is actively connected |
| **UI Aesthetics** | Cluttered 100+ widget grid | **Modern Obsidian Glassmorphism**: Clean OLED dark theme, tactile haptics & vibrant accents |
| **Connection Setup** | Complex URL / token config | **Zero-Config Wi-Fi Auto-Discovery**: Mobile app automatically detects your PC via UDP radar |
| **Usability Focus** | Gimmicky widgets & rules | **High-Value Productivity**: Mic Mute, PC Lock, Screenshot, Task Manager, Trackpad & Clipboard Beam |
| **Mobile Tech** | Web / Node wrapper | **Native Flutter 3.47**: 60/120 FPS buttery-smooth performance |

---

## 🚀 Key Features

### 1. 🖥️ Horizontal Desk Standby Deck (PhoneBox-Style)
- **Automatic Dock Detection**: Place your phone horizontally on your desk stand or charger dock, and the app automatically transforms into an edge-to-edge ambient **Desk Deck**!
- **Prominent Digital Standby Clock**: Clean ambient clock with hours, minutes, seconds, full date, day of the week, and live PC connection & latency ping.
- **Hardware Telemetry Center**: High-precision circular gauges for CPU, RAM, Disk C:, and Network KB/s with smooth 60 FPS transitions.
- **Master Audio & Media Controls**: Integrated master volume slider with mute toggle and media control buttons (Prev, Play/Pause, Next).
- **Macro Control Deck**: Dedicated tactile tiles for Microphone Mute, PC Lock, Snipping Tool, Show Desktop, Task Manager, and Sleep.
- **One-Tap Mode Switcher**: Quick toggle between Standby Deck, Remote Touchpad, and Universal Clipboard Beam.
- **Zero Hardcoded Emojis**: Replaced completely with modern, crisp vector icons and subtle neon glow accents.

### 2. 🎚️ Master Volume & Media Deck
- **Tactile Volume Slider**: Direct control over Windows master volume with percentage feedback.
- **One-Tap System Mute**: Instant audio mute/unmute.
- **Media Controls**: Previous, Play/Pause, and Next track buttons.

### 3. ⚡ Tactile Productivity Deck
- 🎙️ **Microphone Mute**: Real-time microphone mute toggle with live state tracking.
- 🔒 **Lock Workstation**: Secure your PC instantly with one tap (`user32.LockWorkStation`).
- 🖥️ **Show Desktop**: Win+D shortcut to minimize or reveal your desktop.
- 📸 **Snipping Tool**: Instant Windows Snipping Tool shortcut (Win+Shift+S).
- 📋 **Task Manager**: Instantly open Windows Task Manager (Ctrl+Shift+Esc).
- 🌙 **Sleep Mode**: Put your PC to sleep with confirmation.

### 4. 🚀 Quick App Launchers
- **VS Code**: Launch Visual Studio Code instantly.
- **Windows Terminal**: Launch Terminal / PowerShell.
- **Browser**: Open default web browser.
- **Spotify**: Launch Spotify desktop.
- **Calculator & Notepad**: Instant desktop utilities.

### 5. 🖱️ High-Precision Remote Trackpad
- **Smooth Cursor Movement**: Touchpad gestures with adjustable sensitivity (0.8x to 2.5x).
- **Tap to Click**: Single tap = Left Click, Long Press = Right Click.
- **Dedicated Scroll Rail**: Smooth vertical wheel scrolling.
- **Tactile Click Buttons**: Left Click, Middle / Scroll Click, and Right Click.

### 6. 📋 Universal Clipboard & Link Beam
- **Beam to PC**: Type or paste a URL/note on your phone and either copy it to the PC clipboard or open it immediately in the PC browser.
- **Grab PC Clipboard**: One-tap fetch to pull whatever is currently copied on your PC right into your phone.

---

## 🛠️ Getting Started

### Step 1: Start the PC Companion
The PC companion is an ultra-lean Python service that consumes **0.0% CPU** when idle and **<18 MB RAM**.

#### Option A: Automatic Silent Start on Windows Boot (Recommended)
You only need to do this **once**:
1. Double-click [enable_autostart.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/enable_autostart.bat).
2. That's it! DeskFlow will now start automatically whenever your PC turns on.
   - It runs completely silently in the background (no console window).
   - Consumes **0% CPU** when you are not using the mobile app.
   - To disable it at any time, just run [disable_autostart.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/disable_autostart.bat).

#### Option B: Manual / Background Run
- To start it silently right now without restarting: run [start_background.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/start_background.bat).
- To run with console visible (for debugging): run [run_pc_companion.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/run_pc_companion.bat).
- To stop the server at any time: run [stop_pc_companion.bat](file:///c:/for%20me/Phone%20pc%20widget/pc_companion/stop_pc_companion.bat).

---

### Step 2: Open the Mobile App
1. Make sure your phone and PC are connected to the **same Wi-Fi network**.
2. Run or install the Flutter mobile app:
   ```bash
   cd mobile_app
   flutter run
   ```
3. **Automatic Discovery**:
   - The mobile app will automatically scan your local network using UDP broadcast on port `41532`.
   - When detected, your PC will appear in the radar dialog—tap **Connect**!
   - On subsequent launches, DeskFlow **remembers your PC and reconnects automatically**.
4. *(Optional) Manual IP*: If your Wi-Fi router isolates UDP broadcast packets, tap the status pill in the top app bar, enter your PC's IP address (displayed on the PC companion console), and tap Connect.

---

## 📁 Project Structure

```
Phone pc widget/
├── pc_companion/                 # Ultra-lightweight Windows companion
│   ├── deskflow_server.py        # UDP discovery + WebSocket telemetry & actions
│   ├── run_pc_companion.bat      # 1-click batch launcher
│   ├── run_silent.vbs            # Silent background launcher
│   └── requirements.txt          # Minimal dependencies (psutil, websockets, pycaw)
│
└── mobile_app/                   # Modern Flutter mobile application
    ├── pubspec.yaml
    └── lib/
        ├── main.dart             # App entrypoint
        ├── theme/
        │   └── app_theme.dart    # Obsidian dark glassmorphism theme
        ├── models/
        │   ├── pc_device.dart    # Network PC discovery model
        │   └── system_stats.dart # Hardware telemetry model
        ├── services/
        │   ├── discovery_service.dart  # UDP broadcast scanner
        │   └── connection_service.dart # WebSocket connection & commands
        ├── widgets/
        │   ├── glass_container.dart
        │   ├── stat_gauge_card.dart
        │   ├── volume_slider.dart
        │   └── tactile_tile.dart
        └── screens/
            ├── home_screen.dart      # Navigation & app header
            ├── dashboard_tab.dart    # Telemetry, volume & media
            ├── actions_tab.dart      # Mic mute, lock, app shortcuts
            ├── trackpad_tab.dart     # Responsive remote touchpad
            ├── share_tab.dart        # Universal clipboard & link beam
            └── discovery_dialog.dart # Radar scanner & manual IP modal
```
