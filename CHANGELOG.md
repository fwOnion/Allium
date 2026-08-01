<div align="center">

# Allium changelog

### A human-readable history of notable Allium changes

[README](README.md) · [Latest release](https://github.com/fwOnion/Allium/releases/latest) · [Install](docs/installation.md) · [Support](https://discord.gg/gFK9fhMUQm)

</div>

---

All notable changes to Allium are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), with changes grouped by their effect on users.

## [Unreleased]

Add notable changes here as they are merged. Remove empty categories when preparing a release.

<!--
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
-->

## [1.0.0] - 2026-07-31

Allium v1.0.0 is the first public release.

### Highlights

- A WinUI interface for discovering, editing, applying, and managing Roblox FastFlags.
- A two-script release package containing `Allium.ps1` and `Allium-Setup.ps1`.
- Beginner-friendly graphical setup, verification, launch, and uninstall workflows.
- Public distribution of the verified minified application artifact while the readable development source remains private.

<details>
<summary><strong>View the complete v1.0.0 feature summary</strong></summary>

### Added

#### FastFlag editing

- Add, edit, batch-edit, pin, search, filter, copy, delete, and clean FastFlags.
- Import, paste, drag, and export FastFlag JSON.
- Undo and redo editor changes.
- Write FastFlags to Roblox client settings.
- Save, apply, and launch through one workflow.

#### Browser and profiles

- Searchable FastFlag browser with multiple configured data sources.
- Parallel source retrieval, result processing, caching, and selection tools.
- Save, load, update, delete, and merge profiles.

#### Roblox launch support

- Roblox installation and client-settings discovery.
- Compatible bootstrapper detection and selection.
- Custom bootstrapper executable support.

#### Watchdog

- Monitor supported configuration, Roblox version, and process restart events.
- Reapply FastFlags after supported events or on a configurable interval.

#### Advanced tools

- Optional memory application with address acquisition, validation, caching, source merging, manual entry, and supported typed value operations.
- Optional HTTPS interception controls for Allium-managed hosts entries, local certificate material, status, backups, and restoration.
- Strategy-based FastFlag dumper with asynchronous progress, validation, quorum merging, persistence, and multiple supported strategies.

#### Interface and diagnostics

- Launcher, editor, browser, settings, progress dialogs, tray controls, notifications, context menus, keyboard shortcuts, and built-in logs.
- General, watchdog, memory, HTTPS, and About settings pages.
- Atomic JSON writes, backups, corrupt-settings recovery, caches, diagnostic bundles, and dependency checks.

#### Setup and repository

- Setup checks for PowerShell 7.4 or later, Windows App SDK Runtime 1.6, PSResourceGet, WinUIShell 0.12.0 or later, ZstdSharp.Port 0.8.8, and the supported fonts.
- Setup verification and uninstall modes.
- Repository documentation, security policy, issue templates, validation workflow, release workflow, packaging, and checksums.

</details>

---

## Versioning notes

- Published releases use tags such as `v1.0.0`.
- The **Unreleased** section is for changes merged after the latest release.
- Release notes may summarize this file, but this changelog remains the durable project history.

<div align="center">

[Back to the README](README.md)

</div>
