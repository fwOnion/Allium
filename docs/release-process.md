# Release Process

1. Add verified minified root `Allium.ps1` and verified root `Allium-Setup.ps1`.
2. Match tag, application version, and setup version.
3. Parse both scripts with the native PowerShell parser.
4. Run repository policy checks.
5. Confirm private source, runtime data, dependencies, certificates, keys, logs, dumps, backups, and patchers are absent.
6. Build the ZIP from the explicit allowlist and generate SHA-256 checksums.
7. Test setup, Verify twice, launch, runtime features, and uninstall on clean x64 Windows.
8. Publish only after manual approval.
