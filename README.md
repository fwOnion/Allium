# Allium

<p align="center"><img src="assets/allium-icon.png" alt="Allium circular pink dot logo" width="160"></p>

Allium is a Windows PowerShell application for inspecting, editing, applying, and managing Roblox FastFlags. Version 1.0.0 is the first verified public release.

## Status

- Platform: x64 Windows 10 build 17763 or later, or Windows 11
- PowerShell: 7.4 or later
- Public source policy: root `Allium.ps1` is the verified minified release artifact
- The readable development source remains private

## Install

1. Download the release ZIP and `SHA256SUMS.txt`.
2. Verify the checksum and extract to a user-writable folder.
3. Run `Allium-Setup.ps1` with PowerShell 7.

Setup may install system-wide dependencies and fonts, set CurrentUser execution policy to `Unrestricted`, and remove Zone.Identifier streams from supported files below the Allium folder. See [Installation](docs/installation.md) and [Security](docs/security-and-privacy.md).

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Verify
pwsh -NoProfile -File .\Allium-Setup.ps1 -Uninstall
```

Screenshots will be added only from verified user-supplied captures. Approved locations are in `docs/screenshots/README.md`.

See [SECURITY.md](SECURITY.md), [CONTRIBUTING.md](CONTRIBUTING.md), and [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). Allium is licensed under the [MIT License](LICENSE).
