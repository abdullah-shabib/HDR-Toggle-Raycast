<!--
Short README for the Raycast Store listing.
The store renders README.md from the published extension folder, so to use this version
copy it over README.md right before publishing:
    Copy-Item README.store.md README.md -Force
Keep the full README.md for the GitHub repo.
-->

# HDR Toggle

Turn Windows HDR on or off for **individual monitors** — not all displays at once.

Windows' `Win`+`Alt`+`B` shortcut flips HDR globally. This extension lets you control each
HDR-capable monitor independently, so you can keep HDR on your main display while the rest
stay in SDR.

## Commands

- **Toggle HDR** — Lists your HDR-capable monitors with their current state. Select one to
  turn its HDR on or off, or assign it to a shortcut slot.
- **Toggle HDR – Shortcut 1–4** — Optional no-view commands that toggle HDR on a specific
  monitor. Assign a monitor in the **Toggle HDR** command, then give each a global hotkey in
  Raycast for a one-press per-monitor toggle. (Enable them in the extension's settings first.)

## Requirements

- Windows 10 (1803+) or Windows 11
- At least one HDR-capable monitor

It uses the HDR-specific Windows API on Windows 11 24H2+ and falls back to the legacy
advanced-color API on older builds. No administrator rights required.
