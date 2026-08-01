<div align="center">

# Third-party notices

### Dependencies, fonts, upstream projects, and data-source provenance

[README](README.md) · [Security](SECURITY.md) · [License](LICENSE)

</div>

---

Allium's MIT license applies to Allium itself. Third-party software, fonts, services, and data remain subject to their own terms.

> [!IMPORTANT]
> Inclusion in this register is attribution and provenance tracking. It is not a claim that Allium owns, endorses, or can redistribute every referenced external resource.

## Runtime components

### WinUIShell

- **Purpose:** Provides the WinUI bridge used by the Allium interface.
- **Supported baseline:** 0.12.0 or later; versions newer than the tested 0.12.x series may produce a compatibility warning.
- **Distribution model:** Installed separately by setup through PowerShell resource tooling.
- **Upstream:** [mdgrs-mei/WinUIShell](https://github.com/mdgrs-mei/WinUIShell)
- **Package:** [WinUIShell 0.12.0 on PowerShell Gallery](https://www.powershellgallery.com/packages/WinUIShell/0.12.0)
- **License:** MIT
- **Bundled in the release ZIP:** No

### Windows App SDK Runtime 1.6

- **Purpose:** Runtime required by the WinUI application surface.
- **Distribution model:** Setup checks or installs the x64 runtime.
- **Upstream documentation:** [Windows App SDK and WinUI](https://learn.microsoft.com/windows/apps/winui/winui3/)
- **License:** Microsoft's applicable license terms
- **Bundled in the release ZIP:** No

### PowerShell 7

- **Purpose:** Runs Allium and the setup script.
- **Required version:** 7.4 or later.
- **Distribution model:** Setup checks for PowerShell and may install the configured x64 package.
- **Upstream:** [PowerShell](https://github.com/PowerShell/PowerShell)
- **License:** MIT for the open-source PowerShell project; distributed packages remain subject to their included notices
- **Bundled in the release ZIP:** No

### Microsoft.PowerShell.PSResourceGet

- **Purpose:** Installs and queries PowerShell resources such as WinUIShell.
- **Distribution model:** Installed or imported through setup.
- **Upstream documentation:** [Microsoft.PowerShell.PSResourceGet](https://learn.microsoft.com/powershell/module/microsoft.powershell.psresourceget/)
- **License:** Refer to the upstream package and repository notices
- **Bundled in the release ZIP:** No

### ZstdSharp.Port 0.8.8

- **Purpose:** Provides Zstandard decompression support used by supported Allium data workflows.
- **Distribution model:** Downloaded by setup into Allium's local dependency folder.
- **Upstream:** [oleg-st/ZstdSharp](https://github.com/oleg-st/ZstdSharp)
- **Package:** [ZstdSharp.Port 0.8.8 on NuGet](https://www.nuget.org/packages/ZstdSharp.Port/0.8.8)
- **License:** MIT
- **Bundled in the release ZIP:** No

## Fonts

### Nunito

- **Purpose:** Allium interface typography.
- **Distribution model:** Downloaded and installed by setup unless font installation is skipped.
- **Upstream:** [googlefonts/nunito](https://github.com/googlefonts/nunito)
- **License:** SIL Open Font License 1.1
- **Bundled in the release ZIP:** No

### Sono

- **Purpose:** Monospace typography used by supported Allium surfaces.
- **Distribution model:** Downloaded and installed by setup unless font installation is skipped.
- **Upstream:** [Google Fonts Sono directory](https://github.com/google/fonts/tree/main/ofl/sono)
- **License:** SIL Open Font License 1.1
- **Bundled in the release ZIP:** No

## Referenced FastFlag and offset projects

Allium source references the following third-party projects or endpoints for discovery, attribution, FastFlag data, offset data, or related context:

| Project or source | Reference | Known role in Allium |
|---|---|---|
| 4anti Roblox FastFlag Manager | [Repository](https://github.com/4anti/Roblox-Fastflag-Manager) | Referenced FastFlag project |
| Fleasion | [Repository](https://github.com/fleasion/fleasion) | Referenced "FastFlag" project | 
| Froststrap | [Repository](https://github.com/Froststrap/Froststrap) | Referenced Roblox bootstrapper | 
| MaximumADHD Roblox FFlag Tracker | [Repository](https://github.com/MaximumADHD/Roblox-FFlag-Tracker) | FastFlag tracking data reference |
| Roblox Client Tracker | [FVariables data](https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/FVariables.txt) | FastFlag-variable source |
| souloveryall DataBase.json | [Data source](https://raw.githubusercontent.com/souloveryall/DataBase.json/refs/heads/main/database.json) | FastFlag database reference |
| souloveryall offsets.hpp | [Repository](https://github.com/souloveryall/offsets.hpp) | Offset data reference |
| offsets.imtheo.lol | [FFlagsHex data](https://offsets.imtheo.lol/fflags.hpp) | Offset and FastFlag data reference |

Note: External endpoints can change, become unavailable, or return different data without an Allium release.

## Icon and artwork

- The Allium icon was supplied by the project owner.
- Original artwork provenance and any upstream license should be documented when confirmed.
- Until then, do not assume the icon is available for reuse outside Allium.


<div align="center">

[Back to the README](README.md)

</div>
