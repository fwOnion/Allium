<div align="center">

# Installing Allium

### A complete first-time setup guide for Windows users

[README](../README.md) · [Troubleshooting](troubleshooting.md) · [Security](security-and-privacy.md) · [Discord support](https://discord.gg/gFK9fhMUQm)

</div>

---

This guide walks through the complete process from downloading Allium to opening the launcher for the first time. The normal path uses File Explorer and does not require terminal commands.

> [!IMPORTANT]
> Use a Windows account that can approve administrator prompts. Keep `Allium-Setup.ps1` and `Allium.ps1` together in the same extracted folder.

## Before you begin

### Supported environment

- x64 Windows 10 build 17763 or later, or Windows 11
- Internet access during first-time setup
- A user-writable installation folder
- Permission to approve administrator actions

ARM64 is not declared supported for Allium v1.0.0 because the current fallback installers are x64.

### What setup may change

Depending on the computer's current state, setup may:

- Install or locate PowerShell 7.4 or later
- Install Windows App SDK Runtime 1.6 for x64
- Install or import Microsoft.PowerShell.PSResourceGet
- Install WinUIShell 0.12.0 or later for all users
- Download ZstdSharp.Port 0.8.8 into Allium's local dependency folder
- Install Nunito and Sono fonts unless font installation is skipped
- Set CurrentUser PowerShell execution policy to `Unrestricted`
- Trust PowerShell Gallery for supported resource installation
- Remove downloaded-file zone markers from supported files below the Allium folder
- Create Allium's local `data` folder structure

Read [Security and privacy](security-and-privacy.md) before proceeding if any of these changes are a concern.

---

## Step 1: Open the official release

1. Open the [latest Allium release](https://github.com/fwOnion/Allium/releases/latest).
2. Scroll to **Assets**.
3. Locate `Allium-v1.0.0.zip`.
4. If provided, also locate `SHA256SUMS.txt`.

> [!CAUTION]
> GitHub automatically shows **Source code (zip)** and **Source code (tar.gz)**. Those are repository snapshots. Download `Allium-v1.0.0.zip` for the normal Allium package.

## Step 2: Download the release files

1. Select `Allium-v1.0.0.zip`.
2. Save the file to **Downloads** or another known folder.
3. Download `SHA256SUMS.txt` if checksum verification is desired.
4. Wait for both downloads to finish.

Continue only when the ZIP came from the official Allium repository.

## Step 3: Optionally verify the ZIP

1. Open **Command Prompt**.
2. Run:

```cmd
certutil -hashfile "%USERPROFILE%\Downloads\Allium-v1.0.0.zip" SHA256
```

3. Compare the displayed value with `SHA256SUMS.txt`.
4. Do not continue if the values differ.

If the ZIP was saved elsewhere, replace the path with the actual location.

## Step 4: Choose a permanent folder

Recommended:

```text
C:\Users\YOUR_NAME\Documents\Allium
```

Avoid running from:

- The ZIP preview
- A temporary folder
- `C:\Windows`
- A folder the current user cannot write to

## Step 5: Extract the ZIP

1. Open **File Explorer**.
2. Open **Downloads** or the folder containing the ZIP.
3. Right-select `Allium-v1.0.0.zip`.
4. Select **Extract All**.
5. Choose the permanent Allium folder.
6. Select **Extract**.
7. Open the extracted folder.

The folder should contain:

```text
Allium-Setup.ps1
Allium.ps1
```

Keep both files together. Setup locates `Allium.ps1` relative to its own folder.

## Step 6: Run setup

1. Right-select `Allium-Setup.ps1`.
2. Select **Run with PowerShell**.
3. On Windows 11, if the option is missing:
   1. Select **Show more options**.
   2. Select **Run with PowerShell**.
4. Approve the User Account Control prompt if it appears.
5. Wait for the setup window.

PowerShell 7 can also provide **Run with PowerShell 7**, but that entry may not appear in the Windows 11 context menu. Setup checks the PowerShell prerequisite.

## Step 7: Complete setup

1. Read each status row.
2. Let every critical step finish.
3. Approve any additional installer prompts.
4. Do not close setup while a critical step is running.
5. If a step fails, read its message and open [Troubleshooting](troubleshooting.md).

Setup can check:

- Windows version and architecture
- Administrator status
- PowerShell 7
- Windows App SDK Runtime
- PowerShell resource tooling
- Execution policy
- WinUIShell
- ZstdSharp dependency bootstrap
- Fonts
- Allium data folders
- Roblox or compatible bootstrapper discovery

## Step 8: Launch Allium

When critical setup steps are complete:

1. Select **Launch Allium**.
2. Wait for the Allium launcher menu.
3. Approve an administrator prompt if Windows requests one.
4. Allow first-launch data files to be created.
5. Choose the desired launcher action.

## First interface: Allium launcher

<p align="center">
  <a href="https://github.com/fwOnion/Allium/blob/main/docs/screenshots/launcher.png">
    <img src="https://raw.githubusercontent.com/fwOnion/Allium/main/docs/screenshots/launcher.png" alt="Allium launcher menu" width="100%">
  </a>
</p>

## Step 9: Keep the folder together

Do not move only one script. Move the entire Allium folder if relocating it.

Allium can create a local `data` folder containing settings, flags, profiles, caches, dependencies, logs, dumps, address data, backups, and certificate-related material. Do not publish the complete `data` folder.

## Step 10: Launch Allium later

### Method A: Verified launch through setup

1. Open the Allium folder.
2. Right-select `Allium-Setup.ps1`.
3. Select **Run with PowerShell**.
4. Let setup verify the installation.
5. Select **Launch Allium**.

### Method B: Direct launch

1. Open the Allium folder.
2. Right-select `Allium.ps1`.
3. Select **Run with PowerShell**.
4. Approve an administrator prompt if it appears.

## WinUIShell behavior

- Allium requires WinUIShell 0.12.0 or later.
- Setup installs a compatible version when WinUIShell is missing.
- Allium does not automatically update WinUIShell after installation.
- Versions newer than the tested 0.12.x series may show a compatibility warning.

## Verify an installation

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Verify
```

## Debug setup

If supported by the installed release:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -DebugTrace
```

Review generated output before sharing it. Remove usernames, private paths, account data, certificate details, and unrelated system information.

## Uninstall

Back up wanted profiles or configuration first, then run:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Uninstall
```

The current uninstall workflow backs up and removes local `data`, removes known Allium-installed font files, and attempts to remove WinUIShell. It does not promise to remove every shared dependency or restore every system setting.

## Getting help

- Read [Troubleshooting](troubleshooting.md).
- Join the [Allium Discord](https://discord.gg/gFK9fhMUQm) for general support, ordinary bugs, and FastFlag configuration or list discussion.
- Use [GitHub issues](https://github.com/fwOnion/Allium/issues) for reproducible public bugs.
- Use [private vulnerability reporting](https://github.com/fwOnion/Allium/security/advisories/new) for security issues.

<div align="center">

[Back to the README](../README.md)

</div>
