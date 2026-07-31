[CmdletBinding()] param([string]$Root=(Split-Path -Parent $PSScriptRoot),[string]$ExpectedVersion='1.0.0',[switch]$RequireReleaseArtifacts)
$ErrorActionPreference='Stop'; $fail=[Collections.Generic.List[string]]::new()
function CheckPs([string]$p){if(!(Test-Path -LiteralPath $p)){ $fail.Add("Missing $p");return };$t=$null;$e=$null;[Management.Automation.Language.Parser]::ParseFile($p,[ref]$t,[ref]$e)>$null;foreach($x in $e){$fail.Add("Parser error: $($x.Message)")};$s=[IO.File]::ReadAllText($p);$m=[regex]::Match($s,'(?m)^\$(?:script|Script):AppVersion\s*=\s*["'']([^"'']+)["'']');if(!$m.Success-or$m.Groups[1].Value-ne$ExpectedVersion){$fail.Add("Version mismatch: $p")}}
@('README.md','LICENSE','SECURITY.md','THIRD-PARTY-NOTICES.md','assets/allium-icon.png')|%{if(!(Test-Path -LiteralPath(Join-Path $Root $_))){$fail.Add("Missing $_")}}
if($RequireReleaseArtifacts){CheckPs (Join-Path $Root 'Allium.ps1'); CheckPs (Join-Path $Root 'Allium-Setup.ps1')}else{Write-Host 'Foundation validation mode: release artifacts are not required.'}
@('Allium.dev.ps1','ZstdSharp.dll')|%{if(Get-ChildItem $Root -Recurse -File -Filter $_ -ErrorAction SilentlyContinue){$fail.Add("Forbidden $_")}}
if(Test-Path(Join-Path $Root data)){$fail.Add('Forbidden data directory')}
if($fail.Count){$fail|%{Write-Error $_};exit 1};Write-Host 'Repository validation passed.' -ForegroundColor Green
