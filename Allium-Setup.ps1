# b25pb24=
[CmdletBinding()]
param(
[switch] $Uninstall,
[switch] $Verify,
[switch] $Quiet,
[switch] $SkipFont,
[switch] $Force,
[switch] $DebugTrace,
[ValidateSet('Mica','Acrylic','MicaAlt','None')]
[string] $Backdrop = 'Mica'
)
$ErrorActionPreference = 'Stop'
$Script:AppName = 'Allium Setup'
$Script:AppVersion = '1.0.0'
$Script:ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Script:ScriptPath = $MyInvocation.MyCommand.Path
$Script:DataRoot = Join-Path $Script:ScriptRoot 'data'
$Script:SettingsPath = Join-Path $Script:DataRoot 'settings.json'
$Script:Theme = @{
Background = '#191919'
BackgroundT = '#D0191919'
Surface = '#2A2A2A'
Border = '#2E2E2E'
Accent = '#7B2E3F'
AccentHover = '#8F3A4C'
Foreground = '#EEEEEE'
ForegroundD = '#A0A0A0'
Success = '#4CAF50'
Warning = '#FFA726'
Error = '#E53935'
Info = '#64B5F6'
RunningTint = '#3D2E1E24'
HoverBg = '#242424'
}
$Script:MonoStack = 'Cascadia Code, Consolas, Courier New'
$Script:PS7VersionPin = '7.4.17'
$Script:PS7MinVersion = [Version]'7.4.0'
$Script:AppSdkTag = '1.6'
$Script:AppSdkPkgPrefix = 'Microsoft.WindowsAppRuntime.1.6'
$Script:WinUIShellMin = [Version]'0.12.0'
$Script:WinUIShellMax = [Version]'0.12.99'
$Script:UrlNunito = 'https://github.com/googlefonts/nunito/raw/main/fonts/variable/Nunito%5Bwght%5D.ttf'
$Script:UrlSono = 'https://github.com/google/fonts/raw/main/ofl/sono/Sono%5BMONO%2Cwght%5D.ttf'
$Script:UrlIcon = 'https://github.com/fwOnion/Log-v1.0/releases/download/ico/new.ico'
$Script:UrlPS7Msi = "https://github.com/PowerShell/PowerShell/releases/download/v$($Script:PS7VersionPin)/PowerShell-$($Script:PS7VersionPin)-win-x64.msi"
$Script:UrlAppSdk = 'https://aka.ms/windowsappsdk/1.6/latest/windowsappruntimeinstall-x64.exe'
$Script:UrlPS7Help = 'https://aka.ms/powershell'
$Script:UrlSdkHelp = 'https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/downloads'
$Script:DataSubdirs = @('patterns','anchors','per-flag-rvas','dumps','profiles')
$Script:BootstrapperNames = @('Roblox','Bloxstrap','Fishstrap','Froststrap','Voidstrap')
$Script:LogEntries = New-Object System.Collections.ArrayList
$Script:Steps = New-Object System.Collections.ArrayList
$Script:Ui = @{}
$Script:GuiMode = $false
$Script:CancelToken = $false
$Script:StepIndex = 0
$Script:StepTimer = $null
$Script:LogSavedPath = $null
$Script:DebugTracePath = $null
$Script:StartTime = Get-Date
function Write-InstallLog {
param(
[Parameter(Mandatory)] [string] $Message,
[ValidateSet('INFO','WARN','ERROR','SUCCESS','PROGRESS')]
[string] $Level = 'INFO',
[int] $StepNumber
)
$ts = Get-Date -Format 'HH:mm:ss'
$stepT = if ($PSBoundParameters.ContainsKey('StepNumber')) { "Step-$StepNumber " } else { '' }
$line = "[$ts] $Level $stepT$Message"
$entry = [PSCustomObject]@{
Time = $ts
Level = $Level
Step = $stepT.Trim()
Message = $Message
Formatted = $line
}
[void]$Script:LogEntries.Add($entry)
if ($Script:GuiMode -and $Script:Ui.LogDoc) {
try {
$para = New-Object Windows.Documents.Paragraph
$para.Margin = New-Object Windows.Thickness(0,0,0,2)
$para.Padding = New-Object Windows.Thickness(0)
$bodyText = "$Level $stepT$Message"
$color = switch ($Level) {
'INFO' { $Script:Theme.Info }
'WARN' { $Script:Theme.Warning }
'ERROR' { $Script:Theme.Error }
'SUCCESS' { $Script:Theme.Success }
'PROGRESS' { $Script:Theme.ForegroundD }
default { $Script:Theme.Foreground }
}
$mono = New-Object Windows.Media.FontFamily($Script:MonoStack)
$tsRun = New-Object Windows.Documents.Run("[$ts] ")
$tsRun.Foreground = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($Script:Theme.ForegroundD))
$tsRun.FontFamily = $mono
$bodyRun = New-Object Windows.Documents.Run($bodyText)
$bodyRun.Foreground = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($color))
$bodyRun.FontFamily = $mono
$para.Inlines.Add($tsRun) | Out-Null
$para.Inlines.Add($bodyRun) | Out-Null
$Script:Ui.LogDoc.Blocks.Add($para)
$Script:Ui.LogScroll.ScrollToEnd()
} catch { }
}
if (-not $Script:GuiMode) {
$fg = switch ($Level) {
'INFO' { 'Gray' }
'WARN' { 'Yellow' }
'ERROR' { 'Red' }
'SUCCESS' { 'Green' }
'PROGRESS' { 'DarkCyan' }
}
if ($Quiet -and $Level -in @('INFO','PROGRESS')) { return }
Write-Host $line -ForegroundColor $fg
}
}
function Save-InstallLogToDisk {
try {
$ts = Get-Date -Format 'yyyyMMddHHmmss'
$path = Join-Path $env:TEMP "Allium-Setup-$ts.log"
$lines = $Script:LogEntries | ForEach-Object { $_.Formatted }
Set-Content -Path $path -Value $lines -Encoding UTF8 -ErrorAction Stop
return $path
} catch {
return $null
}
}
function Write-DebugTrace {
param(
[int] $StepId,
[string] $StepTitle,
[string] $Status,
[double] $DurationMs,
[string] $ErrorMessage
)
if (-not $DebugTrace) { return }
if (-not $Script:DebugTracePath) { return }
try {
$entry = [PSCustomObject]@{
Timestamp = (Get-Date).ToString('o')
StepId = $StepId
StepTitle = $StepTitle
Status = $Status
DurationMs = $DurationMs
Error = $ErrorMessage
}
$json = $entry | ConvertTo-Json -Compress -Depth 3
Add-Content -Path $Script:DebugTracePath -Value $json -ErrorAction SilentlyContinue
} catch { }
}
function Test-IsAdmin {
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$wp = New-Object Security.Principal.WindowsPrincipal($id)
return $wp.IsInRole(544)
}
function Invoke-SelfElevate {
$argList = New-Object System.Collections.ArrayList
[void]$argList.Add('-NoProfile')
[void]$argList.Add('-ExecutionPolicy'); [void]$argList.Add('Bypass')
[void]$argList.Add('-File'); [void]$argList.Add("`"$Script:ScriptPath`"")
foreach ($k in $PSBoundParameters.Keys) {
$v = $PSBoundParameters[$k]
if ($v -is [switch] -and $v.IsPresent) { [void]$argList.Add("-$k") }
elseif ($v -isnot [switch]) { [void]$argList.Add("-$k"); [void]$argList.Add("`"$v`"") }
}
$launcher = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
Write-InstallLog "Relaunching elevated via UAC..." -Level INFO
try {
Start-Process -FilePath $launcher -Verb RunAs -ArgumentList ($argList -join ' ') -ErrorAction Stop
exit 0
} catch [System.ComponentModel.Win32Exception] {
if ($_.Exception.NativeErrorCode -eq 1223) {
Write-InstallLog "UAC prompt cancelled. Administrator rights are required." -Level ERROR
exit 5
}
Write-InstallLog "Relaunch failed: $($_.Exception.Message)" -Level ERROR
exit 5
}
}
function Test-NetworkAvailable {
try {
$req = [Net.WebRequest]::Create('https://aka.ms/')
$req.Timeout = 5000
$req.Method = 'HEAD'
$resp = $req.GetResponse()
$resp.Close()
return $true
} catch { return $false }
}
function Get-FreeDiskGb {
param([string] $Path = $Script:ScriptRoot)
try {
$d = (Get-Item $Path).PSDrive
return [Math]::Round((Get-PSDrive -Name $d.Name).Free / 1GB, 1)
} catch { return -1 }
}
function Format-KbSize {
param([long] $Bytes)
return [Math]::Round($Bytes / 1KB, 1)
}
function Invoke-DownloadWithRetry {
param(
[Parameter(Mandatory)] [string] $Url,
[Parameter(Mandatory)] [string] $OutFile,
[int] $MaxAttempts = 3
)
$attempt = 0
$delay = 2
while ($attempt -lt $MaxAttempts) {
$attempt++
try {
Write-InstallLog "Downloading ($attempt/$MaxAttempts): $Url" -Level PROGRESS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = New-Object System.Net.WebClient
$wc.Headers.Add('User-Agent','Setup-Allium/1.0')
$wc.DownloadFile($Url, $OutFile)
if (Test-Path -LiteralPath $OutFile -PathType Leaf) {
$size = (Get-Item -LiteralPath $OutFile).Length
if ($size -gt 0) {
$kb = Format-KbSize -Bytes $size
Write-InstallLog "Download OK ($kb KB): $OutFile" -Level SUCCESS
return $true
}
Write-InstallLog "Download produced zero-byte file (possible AV quarantine)." -Level WARN
Remove-Item -LiteralPath $OutFile -Force -ErrorAction SilentlyContinue
}
} catch {
Write-InstallLog "Download attempt $attempt failed: $($_.Exception.Message)" -Level WARN
}
if ($attempt -lt $MaxAttempts) {
Start-Sleep -Seconds $delay
$delay *= 2
}
}
return $false
}
function Refresh-Path {
$machineKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
try { $m = (Get-ItemProperty -Path $machineKey -Name Path -ErrorAction Stop).Path } catch { $m = '' }
try { $u = (Get-ItemProperty -Path 'HKCU:\Environment' -Name Path -ErrorAction Stop).Path } catch { $u = '' }
if ($m -and $u) { $env:PATH = "$m;$u" }
elseif ($m) { $env:PATH = $m }
elseif ($u) { $env:PATH = $u }
}
function Get-OsBuildNumber {
try {
$val = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild -ErrorAction Stop).CurrentBuild
return [int]$val
} catch {
return 0
}
}
function Test-Is64BitOs {
if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') { return $true }
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { return $true }
if ($env:PROCESSOR_ARCHITEW6432) { return $true }
return $false
}
function Get-LatestInstalled {
param(
[Parameter(ValueFromPipeline=$true)] $InputObject
)
begin { $items = @() }
process {
if ($null -ne $InputObject) { $items += $InputObject }
}
end {
$items | Sort-Object Version -Descending | Select-Object -First 1
}
}
function Invoke-WingetOrFallback {
param(
[Parameter(Mandatory)] [int] $StepNumber,
[Parameter(Mandatory)] [string] $WingetId,
[Parameter(Mandatory)] [string] $FallbackUrl,
[Parameter(Mandatory)] [string] $FallbackPath,
[Parameter(Mandatory)] [string] $FallbackExe,
[Parameter(Mandatory)] [string[]] $FallbackArgs,
[Parameter(Mandatory)] [string] $FallbackDescription,
[Parameter(Mandatory)] [string] $HelpUrl,
[scriptblock] $PostInstall
)
if (Get-Command winget -EA 0) {
Write-InstallLog "Attempting winget install of $WingetId..." -Level PROGRESS -StepNumber $StepNumber
$wg = Start-Process -FilePath 'winget' -ArgumentList 'install',$WingetId,'--silent','--accept-package-agreements','--accept-source-agreements' -Wait -PassThru -NoNewWindow
if ($wg.ExitCode -eq 0) {
if ($PostInstall) { & $PostInstall }
Write-InstallLog "winget install succeeded." -Level SUCCESS -StepNumber $StepNumber
return
}
Write-InstallLog "winget exited $($wg.ExitCode); falling back to $FallbackDescription." -Level WARN -StepNumber $StepNumber
} else {
Write-InstallLog "winget not present; using $FallbackDescription." -Level INFO -StepNumber $StepNumber
}
if (-not (Invoke-DownloadWithRetry -Url $FallbackUrl -OutFile $FallbackPath)) {
throw "Failed to download $WingetId installer. Manual install: $HelpUrl"
}
Write-InstallLog "Running $FallbackDescription (silent)..." -Level PROGRESS -StepNumber $StepNumber
$rt = Start-Process -FilePath $FallbackExe -ArgumentList $FallbackArgs -Wait -PassThru -NoNewWindow
Remove-Item $FallbackPath -Force -ErrorAction SilentlyContinue
if ($rt.ExitCode -ne 0) {
throw "$FallbackDescription returned exit $($rt.ExitCode). Manual install: $HelpUrl"
}
if ($PostInstall) { & $PostInstall }
Write-InstallLog "$FallbackDescription install OK." -Level SUCCESS -StepNumber $StepNumber
}
function Register-Step {
param(
[Parameter(Mandatory)] [int] $Id,
[Parameter(Mandatory)] [string] $Title,
[Parameter(Mandatory)] [bool] $Critical,
[Parameter(Mandatory)] [scriptblock] $Verify,
[scriptblock] $Action
)
$entry = [PSCustomObject]@{
Id = $Id
Title = $Title
Critical = $Critical
Verify = $Verify
Action = $Action
Status = 'Pending'
Error = $null
UiRow = $null
}
[void]$Script:Steps.Add($entry)
}
function Register-AllSteps {
$Script:Steps.Clear()
Register-Step -Id 1 -Title 'OS Version Check' -Critical $true -Verify {
$build = Get-OsBuildNumber
if ($build -lt 17763) {
throw "Windows 10 1809+ or Windows 11 required. Detected build: $build. Please upgrade Windows."
}
Write-InstallLog "OS build $build OK." -Level SUCCESS -StepNumber 1
return $true
}
Register-Step -Id 2 -Title 'Architecture Check' -Critical $true -Verify {
if (-not (Test-Is64BitOs)) {
throw 'Allium requires 64-bit Windows. Detected 32-bit.'
}
Write-InstallLog "64-bit OS OK." -Level SUCCESS -StepNumber 2
return $true
}
Register-Step -Id 3 -Title 'PowerShell 7.4+ Verify/Install' -Critical $true -Verify {
$cmd = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $cmd) { return $false }
try {
$v = & pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
if ($LASTEXITCODE -eq 0 -and $v -and [Version]$v -ge $Script:PS7MinVersion) {
Write-InstallLog "pwsh $v detected." -Level SUCCESS -StepNumber 3
return $true
}
} catch { }
return $false
} -Action {
$tmp = Join-Path $env:TEMP "PowerShell-$($Script:PS7VersionPin)-win-x64.msi"
Invoke-WingetOrFallback -StepNumber 3 -WingetId 'Microsoft.PowerShell' -FallbackUrl $Script:UrlPS7Msi -FallbackPath $tmp -FallbackExe 'msiexec.exe' -FallbackArgs @('/i',"`"$tmp`"",'/quiet','ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1','REGISTER_MANIFEST=1') -FallbackDescription 'PowerShell 7 MSI (msiexec)' -HelpUrl $Script:UrlPS7Help -PostInstall { Refresh-Path }
}
Register-Step -Id 4 -Title 'Windows App SDK Runtime 1.6+' -Critical $true -Verify {
$pkg = Get-AppxPackage "$($Script:AppSdkPkgPrefix)*" -ErrorAction SilentlyContinue | Get-LatestInstalled
if ($pkg) {
Write-InstallLog "WindowsAppRuntime $($pkg.Version) detected." -Level SUCCESS -StepNumber 4
return $true
}
return $false
} -Action {
$tmp = Join-Path $env:TEMP 'WindowsAppRuntimeInstall-x64.exe'
Invoke-WingetOrFallback -StepNumber 4 -WingetId $Script:AppSdkPkgPrefix -FallbackUrl $Script:UrlAppSdk -FallbackPath $tmp -FallbackExe $tmp -FallbackArgs @('--quiet') -FallbackDescription 'WindowsAppRuntimeInstall.exe' -HelpUrl $Script:UrlSdkHelp
}
Register-Step -Id 5 -Title 'PSResourceGet Availability' -Critical $true -Verify {
$mod = Get-Module -ListAvailable -Name Microsoft.PowerShell.PSResourceGet -ErrorAction SilentlyContinue | Get-LatestInstalled
if ($mod -and $mod.Version -ge [Version]'1.0.0') {
Write-InstallLog "PSResourceGet $($mod.Version) detected." -Level SUCCESS -StepNumber 5
return $true
}
return $false
} -Action {
try {
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$nugetProv = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue | Get-LatestInstalled
if (-not $nugetProv -or $nugetProv.Version -lt [Version]'2.8.5.201') {
Write-InstallLog "Bootstrapping NuGet provider (silent, no prompt)..." -Level PROGRESS -StepNumber 5
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ForceBootstrap -Confirm:$false -Scope AllUsers | Out-Null
Write-InstallLog "NuGet provider bootstrapped." -Level SUCCESS -StepNumber 5
}
Import-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue | Out-Null
} catch {
Write-InstallLog "NuGet bootstrap warning (continuing): $($_.Exception.Message)" -Level WARN -StepNumber 5
}
try {
$repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if ($repo -and $repo.InstallationPolicy -ne 'Trusted') {
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-InstallLog "PSGallery marked Trusted." -Level INFO -StepNumber 5
}
} catch { }
Write-InstallLog "Installing Microsoft.PowerShell.PSResourceGet (AllUsers)..." -Level PROGRESS -StepNumber 5
Install-Module -Name Microsoft.PowerShell.PSResourceGet -Repository PSGallery -Scope AllUsers -Force -AllowClobber -Confirm:$false -ErrorAction Stop
Write-InstallLog "PSResourceGet installed." -Level SUCCESS -StepNumber 5
}
Register-Step -Id 6 -Title 'Execution Policy' -Critical $true -Verify {
$p = Get-ExecutionPolicy -Scope CurrentUser
if ($p -in @('Unrestricted','Bypass')) {
Write-InstallLog "Execution policy = $p." -Level SUCCESS -StepNumber 6
return $true
}
return $false
} -Action {
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
Write-InstallLog "Execution policy set to Unrestricted (CurrentUser)." -Level SUCCESS -StepNumber 6
}
Register-Step -Id 7 -Title 'WinUIShell Module' -Critical $true -Verify {
try {
$probe = & pwsh -NoProfile -Command @"
Import-Module Microsoft.PowerShell.PSResourceGet -ErrorAction SilentlyContinue
`$r = Get-InstalledPSResource -Name WinUIShell -Scope AllUsers -ErrorAction SilentlyContinue |
    Sort-Object Version -Descending | Select-Object -First 1
if (`$r) { `$r.Version.ToString() } else { '' }
"@ 2>$null
if ($probe -and [Version]$probe -ge $Script:WinUIShellMin) {
Write-InstallLog "WinUIShell $probe detected." -Level SUCCESS -StepNumber 7
if ([Version]$probe -gt $Script:WinUIShellMax) {
Write-InstallLog "WinUIShell $probe is newer than max tested ($($Script:WinUIShellMax)). If Allium fails to launch, downgrade via: Install-PSResource -Name WinUIShell -Version '$($Script:WinUIShellMax)'" -Level WARN -StepNumber 7
}
return $true
}
} catch { }
return $false
} -Action {
$rangeSpec = "[$($Script:WinUIShellMin),)"
Write-InstallLog "Installing WinUIShell via PSResourceGet (Version $rangeSpec, AllUsers)..." -Level PROGRESS -StepNumber 7
$inst = & pwsh -NoProfile -Command @"
Import-Module Microsoft.PowerShell.PSResourceGet -ErrorAction Stop
Install-PSResource -Name WinUIShell -Version '$rangeSpec' -Scope AllUsers -TrustRepository -Repository PSGallery -ErrorAction Stop
"@ 2>&1
if ($LASTEXITCODE -ne 0) {
throw "Install-PSResource WinUIShell failed. Manual: Install-PSResource -Name WinUIShell -Scope AllUsers -TrustRepository`nDetails: $inst"
}
Write-InstallLog "WinUIShell installed." -Level SUCCESS -StepNumber 7
}
Register-Step -Id 8 -Title 'ZstdSharp Assembly Bootstrap' -Critical $true -Verify {
$depsDir = Join-Path $Script:DataRoot 'deps'
$dllPath = Join-Path $depsDir 'ZstdSharp.dll'
if (-not (Test-Path $dllPath -PathType Leaf)) { return $false }
try {
$null = [Reflection.AssemblyName]::GetAssemblyName($dllPath)
Write-InstallLog "ZstdSharp.dll detected at $dllPath." -Level SUCCESS -StepNumber 8
return $true
} catch {
Write-InstallLog "ZstdSharp.dll present but invalid: $($_.Exception.Message). Will re-download." -Level WARN -StepNumber 8
return $false
}
} -Action {
$depsDir = Join-Path $Script:DataRoot 'deps'
$dllPath = Join-Path $depsDir 'ZstdSharp.dll'
$nupkgVersion = '0.8.8'
$nupkgUrl = "https://api.nuget.org/v3-flatcontainer/zstdsharp.port/$nupkgVersion/zstdsharp.port.$nupkgVersion.nupkg"
if (-not (Test-Path $depsDir)) {
New-Item -Path $depsDir -ItemType Directory -Force | Out-Null
}
$tempNupkg = Join-Path $env:TEMP "zstdsharp.port.$nupkgVersion.nupkg"
Write-InstallLog "Downloading ZstdSharp.Port $nupkgVersion from NuGet..." -Level PROGRESS -StepNumber 8
$ok = Invoke-DownloadWithRetry -Url $nupkgUrl -OutFile $tempNupkg -MaxAttempts 3
if (-not $ok) {
throw "ZstdSharp.Port .nupkg download failed after retries. Check network / firewall for api.nuget.org."
}
Write-InstallLog "Extracting ZstdSharp.dll from nupkg..." -Level PROGRESS -StepNumber 8
Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
$tempExtract = Join-Path $env:TEMP "zstdsharp_extract_$([guid]::NewGuid().ToString('N'))"
try {
[System.IO.Compression.ZipFile]::ExtractToDirectory($tempNupkg, $tempExtract)
$dllSrc = Get-ChildItem -Path $tempExtract -Filter 'ZstdSharp.dll' -Recurse -File -ErrorAction SilentlyContinue |
Where-Object { $_.FullName -match '[\\/]lib[\\/]netstandard2\.0[\\/]' } |
Select-Object -First 1
if (-not $dllSrc) {
$dllSrc = Get-ChildItem -Path $tempExtract -Filter 'ZstdSharp.dll' -Recurse -File -ErrorAction SilentlyContinue |
Select-Object -First 1
}
if (-not $dllSrc) {
throw "ZstdSharp.dll not found inside extracted nupkg. NuGet package structure may have changed."
}
Copy-Item -LiteralPath $dllSrc.FullName -Destination $dllPath -Force
$null = [Reflection.AssemblyName]::GetAssemblyName($dllPath)
Write-InstallLog "ZstdSharp.dll installed to $dllPath." -Level SUCCESS -StepNumber 8
} finally {
Remove-Item -LiteralPath $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $tempNupkg -Force -ErrorAction SilentlyContinue
}
}
Register-Step -Id 9 -Title 'Nunito Font Install' -Critical $false -Verify {
if ($SkipFont) {
Write-InstallLog "SkipFont set; skipping Nunito." -Level INFO -StepNumber 9
return $true
}
$fontFile = Join-Path $env:WINDIR 'Fonts\Nunito-VariableFont_wght.ttf'
if (Test-Path $fontFile -PathType Leaf) {
$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
$reg = Get-ItemProperty -Path $regPath -Name 'Nunito (TrueType)' -ErrorAction SilentlyContinue
if ($reg) {
Write-InstallLog "Nunito already installed." -Level SUCCESS -StepNumber 9
return $true
}
}
return $false
} -Action {
$fontDir = Join-Path $env:WINDIR 'Fonts'
if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Force -Path $fontDir | Out-Null }
$tmp = Join-Path $env:TEMP 'Nunito-VariableFont_wght.ttf'
if (-not (Invoke-DownloadWithRetry -Url $Script:UrlNunito -OutFile $tmp)) {
throw 'Nunito font download failed. Allium will fall back to Segoe UI.'
}
$destFile = Join-Path $fontDir 'Nunito-VariableFont_wght.ttf'
Copy-Item -Path $tmp -Destination $destFile -Force
Remove-Item $tmp -Force -ErrorAction SilentlyContinue
$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
New-ItemProperty -Path $regPath -Name 'Nunito (TrueType)' -PropertyType String -Value 'Nunito-VariableFont_wght.ttf' -Force | Out-Null
Add-InteropTypes
[Allium.Setup.FontBroadcast]::Notify()
Write-InstallLog "Nunito installed and WM_FONTCHANGE broadcast." -Level SUCCESS -StepNumber 9
}
Register-Step -Id 10 -Title 'Sono Font Install' -Critical $false -Verify {
if ($SkipFont) {
Write-InstallLog "SkipFont set; skipping Sono." -Level INFO -StepNumber 10
return $true
}
$fontFile = Join-Path $env:WINDIR 'Fonts\Sono[MONO,wght].ttf'
if (Test-Path -LiteralPath $fontFile -PathType Leaf) {
$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
$reg = Get-ItemProperty -Path $regPath -Name 'Sono (TrueType)' -ErrorAction SilentlyContinue
if ($reg) {
Write-InstallLog "Sono already installed." -Level SUCCESS -StepNumber 10
return $true
}
}
return $false
} -Action {
$fontDir = Join-Path $env:WINDIR 'Fonts'
if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Force -Path $fontDir | Out-Null }
$tmp = Join-Path $env:TEMP 'Sono[MONO,wght].ttf'
if (-not (Invoke-DownloadWithRetry -Url $Script:UrlSono -OutFile $tmp)) {
throw 'Sono font download failed. Allium will fall back to Cascadia Mono.'
}
$destFile = Join-Path $fontDir 'Sono[MONO,wght].ttf'
Copy-Item -LiteralPath $tmp -Destination $destFile -Force
Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
New-ItemProperty -Path $regPath -Name 'Sono (TrueType)' -PropertyType String -Value 'Sono[MONO,wght].ttf' -Force | Out-Null
Add-InteropTypes
[Allium.Setup.FontBroadcast]::Notify()
Write-InstallLog "Sono installed and WM_FONTCHANGE broadcast." -Level SUCCESS -StepNumber 10
}
Register-Step -Id 11 -Title 'Data Folder Tree Creation' -Critical $false -Verify {
$dataRoot = $Script:DataRoot
if (-not (Test-Path $dataRoot)) { return $false }
foreach ($sd in $Script:DataSubdirs) {
if (-not (Test-Path (Join-Path $dataRoot $sd))) { return $false }
}
Write-InstallLog "Data tree present." -Level SUCCESS -StepNumber 11
return $true
} -Action {
$dataRoot = $Script:DataRoot
New-Item -Path $dataRoot -ItemType Directory -Force | Out-Null
foreach ($sd in $Script:DataSubdirs) {
New-Item -Path (Join-Path $dataRoot $sd) -ItemType Directory -Force | Out-Null
}
Write-InstallLog "Data tree ensured under $dataRoot." -Level SUCCESS -StepNumber 11
}
Register-Step -Id 12 -Title 'Zone.Identifier Unblock' -Critical $false -Verify {
$blocked = Get-ChildItem -Path $Script:ScriptRoot -Recurse -File -Include *.ps1,*.ps1xml,*.psm1,*.psd1,*.dll -ErrorAction SilentlyContinue |
Where-Object {
Get-Item $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue
} | Select-Object -First 1
if (-not $blocked) {
Write-InstallLog "No Zone.Identifier streams found." -Level SUCCESS -StepNumber 12
return $true
}
return $false
} -Action {
Get-ChildItem -Path $Script:ScriptRoot -Recurse -File -Include *.ps1,*.ps1xml,*.psm1,*.psd1,*.dll -ErrorAction SilentlyContinue |
Unblock-File -ErrorAction SilentlyContinue
Unblock-File -Path $Script:ScriptPath -ErrorAction SilentlyContinue
Write-InstallLog "Zone.Identifier ADS removed from Allium files." -Level SUCCESS -StepNumber 12
}
Register-Step -Id 13 -Title 'Write Permissions Preflight' -Critical $false -Verify {
$dataRoot = $Script:DataRoot
if (-not (Test-Path $dataRoot)) {
try { New-Item -Path $dataRoot -ItemType Directory -Force | Out-Null } catch { return $false }
}
$probe = Join-Path $dataRoot ".write-test-$PID"
try {
Set-Content -Path $probe -Value 'ok' -Force
Remove-Item $probe -Force
Write-InstallLog "Write test OK." -Level SUCCESS -StepNumber 13
return $true
} catch {
Write-InstallLog "Data folder not writable: $($_.Exception.Message). Move Allium to a location where you have write permissions." -Level WARN -StepNumber 13
return $false
}
}
Register-Step -Id 14 -Title 'Bootstrapper Detection' -Critical $false -Verify {
$found = @()
foreach ($name in $Script:BootstrapperNames) {
$p = Join-Path $env:LOCALAPPDATA "$name\Versions"
if (Test-Path $p) { $found += $name }
}
if ($found.Count -gt 0) {
Write-InstallLog "Detected bootstrappers: $($found -join ', ')" -Level SUCCESS -StepNumber 14
} else {
Write-InstallLog "No bootstrappers detected. Install Roblox or a bootstrapper before launching Allium." -Level WARN -StepNumber 14
}
return $true
}
Register-Step -Id 15 -Title 'Settings Health Check' -Critical $false -Verify {
$settingsPath = $Script:SettingsPath
if (-not (Test-Path $settingsPath)) {
Write-InstallLog "No existing settings.json; Allium will generate on first launch." -Level SUCCESS -StepNumber 15
return $true
}
try {
$raw = Get-Content -Path $settingsPath -Raw -ErrorAction Stop
$obj = $raw | ConvertFrom-Json -ErrorAction Stop
if (-not ($obj.PSObject.Properties.Name -contains 'schemaVersion')) {
Write-InstallLog "settings.json missing schemaVersion key (may be pre-v1). Allium will migrate." -Level WARN -StepNumber 15
} else {
Write-InstallLog "settings.json parses OK (schemaVersion=$($obj.schemaVersion))." -Level SUCCESS -StepNumber 15
}
return $true
} catch {
$bak = "$settingsPath.corrupt-$(Get-Date -Format 'yyyyMMddHHmmss')"
Move-Item -Path $settingsPath -Destination $bak -Force
Write-InstallLog "settings.json corrupt; backed up to $bak. Allium will regenerate defaults." -Level WARN -StepNumber 15
return $false
}
}
Register-Step -Id 16 -Title 'Final Summary' -Critical $false -Verify {
$crit = $Script:Steps | Where-Object { $_.Critical -and $_.Id -lt 16 }
$passed = ($crit | Where-Object { $_.Status -in @('Success','Skipped') }).Count
$failed = ($crit | Where-Object { $_.Status -eq 'Failed' }).Count
$warned = ($Script:Steps | Where-Object { $_.Status -eq 'Warning' }).Count
Write-InstallLog "Summary: $passed/$($crit.Count) critical passed, $failed failed, $warned warnings." -Level SUCCESS -StepNumber 16
return $true
}
}
function Set-StepStatus {
param($Step, [string]$Status)
$Step.Status = $Status
if ($Script:GuiMode -and $Step.UiRow) {
try {
Update-StepRowVisual -Row $Step.UiRow -Status $Status
Update-Progress
} catch { }
}
if ($Script:GuiMode -and $Script:Ui.Window) {
try {
if ($Status -eq 'Running') {
$Script:Ui.Window.Cursor = [System.Windows.Input.Cursors]::Wait
} else {
$Script:Ui.Window.Cursor = $null
}
} catch { }
}
}
function Update-Progress {
if (-not $Script:Ui.ProgressBar) { return }
$total = $Script:Steps.Count
$finished = ($Script:Steps | Where-Object { $_.Status -in @('Success','Warning','Failed','Skipped') }).Count
$pct = if ($total -gt 0) { ($finished / $total) * 100 } else { 0 }
$pbar = $Script:Ui.ProgressBar
try {
$anim = New-Object System.Windows.Media.Animation.DoubleAnimation
$anim.From = [double]$pbar.Value
$anim.To = [double]$pct
$dur = New-Object TimeSpan -ArgumentList 0,0,0,0,200
$anim.Duration = New-Object Windows.Duration($dur)
$anim.FillBehavior = 'Stop'
$pbar.BeginAnimation([System.Windows.Controls.ProgressBar]::ValueProperty, $anim)
$pbar.Value = $pct
} catch {
$pbar.Value = $pct
}
$pctInt = [int]($pct + 0.5)
$Script:Ui.ProgressLabel.Content = "$pctInt%"
$crit = $Script:Steps | Where-Object { $_.Critical }
$allOk = ($crit.Count -gt 0) -and (($crit | Where-Object { $_.Status -eq 'Success' }).Count -eq $crit.Count)
$anyRun = ($Script:Steps | Where-Object { $_.Status -in @('Running','Pending') }).Count -gt 0
$Script:Ui.LaunchButton.IsEnabled = ($allOk -and -not $anyRun)
$firstFailedCritical = $Script:Steps |
Where-Object { $_.Critical -and $_.Status -eq 'Failed' } |
Select-Object -First 1
if ($firstFailedCritical) {
if ($Script:Ui.ErrorBanner) {
try {
$Script:Ui.ErrorBanner.Visibility = 'Visible'
if ($Script:Ui.ErrorBannerText) {
$Script:Ui.ErrorBannerText.Text = "Step $($firstFailedCritical.Id) ($($firstFailedCritical.Title)) failed. See log for details."
}
} catch { }
}
if (-not $Script:LogSavedPath) {
$Script:LogSavedPath = Save-InstallLogToDisk
if ($Script:LogSavedPath) {
Write-InstallLog "Full install log saved to: $Script:LogSavedPath" -Level INFO
}
}
} else {
if ($Script:Ui.ErrorBanner) {
try { $Script:Ui.ErrorBanner.Visibility = 'Collapsed' } catch { }
}
}
try {
if ($anyRun) {
$Script:Ui.LaunchButton.ToolTip = 'Installation in progress...'
} elseif ($firstFailedCritical) {
$Script:Ui.LaunchButton.ToolTip = "Cannot launch: Step $($firstFailedCritical.Id) ($($firstFailedCritical.Title)) failed. See log."
} elseif (-not $allOk) {
$Script:Ui.LaunchButton.ToolTip = 'Waiting for setup to complete...'
} else {
$Script:Ui.LaunchButton.ToolTip = $null
}
} catch { }
}
function Invoke-Step {
param([Parameter(Mandatory)] $Step)
$stepStart = Get-Date
try {
if ($Script:CancelToken) { $Step.Status = 'Failed'; return }
Set-StepStatus -Step $Step -Status 'Running'
Write-InstallLog "$($Step.Title): starting..." -Level INFO -StepNumber $Step.Id
if (-not $Force) {
try {
$vr = & $Step.Verify
if ($vr) {
Set-StepStatus -Step $Step -Status 'Success'
return
}
} catch {
Write-InstallLog "Verify threw: $($_.Exception.Message)" -Level WARN -StepNumber $Step.Id
}
}
if (-not $Step.Action) {
if ($Step.Critical) {
Set-StepStatus -Step $Step -Status 'Failed'
$Step.Error = 'Verify failed and step has no Action to install.'
Write-InstallLog $Step.Error -Level ERROR -StepNumber $Step.Id
} else {
Set-StepStatus -Step $Step -Status 'Warning'
}
return
}
$attempt = 0
$lastError = $null
while ($attempt -lt 3) {
$attempt++
try {
& $Step.Action
$vr2 = & $Step.Verify
if ($vr2) {
Set-StepStatus -Step $Step -Status 'Success'
return
}
$lastError = 'Post-install verify still failed.'
} catch {
$lastError = $_.Exception.Message
Write-InstallLog "Attempt $attempt failed: $lastError" -Level WARN -StepNumber $Step.Id
}
if ($attempt -lt 3) { Start-Sleep -Seconds 2 }
}
$Step.Error = $lastError
if ($Step.Critical) {
Set-StepStatus -Step $Step -Status 'Failed'
Write-InstallLog "CRITICAL FAILURE: $lastError" -Level ERROR -StepNumber $Step.Id
} else {
Set-StepStatus -Step $Step -Status 'Warning'
Write-InstallLog "Non-critical warning: $lastError" -Level WARN -StepNumber $Step.Id
}
} finally {
$elapsed = (Get-Date) - $stepStart
Write-DebugTrace -StepId $Step.Id -StepTitle $Step.Title -Status ([string]$Step.Status) -DurationMs ([double]$elapsed.TotalMilliseconds) -ErrorMessage ([string]$Step.Error)
}
}
function Run-AllSteps {
foreach ($s in $Script:Steps) {
if ($Script:CancelToken) { break }
Invoke-Step -Step $s
if ($s.Status -eq 'Failed' -and $s.Critical) {
Write-InstallLog "Halting: critical step $($s.Id) failed." -Level ERROR
break
}
}
}
function Add-InteropTypes {
if ('Allium.Setup.BackdropV16' -as [type]) { return }
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace Allium.Setup {
    public static class FontBroadcast {
        private const uint WM_FONTCHANGE  = 0x001D;
        private static readonly IntPtr HWND_BROADCAST = (IntPtr)0xFFFF;
        private const uint SMTO_ABORTIFHUNG = 0x0002;
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr SendMessageTimeout(
            IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam,
            uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
        public static void Notify() {
            UIntPtr r;
            SendMessageTimeout(HWND_BROADCAST, WM_FONTCHANGE,
                UIntPtr.Zero, IntPtr.Zero, SMTO_ABORTIFHUNG, 3000, out r);
        }
    }
    public static class TitleBar {
        [DllImport("dwmapi.dll", PreserveSig = true)]
        private static extern int DwmSetWindowAttribute(
            IntPtr hwnd, int attr, ref int attrValue, int attrSize);
        public static void EnableDarkMode(IntPtr hwnd) {
            int useDark = 1;
            int hr = DwmSetWindowAttribute(hwnd, 20, ref useDark, 4);
            if (hr != 0) {
                DwmSetWindowAttribute(hwnd, 19, ref useDark, 4);
            }
        }
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct MARGINS {
        public int cxLeftWidth;
        public int cxRightWidth;
        public int cyTopHeight;
        public int cyBottomHeight;
    }

    public static class TaskbarIcon {
        private const uint WM_SETICON = 0x0080;
        private const int  ICON_SMALL = 0;
        private const int  ICON_BIG   = 1;

        private const uint IMAGE_ICON       = 1;
        private const uint LR_LOADFROMFILE  = 0x00000010;
        private const uint LR_DEFAULTSIZE   = 0x00000040;

        [DllImport("shell32.dll", CharSet = CharSet.Unicode, PreserveSig = true)]
        private static extern int SetCurrentProcessExplicitAppUserModelID(
            [MarshalAs(UnmanagedType.LPWStr)] string AppID);

        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern IntPtr LoadImage(
            IntPtr hInst, string lpszName, uint uType,
            int cxDesired, int cyDesired, uint fuLoad);

        [DllImport("user32.dll")]
        private static extern IntPtr SendMessage(
            IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        public static void SetAppId(string appId) {
            try {
                SetCurrentProcessExplicitAppUserModelID(appId);
            } catch {
            }
        }

        public static bool ApplyIcon(IntPtr hwnd, string icoPath) {
            if (hwnd == IntPtr.Zero) return false;
            if (string.IsNullOrEmpty(icoPath)) return false;

            IntPtr hSmall = LoadImage(IntPtr.Zero, icoPath, IMAGE_ICON,
                16, 16, LR_LOADFROMFILE);
            IntPtr hLarge = LoadImage(IntPtr.Zero, icoPath, IMAGE_ICON,
                32, 32, LR_LOADFROMFILE);

            bool ok = false;
            if (hSmall != IntPtr.Zero) {
                SendMessage(hwnd, WM_SETICON, (IntPtr)ICON_SMALL, hSmall);
                ok = true;
            }
            if (hLarge != IntPtr.Zero) {
                SendMessage(hwnd, WM_SETICON, (IntPtr)ICON_BIG, hLarge);
                ok = true;
            }
            return ok;
        }
    }
    public static class BackdropV16 {
        private const int DWMWA_SYSTEMBACKDROP_TYPE = 38;

        [DllImport("dwmapi.dll", PreserveSig = true)]
        private static extern int DwmSetWindowAttribute(
            IntPtr hwnd, int attr, ref int attrValue, int attrSize);

        [DllImport("dwmapi.dll", PreserveSig = true)]
        private static extern int DwmExtendFrameIntoClientArea(
            IntPtr hwnd, ref MARGINS pMarInset);

        public static bool EnableBackdrop(IntPtr hwnd, int backdropType) {
            int t = backdropType;
            int hr = DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, ref t, 4);
            if (hr != 0) {
                return false;
            }
            MARGINS m = new MARGINS();
            m.cxLeftWidth   = -1;
            m.cxRightWidth  = -1;
            m.cyTopHeight   = -1;
            m.cyBottomHeight = -1;
            DwmExtendFrameIntoClientArea(hwnd, ref m);
            return true;
        }
    }
}
'@ -Language CSharp
}
$Script:XamlGui = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Allium Setup" Height="560" Width="800"
        MinHeight="480" MinWidth="640"
        WindowStartupLocation="CenterScreen"
        Background="#191919" Foreground="#EEEEEE"
        FontFamily="Segoe UI" FontSize="12"
        WindowStyle="SingleBorderWindow"
        AllowsTransparency="False" ResizeMode="CanResize">
    <Window.Resources>
        <SolidColorBrush x:Key="AccentBrush"      Color="#7B2E3F"/>
        <SolidColorBrush x:Key="AccentHoverBrush" Color="#8F3A4C"/>
        <SolidColorBrush x:Key="SurfaceBrush"     Color="#212121"/>
        <SolidColorBrush x:Key="BorderBrushX"     Color="#383838"/>
        <SolidColorBrush x:Key="FgBrush"          Color="#EEEEEE"/>
        <SolidColorBrush x:Key="FgDimBrush"       Color="#EEEEEE"/>
        <SolidColorBrush x:Key="ThumbBrush"       Color="#555555"/>
        <SolidColorBrush x:Key="ThumbHoverBrush"  Color="#777777"/>
        <SolidColorBrush x:Key="NeutralHoverBrush" Color="#2d2d2d"/>

        <Style x:Key="HiddenRepeatButton" TargetType="{x:Type RepeatButton}">
            <Setter Property="OverridesDefaultStyle" Value="True"/>
            <Setter Property="Focusable" Value="False"/>
            <Setter Property="IsTabStop" Value="False"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type RepeatButton}">
                        <Border Background="Transparent"/>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SlimScrollBarThumb" TargetType="{x:Type Thumb}">
            <Setter Property="OverridesDefaultStyle" Value="True"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type Thumb}">
                        <Border x:Name="ThumbBd" Margin="2,0,2,0"
                                Background="{StaticResource ThumbBrush}"
                                CornerRadius="3"/>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ThumbBd" Property="Background" Value="{StaticResource ThumbHoverBrush}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="{x:Type ScrollBar}">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Width" Value="10"/>
            <Setter Property="MinWidth" Value="10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type ScrollBar}">
                        <Grid Background="{TemplateBinding Background}">
                            <Track x:Name="PART_Track" IsDirectionReversed="True">
                                <Track.DecreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.PageUpCommand" Style="{StaticResource HiddenRepeatButton}"/>
                                </Track.DecreaseRepeatButton>
                                <Track.Thumb>
                                    <Thumb Style="{StaticResource SlimScrollBarThumb}"/>
                                </Track.Thumb>
                                <Track.IncreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.PageDownCommand" Style="{StaticResource HiddenRepeatButton}"/>
                                </Track.IncreaseRepeatButton>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button">
            <Setter Property="Background" Value="{StaticResource SurfaceBrush}"/>
            <Setter Property="Foreground" Value="{StaticResource FgBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrushX}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="Width"  Value="120"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" CornerRadius="8" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{StaticResource NeutralHoverBrush}"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="AccentButton" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
            <Setter Property="Background" Value="{StaticResource AccentBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource AccentBrush}"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" CornerRadius="8" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{StaticResource AccentHoverBrush}"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ProgressBar">
            <Setter Property="Foreground" Value="{StaticResource AccentBrush}"/>
            <Setter Property="Background" Value="{StaticResource SurfaceBrush}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Height" Value="14"/>
        </Style>
    </Window.Resources>

    <DockPanel>
        <Border DockPanel.Dock="Top" Background="{StaticResource SurfaceBrush}" Padding="16,10">
            <StackPanel Orientation="Horizontal">
                <TextBlock Text="Allium Setup" FontSize="14" FontWeight="SemiBold"
                           Foreground="{StaticResource FgBrush}"/>
                <TextBlock Text="  v1.0.0  " FontSize="11" VerticalAlignment="Center"
                           Foreground="{StaticResource FgDimBrush}"/>
            </StackPanel>
        </Border>

        <Border Name="ErrorBanner" DockPanel.Dock="Top"
                Background="#33E53935" BorderBrush="#E53935"
                BorderThickness="0,0,0,1" Padding="16,8"
                Visibility="Collapsed">
            <StackPanel Orientation="Horizontal">
                <TextBlock Text="Error" FontWeight="SemiBold" FontSize="12"
                           VerticalAlignment="Center"
                           Foreground="#E53935" Margin="0,0,10,0"/>
                <TextBlock Name="ErrorBannerText" VerticalAlignment="Center"
                           Foreground="#EEEEEE" TextWrapping="Wrap"/>
            </StackPanel>
        </Border>

        <Border DockPanel.Dock="Bottom" Background="{StaticResource SurfaceBrush}" Padding="16,10">
            <Grid>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button Name="BtnLaunch" Content="Launch Allium" Style="{StaticResource AccentButton}"
                            IsEnabled="False" Margin="0,0,8,0"
                            ToolTipService.ShowOnDisabled="True"/>
                    <Button Name="BtnCancel" Content="Cancel"/>
                </StackPanel>
            </Grid>
        </Border>

        <Border DockPanel.Dock="Bottom" Background="{StaticResource SurfaceBrush}" Padding="16,8">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <ProgressBar Name="MainProgress" Grid.Column="0" Minimum="0" Maximum="100" Value="0"/>
                <Label Name="ProgressLabel" Grid.Column="1" Content="0%" Margin="8,0,0,0"
                       Foreground="{StaticResource FgDimBrush}" Padding="0"/>
            </Grid>
        </Border>

        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="320"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <ScrollViewer Grid.Column="0" VerticalScrollBarVisibility="Hidden"
                          Background="{StaticResource SurfaceBrush}">
                <StackPanel Name="StepList" Margin="8"/>
            </ScrollViewer>

            <Border Grid.Column="1" Background="#901A1A1A" BorderBrush="{StaticResource BorderBrushX}"
                    BorderThickness="1,0,0,0">
                <ScrollViewer Name="LogScroll" VerticalScrollBarVisibility="Auto" Margin="4">
                    <RichTextBox Name="LogBox" IsReadOnly="True" Background="Transparent"
                                 Foreground="{StaticResource FgBrush}"
                                 BorderThickness="0"
                                 FontFamily="Cascadia Code, Consolas, Courier New"
                                 FontSize="11"
                                 IsUndoEnabled="False"
                                 VerticalScrollBarVisibility="Disabled"
                                 HorizontalScrollBarVisibility="Disabled">
                        <FlowDocument Name="LogDoc" PageWidth="2000"/>
                    </RichTextBox>
                </ScrollViewer>
            </Border>
        </Grid>
    </DockPanel>
</Window>
"@
function Get-AlliumIcon {
$cache = Join-Path $env:TEMP 'Allium-Setup-icon.ico'
if (-not (Test-Path $cache -PathType Leaf) -or (Get-Item $cache).Length -eq 0) {
try {
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = New-Object System.Net.WebClient
$wc.Headers.Add('User-Agent','Setup-Allium/1.4')
$wc.DownloadFile($Script:UrlIcon, $cache)
} catch {
Write-InstallLog "Icon download failed: $($_.Exception.Message). Falling back to default." -Level WARN
return $null
}
}
$Script:AlliumIconPath = $cache
try {
$uri = New-Object System.Uri($cache)
$bmp = [System.Windows.Media.Imaging.BitmapFrame]::Create(
$uri,
[System.Windows.Media.Imaging.BitmapCreateOptions]::None,
[System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
return $bmp
} catch {
Write-InstallLog "Icon decode failed: $($_.Exception.Message)." -Level WARN
return $null
}
}
function Test-WpfAvailable {
try {
Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
Add-Type -AssemblyName PresentationCore -ErrorAction Stop
Add-Type -AssemblyName WindowsBase -ErrorAction Stop
Add-Type -AssemblyName System.Xaml -ErrorAction Stop
return $true
} catch {
Write-InstallLog "WPF assemblies unavailable: $($_.Exception.Message). Falling back to console." -Level WARN
return $false
}
}
function New-StepRow {
param($Step)
$border = New-Object Windows.Controls.Border
$border.Padding = New-Object Windows.Thickness(10,4,10,4)
$border.Margin = New-Object Windows.Thickness(0,0,0,2)
$border.Background = [System.Windows.Media.Brushes]::Transparent
$border.CornerRadius = New-Object Windows.CornerRadius(6)
$border.Tag = 'Pending'
$border.Add_MouseEnter({
try {
$this.Background = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($Script:Theme.HoverBg))
} catch { }
})
$border.Add_MouseLeave({
try {
if ($this.Tag -eq 'Running') {
$this.Background = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($Script:Theme.RunningTint))
} else {
$this.Background = [System.Windows.Media.Brushes]::Transparent
}
} catch { }
})
$sp = New-Object Windows.Controls.StackPanel
$sp.Orientation = 'Horizontal'
$sp.Height = 20
$icon = New-Object Windows.Controls.TextBlock
$icon.Text = [char]0x25CB
$icon.Width = 20
$icon.FontSize = 14
$icon.VerticalAlignment = 'Center'
$icon.Foreground = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($Script:Theme.ForegroundD))
$title = New-Object Windows.Controls.TextBlock
$title.Text = "Step $($Step.Id): $($Step.Title)"
$title.Margin = New-Object Windows.Thickness(8,0,0,0)
$title.VerticalAlignment = 'Center'
$title.Foreground = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($Script:Theme.Foreground))
$sp.Children.Add($icon) | Out-Null
$sp.Children.Add($title) | Out-Null
$border.Child = $sp
return @{ Root = $border; Icon = $icon; Title = $title }
}
function Update-StepRowVisual {
param($Row, [string]$Status)
$glyph = switch ($Status) {
'Pending' { [char]0x25CB }
'Running' { [char]0x21BB }
'Success' { [char]0x2713 }
'Skipped' { [char]0x2713 }
'Warning' { [char]0x26A0 }
'Failed' { [char]0x2717 }
default { [char]0x25CB }
}
$color = switch ($Status) {
'Pending' { $Script:Theme.ForegroundD }
'Running' { $Script:Theme.Info }
'Success' { $Script:Theme.Success }
'Skipped' { $Script:Theme.Success }
'Warning' { $Script:Theme.Warning }
'Failed' { $Script:Theme.Error }
default { $Script:Theme.Foreground }
}
$Row.Icon.Text = $glyph
$Row.Icon.Foreground = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($color))
if ($Row.Root) {
$Row.Root.Tag = $Status
try {
if ($Status -eq 'Running') {
$Row.Root.Background = New-Object Windows.Media.SolidColorBrush(
[Windows.Media.ColorConverter]::ConvertFromString($Script:Theme.RunningTint))
} else {
$Row.Root.Background = [System.Windows.Media.Brushes]::Transparent
}
} catch { }
}
}
function Start-AsyncSteps {
$Script:StepIndex = 0
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = New-Object TimeSpan -ArgumentList 0,0,0,0,50
$Script:StepTimer = $timer
$timer.Add_Tick({
if ($Script:CancelToken) {
$this.Stop()
return
}
if ($Script:StepIndex -ge $Script:Steps.Count) {
$this.Stop()
return
}
$step = $Script:Steps[$Script:StepIndex]
$Script:StepIndex++
try {
Invoke-Step -Step $step
} catch {
Write-InstallLog "Step $($step.Id) crashed: $($_.Exception.Message)" -Level ERROR
}
if ($step.Status -eq 'Failed' -and $step.Critical) {
Write-InstallLog "Halting: critical step $($step.Id) failed." -Level ERROR
$this.Stop()
}
})
$timer.Start()
}
function Show-Gui {
if (-not (Test-WpfAvailable)) { return $false }
try {
Add-InteropTypes
[Allium.Setup.TaskbarIcon]::SetAppId('Allium.Setup')
} catch {
Write-InstallLog "Interop / AppUserModelID init failed: $($_.Exception.Message)" -Level WARN
}
$Script:AlliumIcon = $null
$Script:AlliumIconPath = $null
try {
$Script:AlliumIcon = Get-AlliumIcon
} catch {
Write-InstallLog "Icon fetch failed: $($_.Exception.Message)" -Level WARN
}
try {
$reader = New-Object System.Xml.XmlNodeReader ([xml]$Script:XamlGui)
$window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
Write-InstallLog "XAML load failed: $($_.Exception.Message)" -Level ERROR
return $false
}
if ($Script:AlliumIcon) {
try { $window.Icon = $Script:AlliumIcon } catch { }
}
$Script:Ui.Window = $window
$Script:Ui.StepList = $window.FindName('StepList')
$Script:Ui.LogBox = $window.FindName('LogBox')
$Script:Ui.LogDoc = $window.FindName('LogDoc')
$Script:Ui.LogScroll = $window.FindName('LogScroll')
$Script:Ui.ProgressBar = $window.FindName('MainProgress')
$Script:Ui.ProgressLabel = $window.FindName('ProgressLabel')
$Script:Ui.LaunchButton = $window.FindName('BtnLaunch')
$Script:Ui.CancelButton = $window.FindName('BtnCancel')
$Script:Ui.ErrorBanner = $window.FindName('ErrorBanner')
$Script:Ui.ErrorBannerText = $window.FindName('ErrorBannerText')
foreach ($step in $Script:Steps) {
$row = New-StepRow -Step $step
[void]$Script:Ui.StepList.Children.Add($row.Root)
$step.UiRow = $row
}
$window.Add_SourceInitialized({
try {
$helper = New-Object System.Windows.Interop.WindowInteropHelper($window)
$hwnd = $helper.Handle
[Allium.Setup.TitleBar]::EnableDarkMode($hwnd)
$backdropTypeInt = switch ($Backdrop) {
'Mica' { 2 }
'Acrylic' { 3 }
'MicaAlt' { 4 }
'None' { 0 }
default { 2 }
}
if ($backdropTypeInt -eq 0) {
Write-InstallLog "Backdrop disabled (-Backdrop None); using solid theme color." -Level INFO
} else {
$micaOk = [Allium.Setup.BackdropV16]::EnableBackdrop($hwnd, $backdropTypeInt)
if ($micaOk) {
$window.Background = [System.Windows.Media.Brushes]::Transparent
Write-InstallLog "$Backdrop backdrop enabled." -Level INFO
if ($Backdrop -eq 'Mica') {
Write-InstallLog "Mica subtle on dark themes; try -Backdrop Acrylic." -Level INFO
}
try {
$t = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name EnableTransparency -ErrorAction SilentlyContinue
if ($t -and $t.EnableTransparency -eq 0) {
Write-InstallLog "Note: 'Transparency effects' is disabled in Settings > Personalization > Colors. Enable it to see the backdrop." -Level WARN
}
} catch { }
} else {
Write-InstallLog "$Backdrop backdrop not supported here (Windows 10 or older Windows 11); using solid backdrop." -Level INFO
}
}
if ($Script:AlliumIconPath) {
$applied = [Allium.Setup.TaskbarIcon]::ApplyIcon($hwnd, $Script:AlliumIconPath)
if (-not $applied) {
Write-InstallLog "Native icon apply returned false (LoadImage failure)." -Level WARN
}
}
} catch {
Write-InstallLog "Backdrop / icon init failed: $($_.Exception.Message)" -Level WARN
}
})
$Script:Ui.CancelButton.Add_Click({
$Script:CancelToken = $true
Write-InstallLog "User pressed Cancel." -Level WARN
try { $Script:Ui.Window.Close() } catch { }
})
$Script:Ui.LaunchButton.Add_Click({
$alliumPath = Join-Path $Script:ScriptRoot 'Allium.ps1'
if (-not (Test-Path $alliumPath)) {
Write-InstallLog "Allium.ps1 not found at $alliumPath" -Level ERROR
return
}
try {
$pwshCmd = Get-Command pwsh -ErrorAction Stop
Start-Process -FilePath $pwshCmd.Source -ArgumentList '-NoProfile','-WindowStyle','Hidden','-ExecutionPolicy','Bypass','-File',"`"$alliumPath`"" -WindowStyle Hidden
Write-InstallLog "Launched Allium." -Level SUCCESS
$Script:Ui.Window.Close()
} catch {
Write-InstallLog "Failed to launch Allium: $($_.Exception.Message)" -Level ERROR
}
})
$Script:GuiMode = $true
$window.Add_Loaded({
try {
if ($Script:AlliumIcon) {
$Script:Ui.Window.Icon = $Script:AlliumIcon
}
} catch { }
try {
if ($Script:AlliumIconPath) {
$helper = New-Object System.Windows.Interop.WindowInteropHelper($Script:Ui.Window)
[void][Allium.Setup.TaskbarIcon]::ApplyIcon($helper.Handle, $Script:AlliumIconPath)
}
} catch { }
try {
Start-AsyncSteps
} catch {
Write-InstallLog "Async runner failed to start ($($_.Exception.Message)); falling back to synchronous run (UI may briefly freeze)." -Level WARN
Run-AllSteps
}
})
[void]$window.ShowDialog()
return $true
}
function Invoke-VerifyMode {
Write-InstallLog "== VERIFY MODE ==" -Level INFO
$failures = 0
foreach ($step in $Script:Steps) {
if (-not $step.Verify) { continue }
try {
$ok = & $step.Verify
if ($ok) {
Write-Host ("Step {0,2}: {1,-38}  PASS" -f $step.Id,$step.Title) -ForegroundColor Green
} else {
$label = if ($step.Critical) { 'FAIL' } else { 'WARN' }
if ($step.Critical) { $failures++ }
$color = if ($step.Critical) { 'Red' } else { 'Yellow' }
Write-Host ("Step {0,2}: {1,-38}  {2}" -f $step.Id,$step.Title,$label) -ForegroundColor $color
}
} catch {
if ($step.Critical) { $failures++ }
Write-Host ("Step {0,2}: {1,-38}  ERROR: {2}" -f $step.Id,$step.Title,$_.Exception.Message) -ForegroundColor Red
}
}
if ($failures -eq 0) { exit 0 } else { exit 1 }
}
function Invoke-QuietMode {
Write-InstallLog "== QUIET MODE (no GUI) ==" -Level INFO
Run-AllSteps
$crit = $Script:Steps | Where-Object { $_.Critical }
$failed = ($crit | Where-Object { $_.Status -eq 'Failed' }).Count
if ($failed -eq 0) {
Write-InstallLog "All critical steps passed." -Level SUCCESS
exit 0
}
$firstFail = $crit | Where-Object { $_.Status -eq 'Failed' } | Select-Object -First 1
if ($firstFail -and $firstFail.Id -lt 7) {
$ec = $firstFail.Id
} elseif ($firstFail) {
$ec = 7
} else {
$ec = 99
}
Write-InstallLog "$failed critical failure(s). Exit code $ec." -Level ERROR
exit $ec
}
function Invoke-UninstallMode {
Write-InstallLog "== UNINSTALL MODE ==" -Level INFO
$failures = 0
try {
$fontFile = Join-Path $env:WINDIR 'Fonts\Nunito-VariableFont_wght.ttf'
if (Test-Path $fontFile) {
Remove-Item $fontFile -Force -ErrorAction Stop
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name 'Nunito (TrueType)' -ErrorAction SilentlyContinue
Write-InstallLog "Nunito font removed." -Level SUCCESS
}
} catch { $failures++; Write-InstallLog "Font removal failed: $_" -Level ERROR }
try {
$fontFile = Join-Path $env:WINDIR 'Fonts\Sono[MONO,wght].ttf'
if (Test-Path -LiteralPath $fontFile) {
Remove-Item -LiteralPath $fontFile -Force -ErrorAction Stop
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name 'Sono (TrueType)' -ErrorAction SilentlyContinue
Write-InstallLog "Sono font removed." -Level SUCCESS
}
} catch { $failures++; Write-InstallLog "Sono font removal failed: $_" -Level ERROR }
try {
Write-InstallLog "Removing WinUIShell (AllUsers)..." -Level INFO
& pwsh -NoProfile -Command "Import-Module Microsoft.PowerShell.PSResourceGet; Uninstall-PSResource -Name WinUIShell -Scope AllUsers -ErrorAction SilentlyContinue" | Out-Null
Write-InstallLog "WinUIShell uninstalled (or was not installed)." -Level SUCCESS
} catch { $failures++; Write-InstallLog "WinUIShell uninstall failed: $_" -Level ERROR }
$dataRoot = $Script:DataRoot
if (Test-Path $dataRoot) {
try {
$zip = Join-Path $Script:ScriptRoot ("data-backup-" + (Get-Date -Format 'yyyyMMddHHmmss') + ".zip")
Compress-Archive -Path $dataRoot -DestinationPath $zip -Force
Write-InstallLog "Backup written: $zip" -Level SUCCESS
} catch { Write-InstallLog "Backup failed: $_" -Level WARN }
try {
Remove-Item -Path $dataRoot -Recurse -Force
Write-InstallLog "data folder removed." -Level SUCCESS
} catch { $failures++; Write-InstallLog "data folder delete failed: $_" -Level ERROR }
}
try {
$p = Get-ExecutionPolicy -Scope CurrentUser
if ($p -eq 'Unrestricted') {
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
Write-InstallLog "Execution policy reset to RemoteSigned." -Level SUCCESS
}
} catch { $failures++; Write-InstallLog "Execution policy reset failed: $_" -Level ERROR }
Write-InstallLog "Uninstall NOT touched: PowerShell 7 (may be used by other apps), Windows App SDK Runtime (system component)." -Level INFO
if ($failures -eq 0) { exit 0 } else { exit 1 }
}
trap {
Write-InstallLog "Uncaught exception: $($_.Exception.Message)" -Level ERROR
Write-InstallLog $_.ScriptStackTrace -Level ERROR
exit 99
}
Write-InstallLog "$Script:AppName $Script:AppVersion starting..." -Level INFO
Write-InstallLog "Script: $Script:ScriptPath" -Level INFO
Write-InstallLog "Root:   $Script:ScriptRoot" -Level INFO
if ($DebugTrace) {
try {
$traceTs = Get-Date -Format 'yyyyMMddHHmmss'
$Script:DebugTracePath = Join-Path $env:TEMP "Allium-Setup-trace-$traceTs.jsonl"
Set-Content -Path $Script:DebugTracePath -Value '' -Encoding UTF8 -ErrorAction Stop
Write-InstallLog "DebugTrace enabled. Writing to: $Script:DebugTracePath" -Level INFO
} catch {
Write-InstallLog "DebugTrace init failed: $($_.Exception.Message)" -Level WARN
$Script:DebugTracePath = $null
}
}
if (-not (Test-NetworkAvailable)) {
Write-InstallLog "Network unreachable (no route to aka.ms). Installer steps that require downloads will fail. Please connect and retry." -Level WARN
}
$freeGb = Get-FreeDiskGb
if ($freeGb -ge 0 -and $freeGb -lt 1) {
Write-InstallLog "Low disk space: ${freeGb} GB free. PS7 MSI + WinAppSDK need ~500 MB." -Level WARN
}
if (-not (Test-IsAdmin)) {
if ($Verify) {
Write-InstallLog "Verify mode does not require elevation; continuing without admin." -Level INFO
} else {
Invoke-SelfElevate
}
}
Register-AllSteps
if ($Uninstall) {
Invoke-UninstallMode
} elseif ($Verify) {
Invoke-VerifyMode
} elseif ($Quiet) {
Invoke-QuietMode
} else {
if (-not (Show-Gui)) {
Write-InstallLog "GUI could not initialize; falling back to quiet mode." -Level WARN
Invoke-QuietMode
}
}
if ($Script:CancelToken) { exit 130 }
exit 0
