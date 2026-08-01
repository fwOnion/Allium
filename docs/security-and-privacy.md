<div align="center">

# Security and privacy

### What Allium can change, store, monitor, and download

[README](../README.md) · [Install](installation.md) · [Troubleshooting](troubleshooting.md) · [Security policy](../SECURITY.md) · [Discord](https://discord.gg/gFK9fhMUQm)

</div>

---

> [!WARNING]
> Allium includes optional advanced features involving process memory, local monitoring, hosts-file changes, and certificate material. Enable only features that are understood and authorized for the system and account being used.

## Beginner risk summary

### Normal editor use

Normal FastFlag editing primarily works with local Allium data and Roblox client settings. Allium still runs with elevated permissions and can launch or monitor Roblox-related processes.

### Watchdog

Watchdog features monitor supported local files, Roblox versions, and process restart events. Automatic reapplication can rewrite supported FastFlag configuration after detected events.

### Memory application

Memory mode reads or writes supported values in a running Roblox process. Compatibility can change after Roblox updates. Use only on a process and account the user is authorized to control.

### HTTPS interception

HTTPS interception is the highest-impact optional feature. It can modify the local hosts file and install local certificate-authority material. Incorrect handling of certificate material can create security risk.

### Diagnostics

Logs, dumps, settings, profiles, caches, and diagnostic bundles can reveal local paths, configuration, process information, or other private data. Review every file before sharing it.

---

## Administrator access

Allium setup requests administrator access for system-level actions such as dependency installation, font installation, execution-policy changes, and supported hosts or certificate operations.

Allium itself can also request elevation during launch.

Approve elevation only when running files obtained from the official Allium release.

## PowerShell execution policy

Setup may set the CurrentUser execution policy to:

```text
Unrestricted
```

This affects PowerShell script execution for the current Windows user, not only Allium.

The uninstall workflow does not promise to restore the previous execution policy. Record the earlier setting manually if restoration is important.

## System-wide dependencies

Setup may install shared components, including:

- PowerShell 7
- Windows App SDK Runtime
- PSResourceGet
- WinUIShell for all users
- Nunito and Sono fonts

These components can be used by software other than Allium. Uninstall does not remove every shared dependency.

## Network downloads and upstream services

First-time setup and some application features use network access.

Potential network activity includes:

- Downloading setup dependencies
- Querying PowerShell Gallery or NuGet-related resources
- Downloading fonts
- Retrieving FastFlag lists
- Retrieving Roblox client tracking data
- Retrieving offset or address-source data
- Fetching configured external data sources

External services can observe ordinary request metadata such as the requesting IP address. External content and availability are controlled by their maintainers.

See [Third-party notices](../THIRD-PARTY-NOTICES.md) for the provenance register.

## Local data storage

Allium creates a `data` folder beside the two scripts.

Depending on enabled features, the folder can contain:

- `settings.json`
- `flags.json`
- Profiles
- Source caches
- Dependencies
- Logs
- Dumps
- Address and pattern data
- Backups
- Certificate-related material

Treat the complete `data` folder as private by default.

Do not commit it to Git, attach it wholesale to an issue, or share it in Discord without reviewing every file.

## FastFlag and profile data

FastFlag collections and profiles can reveal preferences, experiments, or configuration history.

Before sharing:

- Remove flags unrelated to the reported issue.
- Remove account-specific or environment-specific values.
- Prefer a minimal reproduction profile.
- Confirm that exported JSON contains only intended entries.

## Watchdog and monitoring

Watchdog can monitor supported files, Roblox versions, and process restart state. Depending on settings, watchdog can automatically reapply configuration.

Consider disabling watchdog while:

- Troubleshooting unexpected file changes
- Comparing manual edits
- Testing a clean Roblox configuration
- Capturing a minimal reproduction

## Process-memory application

Memory mode can:

- Identify a running Roblox process
- Acquire and validate addresses
- Cache address information
- Read supported values
- Write supported values
- Apply one or more values in batches

Risks include:

- Incompatibility after Roblox updates
- Incorrect or stale address data
- Unexpected process behavior
- Exposure of process and address information in diagnostics

Use memory mode only where authorized. Restart the affected application if behavior becomes unstable.

## Hosts-file changes

Optional interception setup can add or remove Allium-managed entries in the Windows hosts file.

Hosts-file changes can redirect network names on the local computer. Review installed entries and disable the feature before attributing unrelated connectivity problems to the network or service.

Allium includes backup and restoration logic for supported modifications, but backups should be reviewed rather than assumed to cover every external change.

## Local certificate authority

Optional HTTPS interception can create or install local certificate-authority material.

> [!CAUTION]
> A certificate-authority private key must remain private. Anyone who obtains that key may be able to misuse certificates created from it.

Never share:

- PFX or P12 files
- PEM private keys
- Certificate private-key exports
- Passwords protecting certificate bundles
- Complete certificate data folders

Remove Allium-managed certificate material when interception is no longer required.

## HTTPS interception

HTTPS interception can affect traffic routed through the configured local mechanism.

Before enabling it:

1. Read the settings shown in Allium.
2. Confirm that the computer and account are authorized for the operation.
3. Close unrelated sensitive applications.
4. Understand how to disable interception and remove certificate material.
5. Avoid collecting unrelated traffic or data.

<p align="center">
  <a href="https://github.com/fwOnion/Allium/blob/main/docs/screenshots/settings-https.png">
    <img src="https://raw.githubusercontent.com/fwOnion/Allium/main/docs/screenshots/settings-https.png" alt="Allium HTTPS interception settings" width="100%">
  </a>
</p>

## Dumps and diagnostics

Dumps and diagnostic bundles can contain:

- Process metadata
- Address data
- FastFlag names and values
- Source status
- Local paths
- Timestamps
- Error messages
- Configuration details

Share the smallest relevant extract. Do not publish raw memory dumps.

## Backups

Allium can create backups before supported file modifications and during uninstall.

Backups may contain the same sensitive information as the original files. Store backups securely and remove obsolete copies only after confirming that recovery is no longer needed.

## Uninstall limitations

The current uninstall workflow backs up and removes Allium's local `data` directory, removes known Allium-installed fonts, and attempts to remove WinUIShell.

It does not promise to remove all shared dependencies or restore every system setting. Review:

- Execution policy
- PowerShell Gallery settings
- Windows App SDK Runtime
- PowerShell installation
- PSResourceGet
- Hosts-file state
- Certificate stores
- Remaining backups

## Safe public issue checklist

Before attaching diagnostics to a public issue:

- Remove usernames and personal paths.
- Remove account data.
- Remove tokens, cookies, and credentials.
- Remove certificate thumbprints if not required.
- Never include private keys or PFX bundles.
- Remove unrelated FastFlags and profiles.
- Remove raw memory content.
- Confirm screenshots do not expose other applications or notifications.

## Reporting security issues

Use [GitHub private vulnerability reporting](https://github.com/fwOnion/Allium/security/advisories/new).

Use the [Allium Discord](https://discord.gg/gFK9fhMUQm) for general support and ordinary bugs, but do not post vulnerability details or sensitive artifacts in public channels.

<div align="center">

[Back to the README](../README.md)

</div>
