# Installation

Supported environment: x64 Windows 10 build 17763 or later, or Windows 11, with PowerShell 7.4 or later. ARM64 is not declared supported for v1.0.0 because current fallback installers are x64.

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1
pwsh -NoProfile -File .\Allium-Setup.ps1 -Verify
pwsh -NoProfile -File .\Allium-Setup.ps1 -Uninstall
```

Setup may install PowerShell, Windows App SDK Runtime 1.6, PSResourceGet, exact WinUIShell 0.12.0, ZstdSharp.Port 0.8.8, Nunito, and Sono. The approved policy keeps CurrentUser execution policy at `Unrestricted` when setup changes it.

Uninstall backs up and removes local `data`, removes known Allium font files, and attempts to remove WinUIShell. It does not remove PowerShell, Windows App SDK, PSResourceGet, or restore execution-policy and PowerShell Gallery settings.
