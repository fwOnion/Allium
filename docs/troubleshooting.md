<div align="center">

# Troubleshooting Allium

### Symptom-based fixes for setup, launch, editing, monitoring, and advanced tools

[README](../README.md) · [Install](installation.md) · [Security](security-and-privacy.md) · [Discord support](https://discord.gg/gFK9fhMUQm)

</div>

---

Start with the quick checks, then use the section that matches the symptom.

## Quick checks

1. Confirm both scripts are in the same extracted folder:

   ```text
   Allium-Setup.ps1
   Allium.ps1
   ```

2. Do not run the scripts from inside the ZIP preview.
3. Use the latest official release.
4. Right-select `Allium-Setup.ps1` and run setup again.
5. Approve administrator prompts.
6. Confirm internet access during dependency checks.
7. Run setup verification.
8. Restart the terminal or application after module or dependency changes.

Run verification from PowerShell 7:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Verify
```

## Run with PowerShell is missing

### Windows 11

1. Right-select the script.
2. Select **Show more options**.
3. Look for **Run with PowerShell**.

PowerShell 7 may also provide **Run with PowerShell 7**, but that entry may not appear in the Windows 11 context menu.

### If neither option appears

- Confirm the filename ends in `.ps1`, not `.ps1.txt`.
- In File Explorer, enable **View → Show → File name extensions**.
- Open PowerShell 7, change to the Allium folder, and run the script explicitly.

## Setup opens and immediately closes

- Confirm setup was extracted from the ZIP.
- Use **Run with PowerShell**, not double-select.
- Run setup from PowerShell 7 to retain error output:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1
```

- If supported by the installed release, add `-DebugTrace`.
- Check whether security software blocked the script or a downloaded dependency.

## Administrator prompt does not appear

- Confirm the current account can approve elevation.
- Right-select setup and try **Run with PowerShell** again.
- Run PowerShell as administrator, change to the Allium folder, and start setup.
- Check whether organizational policy prevents elevation.

## PowerShell is missing or too old

Allium requires PowerShell 7.4 or later.

Check the version:

```powershell
$PSVersionTable.PSVersion
```

Run setup again and allow the PowerShell prerequisite step to complete. Open a fresh terminal after installation.

## Windows App SDK is missing

- Run setup again.
- Allow the Windows App SDK Runtime step to complete.
- Confirm the machine is x64 Windows 10 build 17763 or later, or Windows 11.
- Restart the terminal after runtime installation.
- Run setup verification.

## WinUIShell does not load

Current Allium requires WinUIShell 0.12.0 or later.

- Run setup again.
- Confirm internet access to PowerShell Gallery.
- Run verification.
- Open a fresh PowerShell 7 session after installation.
- If a version newer than the tested 0.12.x series is installed, review any compatibility warning.

Check installed versions:

```powershell
Get-InstalledPSResource -Name WinUIShell -Scope AllUsers
```

Allium does not automatically update WinUIShell after installation.

## ZstdSharp does not load

- Run setup again with internet access.
- Confirm that the Allium folder is writable.
- Check whether security software quarantined the downloaded DLL.
- Do not download an unrelated DLL from an unofficial site.
- Run setup verification after restoring the dependency.

The expected dependency is acquired under Allium's local `data\deps` area and is not committed to the repository.

## Fonts do not appear

- Run setup with administrator approval.
- Confirm the font-installation step was not skipped.
- Close and reopen Allium.
- If necessary, sign out and back in so Windows refreshes installed fonts.
- Allium can fall back to other Windows fonts, but appearance may differ.

## Allium does not launch

- Confirm `Allium.ps1` is beside `Allium-Setup.ps1`.
- Use setup's **Launch Allium** button.
- Run setup verification.
- Confirm PowerShell 7.4 or later.
- Confirm Windows App SDK and WinUIShell checks pass.
- Open a fresh terminal after dependency changes.
- Check setup logs and sanitized console output.

Direct launch from PowerShell 7:

```powershell
pwsh -NoProfile -File .\Allium.ps1
```

## Roblox is not detected

- Confirm Roblox Player is installed for the current Windows user.
- Launch Roblox once, close it, and try detection again.
- Verify the installation path is accessible.
- If using a bootstrapper, confirm the executable still exists.
- Add a custom bootstrapper executable through Allium when appropriate.

## A bootstrapper is not detected

- Confirm the bootstrapper is installed.
- Confirm its executable path has not changed.
- Use Allium's custom-bootstrapper option to select the executable.
- Remove stale custom entries before adding a replacement.

Third-party bootstrapper compatibility can change independently of Allium.

## FastFlags are not written

- Confirm the FastFlag list contains valid names and values.
- Use the editor's clean-list action.
- Confirm Roblox client settings can be located.
- Close Roblox before testing file-based changes.
- Check whether watchdog or another tool is rewriting the same file.
- Review Allium's console log for a write error.

## Importing JSON fails

- Confirm the content is valid JSON.
- Confirm the top-level shape matches the supported FastFlag object format.
- Remove comments and trailing commas.
- Import a minimal one-flag example to isolate the invalid entry.
- Use UTF-8 text when saving a JSON file.

## Browser sources fail to load

- Confirm internet access.
- Try again later because external sources can be unavailable independently.
- Review source status in the browser.
- Check whether a firewall, proxy, DNS filter, or security product blocks a configured endpoint.
- Clear only the relevant cache if a stale result is suspected.

Do not assume one unavailable source means every browser result is invalid. Allium can use multiple configured sources.

## Profiles do not load

- Confirm the profile exists under Allium's local profile folder.
- Confirm the file is valid JSON.
- Avoid editing profile files while Allium is saving them.
- Test with a newly created minimal profile.
- Restore from a known backup only after preserving the current file.

## Watchdog does not reapply

- Confirm watchdog is enabled.
- Confirm the correct monitoring options are enabled.
- Confirm the periodic interval is within the supported interface range.
- Confirm Allium remains running when the selected behavior requires it.
- Review watchdog logs.
- Test file monitoring, version monitoring, restart monitoring, and periodic reapplication separately.
- Disable watchdog during manual file-comparison tests.

## Memory address acquisition fails

> [!WARNING]
> Memory mode is advanced and can stop working after Roblox updates.

- Confirm Roblox is running.
- Confirm Allium is elevated when required.
- Refresh address acquisition.
- Review source status and quorum diagnostics.
- Check whether cached data is stale.
- Test a validated manual address only when authorized and understood.
- Restart Roblox and Allium before retrying.
- Do not share raw memory dumps publicly.

## Memory application does not change a value

- Confirm address acquisition passed validation.
- Confirm the FastFlag type and selected value mode are compatible.
- Confirm the target process has not restarted since acquisition.
- Try one supported flag before a batch operation.
- Review the console log for validation or write failures.
- Treat a Roblox update as a possible compatibility change.

## HTTPS interception or certificate setup fails

> [!CAUTION]
> Do not improvise certificate or private-key commands from untrusted sources.

- Confirm setup and Allium have administrator approval.
- Review the HTTPS settings status.
- Confirm the hosts file is writable and not controlled by another product.
- Check whether security software blocks local certificate installation.
- Stop interception before reinstalling certificate material.
- Remove only Allium-managed entries and certificates.
- Review [Security and privacy](security-and-privacy.md) before sharing diagnostics.

<p align="center">
  <a href="https://github.com/fwOnion/Allium/blob/main/docs/screenshots/settings-https.png">
    <img src="https://raw.githubusercontent.com/fwOnion/Allium/main/docs/screenshots/settings-https.png" alt="Allium HTTPS interception settings" width="100%">
  </a>
</p>

## Settings JSON is corrupt

Setup can move a corrupt settings file to a timestamped backup so defaults can be regenerated.

Before changing files:

1. Close Allium.
2. Copy the current settings file to a safe private location.
3. Run setup verification.
4. Check for a timestamped corrupt-file backup.
5. Reconfigure only the needed settings.
6. Do not paste the entire old file into a public issue.

## Uninstall fails

- Close Allium and Roblox.
- Run uninstall with administrator approval.
- Review each reported failure.
- Preserve the uninstall backup path.
- Check whether files are locked by another process.
- Do not manually delete certificate material without identifying the Allium-managed item.

Run:

```powershell
pwsh -NoProfile -File .\Allium-Setup.ps1 -Uninstall
```

## Backup cannot be found

- Review the uninstall or setup log for the exact backup path.
- Search the Allium parent folder for timestamped backup archives.
- Do not rerun cleanup repeatedly before locating the first backup.
- Confirm the backup opens before deleting remaining local data.

## Collect sanitized diagnostics

Include only what is needed:

- Allium version
- Windows version and build
- PowerShell version
- Affected feature
- Exact reproduction steps
- Expected and observed behavior
- Sanitized log excerpts
- Sanitized screenshots

Remove:

- Usernames and private paths
- Tokens, cookies, and account data
- Private keys and certificate bundles
- Raw memory dumps
- Complete `data` folders
- Unrelated FastFlags and profiles

## Get more help

- Join the [Allium Discord](https://discord.gg/gFK9fhMUQm) for ordinary support, bugs, and FastFlag configuration discussion.
- Open a [GitHub issue](https://github.com/fwOnion/Allium/issues) for a reproducible public bug.
- Use [private vulnerability reporting](https://github.com/fwOnion/Allium/security/advisories/new) for security issues.

<div align="center">

[Back to the README](../README.md)

</div>
