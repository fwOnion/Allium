<div align="center">

# Allium security policy

### Private reporting, coordinated review, and safe diagnostics

[README](README.md) · [Security and privacy guide](docs/security-and-privacy.md) · [Troubleshooting](docs/troubleshooting.md) · [Discord support](https://discord.gg/gFK9fhMUQm)

</div>

---

## Supported versions

| Version | Security support |
|---|---|
| 1.0.x | Supported |
| Earlier versions | Not supported |

Support may change when a newer release replaces the current supported line. Check the [latest release](https://github.com/fwOnion/Allium/releases/latest) before reporting a problem.

## Report a vulnerability privately

Use GitHub private vulnerability reporting:

1. Open the repository's **Security** area.
2. Select **Report a vulnerability**.
3. Provide the issue description, affected version, reproduction conditions, and impact.
4. Include a minimal proof of concept only when needed.
5. Remove unrelated personal or account data.

[Open Allium private vulnerability reporting](https://github.com/fwOnion/Allium/security/advisories/new)

> [!CAUTION]
> Do not disclose an unpatched vulnerability in a public issue, pull request, discussion, screenshot, or Discord channel.

GitHub private vulnerability reporting is separate from the presence of a `SECURITY.md` file and must be enabled for the repository. If the reporting form is unavailable, use the policy in this file and ask for a private contact without publishing vulnerability details.

## Discord support

The [Allium Discord](https://discord.gg/gFK9fhMUQm) is available for:

- General setup and usage help
- Reproducible non-security bugs
- FastFlag configuration and list discussion
- Clarifying whether an issue should be handled privately

Discord is not the preferred place to post:

- Exploit details
- Private keys or certificate bundles
- Cookies, tokens, or account data
- Raw memory dumps
- Full settings or data folders
- Unsanitized logs
- Vulnerability proof-of-concept material

## What to include in a private report

Include as much of the following as is safe and relevant:

- A concise title
- Affected Allium version
- Affected feature
- Windows and PowerShell versions
- Reproduction prerequisites
- Step-by-step reproduction
- Actual and expected behavior
- Security impact
- Whether the issue is consistently reproducible
- Minimal sanitized logs or screenshots
- Suggested mitigation, if known

## What happens after reporting

The maintainer will review the report, may request clarification, and will coordinate disclosure if the issue is confirmed. No fixed response or remediation timeline is promised.

Please do not publish details until a coordinated disclosure decision is made.

## Security-sensitive features

Allium includes optional features that deserve additional care:

- Process-memory application
- Roblox process and version monitoring
- Local hosts-file changes
- Local certificate-authority material
- HTTPS interception controls
- Dumps, address caches, and diagnostic bundles
- Administrator-level setup actions

Read [Security and privacy](docs/security-and-privacy.md) before enabling advanced features.

## Safe handling reminders

- Use Allium only on systems and accounts you are authorized to control.
- Download releases from the official repository.
- Verify the release ZIP with the published checksum when available.
- Keep generated private keys and certificates private.
- Review diagnostics before sharing them.
- Do not publish the complete local `data` directory.

<div align="center">

[Back to the README](README.md)

</div>
