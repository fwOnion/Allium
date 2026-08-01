<div align="center">

# Contributing to Allium

### Focused improvements, reproducible reports, and respectful collaboration

[README](README.md) · [Install](docs/installation.md) · [Troubleshooting](docs/troubleshooting.md) · [Security](SECURITY.md) · [Discord](https://discord.gg/gFK9fhMUQm)

</div>

---

Thank you for helping improve Allium. Contributions should be narrow, testable, and easy to review.

> [!IMPORTANT]
> The public root `Allium.ps1` is the verified minified release artifact and is not intended for large unsolicited refactors.

## Ways to contribute

Allium currently welcomes:

- Reproducible bug reports
- Documentation corrections
- Beginner-experience and accessibility improvements
- Setup and uninstall corrections
- Packaging, checksum, and workflow corrections
- Focused feature proposals discussed before implementation
- Small, reviewable application changes coordinated with the maintainer
- Verified screenshot updates with private information removed

For general help, bug discussion, and community FastFlag configurations or lists, join the [Allium Discord](https://discord.gg/gFK9fhMUQm).

## Before opening an issue

1. Use the latest public release.
2. Read [Installation](docs/installation.md) and [Troubleshooting](docs/troubleshooting.md).
3. Reproduce the problem with the smallest practical configuration.
4. Search existing issues for the same symptom.
5. Remove private information from logs, screenshots, settings, and paths.

## Writing a useful bug report

Include:

- Allium version
- Windows version and build
- PowerShell version
- The affected Allium feature
- Exact reproduction steps
- Expected behavior
- Observed behavior
- Whether the issue reproduces after running setup verification
- Sanitized diagnostics, if relevant

Do not attach complete `data` folders, certificate material, private keys, cookies, account data, raw memory dumps, or unsanitized logs.

## Feature proposals

Open a discussion or use the [Allium Discord](https://discord.gg/gFK9fhMUQm) before implementing a significant feature.

A strong proposal explains:

- The user problem
- The intended workflow
- Why the feature belongs in Allium
- Security or privacy impact
- Compatibility impact
- How the behavior could be tested

Discussion does not guarantee acceptance. Keeping the project understandable and supportable takes priority over adding every possible feature.

## Pull request workflow

1. Create a branch from current `main`.
2. Keep the change focused on one purpose.
3. Do not include runtime data, downloaded dependencies, secrets, or private source.
4. Update documentation and the changelog when user-visible behavior changes.
5. Parse changed PowerShell scripts before committing.
6. Run the repository validator when applicable.
7. Review the complete staged file list.
8. Open a pull request with a clear summary and verification notes.
9. Address review comments without force-pushing unrelated history.

## PowerShell checks

Parse a changed script without executing it:

```powershell
$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile(
    '.\Allium-Setup.ps1',
    [ref]$tokens,
    [ref]$errors
)
$errors
```

Run strict repository validation when both public release artifacts are present:

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1 `
    -Root . `
    -ExpectedVersion 1.0.0 `
    -RequireReleaseArtifacts
```

## Repository hygiene

Never commit:

- Private readable development source
- `data` or its contents
- `settings.json` or `flags.json`
- Profiles, dumps, logs, or backups
- Proxy certificates, PFX files, PEM files, or private keys
- `ZstdSharp.dll` or downloaded packages
- Patch-chain files or Python patchers
- User-specific paths or screenshots containing private information

## Documentation style

- Use plain language.
- Put the beginner path first.
- State prerequisites and side effects directly.
- Use relative repository links.
- Avoid unsupported promises.
- Distinguish verified behavior from suggestions.
- Keep paragraphs short and headings descriptive.

## Security reports

Do not open a public issue for a vulnerability. Follow [SECURITY.md](SECURITY.md) and use GitHub private vulnerability reporting.

The public Discord is appropriate for ordinary support and bug discussion, but not for secrets, exploit details, private keys, certificate bundles, or sensitive proof-of-concept material.

## Code of conduct

Be respectful, stay focused on the technical issue, and do not pressure maintainers or contributors for private source, private data, or immediate responses.

<div align="center">

[Back to the README](README.md)

</div>
