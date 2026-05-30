# HDR Toggle

Toggle Windows HDR on **individual monitors** instead of all displays at once.

Windows' built-in shortcut (`Win`+`Alt`+`B`) flips HDR globally across every display. In
a multi-monitor setup you usually want HDR on only one panel — your HDR-capable main
monitor — while the others stay in SDR. This extension lists each HDR-capable monitor and
lets you toggle HDR on each one independently.

## Commands

- **Toggle HDR** — Lists every HDR-capable monitor with its current state. Select a
  monitor to turn its HDR on or off, or use the **Assign to Shortcut** action to bind it
  to one of four shortcut slots.
- **Toggle HDR – Shortcut 1–4** — No-view commands that instantly toggle HDR on the
  monitor you assigned to that slot. Each can be given its own global hotkey, so you get
  a dedicated keypress per monitor.

### Per-monitor hotkeys

The four shortcut commands are **disabled by default** to keep your root search clean.
To use one:

1. Open **Toggle HDR**, select a monitor, and choose **Assign to Shortcut → Shortcut N**.
2. In Raycast Settings → Extensions → HDR Toggle, enable **Toggle HDR – Shortcut N** and
   assign it a hotkey.

Pressing that hotkey then toggles HDR on the assigned monitor, with no window — a HUD
confirms the result. A monitor lives in only one slot at a time.

## How it works

Raycast extensions run in Node and can't call Win32 APIs directly, so this extension
ships a small, fully readable PowerShell helper (`assets/hdr.ps1`). The helper P/Invokes
the public Windows **DisplayConfig** API:

- `QueryDisplayConfig` to enumerate active display targets,
- `DisplayConfigGetDeviceInfo` to read per-monitor HDR state,
- `DisplayConfigSetDeviceInfo` to toggle HDR on one target.

On Windows 11 24H2 and newer it uses the HDR-specific API (`GET_ADVANCED_COLOR_INFO_2` /
`SET_HDR_STATE`) for an accurate HDR state, automatically falling back to the legacy
advanced-color API (`GET_ADVANCED_COLOR_INFO` / `SET_ADVANCED_COLOR_STATE`) on older builds.

Monitors are addressed by their stable device path, so toggling targets the right display
even after a reboot or GPU re-enumeration. There are **no bundled binaries** — only the
plain-text script — and toggling HDR does **not** require administrator privileges.

## Requirements

- Windows 10 (1803+) or Windows 11
- At least one HDR-capable monitor
- Windows PowerShell 5.1 (built into Windows)

## Credits

Approach inspired by [GiulioSamp/HDRToggler](https://github.com/GiulioSamp/HDRToggler),
which demonstrates the same DisplayConfig per-monitor HDR technique in a C# tray app.
