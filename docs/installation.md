<div align="center">

# Installing Allium

### A complete first-time setup guide for Windows users

[README](../README.md) · [Troubleshooting](troubleshooting.md) · [Security](security-and-privacy.md) · [Discord support](https://discord.gg/gFK9fhMUQm)

</div>

---

This guide walks through the complete process from downloading Allium to opening the application for the first time. The normal path uses File Explorer and does not require typing terminal commands.

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

Setup checks, installs, or configures components Allium needs. Depending on the computer's current state, setup may:

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
2. Scroll to the **Assets** section.
3. Locate `Allium-v1.0.0.zip`.
4. If provided, also locate `SHA256SUMS.txt`.

> [!CAUTION]
> GitHub automatically shows **Source code (zip)** and **Source code (tar.gz)** for a release. Those are repository snapshots. Download `Allium-v1.0.0.zip` for the normal two-file Allium package.

## Step 2: Download the release files

1. Select `Allium-v1.0.0.zip`.
2. Save the file to **Downloads** or another known folder.
3. Select `SHA256SUMS.txt` if checksum verification is desired.
4. Wait for both downloads to finish before opening the ZIP.

Your browser may warn that PowerShell scripts can change the computer. This is expected for an installer script, but continue only if the download came from the official Allium repository.

## Step 3: Optionally verify the ZIP checksum

Checksum verification confirms that the downloaded ZIP matches the published release asset.

1. Open **Command Prompt**.
2. Run:

```cmd
certutil -hashfile "%USERPROFILE%\Downloads\Allium-v1.0.0.zip" SHA256
```

3. Compare the displayed 64-character value with the value in `SHA256SUMS.txt`.
4. Do not continue if the values differ.

If the ZIP was saved elsewhere, replace the path with the actual location.

## Step 4: Create a permanent Allium location

Do not use the ZIP as the permanent installation location.

Recommended locations include:

```text
C:\Users\YOUR_NAME\Documents\Allium
```

or another folder owned by the current user.

Avoid:

- Running directly from the browser download prompt
- Running inside the ZIP preview
- Temporary folders
- System folders such as `C:\Windows`
- Folders where the current user cannot create files

## Step 5: Extract the ZIP

1. Open **File Explorer**.
2. Open **Downloads** or the folder containing the ZIP.
3. Right-select `Allium-v1.0.0.zip`.
4. Select **Extract All**.
5. Choose the permanent Allium folder.
6. Select **Extract**.
7. Open the extracted folder.

The folder should contain exactly these release scripts:

```text
Allium-Setup.ps1
Allium.ps1
```

Keep both files together. Setup locates `Allium.ps1` relative to the setup script's folder.

## Step 6: Run the setup script

1. Right-select `Allium-Setup.ps1`.
2. Select **Run with PowerShell**.
3. If Windows 11 shows the compact context menu and the option is missing:
   1. Select **Show more options**.
   2. Select **Run with PowerShell**.
4. Approve the User Account Control administrator prompt if it appears.
5. Wait for the setup window to open.

PowerShell 7 can also provide **Run with PowerShell 7**. Microsoft documents a Windows 11 context-menu issue where that entry may not appear. The setup workflow checks the PowerShell prerequisite.

> [!NOTE]
> **Run with PowerShell** can initially use Windows PowerShell. Setup can relaunch or install the required PowerShell 7 environment as part of its prerequisite handling.

## Step 7: Review the setup window

The setup interface checks required components in ordered steps.

1. Read each status row.
2. Allow the setup process to complete.
3. Approve any additional administrator or installer prompts.
4. Do not close the setup window while a critical step is running.
5. If a step fails, read its message and open [Troubleshooting](troubleshooting.md).

Potential checks include:

- Supported Windows version and architecture
- Administrator status
- PowerShell 7 availability
- Windows App SDK Runtime
- PowerShell resource tooling
- Execution policy
- WinUIShell
- ZstdSharp dependency bootstrap
- Font installation
- Allium data folders
- Roblox or compatible bootstrapper discovery

A missing Roblox installation or bootstrapper may be shown as a warning rather than a setup failure, depending on the affected step.

## Step 8: Launch Allium for the first time

When setup reports that critical steps are complete:

1. Select **Launch Allium**.
2. Wait for the Allium launcher or interface to appear.
3. Approve an administrator prompt if Windows requests one.
4. Allow first-launch data files to be created.
5. Open the editor or settings to confirm the interface is responsive.

If Allium does not appear, use the setup window's log and see [Allium does not launch](troubleshooting.md#allium-does-not-launch).

## Step 9: Keep the Allium folder together

After setup, the folder contains the public scripts and can gain a local `data` folder.

Do not move only one script. Move the entire Allium folder if relocating the installation.

Depending on enabled features, `data` can contain:

- Settings and flags
- Profiles
- Caches
- Dependencies
- Logs
- Dump output
- Address and pattern data
- Backups
- Certificate-related material

Do not publish the complete `data` folder.

## Step 10: Launch Allium later

### Method A: Use setup as a verified launcher

1. Open the Allium folder.
2. Right-select `Allium-Setup.ps1`.
3. Select **Run with PowerShell**.
4. Let setup verify the installation.
5. Select **Launch Allium**.

This is the recommended beginner method because setup checks prerequisites before launch.

### Method B: Launch Allium directly

1. Open the Allium folder.
2. Right-select `Allium.ps1`.
3. Select **Run with PowerShell**.
4. Approve an administrator prompt if it appears.

Use setup verification if direct launch stops working after a system or dependency change.

---

## WinUIShell behavior

Allium requires WinUIShell 0.12.0 or later.

- Setup installs a compatible version when WinUIShell is missing.
- An installed version at or above 0.12.0 passes the current setup check.
- Allium does not automatically update WinUIShell after installation.
- Versions newer than the tested 0.12.x series may show a compatibility warning.
- Another explicit package-management action can install a newer version side by side.

## Verify an existing installation

From PowerShell 7 in the Allium folder:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Verify
```

Verification checks the configured setup steps without intentionally rebuilding the whole installation.

## Debug setup

If setup supports debug tracing in the installed release, run:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -DebugTrace
```

Review generated output before sharing it. Remove usernames, local paths, account data, certificate details, and unrelated system information.

## Uninstall Allium-managed data

Before uninstalling, back up any profiles or FastFlag configuration that should be retained.

Run:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Uninstall
```

The current uninstall workflow:

- Backs up and removes the local `data` directory
- Removes known Allium-installed font files
- Attempts to remove WinUIShell

The uninstall workflow does not promise to:

- Remove PowerShell
- Remove Windows App SDK Runtime
- Remove PSResourceGet
- Restore every PowerShell Gallery setting
- Restore every execution-policy setting
- Remove unrelated versions of shared dependencies

After uninstall completes, review the reported backup location before deleting the remaining Allium folder.

---

## Screenshot: first Allium interface

<p align="center">
  <a href="https://github.com/fwOnion/Allium/blob/main/docs/screenshots/editor.png">
    <img src="https://raw.githubusercontent.com/fwOnion/Allium/main/docs/screenshots/editor.png" alt="Allium FastFlag editor" width="100%">
  </a>
</p>

---

## Getting help

- Read [Troubleshooting](troubleshooting.md).
- Join the [Allium Discord](https://discord.gg/gFK9fhMUQm) for general support, ordinary bug reporting, and FastFlag configuration or list discussion.
- Use [GitHub issues](https://github.com/fwOnion/Allium/issues) for reproducible public bugs.
- Use [private vulnerability reporting](https://github.com/fwOnion/Allium/security/advisories/new) for security issues.

Never post private keys, certificate bundles, tokens, cookies, account data, raw memory dumps, or unsanitized logs in public support channels.

<div align="center">

[Back to the README](../README.md)

</div>
