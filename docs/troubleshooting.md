<div align="center">

# Allium troubleshooting FAQ

### Quick answers for setup, launch, editing, monitoring, and advanced tools

[README](../README.md) · [Install](installation.md) · [Security](security-and-privacy.md) · [Discord support](https://discord.gg/gFK9fhMUQm)

</div>

---

## Start here

Before using the FAQ:

1. Confirm `Allium-Setup.ps1` and `Allium.ps1` are in the same extracted folder.
2. Do not run either script from inside the ZIP preview.
3. Use the latest official release.
4. Run setup again and approve administrator prompts.
5. Run verification from PowerShell 7:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Verify
```

---

# Installation and setup FAQ

## Why can I not see “Run with PowerShell”?

On Windows 11:

1. Right-select the script.
2. Select **Show more options**.
3. Select **Run with PowerShell**.

Also confirm the filename ends in `.ps1`, not `.ps1.txt`. In File Explorer, enable **View → Show → File name extensions**.

## Why does setup open and immediately close?

- Confirm setup was extracted from the ZIP.
- Use **Run with PowerShell**, not a normal double-select.
- Run setup from PowerShell 7 to keep the error visible:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1
```

- Check whether Windows Security or another security product blocked the script or a dependency.

## Why did Windows ask for administrator approval?

Setup performs system-level actions such as installing dependencies and fonts. Allium can also request elevation during launch. Approve only files obtained from the official Allium release.

## Why is PowerShell reported as missing or too old?

Allium requires PowerShell 7.4 or later. Check:

```powershell
$PSVersionTable.PSVersion
```

Run setup again and allow the PowerShell prerequisite step to finish. Open a fresh terminal afterward.

## Why is Windows App SDK reported as missing?

Run setup again and allow the Windows App SDK Runtime step to complete. Confirm the system is x64 Windows 10 build 17763 or later, or Windows 11. Restart the terminal after installation.

## Why does WinUIShell fail to load?

- Run setup again with internet access.
- Confirm access to PowerShell Gallery.
- Run setup verification.
- Open a fresh PowerShell 7 session.
- Review any warning about a version newer than the tested 0.12.x series.

Check installed versions:

```powershell
Get-InstalledPSResource -Name WinUIShell -Scope AllUsers
```

Allium does not automatically update WinUIShell after installation.

## Why does ZstdSharp fail to load?

- Run setup again with internet access.
- Confirm the Allium folder is writable.
- Check whether security software quarantined the dependency.
- Do not download replacement DLLs from unofficial sites.
- Run verification again.

## Why do the Allium fonts look wrong?

- Run setup with administrator approval.
- Confirm font installation was not skipped.
- Close and reopen Allium.
- If needed, sign out and back in so Windows refreshes installed fonts.

---

# Launch and interface FAQ

## Why does Allium not launch?

- Confirm both scripts are together.
- Use setup’s **Launch Allium** button.
- Run setup verification.
- Confirm PowerShell 7.4 or later.
- Confirm Windows App SDK and WinUIShell checks pass.
- Open a fresh terminal after dependency changes.

Direct diagnostic launch:

```powershell
pwsh -NoProfile -File .\Allium.ps1
```

## What should appear after setup?

The first Allium interface should be the launcher menu:

<p align="center">
  <a href="https://github.com/fwOnion/Allium/blob/main/docs/screenshots/launcher.png">
    <img src="https://raw.githubusercontent.com/fwOnion/Allium/main/docs/screenshots/launcher.png" alt="Allium launcher menu" width="100%">
  </a>
</p>

## Why does Allium take so long to start up?

- Allium 

## Why is Roblox not detected?

- Confirm Roblox Player is installed for the current Windows user.
- Launch Roblox once, close it, and try again.
- Confirm the installation path is accessible.
- If using a bootstrapper, confirm its executable still exists.

## Why is my bootstrapper not detected?

- Confirm the bootstrapper is installed.
- Confirm its path has not changed.
- Use Allium’s custom-bootstrapper option to select the executable.
- Remove stale custom entries before adding a replacement.

---

# FastFlag editor FAQ

## Why are FastFlags not being written?

- Confirm names and values are valid.
- Use the editor’s clean-list action.
- Confirm Roblox client settings can be located.
- If using Memory Writing, ensure that you have ran a dump first (open the Allium Settings, head over to the FFlag Dumper tab, locate the "Run dump" card, and press "Dump now"). Then, retry applying your FFlags.
- If using HTTPS Interception. ensure that HTTS Interception is enabled and the certificate is installed. If this is your first time using HTTPS Interception, then you may have to wait a few minutes for the proxy to properly start up in order for your FFlags to actually apply to Roblox.
- Close Roblox before testing file-based changes.
- Check whether watchdog or another tool rewrites the same file.
- Review Allium’s console log.

## Why does JSON import fail?

- Confirm the content is valid JSON.
- Remove comments and trailing commas.
- Use a minimal one-flag example to isolate the invalid entry.
- Save imported files as UTF-8.

## Why do profiles not load?

- Confirm the profile exists under Allium’s local profile folder.
- Confirm the file is valid JSON.
- Avoid editing a profile while Allium is saving it.
- Test with a new minimal profile.
- Preserve the current file before restoring a backup.

## Why does the FFlag browser fail to load sources?

- Confirm internet access.
- Try again later because external sources can be independently unavailable.
- Review the source status in the browser.
- Check firewall, proxy, DNS, or security filtering.
- Clear only the relevant cache when stale results are suspected.

---

# Watchdog FAQ

## Why is watchdog not reapplying FastFlags?

- Confirm watchdog is enabled.
- Confirm the required monitoring options are enabled.
- Confirm the interval is supported.
- Confirm Allium remains running when required.
- Review watchdog logs.
- Test file, version, restart, and periodic monitoring separately.
- Disable watchdog during manual comparison tests.

## Why does my settings file change again after I edit it manually?

Watchdog or periodic reapplication may be writing the configured FastFlags back to disk. Disable the relevant watchdog and automatic-reapply settings before testing manual file changes.

---

# Memory mode FAQ

> [!WARNING]
> Memory mode is advanced and may stop working after Roblox updates.

## Why does address acquisition fail?

- Confirm Roblox is running.
- Confirm Allium is elevated when required.
- Refresh address acquisition.
- Review source and quorum diagnostics.
- Check for stale cached data.
- Restart Roblox and Allium before retrying.
- Use manual addresses only when authorized and understood.

## Why does memory application not change a value?

- Ensure that you have ran a dump first (open the Allium Settings, head over to the FFlag Dumper tab, locate the "Run dump" card, and press "Dump now"). Then, retry applying your FFlags.
- Confirm address validation passed.
- Confirm the FastFlag type and selected mode are compatible.
- Confirm Roblox has not restarted since acquisition.
- Try one supported flag before a batch.
- Review the console log.
- Treat a Roblox update as a possible compatibility change.

---

# HTTPS interception FAQ

> [!CAUTION]
> Do not improvise certificate or private-key commands from untrusted sources.

## Why does HTTPS interception or certificate setup fail?

- Confirm setup and Allium have administrator approval.
- Review HTTPS status in settings.
- Confirm the hosts file is writable.
- Check whether security software blocks local certificate installation.
- Stop interception before reinstalling certificate material.
- Remove only Allium-managed entries and certificates.
- Read [Security and privacy](security-and-privacy.md).

## Is it safe to share the certificate files?

No. Do not share PFX, P12, PEM private keys, passwords, or complete certificate folders. Use GitHub private vulnerability reporting for security issues.

## Why is HTTPS Interception not modifying FFlags to Roblox?
- Ensure that HTTS Interception is enabled and the certificate is installed.
- If this is your first time using HTTPS Interception, then you may have to wait a few minutes for the proxy to properly start up in order for your FFlags to actually apply to Roblox.

## Why does HTTPS Interception result in me having connection issues in Roblox?
- First, ensure that the FFlags that you are using are not causing this issue. Remove all of your current FFlags and apply a known, untroublesome FFlag, and test again.
- Attempt to reset the HTTPS state. Re-enable HTTPS Interception and reinstall the certificate afterwards.

---

# Data, settings, and uninstall FAQ

## What should I do if settings JSON is corrupt?

1. Close Allium.
2. Copy the current settings file to a private backup location.
3. Run setup verification.
4. Check for a timestamped corrupt-file backup.
5. Reconfigure only the necessary settings.
6. Do not post the complete old settings file publicly.

## Why did uninstall fail?

- Close Allium and Roblox.
- Run uninstall with administrator approval.
- Review the reported failure.
- Preserve the backup path.
- Check whether another process locks the files.
- Do not manually delete certificate material without identifying it.

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Uninstall
```

## Where is my uninstall backup?

- Review the uninstall log for the exact path.
- Search the Allium parent folder for timestamped backup archives.
- Do not rerun cleanup repeatedly before locating the first backup.
- Confirm the backup opens before deleting remaining files.

---

# Support and reporting FAQ

## What should I include in a bug report?

- Allium version
- Windows version and build
- PowerShell version
- Affected feature
- Exact reproduction steps
- Expected and observed behavior
- Sanitized log excerpts
- Sanitized screenshots

## What must I remove before sharing diagnostics?

Remove:

- Usernames and private paths
- Tokens, cookies, and account data
- Private keys and certificate bundles
- Raw memory dumps
- Complete `data` folders
- Unrelated FastFlags and profiles

## Where should I ask for help?

- Join the [Allium Discord](https://discord.gg/gFK9fhMUQm) for ordinary support, bug discussion, and FastFlag configuration or list discussion.
- Open a [GitHub issue](https://github.com/fwOnion/Allium/issues) for a reproducible public bug.
- Use [private vulnerability reporting](https://github.com/fwOnion/Allium/security/advisories/new) for security issues.

<div align="center">

[Back to the README](../README.md)

</div>
