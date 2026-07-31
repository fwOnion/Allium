if ($PSVersionTable.PSVersion.Major -lt 7 -or ($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion.Minor -lt 4)) {
$pwshPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
if (-not (Test-Path $pwshPath)) {
$pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
$pwshPath = if ($null -ne $pwshCmd) { $pwshCmd.Source } else { $null }
}
if ($null -ne $pwshPath) {
Start-Process -FilePath $pwshPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
exit
} else {
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("PowerShell 7.4+ is required. Please run setup.bat first.", "Allium", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
exit 1
}
}
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
$pwshPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
if (-not (Test-Path $pwshPath)) {
$pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
$pwshPath = if ($null -ne $pwshCmd) { $pwshCmd.Source } else { $null }
}
if ($null -ne $pwshPath) {
Start-Process -FilePath $pwshPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
exit
}
}
Import-Module WinUIShell -ErrorAction SilentlyContinue 2>$null
try {
Add-Type -Name Win32Hide -Namespace Allium -MemberDefinition @"
        [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@ -ErrorAction SilentlyContinue
$hwnd = [Allium.Win32Hide]::GetConsoleWindow()
if ($hwnd -ne [System.IntPtr]::Zero) {
[Allium.Win32Hide]::ShowWindow($hwnd, 0) | Out-Null
}
} catch {}
try {
Add-Type -Name KbdState -Namespace Allium -MemberDefinition '[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey); [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow(); [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern IntPtr FindWindowW(IntPtr lpClassName, string lpWindowName);' -ErrorAction SilentlyContinue
} catch {}
try {
Add-Type -Name DialogFocus -Namespace Allium -MemberDefinition @"
        [DllImport("user32.dll")]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
        [DllImport("user32.dll")]
        public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
"@ -ErrorAction SilentlyContinue
} catch {}
try {
Add-Type -Name Win32Tray -Namespace Allium -MemberDefinition @'
        public const int  NIM_ADD               = 0x00000000;
        public const int  NIM_MODIFY            = 0x00000001;
        public const int  NIM_DELETE            = 0x00000002;
        public const int  NIM_SETVERSION        = 0x00000004;
        public const uint NIF_MESSAGE           = 0x00000001;
        public const uint NIF_ICON              = 0x00000002;
        public const uint NIF_TIP               = 0x00000004;
        public const uint NIF_SHOWTIP           = 0x00000080;
        public const uint NIF_STATE             = 0x00000008;
        public const uint NIS_HIDDEN            = 0x00000001;
        public const uint NOTIFYICON_VERSION_4  = 4;
        public const uint WM_APP                = 0x8000;
        public const uint WM_TRAYCALLBACK       = 0x8001;
        public const uint IMAGE_ICON            = 1;
        public const uint LR_LOADFROMFILE       = 0x00000010;
        public const uint LR_DEFAULTSIZE        = 0x00000040;
        public const uint PM_REMOVE             = 0x0001;
        public const uint WM_NULL               = 0x0000;
        public const uint WM_COMMAND            = 0x0111;
        public const uint WM_CONTEXTMENU        = 0x007B;
        public const uint WM_LBUTTONUP          = 0x0202;
        public const uint WM_RBUTTONUP          = 0x0205;
        public const uint NIN_SELECT            = 0x0400;
        public const uint NIN_KEYSELECT         = 0x0401;
        public const uint MF_STRING             = 0x00000000;
        public const uint MF_SEPARATOR          = 0x00000800;
        public const uint TPM_LEFTALIGN         = 0x00000000;
        public const uint TPM_BOTTOMALIGN       = 0x00000020;
        public const uint TPM_RIGHTBUTTON       = 0x00000002;
        public const uint TPM_NONOTIFY          = 0x00000080;
        public const uint TPM_RETURNCMD         = 0x00000100;
        public const int  WIN_BUILD_MIN_DARK            = 18362;
        public const int  PREFERRED_APP_MODE_DEFAULT    = 0;
        public const int  PREFERRED_APP_MODE_FORCE_DARK = 2;
        public static readonly IntPtr HWND_MESSAGE = new IntPtr(-3);
        public delegate IntPtr WndProcDelegate(IntPtr hwnd, uint msg, IntPtr wParam, IntPtr lParam);
        [StructLayout(LayoutKind.Sequential)]
        public struct POINT { public int x; public int y; }
        [StructLayout(LayoutKind.Sequential)]
        public struct MSG {
            public IntPtr hwnd;
            public uint   message;
            public IntPtr wParam;
            public IntPtr lParam;
            public uint   time;
            public POINT  pt;
            public uint   lPrivate;
        }
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct WNDCLASSW {
            public uint               style;
            public WndProcDelegate    lpfnWndProc;
            public int                cbClsExtra;
            public int                cbWndExtra;
            public IntPtr             hInstance;
            public IntPtr             hIcon;
            public IntPtr             hCursor;
            public IntPtr             hbrBackground;
            [MarshalAs(UnmanagedType.LPWStr)] public string lpszMenuName;
            [MarshalAs(UnmanagedType.LPWStr)] public string lpszClassName;
        }
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct NOTIFYICONDATAW {
            public uint   cbSize;
            public IntPtr hWnd;
            public uint   uID;
            public uint   uFlags;
            public uint   uCallbackMessage;
            public IntPtr hIcon;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] public string szTip;
            public uint   dwState;
            public uint   dwStateMask;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string szInfo;
            public uint   uVersion;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst =  64)] public string szInfoTitle;
            public uint   dwInfoFlags;
            public Guid   guidItem;
            public IntPtr hBalloonIcon;
        }
        [DllImport("shell32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool Shell_NotifyIconW(int dwMessage, ref NOTIFYICONDATAW lpData);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern ushort RegisterClassW(ref WNDCLASSW lpWndClass);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool UnregisterClassW(string lpClassName, IntPtr hInstance);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr CreateWindowExW(
            uint dwExStyle, string lpClassName, string lpWindowName, uint dwStyle,
            int x, int y, int nWidth, int nHeight,
            IntPtr hWndParent, IntPtr hMenu, IntPtr hInstance, IntPtr lpParam);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool DestroyWindow(IntPtr hwnd);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern IntPtr DefWindowProcW(IntPtr hwnd, uint uMsg, IntPtr wParam, IntPtr lParam);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr LoadImageW(IntPtr hInst, string name, uint type, int cx, int cy, uint fuLoad);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern bool PeekMessageW(out MSG msg, IntPtr hwnd, uint wMsgFilterMin, uint wMsgFilterMax, uint wRemoveMsg);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern bool TranslateMessage(ref MSG msg);
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        public static extern IntPtr DispatchMessageW(ref MSG msg);
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr GetModuleHandleW(string lpModuleName);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr CreatePopupMenu();
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool AppendMenuW(IntPtr hMenu, uint uFlags, UIntPtr uIDNewItem, string lpNewItem);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool DestroyMenu(IntPtr hMenu);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int TrackPopupMenu(IntPtr hMenu, uint uFlags, int x, int y, int nReserved, IntPtr hWnd, IntPtr prcRect);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool PostMessageW(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
        [DllImport("uxtheme.dll", EntryPoint = "#135", SetLastError = true)]
        public static extern int SetPreferredAppMode(int appMode);
        [DllImport("uxtheme.dll", EntryPoint = "#133", SetLastError = true)]
        public static extern int AllowDarkModeForWindow(IntPtr hwnd, bool allow);
        [DllImport("uxtheme.dll", EntryPoint = "#136")]
        public static extern void FlushMenuThemes();
        [DllImport("uxtheme.dll", EntryPoint = "#104")]
        public static extern void RefreshImmersiveColorPolicyState();
        [DllImport("uxtheme.dll", CharSet = CharSet.Unicode)]
        public static extern int SetWindowTheme(IntPtr hwnd, string pszSubAppName, string pszSubIdList);
'@ -ErrorAction SilentlyContinue
if (-not ('Allium.ProcessAttach' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    public static class NtStatus
    {
        public const int STATUS_SUCCESS         = 0;
        public const int STATUS_PARTIAL_COPY    = unchecked((int)0x8000000D);
        public const int STATUS_ACCESS_DENIED   = unchecked((int)0xC0000022);
        public const int STATUS_INVALID_HANDLE  = unchecked((int)0xC0000008);
        public const int STATUS_INVALID_PARAM   = unchecked((int)0xC000000D);
        public const int STATUS_NO_MEMORY       = unchecked((int)0xC0000017);
        [DllImport("ntdll.dll")]
        private static extern int RtlNtStatusToDosError(int status);
        public static (int Win32Error, Exception Ex) ToException(int status)
        {
            if (status == STATUS_SUCCESS) return (0, null);
            int win32 = RtlNtStatusToDosError(status);
            return (win32, new Win32Exception(win32));
        }
    }
    public sealed class SafeSnapshotHandle : SafeHandleZeroOrMinusOneIsInvalid
    {
        public SafeSnapshotHandle() : base(true) { }
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CloseHandle(IntPtr h);
        protected override bool ReleaseHandle() { return CloseHandle(handle); }
    }
    public sealed class AttachedProcess
    {
        public long Pid { get; }
        public SafeProcessHandle Handle { get; }
        public IntPtr ModuleBase { get; }
        public uint ModuleSize { get; }
        public DateTime AttachedAt { get; }
        public AttachedProcess(long pid, SafeProcessHandle handle, IntPtr modBase,
                               uint modSize, DateTime attachedAt)
        { Pid = pid; Handle = handle; ModuleBase = modBase;
          ModuleSize = modSize; AttachedAt = attachedAt; }
    }
    public static class ProcessAttach
    {
        private const uint PROCESS_VM_READ           = 0x0010;
        private const uint PROCESS_VM_WRITE          = 0x0020;
        private const uint PROCESS_VM_OPERATION      = 0x0008;
        private const uint PROCESS_QUERY_INFORMATION = 0x0400;
        private const uint PROCESS_SUSPEND_RESUME    = 0x0800;
        private const uint ACCESS_RW =
            PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_VM_OPERATION |
            PROCESS_QUERY_INFORMATION | PROCESS_SUSPEND_RESUME;
        private const uint LIST_MODULES_64BIT = 0x02;
        private const uint STILL_ACTIVE        = 259;
        private const int  ERROR_ACCESS_DENIED = 5;
        private const int  ERROR_INVALID_PARAM = 87;
        [StructLayout(LayoutKind.Sequential)]
        private struct MODULEINFO
        { public IntPtr lpBaseOfDll; public uint SizeOfImage; public IntPtr EntryPoint; }
        [DllImport("kernel32.dll", SetLastError = true, EntryPoint = "K32EnumProcesses")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool EnumProcesses([Out] uint[] pids, uint cb, out uint cbNeeded);
        [DllImport("kernel32.dll", SetLastError = true, EntryPoint = "K32EnumProcessModulesEx")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool EnumProcessModulesEx(
            SafeProcessHandle h, [Out] IntPtr[] mods, uint cb, out uint cbNeeded, uint filter);
        [DllImport("kernel32.dll", SetLastError = true, EntryPoint = "K32GetModuleBaseNameW",
                   CharSet = CharSet.Unicode)]
        private static extern uint GetModuleBaseNameW(
            SafeProcessHandle h, IntPtr mod, [Out] char[] name, uint nSize);
        [DllImport("kernel32.dll", SetLastError = true, EntryPoint = "K32GetModuleInformation")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetModuleInformation(
            SafeProcessHandle h, IntPtr mod, out MODULEINFO mi, uint cb);
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern SafeProcessHandle OpenProcess(
            uint access, [MarshalAs(UnmanagedType.Bool)] bool inherit, uint pid);
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetExitCodeProcess(SafeProcessHandle h, out uint exit);
        public static long[] FindProcessesByName(string exeName)
        {
            if (string.IsNullOrWhiteSpace(exeName))
                throw new ArgumentException("exeName required", "exeName");
            uint[] pids = new uint[1024];
            if (!EnumProcesses(pids, (uint)(pids.Length * sizeof(uint)), out uint cbNeeded))
                throw new Win32Exception(Marshal.GetLastWin32Error());
            int n = (int)(cbNeeded / sizeof(uint));
            var hits = new List<long>();
            for (int i = 0; i < n; i++)
            {
                uint pid = pids[i];
                if (pid == 0) continue;
                using (var h = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, false, pid))
                {
                    if (h.IsInvalid) continue;
                    IntPtr[] mods = new IntPtr[1];
                    if (!EnumProcessModulesEx(h, mods, (uint)IntPtr.Size, out _, LIST_MODULES_64BIT))
                        continue;
                    var buf = new char[260];
                    uint len = GetModuleBaseNameW(h, mods[0], buf, (uint)buf.Length);
                    if (len == 0) continue;
                    string name = new string(buf, 0, (int)len);
                    if (string.Equals(name, exeName, StringComparison.OrdinalIgnoreCase))
                        hits.Add(pid);
                }
            }
            return hits.ToArray();
        }
        public static SafeProcessHandle OpenForReadWrite(uint pid)
        {
            var h = OpenProcess(ACCESS_RW, false, pid);
            if (h.IsInvalid)
            {
                int err = Marshal.GetLastWin32Error();
                if (err == ERROR_INVALID_PARAM || err == ERROR_ACCESS_DENIED) return h;
                throw new Win32Exception(err);
            }
            return h;
        }
        public static System.ValueTuple<IntPtr, uint> GetPrimaryModuleBase(SafeProcessHandle h)
        {
            if (h == null || h.IsInvalid) return new System.ValueTuple<IntPtr, uint>(IntPtr.Zero, 0);
            IntPtr[] mods = new IntPtr[1024];
            if (!EnumProcessModulesEx(h, mods,
                    (uint)(IntPtr.Size * mods.Length), out uint cbNeeded, LIST_MODULES_64BIT))
                return new System.ValueTuple<IntPtr, uint>(IntPtr.Zero, 0);
            int n = (int)(cbNeeded / (uint)IntPtr.Size);
            if (n == 0) return new System.ValueTuple<IntPtr, uint>(IntPtr.Zero, 0);
            MODULEINFO mi;
            if (!GetModuleInformation(h, mods[0], out mi, (uint)Marshal.SizeOf(typeof(MODULEINFO))))
                return new System.ValueTuple<IntPtr, uint>(mods[0], 0);
            return new System.ValueTuple<IntPtr, uint>(mi.lpBaseOfDll, mi.SizeOfImage);
        }
        public static bool IsProcessAlive(SafeProcessHandle h)
        {
            if (h == null || h.IsInvalid || h.IsClosed) return false;
            uint code;
            return GetExitCodeProcess(h, out code) && code == STILL_ACTIVE;
        }
        public static void Close(SafeProcessHandle h)
        {
            if (h == null || h.IsClosed) return;
            h.Dispose();
        }
    }
}
'@
}
if (-not ('Allium.ProcessSuspension' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.Win32.SafeHandles;
using System.ComponentModel;
namespace Allium
{
    public static class ProcessSuspension
    {
        [DllImport("ntdll.dll", SetLastError = false)]
        private static extern int NtSuspendProcess(SafeProcessHandle h);
        [DllImport("ntdll.dll", SetLastError = false)]
        private static extern int NtResumeProcess(SafeProcessHandle h);
        [DllImport("ntdll.dll")]
        private static extern int RtlNtStatusToDosError(int status);
        public static void Suspend(SafeProcessHandle h)
        {
            if (h == null || h.IsInvalid || h.IsClosed)
                throw new ArgumentException("invalid process handle");
            int status = NtSuspendProcess(h);
            if (status != 0) throw new Win32Exception(RtlNtStatusToDosError(status));
        }
        public static void Resume(SafeProcessHandle h)
        {
            if (h == null || h.IsInvalid || h.IsClosed) return;
            int status = NtResumeProcess(h);
            if (status != 0) throw new Win32Exception(RtlNtStatusToDosError(status));
        }
    }
    public sealed class SuspendScope : IDisposable
    {
        private readonly SafeProcessHandle _h;
        private Timer _watchdog;
        private int _disposed;
        public bool WatchdogFired { get; private set; }
        public int WatchdogMs { get; }
        public SuspendScope(SafeProcessHandle h, int watchdogMs)
        {
            if (h == null || h.IsInvalid || h.IsClosed)
                throw new ArgumentException("invalid process handle");
            if (watchdogMs <= 0) watchdogMs = 250;
            _h = h;
            WatchdogMs = watchdogMs;
            ProcessSuspension.Suspend(_h);
            _watchdog = new Timer(_ => {
                if (Interlocked.CompareExchange(ref _disposed, 1, 0) != 0) return;
                WatchdogFired = true;
                try { ProcessSuspension.Resume(_h); } catch { }
            }, null, watchdogMs, Timeout.Infinite);
        }
        public void Dispose()
        {
            if (Interlocked.CompareExchange(ref _disposed, 1, 0) != 0) return;
            try { if (_watchdog != null) _watchdog.Dispose(); } catch { }
            _watchdog = null;
            try { ProcessSuspension.Resume(_h); } catch { }
            GC.SuppressFinalize(this);
        }
    }
}
'@
}
if (-not ('Allium.ChannelWriter' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    public sealed class WriteResult
    {
        public bool   Success      { get; }
        public int    BytesWritten { get; }
        public string Error        { get; }
        public WriteResult(bool success, int bytesWritten, string error)
        { Success = success; BytesWritten = bytesWritten; Error = error; }
    }
    public static class ChannelWriter
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool WriteProcessMemory(
            SafeProcessHandle h, IntPtr addr, byte[] buf, UIntPtr size, out UIntPtr written);
        [DllImport("ntdll.dll", SetLastError = false)]
        private static extern int NtWriteVirtualMemory(
            SafeProcessHandle h, IntPtr addr, byte[] buf, UIntPtr size, out UIntPtr written);
        [DllImport("ntdll.dll")]
        private static extern int RtlNtStatusToDosError(int status);
        public const int STATUS_SUCCESS      = 0;
        public const int STATUS_PARTIAL_COPY = unchecked((int)0x8000000D);
        public const int ERROR_PARTIAL_COPY  = 299;
        public static WriteResult WriteA(SafeProcessHandle h, IntPtr addr, byte[] bytes)
        {
            if (h == null || h.IsInvalid || h.IsClosed)
                return new WriteResult(false, 0, "invalid process handle");
            if (bytes == null || bytes.Length == 0)
                return new WriteResult(false, 0, "empty buffer");
            UIntPtr written;
            bool ok = WriteProcessMemory(h, addr, bytes, (UIntPtr)bytes.Length, out written);
            int writtenInt = (int)written.ToUInt64();
            if (ok) return new WriteResult(true, writtenInt, null);
            int err = Marshal.GetLastWin32Error();
            if (err == ERROR_PARTIAL_COPY && writtenInt > 0)
                return new WriteResult(true, writtenInt, "partial-copy(" + writtenInt + ")");
            return new WriteResult(false, writtenInt,
                "WriteProcessMemory failed: " + new Win32Exception(err).Message);
        }
        public static WriteResult WriteB(SafeProcessHandle h, IntPtr addr, byte[] bytes)
        {
            if (h == null || h.IsInvalid || h.IsClosed)
                return new WriteResult(false, 0, "invalid process handle");
            if (bytes == null || bytes.Length == 0)
                return new WriteResult(false, 0, "empty buffer");
            UIntPtr written;
            int status = NtWriteVirtualMemory(h, addr, bytes, (UIntPtr)bytes.Length, out written);
            int writtenInt = (int)written.ToUInt64();
            if (status == STATUS_SUCCESS) return new WriteResult(true, writtenInt, null);
            if (status == STATUS_PARTIAL_COPY && writtenInt > 0)
                return new WriteResult(true, writtenInt, "partial-copy(" + writtenInt + ")");
            int win32 = RtlNtStatusToDosError(status);
            return new WriteResult(false, writtenInt,
                "NtWriteVirtualMemory failed: 0x" + status.ToString("X8") + " (" +
                new Win32Exception(win32).Message + ")");
        }
    }
}
'@
}
if (-not ('Allium.HashmapWalker' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    public sealed class Offsets
    {
        public int O_END        { get; }
        public int O_LIST       { get; }
        public int O_MASK       { get; }
        public int O_NEXT       { get; }
        public int O_STR        { get; }
        public int O_VTBL       { get; }
        public int O_SIZE       { get; }
        public int O_ALLOC      { get; }
        public int SSO_THRESHOLD{ get; }
        public int PtrSize      { get; }
        public Offsets(int oEnd, int oList, int oMask, int oNext, int oStr,
                       int oVtbl, int oSize, int oAlloc, int ssoThreshold, int ptrSize)
        {
            O_END=oEnd; O_LIST=oList; O_MASK=oMask; O_NEXT=oNext; O_STR=oStr;
            O_VTBL=oVtbl; O_SIZE=oSize; O_ALLOC=oAlloc;
            SSO_THRESHOLD=ssoThreshold; PtrSize=ptrSize;
        }
    }
    public sealed class FlagEntry
    {
        public IntPtr EntryPtr { get; }
        public IntPtr ValuePtr { get; }
        public string Name     { get; }
        public FlagEntry(IntPtr entryPtr, IntPtr valuePtr, string name)
        { EntryPtr=entryPtr; ValuePtr=valuePtr; Name=name; }
    }
    [StructLayout(LayoutKind.Sequential)]
    internal struct MEMORY_BASIC_INFORMATION
    {
        public IntPtr BaseAddress;
        public IntPtr AllocationBase;
        public uint   AllocationProtect;
        public IntPtr RegionSize;
        public uint   State;
        public uint   Protect;
        public uint   Type;
    }
    public static class MemoryReader
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool ReadProcessMemory(
            SafeProcessHandle h, IntPtr addr, byte[] buf, UIntPtr size, out UIntPtr nread);
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern UIntPtr VirtualQueryEx(
            SafeProcessHandle h, IntPtr addr, out MEMORY_BASIC_INFORMATION mbi, UIntPtr cb);
        private const int ERROR_PARTIAL_COPY = 299;
        private const uint MEM_COMMIT  = 0x1000;
        private const uint PAGE_NOACCESS = 0x01;
        private const uint PAGE_GUARD    = 0x100;
        public static byte[] ReadBytes(SafeProcessHandle h, IntPtr addr, int size)
        {
            if (h == null || h.IsInvalid || h.IsClosed || size <= 0)
                return new byte[0];
            byte[] buf = new byte[size];
            UIntPtr nread;
            bool ok = ReadProcessMemory(h, addr, buf, (UIntPtr)size, out nread);
            int got = (int)nread.ToUInt64();
            if (ok) return buf;
            int err = Marshal.GetLastWin32Error();
            if (err == ERROR_PARTIAL_COPY && got > 0)
            {
                if (got < size) { byte[] trimmed = new byte[got]; Array.Copy(buf, trimmed, got); return trimmed; }
                return buf;
            }
            return new byte[0];
        }
        public static ulong ReadUInt64(SafeProcessHandle h, IntPtr addr)
        {
            byte[] b = ReadBytes(h, addr, 8);
            if (b.Length < 8) return 0UL;
            return BitConverter.ToUInt64(b, 0);
        }
        public static IntPtr ReadIntPtr(SafeProcessHandle h, IntPtr addr)
        {
            byte[] b = ReadBytes(h, addr, 8);
            if (b.Length < 8) return IntPtr.Zero;
            return (IntPtr)BitConverter.ToInt64(b, 0);
        }
        public static bool IsAccessible(SafeProcessHandle h, IntPtr addr, int size)
        {
            if (h == null || h.IsInvalid || h.IsClosed) return false;
            MEMORY_BASIC_INFORMATION mbi;
            UIntPtr got = VirtualQueryEx(h, addr, out mbi,
                (UIntPtr)Marshal.SizeOf(typeof(MEMORY_BASIC_INFORMATION)));
            if (got == UIntPtr.Zero) return false;
            if (mbi.State != MEM_COMMIT) return false;
            if ((mbi.Protect & PAGE_NOACCESS) != 0) return false;
            if ((mbi.Protect & PAGE_GUARD) != 0) return false;
            return true;
        }
    }
    public sealed class LookupCache
    {
        private readonly int _capacity;
        private readonly Dictionary<string, IntPtr> _map;
        private readonly LinkedList<string> _order;
        private readonly object _lock = new object();
        public LookupCache(int capacity)
        {
            _capacity = capacity > 0 ? capacity : 4096;
            _map = new Dictionary<string, IntPtr>(_capacity);
            _order = new LinkedList<string>();
        }
        public bool TryGet(string name, out IntPtr value)
        {
            lock (_lock)
            {
                if (_map.TryGetValue(name, out value))
                {
                    _order.Remove(name); _order.AddFirst(name);
                    return true;
                }
                return false;
            }
        }
        public void Add(string name, IntPtr value)
        {
            lock (_lock)
            {
                if (_map.ContainsKey(name)) { _map[name] = value; _order.Remove(name); _order.AddFirst(name); return; }
                if (_map.Count >= _capacity && _order.Last != null)
                {
                    string evict = _order.Last.Value;
                    _order.RemoveLast(); _map.Remove(evict);
                }
                _map[name] = value; _order.AddFirst(name);
            }
        }
        public void InvalidateAll()
        {
            lock (_lock) { _map.Clear(); _order.Clear(); }
        }
        public int Count { get { lock (_lock) { return _map.Count; } } }
    }
    public static class HashmapWalker
    {
        public static class Fnv1a64
        {
            public const ulong FNV_64_OFFSET = 14695981039346656037UL;
            public const ulong FNV_64_PRIME  = 1099511628211UL;
            public static ulong Hash(byte[] bytes)
            {
                ulong h = FNV_64_OFFSET;
                for (int i = 0; i < bytes.Length; i++) { h ^= bytes[i]; h *= FNV_64_PRIME; }
                return h;
            }
        }
        public static FlagEntry LookupByName(SafeProcessHandle h, IntPtr mapPtr, string name, Offsets o)
        {
            if (h == null || h.IsInvalid || mapPtr == IntPtr.Zero || string.IsNullOrEmpty(name)) return null;
            byte[] nameUtf8 = System.Text.Encoding.UTF8.GetBytes(name);
            ulong hash = Fnv1a64.Hash(nameUtf8);
            ulong mask = MemoryReader.ReadUInt64(h, (IntPtr)((long)mapPtr + o.O_MASK));
            if (mask == 0 || mask >= 0x01000000UL || ((mask + 1) & mask) != 0) return null;
            IntPtr bucketArray = MemoryReader.ReadIntPtr(h, (IntPtr)((long)mapPtr + o.O_LIST));
            if (bucketArray == IntPtr.Zero || ((long)bucketArray & 0x7) != 0) return null;
            ulong index = hash & mask;
            IntPtr bucketHead = MemoryReader.ReadIntPtr(h, (IntPtr)((long)bucketArray + (long)(index * (ulong)o.PtrSize)));
            IntPtr cur = bucketHead;
            for (int depth = 0; depth < 128 && cur != IntPtr.Zero; depth++)
            {
                ulong nameLen = MemoryReader.ReadUInt64(h, (IntPtr)((long)cur + o.O_STR + o.O_SIZE));
                if (nameLen > 1048576UL) break;
                byte[] entryName;
                if ((int)nameLen <= o.SSO_THRESHOLD)
                {
                    entryName = MemoryReader.ReadBytes(h, (IntPtr)((long)cur + o.O_STR + o.O_ALLOC + o.PtrSize), (int)nameLen);
                }
                else
                {
                    IntPtr heapPtr = MemoryReader.ReadIntPtr(h, (IntPtr)((long)cur + o.O_STR + o.O_ALLOC));
                    if (heapPtr == IntPtr.Zero) break;
                    entryName = MemoryReader.ReadBytes(h, heapPtr, (int)nameLen);
                }
                if (entryName.Length == nameUtf8.Length && ByteArraysEqual(entryName, nameUtf8))
                {
                    IntPtr valuePtr = MemoryReader.ReadIntPtr(h, (IntPtr)((long)cur + 0xC0));
                    return new FlagEntry(cur, valuePtr, name);
                }
                cur = MemoryReader.ReadIntPtr(h, (IntPtr)((long)cur + o.O_NEXT));
            }
            return null;
        }
        public static FlagEntry[] DumpAllBuckets(SafeProcessHandle h, IntPtr mapPtr, Offsets o)
        {
            var results = new List<FlagEntry>(16384);
            if (h == null || h.IsInvalid || h.IsClosed || mapPtr == IntPtr.Zero || o == null)
                return results.ToArray();
            ulong mask = MemoryReader.ReadUInt64(h, (IntPtr)((long)mapPtr + o.O_MASK));
            if (mask == 0 || mask >= 0x01000000UL || ((mask + 1) & mask) != 0)
                return results.ToArray();
            IntPtr bucketArray = MemoryReader.ReadIntPtr(h, (IntPtr)((long)mapPtr + o.O_LIST));
            if (bucketArray == IntPtr.Zero || ((long)bucketArray & 0x7) != 0)
                return results.ToArray();
            ulong bucketCount = mask + 1;
            for (ulong bucketIdx = 0; bucketIdx < bucketCount; bucketIdx++)
            {
                IntPtr bucketHead = MemoryReader.ReadIntPtr(h,
                    (IntPtr)((long)bucketArray + (long)(bucketIdx * (ulong)o.PtrSize)));
                IntPtr cur = bucketHead;
                for (int depth = 0; depth < 512 && cur != IntPtr.Zero; depth++)
                {
                    ulong nameLen = MemoryReader.ReadUInt64(h,
                        (IntPtr)((long)cur + o.O_STR + o.O_SIZE));
                    if (nameLen == 0 || nameLen > 1048576UL) break;
                    byte[] entryName;
                    if ((int)nameLen <= o.SSO_THRESHOLD)
                    {
                        entryName = MemoryReader.ReadBytes(h,
                            (IntPtr)((long)cur + o.O_STR + o.O_ALLOC + o.PtrSize), (int)nameLen);
                    }
                    else
                    {
                        IntPtr heapPtr = MemoryReader.ReadIntPtr(h,
                            (IntPtr)((long)cur + o.O_STR + o.O_ALLOC));
                        if (heapPtr == IntPtr.Zero) break;
                        entryName = MemoryReader.ReadBytes(h, heapPtr, (int)nameLen);
                    }
                    if (entryName != null && entryName.Length == (int)nameLen)
                    {
                        string name;
                        try { name = System.Text.Encoding.UTF8.GetString(entryName); }
                        catch { name = null; }
                        if (!string.IsNullOrEmpty(name))
                        {
                            IntPtr valuePtr = MemoryReader.ReadIntPtr(h,
                                (IntPtr)((long)cur + 0xC0));
                            results.Add(new FlagEntry(cur, valuePtr, name));
                        }
                    }
                    cur = MemoryReader.ReadIntPtr(h, (IntPtr)((long)cur + o.O_NEXT));
                }
            }
            return results.ToArray();
        }
        private static bool ByteArraysEqual(byte[] a, byte[] b)
        {
            if (a.Length != b.Length) return false;
            for (int i = 0; i < a.Length; i++) if (a[i] != b[i]) return false;
            return true;
        }
    }
    public static class AlliumOffsetsModule
    {
        public static readonly Offsets Current = new Offsets(
            oEnd: 0x00, oList: 0x10, oMask: 0x28, oNext: 0x08,
            oStr: 0x10, oVtbl: 0x30, oSize: 0x10, oAlloc: 0x18,
            ssoThreshold: 15, ptrSize: 8);
    }
}
'@
}
if (-not ('Allium.TypedWriters' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Buffers.Binary;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    public sealed class TypedWriteResult
    {
        public bool   Success      { get; }
        public int    BytesWritten { get; }
        public string Error        { get; }
        public TypedWriteResult(bool success, int bytesWritten, string error)
        { Success = success; BytesWritten = bytesWritten; Error = error; }
    }
    public sealed class VerifyResult
    {
        public bool   Matched  { get; }
        public byte[] Expected { get; }
        public byte[] Actual   { get; }
        public VerifyResult(bool matched, byte[] expected, byte[] actual)
        { Matched=matched; Expected=expected; Actual=actual; }
    }
    public enum FlagKind { Bool, Int, Float, String }
    public static class TypedWriters
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool WriteProcessMemory(
            SafeProcessHandle h, IntPtr addr, byte[] buf, UIntPtr size, out UIntPtr written);
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool ReadProcessMemory(
            SafeProcessHandle h, IntPtr addr, byte[] buf, UIntPtr size, out UIntPtr nread);
        private const int ERROR_PARTIAL_COPY = 299;
        private static TypedWriteResult WriteBytesCore(SafeProcessHandle h, IntPtr addr, byte[] bytes)
        {
            if (h == null || h.IsInvalid || h.IsClosed)
                return new TypedWriteResult(false, 0, "invalid handle");
            if (addr == IntPtr.Zero)
                return new TypedWriteResult(false, 0, "null address");
            UIntPtr written;
            bool ok = WriteProcessMemory(h, addr, bytes, (UIntPtr)bytes.Length, out written);
            int n = (int)written.ToUInt64();
            if (ok) return new TypedWriteResult(true, n, null);
            int err = Marshal.GetLastWin32Error();
            if (err == ERROR_PARTIAL_COPY && n > 0)
                return new TypedWriteResult(true, n, "partial-copy");
            return new TypedWriteResult(false, n,
                "WriteProcessMemory failed: " + new Win32Exception(err).Message);
        }
        public static TypedWriteResult WriteBool(SafeProcessHandle h, IntPtr addr, bool value)
        {
            byte[] buf = new byte[1];
            buf[0] = value ? (byte)0x01 : (byte)0x00;
            return WriteBytesCore(h, addr, buf);
        }
        public static TypedWriteResult WriteInt(SafeProcessHandle h, IntPtr addr, int value)
        {
            byte[] buf = new byte[4];
            BinaryPrimitives.WriteInt32LittleEndian(buf, value);
            return WriteBytesCore(h, addr, buf);
        }
        public static TypedWriteResult WriteFloat(SafeProcessHandle h, IntPtr addr, float value)
        {
            byte[] buf = new byte[4];
            int bits = BitConverter.SingleToInt32Bits(value);
            BinaryPrimitives.WriteInt32LittleEndian(buf, bits);
            return WriteBytesCore(h, addr, buf);
        }
        public static TypedWriteResult WriteString(SafeProcessHandle h, IntPtr valuePtr, string value,
                                              int offStrSize, int offStrAlloc, int ssoThreshold, int ptrSize)
        {
            if (value == null) return new TypedWriteResult(false, 0, "null string");
            byte[] newBytes = Encoding.UTF8.GetBytes(value);
            int newLen = newBytes.Length;
            byte[] lenBuf = new byte[8];
            UIntPtr nread;
            if (!ReadProcessMemory(h, (IntPtr)((long)valuePtr + offStrSize), lenBuf, (UIntPtr)8, out nread))
                return new TypedWriteResult(false, 0, "failed to read string length");
            long existingLen = BitConverter.ToInt64(lenBuf, 0);
            if (newLen <= ssoThreshold && existingLen <= ssoThreshold)
            {
                IntPtr inlineAddr = (IntPtr)((long)valuePtr + offStrAlloc + ptrSize);
                TypedWriteResult wr = WriteBytesCore(h, inlineAddr, newBytes);
                if (!wr.Success) return wr;
                byte[] lenBuf2 = new byte[8];
                BinaryPrimitives.WriteInt64LittleEndian(lenBuf2, (long)newLen);
                return WriteBytesCore(h, (IntPtr)((long)valuePtr + offStrSize), lenBuf2);
            }
            byte[] capBuf = new byte[8];
            if (!ReadProcessMemory(h, (IntPtr)((long)valuePtr + offStrAlloc), capBuf, (UIntPtr)8, out nread))
                return new TypedWriteResult(false, 0, "failed to read string capacity");
            long capacity = BitConverter.ToInt64(capBuf, 0);
            if (newLen > capacity)
                return new TypedWriteResult(false, 0, "string growth beyond capacity (v1.2.0+ feature)");
            byte[] heapPtrBuf = new byte[8];
            if (!ReadProcessMemory(h, (IntPtr)((long)valuePtr + offStrAlloc), heapPtrBuf, (UIntPtr)8, out nread))
                return new TypedWriteResult(false, 0, "failed to read heap pointer");
            IntPtr heapPtr = (IntPtr)BitConverter.ToInt64(heapPtrBuf, 0);
            TypedWriteResult heapWr = WriteBytesCore(h, heapPtr, newBytes);
            if (!heapWr.Success) return heapWr;
            byte[] lenBuf3 = new byte[8];
            BinaryPrimitives.WriteInt64LittleEndian(lenBuf3, (long)newLen);
            return WriteBytesCore(h, (IntPtr)((long)valuePtr + offStrSize), lenBuf3);
        }
    }
    public static class WriteVerifier
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool ReadProcessMemory(
            SafeProcessHandle h, IntPtr addr, byte[] buf, UIntPtr size, out UIntPtr nread);
        public static VerifyResult Verify(SafeProcessHandle h, IntPtr addr, byte[] expected, FlagKind kind)
        {
            if (h == null || h.IsInvalid || h.IsClosed || expected == null)
                return new VerifyResult(false, expected, new byte[0]);
            byte[] actual = new byte[expected.Length];
            UIntPtr nread;
            if (!ReadProcessMemory(h, addr, actual, (UIntPtr)expected.Length, out nread))
                return new VerifyResult(false, expected, actual);
            if (kind == FlagKind.Float && expected.Length == 4 && actual.Length == 4)
            {
                int eBits = BinaryPrimitives.ReadInt32LittleEndian(expected);
                int aBits = BinaryPrimitives.ReadInt32LittleEndian(actual);
                return new VerifyResult(eBits == aBits, expected, actual);
            }
            if (expected.Length != actual.Length) return new VerifyResult(false, expected, actual);
            for (int i = 0; i < expected.Length; i++)
            {
                if (expected[i] != actual[i]) return new VerifyResult(false, expected, actual);
            }
            return new VerifyResult(true, expected, actual);
        }
    }
}
'@
}
if (-not ('Allium.InjectionResult' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
namespace Allium
{
    public sealed class InjectionResult
    {
        public bool     Success         { get; }
        public int      TotalFlags      { get; }
        public int      SucceededFlags  { get; }
        public int      FailedFlags     { get; }
        public string[] PerFlagErrors   { get; }
        public double   TotalDurationMs { get; }
        public string   Diagnostic      { get; }
        public InjectionResult(bool success, int total, int succeeded, int failed,
                               string[] errors, double durationMs, string diagnostic)
        {
            Success         = success;
            TotalFlags      = total;
            SucceededFlags  = succeeded;
            FailedFlags     = failed;
            PerFlagErrors   = errors;
            TotalDurationMs = durationMs;
            Diagnostic      = diagnostic;
        }
    }
}
'@
}
} catch {}
if (-not ('Allium.PatternScanner' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Globalization;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct BLOCK_G_MBI
    {
        public IntPtr BaseAddress;
        public IntPtr AllocationBase;
        public uint   AllocationProtect;
        public uint   __alignment1;
        public UIntPtr RegionSize;
        public uint   State;
        public uint   Protect;
        public uint   Type;
        public uint   __alignment2;
    }
    internal static class ScannerNative
    {
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool ReadProcessMemory(
            SafeProcessHandle hProcess,
            IntPtr            lpBaseAddress,
            [Out] byte[]      lpBuffer,
            UIntPtr           nSize,
            out UIntPtr       lpNumberOfBytesRead);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern UIntPtr VirtualQueryEx(
            SafeProcessHandle hProcess,
            IntPtr            lpAddress,
            out BLOCK_G_MBI lpBuffer,
            UIntPtr           dwLength);
    }
    public sealed class CompiledPattern
    {
        public readonly byte[] Bytes;
        public readonly byte[] Mask;
        public readonly int    Length;
        public CompiledPattern(byte[] bytes, byte[] mask, int length)
        {
            this.Bytes  = bytes;
            this.Mask   = mask;
            this.Length = length;
        }
    }
    public static class PatternScanner
    {
        private const uint MEM_COMMIT    = 0x1000;
        private const uint PAGE_NOACCESS = 0x01;
        private const uint PAGE_GUARD    = 0x100;
        public static CompiledPattern Compile(string ida)
        {
            if (string.IsNullOrWhiteSpace(ida))
                throw new ArgumentException("Pattern is empty.", "ida");
            string[] tokens = ida.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            int n = tokens.Length;
            if (n == 0)
                throw new ArgumentException("Pattern produced zero tokens.", "ida");
            byte[] bytes = new byte[n];
            byte[] mask  = new byte[n];
            for (int i = 0; i < n; i++)
            {
                string t = tokens[i];
                if (t == "??" || t == "?")
                {
                    bytes[i] = 0; mask[i] = 0;
                }
                else if (t.Length == 2 &&
                         byte.TryParse(t, NumberStyles.HexNumber, CultureInfo.InvariantCulture, out byte v))
                {
                    bytes[i] = v; mask[i] = 1;
                }
                else
                {
                    throw new ArgumentException("Invalid pattern token: '" + t + "' at index " + i, "ida");
                }
            }
            return new CompiledPattern(bytes, mask, n);
        }
        private static int[] BuildShiftTable(CompiledPattern p)
        {
            int last = p.Length - 1;
            int lastWildcard = -1;
            for (int i = last; i >= 0; i--)
            {
                if (p.Mask[i] == 0) { lastWildcard = i; break; }
            }
            int safeStart = lastWildcard + 1;
            int diff = Math.Max(last - safeStart, 1);
            int[] skip = new int[256];
            for (int b = 0; b < 256; b++) skip[b] = diff;
            for (int i = safeStart; i < last; i++)
            {
                skip[p.Bytes[i]] = last - i;
            }
            return skip;
        }
        private static int FindInBuffer(byte[] hay, int hayLen, CompiledPattern p, int[] skip)
        {
            int m = p.Length;
            if (hayLen < m) return -1;
            int limit = hayLen - m;
            int i = 0;
            while (i <= limit)
            {
                int j = m - 1;
                while (j >= 0 && (p.Mask[j] == 0 || p.Bytes[j] == hay[i + j])) j--;
                if (j < 0) return i;
                int s = skip[hay[i + m - 1]];
                i += (s > 0 ? s : 1);
            }
            return -1;
        }
        public static IntPtr Scan(SafeProcessHandle hProcess, IntPtr moduleBase, long moduleSize, CompiledPattern p)
        {
            if (hProcess == null || hProcess.IsInvalid || hProcess.IsClosed) return IntPtr.Zero;
            if (p == null || p.Length == 0)                                  return IntPtr.Zero;
            if (moduleSize <= 0)                                        return IntPtr.Zero;
            int[] skip = BuildShiftTable(p);
            const int CHUNK = 0x10000;
            int overlap = Math.Max(0, p.Length - 1);
            byte[] buf  = new byte[CHUNK + overlap];
            long moduleEnd = moduleBase.ToInt64() + moduleSize;
            IntPtr cursor  = moduleBase;
            UIntPtr mbiSize = (UIntPtr)Marshal.SizeOf(typeof(BLOCK_G_MBI));
            while (cursor.ToInt64() < moduleEnd)
            {
                BLOCK_G_MBI mbi;
                UIntPtr returned = ScannerNative.VirtualQueryEx(hProcess, cursor, out mbi, mbiSize);
                if (returned == UIntPtr.Zero) return IntPtr.Zero;
                long regionStart = mbi.BaseAddress.ToInt64();
                long regionLen   = (long)mbi.RegionSize.ToUInt64();
                long regionEnd   = regionStart + regionLen;
                if (regionEnd > moduleEnd) regionEnd = moduleEnd;
                bool skipRegion = (mbi.State != MEM_COMMIT) ||
                                  ((mbi.Protect & PAGE_NOACCESS) != 0) ||
                                  ((mbi.Protect & PAGE_GUARD)    != 0);
                if (!skipRegion)
                {
                    long pos = Math.Max(regionStart, cursor.ToInt64());
                    while (pos < regionEnd)
                    {
                        long remaining = regionEnd - pos;
                        int want = (int)Math.Min((long)(CHUNK + overlap), remaining);
                        UIntPtr bytesRead;
                        bool ok = ScannerNative.ReadProcessMemory(
                            hProcess, (IntPtr)pos, buf, (UIntPtr)want, out bytesRead);
                        int got = (int)bytesRead.ToUInt32();
                        if (got >= p.Length)
                        {
                            int hit = FindInBuffer(buf, got, p, skip);
                            if (hit >= 0) return (IntPtr)(pos + hit);
                        }
                        if (!ok || got < want) break;
                        pos += CHUNK;
                    }
                }
                cursor = (IntPtr)regionEnd;
            }
            return IntPtr.Zero;
        }
        public static int ScanBuffer(byte[] buffer, CompiledPattern p)
        {
            if (buffer == null || p == null || p.Length == 0) return -1;
            int[] skip = BuildShiftTable(p);
            return FindInBuffer(buffer, buffer.Length, p, skip);
        }
    }
    public static class RipRelativeDecoder
    {
        public static IntPtr Resolve(
            SafeProcessHandle hProcess,
            IntPtr matchAddr,
            int    dispOff,
            int    nextOff,
            int    headerOffset)
        {
            if (hProcess == null || hProcess.IsInvalid || hProcess.IsClosed) return IntPtr.Zero;
            if (nextOff != dispOff + 4)                                      return IntPtr.Zero;
            byte[] buf4 = new byte[4];
            UIntPtr got4;
            bool ok = ScannerNative.ReadProcessMemory(
                hProcess, (IntPtr)(matchAddr.ToInt64() + dispOff), buf4, (UIntPtr)4, out got4);
            if (!ok || got4.ToUInt32() != 4) return IntPtr.Zero;
            int  disp32     = BitConverter.ToInt32(buf4, 0);
            long globalSlot = matchAddr.ToInt64() + nextOff + (long)disp32;
            byte[] buf8 = new byte[8];
            UIntPtr got8;
            ok = ScannerNative.ReadProcessMemory(
                hProcess, (IntPtr)globalSlot, buf8, (UIntPtr)8, out got8);
            if (!ok || got8.ToUInt32() != 8) return IntPtr.Zero;
            long singleton = BitConverter.ToInt64(buf8, 0);
            if (singleton == 0) return IntPtr.Zero;
            return (IntPtr)(singleton + headerOffset);
        }
        public static long ComputeSlotAddress(long matchAddr, int dispOff, int nextOff, int disp32)
        {
            return matchAddr + nextOff + (long)disp32;
        }
    }
}
'@
}
if (-not ('Allium.PeSectionEnumerator' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    internal static class HRsNative
    {
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool ReadProcessMemory(
            SafeProcessHandle hProcess,
            IntPtr            lpBaseAddress,
            [Out] byte[]      lpBuffer,
            UIntPtr           nSize,
            out UIntPtr       lpNumberOfBytesRead);
    }
    public sealed class PeSection
    {
        public readonly string Name;
        public readonly IntPtr VirtualAddress;
        public readonly uint   VirtualSize;
        public PeSection(string name, IntPtr va, uint vsize) { Name=name; VirtualAddress=va; VirtualSize=vsize; }
    }
    public static class PeSectionEnumerator
    {
        public static PeSection[] Enumerate(SafeProcessHandle h, IntPtr moduleBase)
        {
            if (h == null || h.IsInvalid || h.IsClosed) return new PeSection[0];
            if (moduleBase == IntPtr.Zero) return new PeSection[0];
            byte[] dos = new byte[64];
            UIntPtr nr;
            if (!HRsNative.ReadProcessMemory(h, moduleBase, dos, (UIntPtr)64, out nr)) return new PeSection[0];
            if (nr.ToUInt32() != 64) return new PeSection[0];
            if (dos[0] != 0x4D || dos[1] != 0x5A) return new PeSection[0];
            int eLfanew = BitConverter.ToInt32(dos, 0x3C);
            byte[] nt = new byte[24];
            if (!HRsNative.ReadProcessMemory(h, (IntPtr)(moduleBase.ToInt64() + eLfanew), nt, (UIntPtr)24, out nr)) return new PeSection[0];
            if (nr.ToUInt32() != 24) return new PeSection[0];
            if (nt[0] != 0x50 || nt[1] != 0x45 || nt[2] != 0 || nt[3] != 0) return new PeSection[0];
            ushort numberOfSections    = BitConverter.ToUInt16(nt, 6);
            ushort sizeOfOptionalHeader = BitConverter.ToUInt16(nt, 20);
            long sectionTableStart = moduleBase.ToInt64() + eLfanew + 24 + sizeOfOptionalHeader;
            const int sectionEntrySize = 40;
            byte[] sectionTable = new byte[numberOfSections * sectionEntrySize];
            if (!HRsNative.ReadProcessMemory(h, (IntPtr)sectionTableStart, sectionTable, (UIntPtr)sectionTable.Length, out nr)) return new PeSection[0];
            PeSection[] result = new PeSection[numberOfSections];
            for (int i = 0; i < numberOfSections; i++)
            {
                int off = i * sectionEntrySize;
                string name = Encoding.ASCII.GetString(sectionTable, off, 8).TrimEnd('\0');
                uint vsize = BitConverter.ToUInt32(sectionTable, off + 8);
                uint vrva  = BitConverter.ToUInt32(sectionTable, off + 12);
                IntPtr vaAbs = (IntPtr)(moduleBase.ToInt64() + vrva);
                result[i] = new PeSection(name, vaAbs, vsize);
            }
            return result;
        }
        public static PeSection FindByName(PeSection[] sections, string name)
        {
            if (sections == null) return null;
            for (int i = 0; i < sections.Length; i++)
                if (sections[i] != null && string.Equals(sections[i].Name, name, StringComparison.Ordinal))
                    return sections[i];
            return null;
        }
    }
    public static class RdataStringFinder
    {
        public static IntPtr FindString(SafeProcessHandle h, PeSection section, string needle)
        {
            if (h == null || h.IsInvalid || h.IsClosed) return IntPtr.Zero;
            if (section == null || needle == null) return IntPtr.Zero;
            if (section.VirtualSize == 0) return IntPtr.Zero;
            byte[] target = Encoding.ASCII.GetBytes(needle + "\0");
            int targetLen = target.Length;
            const int CHUNK = 0x10000;
            int overlap = Math.Max(0, targetLen - 1);
            byte[] buf = new byte[CHUNK + overlap];
            long pos = section.VirtualAddress.ToInt64();
            long end = pos + section.VirtualSize;
            while (pos < end)
            {
                long remaining = end - pos;
                int want = (int)Math.Min((long)(CHUNK + overlap), remaining);
                UIntPtr got;
                bool ok = HRsNative.ReadProcessMemory(h, (IntPtr)pos, buf, (UIntPtr)want, out got);
                int gotInt = (int)got.ToUInt32();
                if (gotInt >= targetLen)
                {
                    int limit = gotInt - targetLen;
                    for (int i = 0; i <= limit; i++)
                    {
                        bool match = true;
                        for (int j = 0; j < targetLen; j++)
                        {
                            if (buf[i + j] != target[j]) { match = false; break; }
                        }
                        if (match) return (IntPtr)(pos + i);
                    }
                }
                if (!ok || gotInt < want) break;
                pos += CHUNK;
            }
            return IntPtr.Zero;
        }
    }
    public static class XrefScanner
    {
        public static IntPtr[] FindRefsToAddress(SafeProcessHandle h, PeSection section, IntPtr targetAddress)
        {
            if (h == null || h.IsInvalid || h.IsClosed) return new IntPtr[0];
            if (section == null || targetAddress == IntPtr.Zero) return new IntPtr[0];
            System.Collections.Generic.List<IntPtr> hits = new System.Collections.Generic.List<IntPtr>();
            const int INST = 7;
            const int CHUNK = 0x10000;
            int overlap = INST - 1;
            byte[] buf = new byte[CHUNK + overlap];
            long targetI = targetAddress.ToInt64();
            long pos = section.VirtualAddress.ToInt64();
            long end = pos + section.VirtualSize;
            while (pos < end)
            {
                long remaining = end - pos;
                int want = (int)Math.Min((long)(CHUNK + overlap), remaining);
                UIntPtr got;
                bool ok = HRsNative.ReadProcessMemory(h, (IntPtr)pos, buf, (UIntPtr)want, out got);
                int gotInt = (int)got.ToUInt32();
                if (gotInt >= INST)
                {
                    int limit = gotInt - INST;
                    for (int i = 0; i <= limit; i++)
                    {
                        byte b0 = buf[i];
                        byte b1 = buf[i+1];
                        byte b2 = buf[i+2];
                        bool shape = false;
                        if (b0 == 0x48 && (b1 == 0x8B || b1 == 0x8D))
                        {
                            byte mod = (byte)(b2 & 0xC0);
                            byte rm  = (byte)(b2 & 0x07);
                            if (mod == 0x00 && rm == 0x05) shape = true;
                        }
                        else if (b0 == 0x4C && b1 == 0x8D)
                        {
                            byte mod = (byte)(b2 & 0xC0);
                            byte rm  = (byte)(b2 & 0x07);
                            if (mod == 0x00 && rm == 0x05) shape = true;
                        }
                        if (shape)
                        {
                            int disp = BitConverter.ToInt32(buf, i + 3);
                            long instAddr = pos + i;
                            long computed = instAddr + INST + (long)disp;
                            if (computed == targetI)
                            {
                                hits.Add((IntPtr)instAddr);
                            }
                        }
                    }
                }
                if (!ok || gotInt < want) break;
                pos += CHUNK;
            }
            return hits.ToArray();
        }
    }
}
'@
}
if (-not ('Allium.StaticFlagExtractor' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct SFE_MBI
    {
        public IntPtr BaseAddress;
        public IntPtr AllocationBase;
        public uint   AllocationProtect;
        public uint   __align1;
        public UIntPtr RegionSize;
        public uint   State;
        public uint   Protect;
        public uint   Type;
        public uint   __align2;
    }
    internal static class SFENative
    {
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool ReadProcessMemory(
            SafeProcessHandle hProcess,
            IntPtr            lpBaseAddress,
            [Out] byte[]      lpBuffer,
            UIntPtr           nSize,
            out UIntPtr       lpNumberOfBytesRead);
        [DllImport("kernel32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern UIntPtr VirtualQueryEx(
            SafeProcessHandle hProcess,
            IntPtr            lpAddress,
            out SFE_MBI       lpBuffer,
            UIntPtr           dwLength);
    }
    public sealed class SFEFlag
    {
        public readonly string Name;
        public readonly IntPtr ValueAddr;
        public readonly IntPtr NameAddr;
        public readonly IntPtr LeaRdxAddr;
        public readonly string ValueLeaReg;
        public SFEFlag(string name, IntPtr valueAddr, IntPtr nameAddr, IntPtr leaRdxAddr, string valueLeaReg)
        {
            Name = name; ValueAddr = valueAddr; NameAddr = nameAddr;
            LeaRdxAddr = leaRdxAddr; ValueLeaReg = valueLeaReg;
        }
    }
    public sealed class SFEExtractResult
    {
        public readonly SFEFlag[] Flags;
        public readonly int LeaRdxHits;
        public readonly int NameStringHits;
        public readonly int AllowlistHits;
        public readonly int PairedWithValueLea;
        public readonly int TextBytesScanned;
        public readonly long TextBytesReadable;
        public readonly long TextBytesSkipped;
        public readonly int  TextRegionsSkipped;
        public readonly long RdataBytesReadable;
        public readonly long RdataBytesSkipped;
        public readonly int  RdataRegionsSkipped;
        public SFEExtractResult(SFEFlag[] flags, int leaRdxHits, int nameStringHits,
                                int allowlistHits, int pairedWithValueLea, int textBytesScanned,
                                long textBytesReadable, long textBytesSkipped, int textRegionsSkipped,
                                long rdataBytesReadable, long rdataBytesSkipped, int rdataRegionsSkipped)
        {
            Flags = flags;
            LeaRdxHits = leaRdxHits;
            NameStringHits = nameStringHits;
            AllowlistHits = allowlistHits;
            PairedWithValueLea = pairedWithValueLea;
            TextBytesScanned = textBytesScanned;
            TextBytesReadable = textBytesReadable;
            TextBytesSkipped = textBytesSkipped;
            TextRegionsSkipped = textRegionsSkipped;
            RdataBytesReadable = rdataBytesReadable;
            RdataBytesSkipped = rdataBytesSkipped;
            RdataRegionsSkipped = rdataRegionsSkipped;
        }
    }
    public static class StaticFlagExtractor
    {
        private const int LEA_INSTR_LEN = 7;
        private const int VALUE_LEA_WINDOW = 64;
        private const uint MEM_COMMIT     = 0x00001000;
        private const uint PAGE_NOACCESS  = 0x00000001;
        private const uint PAGE_GUARD     = 0x00000100;
        private static byte[] ReadSection(SafeProcessHandle h, IntPtr sectionVA, uint sectionSize,
                                           out long bytesReadable, out long bytesSkipped, out int regionsSkipped)
        {
            bytesReadable = 0;
            bytesSkipped = 0;
            regionsSkipped = 0;
            long total = (long)sectionSize;
            if (total <= 0) return new byte[0];
            byte[] result = new byte[total];
            long sectionStart = sectionVA.ToInt64();
            long sectionEnd = sectionStart + total;
            long addr = sectionStart;
            UIntPtr mbiSize = (UIntPtr)Marshal.SizeOf(typeof(SFE_MBI));
            const int CHUNK = 0x100000;
            while (addr < sectionEnd)
            {
                SFE_MBI mbi;
                UIntPtr q = SFENative.VirtualQueryEx(h, (IntPtr)addr, out mbi, mbiSize);
                if (q == UIntPtr.Zero) break;
                long regionStart = mbi.BaseAddress.ToInt64();
                long regionSize = (long)mbi.RegionSize.ToUInt64();
                long regionEnd = regionStart + regionSize;
                if (regionEnd > sectionEnd) regionEnd = sectionEnd;
                long clipStart = Math.Max(regionStart, addr);
                long clipEnd = regionEnd;
                long clipLen = clipEnd - clipStart;
                if (clipLen <= 0) { addr = regionEnd; continue; }
                bool skip = (mbi.State != MEM_COMMIT) ||
                            ((mbi.Protect & PAGE_NOACCESS) != 0) ||
                            ((mbi.Protect & PAGE_GUARD)    != 0);
                if (skip)
                {
                    bytesSkipped += clipLen;
                    regionsSkipped++;
                    addr = regionEnd;
                    continue;
                }
                long readOffset = clipStart - sectionStart;
                long pos = clipStart;
                while (pos < clipEnd)
                {
                    int want = (int)Math.Min((long)CHUNK, clipEnd - pos);
                    byte[] scratch = new byte[want];
                    UIntPtr got;
                    bool ok = SFENative.ReadProcessMemory(h, (IntPtr)pos, scratch, (UIntPtr)want, out got);
                    int gotI = (int)got.ToUInt32();
                    if (!ok && gotI == 0) break;
                    if (gotI > 0)
                    {
                        Array.Copy(scratch, 0, result, readOffset + (pos - clipStart), gotI);
                        bytesReadable += gotI;
                    }
                    if (!ok || gotI < want) break;
                    pos += gotI;
                }
                addr = regionEnd;
            }
            return result;
        }
        private static string ReadCStringFromBuffer(byte[] rdataBytes, long rdataStart, long absAddr, int maxLen)
        {
            if (rdataBytes == null || rdataBytes.Length == 0) return null;
            long off = absAddr - rdataStart;
            if (off < 0 || off >= rdataBytes.Length) return null;
            int start = (int)off;
            int limit = Math.Min(rdataBytes.Length, start + maxLen);
            int end = start;
            while (end < limit && rdataBytes[end] != 0) end++;
            if (end == start) return null;
            try { return Encoding.ASCII.GetString(rdataBytes, start, end - start); }
            catch { return null; }
        }
        private static long TryLeaTarget(byte[] textBytes, int off, long textStart,
                                          long rangeStart, long rangeEnd, byte reqOp0, byte reqOp1, byte reqOp2)
        {
            if (off < 0 || off + LEA_INSTR_LEN > textBytes.Length) return 0;
            if (textBytes[off] != reqOp0) return 0;
            if (textBytes[off+1] != reqOp1) return 0;
            if (textBytes[off+2] != reqOp2) return 0;
            int disp = BitConverter.ToInt32(textBytes, off + 3);
            long instAddr = textStart + off;
            long target = instAddr + LEA_INSTR_LEN + disp;
            if (target < rangeStart || target >= rangeEnd) return 0;
            return target;
        }
        public static SFEExtractResult Extract(
            SafeProcessHandle h,
            IntPtr textVA,
            uint textSize,
            IntPtr rdataVA,
            uint rdataSize,
            HashSet<string> allowedNames,
            int maxNameLen)
        {
            long textReadable = 0, textSkipped = 0;
            int  textRegionsSkipped = 0;
            long rdataReadable = 0, rdataSkipped = 0;
            int  rdataRegionsSkipped = 0;
            if (h == null || h.IsInvalid || h.IsClosed)
                return new SFEExtractResult(new SFEFlag[0], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            if (textVA == IntPtr.Zero || rdataVA == IntPtr.Zero || textSize == 0 || rdataSize == 0)
                return new SFEExtractResult(new SFEFlag[0], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            if (maxNameLen <= 0) maxNameLen = 128;
            byte[] textBytes = ReadSection(h, textVA, textSize,
                                            out textReadable, out textSkipped, out textRegionsSkipped);
            if (textBytes.Length < 32)
                return new SFEExtractResult(new SFEFlag[0], 0, 0, 0, 0, 0,
                                             textReadable, textSkipped, textRegionsSkipped,
                                             0, 0, 0);
            byte[] rdataBytes = ReadSection(h, rdataVA, rdataSize,
                                             out rdataReadable, out rdataSkipped, out rdataRegionsSkipped);
            long textStart = textVA.ToInt64();
            long rdataStart = rdataVA.ToInt64();
            long rdataEnd = rdataStart + (long)rdataSize;
            List<SFEFlag> results = new List<SFEFlag>(16384);
            HashSet<string> seenNames = new HashSet<string>(StringComparer.Ordinal);
            int leaRdxHits = 0;
            int nameStringHits = 0;
            int allowlistHits = 0;
            int pairedCount = 0;
            int limit = textBytes.Length - LEA_INSTR_LEN;
            for (int i = 0; i < limit; i++)
            {
                if (textBytes[i] != 0x48) continue;
                if (textBytes[i+1] != 0x8D) continue;
                if (textBytes[i+2] != 0x15) continue;
                leaRdxHits++;
                long nameTarget = TryLeaTarget(textBytes, i, textStart,
                                                rdataStart, rdataEnd, 0x48, 0x8D, 0x15);
                if (nameTarget == 0) continue;
                nameStringHits++;
                string name = ReadCStringFromBuffer(rdataBytes, rdataStart, nameTarget, maxNameLen);
                if (string.IsNullOrEmpty(name)) continue;
                if (allowedNames != null && !allowedNames.Contains(name)) continue;
                allowlistHits++;
                if (!seenNames.Add(name)) continue;
                long valueAddr = 0;
                string valueReg = null;
                long leaRdxInstAddr = textStart + i;
                int winStart = Math.Max(0, i - VALUE_LEA_WINDOW);
                int winEnd = Math.Min(limit, i + VALUE_LEA_WINDOW);
                for (int j = winStart; j < winEnd && valueAddr == 0; j++)
                {
                    if (j == i) continue;
                    long t = TryLeaTarget(textBytes, j, textStart,
                                           rdataEnd, textStart + 0x20000000L,
                                           0x4C, 0x8D, 0x05);
                    if (t != 0) { valueAddr = t; valueReg = "r8"; }
                }
                if (valueAddr == 0)
                {
                    for (int j = winStart; j < winEnd && valueAddr == 0; j++)
                    {
                        if (j == i) continue;
                        long t = TryLeaTarget(textBytes, j, textStart,
                                               rdataEnd, textStart + 0x20000000L,
                                               0x48, 0x8D, 0x0D);
                        if (t != 0) { valueAddr = t; valueReg = "rcx"; }
                    }
                }
                if (valueAddr == 0)
                {
                    for (int j = winStart; j < winEnd && valueAddr == 0; j++)
                    {
                        if (j == i) continue;
                        long t = TryLeaTarget(textBytes, j, textStart,
                                               rdataEnd, textStart + 0x20000000L,
                                               0x48, 0x8D, 0x15);
                        if (t != 0) { valueAddr = t; valueReg = "rdx2"; }
                    }
                }
                if (valueAddr != 0)
                {
                    pairedCount++;
                    results.Add(new SFEFlag(
                        name,
                        (IntPtr)valueAddr,
                        (IntPtr)nameTarget,
                        (IntPtr)leaRdxInstAddr,
                        valueReg));
                }
            }
            return new SFEExtractResult(
                results.ToArray(),
                leaRdxHits,
                nameStringHits,
                allowlistHits,
                pairedCount,
                textBytes.Length,
                textReadable, textSkipped, textRegionsSkipped,
                rdataReadable, rdataSkipped, rdataRegionsSkipped);
        }
    }
    public sealed class ContainerFlagEntry
    {
        public readonly string Name;
        public readonly ulong  Rva;
        public ContainerFlagEntry(string name, ulong rva) { Name = name; Rva = rva; }
    }
    public sealed class ContainerScanResult
    {
        public readonly IntPtr  ContainerAddr;
        public readonly ulong   ElementCount;
        public readonly long    BytesScanned;
        public readonly int     RegionsScanned;
        public readonly int     RegionsSkipped;
        public readonly ContainerFlagEntry[] Flags;
        public readonly string  Error;
        public ContainerScanResult(IntPtr containerAddr, ulong elementCount, long bytesScanned,
                              int regionsScanned, int regionsSkipped, ContainerFlagEntry[] flags, string error)
        {
            ContainerAddr = containerAddr; ElementCount = elementCount;
            BytesScanned = bytesScanned; RegionsScanned = regionsScanned;
            RegionsSkipped = regionsSkipped; Flags = flags; Error = error;
        }
    }
    public static class ContainerScanner
    {
        private const uint MEM_COMMIT      = 0x00001000;
        private const uint PAGE_NOACCESS   = 0x00000001;
        private const uint PAGE_GUARD      = 0x00000100;
        private const uint MAGIC_HDR       = 0x3F800000;
        private const ulong MIN_ELEM_COUNT = 5000;
        private const ulong MAX_ELEM_COUNT = 50000;
        private const ulong SENTINEL_30    = 0x7FFF;
        private const ulong SENTINEL_38    = 0x8000;
        private const long  MIN_HEAP_PTR   = 0x10000;
        private const long  MAX_HEAP_PTR   = 0x7FFFFFFFFFFFL;
        private static bool IsValidPtr(long p) { return p > MIN_HEAP_PTR && p < MAX_HEAP_PTR; }
        public static IntPtr FindContainer(SafeProcessHandle h, IntPtr moduleBase, uint moduleSize,
                                            out long bytesScanned, out int regionsScanned, out int regionsSkipped)
        {
            bytesScanned = 0; regionsScanned = 0; regionsSkipped = 0;
            if (h == null || h.IsInvalid || h.IsClosed) return IntPtr.Zero;
            if (moduleBase == IntPtr.Zero || moduleSize == 0) return IntPtr.Zero;
            long moduleEnd = moduleBase.ToInt64() + (long)moduleSize;
            long addr = moduleBase.ToInt64() + ((long)moduleSize / 2);
            UIntPtr mbiSize = (UIntPtr)Marshal.SizeOf(typeof(SFE_MBI));
            const int CHUNK = 0x100000;
            byte[] chunk = new byte[CHUNK];
            byte[] hdr = new byte[0x40];
            while (addr < moduleEnd)
            {
                SFE_MBI mbi;
                UIntPtr q = SFENative.VirtualQueryEx(h, (IntPtr)addr, out mbi, mbiSize);
                if (q == UIntPtr.Zero) break;
                long regionEnd = mbi.BaseAddress.ToInt64() + (long)mbi.RegionSize.ToUInt64();
                if (regionEnd > moduleEnd) regionEnd = moduleEnd;
                long clipStart = Math.Max(mbi.BaseAddress.ToInt64(), addr);
                long clipLen = regionEnd - clipStart;
                if (clipLen <= 0) { addr = regionEnd; continue; }
                bool skip = (mbi.State != MEM_COMMIT) ||
                            ((mbi.Protect & PAGE_NOACCESS) != 0) ||
                            ((mbi.Protect & PAGE_GUARD) != 0);
                if (skip) { regionsSkipped++; addr = regionEnd; continue; }
                regionsScanned++;
                long pos = clipStart;
                while (pos < regionEnd)
                {
                    int want = (int)Math.Min((long)CHUNK, regionEnd - pos);
                    UIntPtr got;
                    bool ok = SFENative.ReadProcessMemory(h, (IntPtr)pos, chunk, (UIntPtr)want, out got);
                    int gotI = (int)got.ToUInt32();
                    if (!ok && gotI == 0) break;
                    bytesScanned += gotI;
                    int scanLimit = gotI - 7;
                    for (int i = 0; i < scanLimit; i += 8)
                    {
                        long ptr = BitConverter.ToInt64(chunk, i);
                        if (!IsValidPtr(ptr)) continue;
                        UIntPtr hdrGot;
                        bool hdrOk = SFENative.ReadProcessMemory(h, (IntPtr)ptr, hdr, (UIntPtr)0x40, out hdrGot);
                        if (!hdrOk || hdrGot.ToUInt32() < 0x40) continue;
                        uint  v00 = BitConverter.ToUInt32(hdr, 0x00);
                        long  v08 = BitConverter.ToInt64(hdr, 0x08);
                        ulong v10 = BitConverter.ToUInt64(hdr, 0x10);
                        ulong v30 = BitConverter.ToUInt64(hdr, 0x30);
                        ulong v38 = BitConverter.ToUInt64(hdr, 0x38);
                        if (v00 != MAGIC_HDR) continue;
                        if (!IsValidPtr(v08)) continue;
                        if (v10 <= MIN_ELEM_COUNT || v10 >= MAX_ELEM_COUNT) continue;
                        if (v30 != SENTINEL_30) continue;
                        if (v38 != SENTINEL_38) continue;
                        return (IntPtr)ptr;
                    }
                    if (!ok || gotI < want) break;
                    pos += gotI;
                }
                addr = regionEnd;
            }
            return IntPtr.Zero;
        }
        private static string ReadStdString(SafeProcessHandle h, long addr)
        {
            byte[] raw = new byte[0x20];
            UIntPtr got;
            if (!SFENative.ReadProcessMemory(h, (IntPtr)addr, raw, (UIntPtr)0x20, out got) || got.ToUInt32() < 0x20)
                return null;
            ulong sz  = BitConverter.ToUInt64(raw, 0x10);
            ulong cap = BitConverter.ToUInt64(raw, 0x18);
            if (sz == 0 || sz > 4096 || cap > 0xFFFFFF) return null;
            try
            {
                if (cap >= 16)
                {
                    long ptr = BitConverter.ToInt64(raw, 0);
                    if (!IsValidPtr(ptr)) return null;
                    int wantN = (int)Math.Min(sz, 512UL);
                    byte[] buf = new byte[wantN];
                    UIntPtr got2;
                    if (!SFENative.ReadProcessMemory(h, (IntPtr)ptr, buf, (UIntPtr)wantN, out got2) || got2.ToUInt32() == 0)
                        return null;
                    return Encoding.UTF8.GetString(buf, 0, (int)got2.ToUInt32());
                }
                else
                {
                    return Encoding.UTF8.GetString(raw, 0, (int)sz);
                }
            }
            catch { return null; }
        }
        public static ContainerScanResult DumpContainer(SafeProcessHandle h, IntPtr containerAddr, IntPtr moduleBase, uint moduleSize)
        {
            if (h == null || h.IsInvalid || h.IsClosed || containerAddr == IntPtr.Zero)
                return new ContainerScanResult(IntPtr.Zero, 0, 0, 0, 0, new ContainerFlagEntry[0], "invalid handle or container");
            byte[] tmp = new byte[8];
            UIntPtr got;
            long containerL = containerAddr.ToInt64();
            if (!SFENative.ReadProcessMemory(h, (IntPtr)(containerL + 8), tmp, (UIntPtr)8, out got) || got.ToUInt32() < 8)
                return new ContainerScanResult(containerAddr, 0, 0, 0, 0, new ContainerFlagEntry[0], "list_head read failed");
            long listHead = BitConverter.ToInt64(tmp, 0);
            if (!IsValidPtr(listHead))
                return new ContainerScanResult(containerAddr, 0, 0, 0, 0, new ContainerFlagEntry[0], "list_head invalid");
            if (!SFENative.ReadProcessMemory(h, (IntPtr)(containerL + 0x10), tmp, (UIntPtr)8, out got) || got.ToUInt32() < 8)
                return new ContainerScanResult(containerAddr, 0, 0, 0, 0, new ContainerFlagEntry[0], "count read failed");
            ulong count = BitConverter.ToUInt64(tmp, 0);
            List<ContainerFlagEntry> results = new List<ContainerFlagEntry>(16384);
            HashSet<string> seen = new HashSet<string>(StringComparer.Ordinal);
            HashSet<long> visited = new HashSet<long>();
            if (!SFENative.ReadProcessMemory(h, (IntPtr)listHead, tmp, (UIntPtr)8, out got) || got.ToUInt32() < 8)
                return new ContainerScanResult(containerAddr, count, 0, 0, 0, new ContainerFlagEntry[0], "first node read failed");
            long node = BitConverter.ToInt64(tmp, 0);
            long moduleBaseL = moduleBase.ToInt64();
            long moduleEndL = moduleBaseL + (long)moduleSize;
            ulong maxIter = count + 100;
            ulong iter = 0;
            while (IsValidPtr(node) && node != listHead && iter < maxIter)
            {
                if (!visited.Add(node)) break;
                iter++;
                int[,] offsetPairs = new int[,] { { 0x10, 0x30 }, { 0x50, 0x70 } };
                for (int p = 0; p < 2; p++)
                {
                    int nameOff = offsetPairs[p, 0];
                    int descOff = offsetPairs[p, 1];
                    string name = ReadStdString(h, node + nameOff);
                    if (string.IsNullOrEmpty(name)) continue;
                    if (!seen.Add(name)) continue;
                    if (!SFENative.ReadProcessMemory(h, (IntPtr)(node + descOff), tmp, (UIntPtr)8, out got) || got.ToUInt32() < 8)
                        continue;
                    long descPtr = BitConverter.ToInt64(tmp, 0);
                    if (!IsValidPtr(descPtr)) continue;
                    if (!SFENative.ReadProcessMemory(h, (IntPtr)(descPtr + 0xC0), tmp, (UIntPtr)8, out got) || got.ToUInt32() < 8)
                        continue;
                    long flagAddr = BitConverter.ToInt64(tmp, 0);
                    if (flagAddr < moduleBaseL || flagAddr >= moduleEndL) continue;
                    ulong rva = (ulong)(flagAddr - moduleBaseL);
                    results.Add(new ContainerFlagEntry(name, rva));
                }
                if (!SFENative.ReadProcessMemory(h, (IntPtr)node, tmp, (UIntPtr)8, out got) || got.ToUInt32() < 8)
                    break;
                node = BitConverter.ToInt64(tmp, 0);
            }
            return new ContainerScanResult(containerAddr, count, 0, 0, 0, results.ToArray(), null);
        }
    }
}
'@
}
if (-not ('Allium.FlagValueMapScanner' -as [type])) {
Add-Type -Language CSharp -ErrorAction SilentlyContinue -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;
namespace Allium
{
    public sealed class FlagValueMapEntry
    {
        public string Name;
        public string Type;
        public string RvaHex;
        public string Value;
    }
    public sealed class FlagValueMapResult
    {
        public long   MapAddress;
        public long   MapStart;
        public long   MapEnd;
        public int    WalkCount;
        public int    FvarMatchScore;
        public int    CandidatesEvaluated;
        public int    IntCount;
        public int    FlagCount;
        public int    StringCount;
        public int    LogCount;
        public int    FlagAltCount;
        public int    UnknownCount;
        public List<FlagValueMapEntry> Flags;
        public string Error;
    }
    internal static class FVMSNative
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool ReadProcessMemory(
            SafeProcessHandle h, IntPtr addr, byte[] buf, UIntPtr size, out UIntPtr nread);
    }
    public static class FlagValueMapScanner
    {
        private const ulong SENTINEL_1F = 0x3F800000UL;
        private const long  MIN_HEAP    = 0x100000L;
        private const long  MAX_HEAP    = 0x7FFFFFFFFFFFL;
        private const long VT_INT       = 0x6AD3800L;
        private const long VT_FLAG      = 0x6AD3918L;
        private const long VT_STRING    = 0x6AD3A68L;
        private const long VT_LOG       = 0x6AD4550L;
        private const long VT_FLAG_ALT  = 0x6AD4668L;
        private static byte[] Read(SafeProcessHandle h, long addr, int size)
        {
            byte[] buf = new byte[size];
            UIntPtr nread;
            bool ok = FVMSNative.ReadProcessMemory(h, (IntPtr)addr, buf, (UIntPtr)size, out nread);
            int got = (int)nread.ToUInt64();
            if (!ok && got == 0) return null;
            if (got < size) { byte[] t = new byte[got]; Array.Copy(buf, t, got); return t; }
            return buf;
        }
        private static long ReadPtr(SafeProcessHandle h, long addr)
        {
            byte[] b = Read(h, addr, 8);
            if (b == null || b.Length < 8) return 0;
            return BitConverter.ToInt64(b, 0);
        }
        private static string DecodeMsvcString(SafeProcessHandle h, long bxAddr, int maxLen)
        {
            byte[] hdr = Read(h, bxAddr, 32);
            if (hdr == null || hdr.Length < 32) return string.Empty;
            long size = BitConverter.ToInt64(hdr, 16);
            long cap  = BitConverter.ToInt64(hdr, 24);
            if (size <= 0 || size > maxLen) return string.Empty;
            int take = (int)size;
            if (cap <= 15)
            {
                return Encoding.ASCII.GetString(hdr, 0, Math.Min(take, 16));
            }
            long strPtr = BitConverter.ToInt64(hdr, 0);
            if (strPtr <= 0) return string.Empty;
            byte[] strBuf = Read(h, strPtr, take);
            if (strBuf == null || strBuf.Length < take) return string.Empty;
            return Encoding.ASCII.GetString(strBuf, 0, take);
        }
        private static string TypeName(long vtRva)
        {
            if (vtRva == VT_INT)      return "Int";
            if (vtRva == VT_FLAG)     return "Flag";
            if (vtRva == VT_STRING)   return "String";
            if (vtRva == VT_LOG)      return "Log";
            if (vtRva == VT_FLAG_ALT) return "FlagAlt";
            return "Unknown";
        }
        public static FlagValueMapResult Scan(SafeProcessHandle h, IntPtr moduleBase,
                                              long scanStart, long scanEnd,
                                              int chunkSize, int maxCandidates,
                                              int maxNodes, int maxStringLen,
                                              long moduleSize, HashSet<string> fvarSet)
        {
            var result = new FlagValueMapResult { Flags = new List<FlagValueMapEntry>() };
            if (h == null || h.IsInvalid || h.IsClosed) { result.Error = "invalid handle"; return result; }
            long baseL = moduleBase.ToInt64();
            long modEnd = baseL + moduleSize;
            long bestCand = 0; int bestScore = 0; int candidatesFound = 0;
            long absStart = baseL + scanStart; long absEnd = baseL + scanEnd;
            long cur = absStart;
            while (cur < absEnd && candidatesFound < maxCandidates)
            {
                long thisChunk = Math.Min((long)chunkSize, absEnd - cur);
                if (thisChunk < 8) break;
                byte[] block = Read(h, cur, (int)thisChunk);
                if (block != null && block.Length >= 8)
                {
                    int pcount = block.Length / 8;
                    for (int i = 0; i < pcount; i++)
                    {
                        if (candidatesFound >= maxCandidates) break;
                        long maybe = BitConverter.ToInt64(block, i * 8);
                        if (maybe < MIN_HEAP || maybe > MAX_HEAP) continue;
                        byte[] hb = Read(h, maybe, 8);
                        if (hb == null || hb.Length < 8) continue;
                        ulong val = BitConverter.ToUInt64(hb, 0);
                        if (val != SENTINEL_1F) continue;
                        candidatesFound++;
                        long ms = ReadPtr(h, maybe + 8);
                        if (ms == 0) continue;
                        long probeNode = ReadPtr(h, ms);
                        int probeSteps = 0; int score = 0;
                        HashSet<long> pvis = new HashSet<long>();
                        while (probeSteps < 20 && probeNode != 0 && probeNode != ms)
                        {
                            if (pvis.Contains(probeNode)) break;
                            pvis.Add(probeNode);
                            probeSteps++;
                            string nm = DecodeMsvcString(h, probeNode + 0x10, maxStringLen);
                            if (!string.IsNullOrEmpty(nm) && fvarSet != null && fvarSet.Contains(nm)) score++;
                            probeNode = ReadPtr(h, probeNode);
                        }
                        if (score > bestScore) { bestScore = score; bestCand = maybe; }
                    }
                }
                cur += chunkSize;
            }
            result.CandidatesEvaluated = candidatesFound;
            result.FvarMatchScore = bestScore;
            if (bestCand == 0) { result.Error = "No FFlag map candidate found (FVariables cross-reference scored zero on all matches)"; return result; }
            result.MapAddress = bestCand;
            long mapStart = ReadPtr(h, bestCand + 8);
            if (mapStart == 0) { result.Error = "MapStart is Zero"; return result; }
            long mapEnd = ReadPtr(h, mapStart + 8);
            long first = ReadPtr(h, mapStart);
            if (first == 0) { result.Error = "First node is Zero"; return result; }
            result.MapStart = mapStart;
            result.MapEnd   = mapEnd;
            HashSet<long> visited = new HashSet<long>();
            long node = first;
            int walk = 0;
            while (walk < maxNodes && node != 0 && node != mapStart && node != mapEnd)
            {
                if (visited.Contains(node)) break;
                visited.Add(node);
                walk++;
                byte[] nb = Read(h, node, 128);
                if (nb == null || nb.Length < 0x40) { node = ReadPtr(h, node); continue; }
                long nextNode = BitConverter.ToInt64(nb, 0);
                string decName = string.Empty;
                long nsize = BitConverter.ToInt64(nb, 0x20);
                long ncap  = BitConverter.ToInt64(nb, 0x28);
                if (nsize > 0 && nsize <= maxStringLen)
                {
                    int take = (int)nsize;
                    if (ncap <= 15) {
                        int avail = Math.Min(take, 16);
                        decName = Encoding.ASCII.GetString(nb, 0x10, avail);
                    } else {
                        long strPtr = BitConverter.ToInt64(nb, 0x10);
                        if (strPtr > 0) {
                            byte[] sb = Read(h, strPtr, take);
                            if (sb != null && sb.Length >= take) decName = Encoding.ASCII.GetString(sb, 0, take);
                        }
                    }
                }
                if (string.IsNullOrEmpty(decName)) { node = nextNode; continue; }
                long getSetPtr = BitConverter.ToInt64(nb, 0x30);
                if (getSetPtr == 0) { node = nextNode; continue; }
                long vtable = ReadPtr(h, getSetPtr);
                long vtRva  = vtable - baseL;
                string typeName = TypeName(vtRva);
                switch (typeName) {
                    case "Int":      result.IntCount++;      break;
                    case "Flag":     result.FlagCount++;     break;
                    case "String":   result.StringCount++;   break;
                    case "Log":      result.LogCount++;      break;
                    case "FlagAlt":  result.FlagAltCount++;  break;
                    default:         result.UnknownCount++;  break;
                }
                byte[] raw16 = Read(h, getSetPtr + 0xC0, 16);
                string decValue = string.Empty; string rvaStr = string.Empty;
                if (raw16 != null && raw16.Length >= 8)
                {
                    if (typeName == "String")
                    {
                        byte[] szInline = Read(h, getSetPtr + 0xD0, 8);
                        byte[] cpInline = Read(h, getSetPtr + 0xD8, 8);
                        if (szInline != null && szInline.Length >= 8 && cpInline != null && cpInline.Length >= 8)
                        {
                            long szV = BitConverter.ToInt64(szInline, 0);
                            long cpV = BitConverter.ToInt64(cpInline, 0);
                            if (szV > 0 && szV <= maxStringLen)
                            {
                                int take = (int)szV;
                                if (cpV <= 15 && raw16.Length >= take) decValue = Encoding.ASCII.GetString(raw16, 0, take);
                                else if (cpV > 15) {
                                    long sp = BitConverter.ToInt64(raw16, 0);
                                    if (sp != 0) {
                                        byte[] sbuf = Read(h, sp, take);
                                        if (sbuf != null && sbuf.Length >= take) decValue = Encoding.ASCII.GetString(sbuf, 0, take);
                                    }
                                }
                            }
                        }
                        rvaStr = "inline-sso";
                    }
                    else if (typeName == "Int" || typeName == "Log" || typeName == "Flag" || typeName == "FlagAlt")
                    {
                        long stL = BitConverter.ToInt64(raw16, 0);
                        if (stL >= baseL && stL < modEnd)
                        {
                            long rvaL = stL - baseL;
                            rvaStr = rvaL.ToString("X");
                            byte[] vb = Read(h, stL, 4);
                            if (vb != null && vb.Length >= 4)
                            {
                                if (typeName == "Flag" || typeName == "FlagAlt")
                                {
                                    if (vb[0] == 0) decValue = "False";
                                    else if (vb[0] == 1) decValue = "True";
                                    else decValue = "byte=" + vb[0];
                                }
                                else
                                {
                                    decValue = BitConverter.ToInt32(vb, 0).ToString();
                                }
                            }
                        }
                    }
                    else
                    {
                        long stL = BitConverter.ToInt64(raw16, 0);
                        if (stL >= baseL && stL < modEnd) {
                            long rvaL = stL - baseL;
                            rvaStr = rvaL.ToString("X");
                        }
                    }
                }
                string __smVal = (typeName == "Unknown") ? ("VT:" + vtRva.ToString("X")) : decValue;
                var entry = new FlagValueMapEntry {
                    Name    = decName,
                    Type    = typeName,
                    RvaHex  = rvaStr,
                    Value   = __smVal
                };
                result.Flags.Add(entry);
                node = nextNode;
            }
            result.WalkCount = walk;
            return result;
        }
        public static FlagValueMapResult WalkKnownMap(SafeProcessHandle h,
                                                       IntPtr moduleBase,
                                                       long moduleSize,
                                                       long knownContainer,
                                                       int maxNodes,
                                                       int maxStringLen)
        {
            var result = new FlagValueMapResult { Flags = new List<FlagValueMapEntry>() };
            if (h == null || h.IsInvalid || h.IsClosed) { result.Error = "invalid handle"; return result; }
            if (knownContainer < MIN_HEAP || knownContainer > MAX_HEAP) { result.Error = "known container out of range"; return result; }
            long baseL = moduleBase.ToInt64();
            long modEnd = baseL + moduleSize;
            byte[] hb = Read(h, knownContainer, 8);
            if (hb == null || hb.Length < 8) { result.Error = "validation read failed"; return result; }
            ulong val = BitConverter.ToUInt64(hb, 0);
            if (val != SENTINEL_1F) { result.Error = "known container does not dereference to sentinel 0x3F800000"; return result; }
            result.MapAddress = knownContainer;
            long mapStart = ReadPtr(h, knownContainer + 8);
            if (mapStart == 0) { result.Error = "MapStart is Zero"; return result; }
            long mapEnd = ReadPtr(h, mapStart + 8);
            long first = ReadPtr(h, mapStart);
            if (first == 0) { result.Error = "First node is Zero"; return result; }
            result.MapStart = mapStart;
            result.MapEnd = mapEnd;
            result.CandidatesEvaluated = 0; 
            result.FvarMatchScore = 0;
            HashSet<long> visited = new HashSet<long>();
            long node = first;
            int walk = 0;
            while (walk < maxNodes && node != 0 && node != mapStart && node != mapEnd)
            {
                if (visited.Contains(node)) break;
                visited.Add(node);
                walk++;
                byte[] nb = Read(h, node, 128);
                if (nb == null || nb.Length < 0x40) { node = ReadPtr(h, node); continue; }
                long nextNode = BitConverter.ToInt64(nb, 0);
                string decName = string.Empty;
                long nsize = BitConverter.ToInt64(nb, 0x20);
                long ncap = BitConverter.ToInt64(nb, 0x28);
                if (nsize > 0 && nsize <= maxStringLen)
                {
                    int take = (int)nsize;
                    if (ncap <= 15) { int avail = Math.Min(take, 16); decName = Encoding.ASCII.GetString(nb, 0x10, avail); }
                    else {
                        long strPtr = BitConverter.ToInt64(nb, 0x10);
                        if (strPtr > 0) {
                            byte[] sb = Read(h, strPtr, take);
                            if (sb != null && sb.Length >= take) decName = Encoding.ASCII.GetString(sb, 0, take);
                        }
                    }
                }
                if (string.IsNullOrEmpty(decName)) { node = nextNode; continue; }
                long getSetPtr = BitConverter.ToInt64(nb, 0x30);
                if (getSetPtr == 0) { node = nextNode; continue; }
                long vtable = ReadPtr(h, getSetPtr);
                long vtRva = vtable - baseL;
                string typeName = TypeName(vtRva);
                switch (typeName) {
                    case "Int":      result.IntCount++;     break;
                    case "Flag":     result.FlagCount++;    break;
                    case "String":   result.StringCount++;  break;
                    case "Log":      result.LogCount++;     break;
                    case "FlagAlt":  result.FlagAltCount++; break;
                    default:         result.UnknownCount++; break;
                }
                byte[] raw16 = Read(h, getSetPtr + 0xC0, 16);
                string decValue = string.Empty; string rvaStr = string.Empty;
                if (raw16 != null && raw16.Length >= 8)
                {
                    if (typeName == "String") {
                        byte[] szInline = Read(h, getSetPtr + 0xD0, 8);
                        byte[] cpInline = Read(h, getSetPtr + 0xD8, 8);
                        if (szInline != null && szInline.Length >= 8 && cpInline != null && cpInline.Length >= 8) {
                            long szV = BitConverter.ToInt64(szInline, 0);
                            long cpV = BitConverter.ToInt64(cpInline, 0);
                            if (szV > 0 && szV <= maxStringLen) {
                                int take = (int)szV;
                                if (cpV <= 15 && raw16.Length >= take) decValue = Encoding.ASCII.GetString(raw16, 0, take);
                                else if (cpV > 15) {
                                    long sp = BitConverter.ToInt64(raw16, 0);
                                    if (sp != 0) {
                                        byte[] sbuf = Read(h, sp, take);
                                        if (sbuf != null && sbuf.Length >= take) decValue = Encoding.ASCII.GetString(sbuf, 0, take);
                                    }
                                }
                            }
                        }
                        rvaStr = "inline-sso";
                    } else if (typeName == "Int" || typeName == "Log" || typeName == "Flag" || typeName == "FlagAlt") {
                        long stL = BitConverter.ToInt64(raw16, 0);
                        if (stL >= baseL && stL < modEnd) {
                            long rvaL = stL - baseL;
                            rvaStr = rvaL.ToString("X");
                            byte[] vb = Read(h, stL, 4);
                            if (vb != null && vb.Length >= 4) {
                                if (typeName == "Flag" || typeName == "FlagAlt") {
                                    if (vb[0] == 0) decValue = "False"; else if (vb[0] == 1) decValue = "True"; else decValue = "byte=" + vb[0];
                                } else {
                                    decValue = BitConverter.ToInt32(vb, 0).ToString();
                                }
                            }
                        }
                    } else {
                        long stL = BitConverter.ToInt64(raw16, 0);
                        if (stL >= baseL && stL < modEnd) { long rvaL = stL - baseL; rvaStr = rvaL.ToString("X"); }
                    }
                }
                string __smVal = (typeName == "Unknown") ? ("VT:" + vtRva.ToString("X")) : decValue;
                var entry = new FlagValueMapEntry { Name = decName, Type = typeName, RvaHex = rvaStr, Value = __smVal };
                result.Flags.Add(entry);
                node = nextNode;
            }
            result.WalkCount = walk;
            return result;
        }
    }
}
'@
}
$script:HttpsCaCompileError = $null
if (-not ('Allium.HttpsCaGenerator' -as [type])) {
try {
Add-Type -Language CSharp -ErrorAction Stop -TypeDefinition @'
using System;
using System.IO;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
#pragma warning disable SYSLIB0057
namespace Allium
{
    public static class HttpsCaGenerator
    {
        public const string CaSubject = "CN=Allium Local Proxy CA, O=Allium, OU=HTTPS Interception";
        public const string PfxPassword = "allium";
        public static X509Certificate2 GenerateRootCa(int validityYears)
        {
            if (validityYears <= 0) { validityYears = 10; }
            RSA rsa = RSA.Create(3072);
            try
            {
                CertificateRequest req = new CertificateRequest(
                    CaSubject, rsa, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
                req.CertificateExtensions.Add(new X509BasicConstraintsExtension(
                    true, false, 0, true));
                req.CertificateExtensions.Add(new X509KeyUsageExtension(
                    X509KeyUsageFlags.KeyCertSign | X509KeyUsageFlags.CrlSign | X509KeyUsageFlags.DigitalSignature,
                    true));
                req.CertificateExtensions.Add(new X509SubjectKeyIdentifierExtension(
                    req.PublicKey, false));
                DateTimeOffset notBefore = DateTimeOffset.UtcNow.AddMinutes(-5);
                DateTimeOffset notAfter = notBefore.AddYears(validityYears);
                X509Certificate2 ephemeral = req.CreateSelfSigned(notBefore, notAfter);
                byte[] pfxBytes = ephemeral.Export(X509ContentType.Pfx, PfxPassword);
                ephemeral.Dispose();
                return new X509Certificate2(pfxBytes, PfxPassword,
                    X509KeyStorageFlags.Exportable | X509KeyStorageFlags.PersistKeySet);
            }
            finally
            {
                rsa.Dispose();
            }
        }
        public static byte[] ExportPfx(X509Certificate2 cert)
        {
            return cert.Export(X509ContentType.Pfx, PfxPassword);
        }
        public static string ExportPem(X509Certificate2 cert)
        {
            byte[] der = cert.Export(X509ContentType.Cert);
            string b64 = Convert.ToBase64String(der, Base64FormattingOptions.InsertLineBreaks);
            return "-----BEGIN CERTIFICATE-----\n" + b64 + "\n-----END CERTIFICATE-----\n";
        }
        public static X509Certificate2 LoadPfx(string path)
        {
            byte[] bytes = File.ReadAllBytes(path);
            return new X509Certificate2(bytes, PfxPassword,
                X509KeyStorageFlags.Exportable | X509KeyStorageFlags.PersistKeySet);
        }
        public static string FormatThumbprint(X509Certificate2 cert)
        {
            if (cert == null) { return ""; }
            string t = cert.Thumbprint;
            if (string.IsNullOrEmpty(t)) { return ""; }
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            for (int i = 0; i < t.Length; i += 2)
            {
                if (i > 0) { sb.Append(":"); }
                sb.Append(t.Substring(i, Math.Min(2, t.Length - i)));
            }
            return sb.ToString();
        }
    }
}
'@
} catch {
$script:HttpsCaCompileError = $_.Exception.Message
Write-Host ('[HTTPS CA] Add-Type FAILED: ' + $_.Exception.Message) -ForegroundColor Yellow
Write-Host '[HTTPS CA] Details captured in $script:HttpsCaCompileError' -ForegroundColor Yellow
}
}
$script:HttpsInterceptorCompileError = $null
if (-not ('Allium.HttpsInterceptor' -as [type])) {
try {
$__zstdScriptRoot = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
$PSScriptRoot
}
$__zstdDllProbe = Join-Path $__zstdScriptRoot 'data\deps\ZstdSharp.dll'
if (-not (Test-Path $__zstdDllProbe -PathType Leaf)) {
Write-Host '[HTTPS Proxy] Skipping HttpsInterceptor compile: ZstdSharp.dll missing at ' -NoNewline -ForegroundColor Yellow
Write-Host $__zstdDllProbe -ForegroundColor Yellow
Write-Host '[HTTPS Proxy] Re-run Allium-Setup.ps1 to install ZstdSharp.dll into data\deps\' -ForegroundColor Yellow
$script:HttpsInterceptorCompileError = 'ZstdSharp.dll missing; skipped compile'
return
}
$__zstdRefDir = Join-Path $PSHome 'ref'
$__zstdDefaultRefs = @()
if (Test-Path $__zstdRefDir -PathType Container) {
$__zstdDefaultRefs = @(Get-ChildItem -Path $__zstdRefDir -Filter '*.dll' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
}
if ($__zstdDefaultRefs.Count -eq 0) {
$__zstdDefaultRefs = @([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { -not $_.IsDynamic -and $_.Location } | ForEach-Object { $_.Location })
}
$__zstdAllRefs = @($__zstdDllProbe) + $__zstdDefaultRefs
Add-Type -Language CSharp -ErrorAction Stop -ReferencedAssemblies $__zstdAllRefs -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Threading;
using System.Threading.Tasks;
#pragma warning disable SYSLIB0057
namespace Allium
{
    public static class HttpsLeafCertFactory
    {
        public const string PfxPassword = "allium";
        private static X509Certificate2 _rootCa;
        private static readonly ConcurrentDictionary<string, X509Certificate2> _cache =
            new ConcurrentDictionary<string, X509Certificate2>(StringComparer.OrdinalIgnoreCase);
        public static bool HasRootCa { get { return _rootCa != null; } }
        public static int CachedCount { get { return _cache.Count; } }
        public static string RootCaThumbprint
        {
            get { return _rootCa == null ? "" : _rootCa.Thumbprint; }
        }
        public static void SetRootCa(X509Certificate2 rootCa)
        {
            if (rootCa == null) throw new ArgumentNullException("rootCa");
            if (!rootCa.HasPrivateKey) throw new ArgumentException("Root CA must have private key.");
            _rootCa = rootCa;
            _cache.Clear();
        }
        public static void Clear() { _cache.Clear(); }
        public static X509Certificate2 GetOrCreateLeaf(string hostname)
        {
            if (string.IsNullOrEmpty(hostname)) throw new ArgumentNullException("hostname");
            if (_rootCa == null) throw new InvalidOperationException("Root CA not set; call SetRootCa first.");
            return _cache.GetOrAdd(hostname, new Func<string, X509Certificate2>(MintLeaf));
        }
        private static X509Certificate2 MintLeaf(string hostname)
        {
            RSA rsa = RSA.Create(2048);
            try
            {
                CertificateRequest req = new CertificateRequest(
                    "CN=" + hostname, rsa, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
                req.CertificateExtensions.Add(new X509BasicConstraintsExtension(false, false, 0, false));
                req.CertificateExtensions.Add(new X509KeyUsageExtension(
                    X509KeyUsageFlags.DigitalSignature | X509KeyUsageFlags.KeyEncipherment, false));
                OidCollection ekus = new OidCollection();
                ekus.Add(new Oid("1.3.6.1.5.5.7.3.1"));
                req.CertificateExtensions.Add(new X509EnhancedKeyUsageExtension(ekus, false));
                SubjectAlternativeNameBuilder sanBuilder = new SubjectAlternativeNameBuilder();
                sanBuilder.AddDnsName(hostname);
                req.CertificateExtensions.Add(sanBuilder.Build());
                req.CertificateExtensions.Add(new X509SubjectKeyIdentifierExtension(req.PublicKey, false));
                byte[] serial = new byte[8];
                RandomNumberGenerator.Fill(serial);
                serial[0] = (byte)(serial[0] & 0x7F);
                DateTimeOffset notBefore = DateTimeOffset.UtcNow.AddMinutes(-5);
                DateTimeOffset notAfter = notBefore.AddYears(5);
                X509Certificate2 leaf = req.Create(_rootCa, notBefore, notAfter, serial);
                X509Certificate2 withKey = leaf.CopyWithPrivateKey(rsa);
                leaf.Dispose();
                byte[] pfxBytes = withKey.Export(X509ContentType.Pfx, PfxPassword);
                withKey.Dispose();
                return new X509Certificate2(
                    pfxBytes, PfxPassword,
                    X509KeyStorageFlags.Exportable | X509KeyStorageFlags.PersistKeySet);
            }
            finally { rsa.Dispose(); }
        }
    }
    public sealed class RequestRecord
    {
        public DateTime UtcTimestamp { get; set; }
        public string Method { get; set; }
        public string Host { get; set; }
        public string PathAndQuery { get; set; }
        public int UpstreamStatus { get; set; }
        public int UpstreamBytes { get; set; }
        public bool Modified { get; set; }
        public string Note { get; set; }
    }
    public static class RawDnsResolver
    {
        private const int DNS_PORT = 53;
        private const int TIMEOUT_MS = 3000;
        private static readonly TimeSpan CACHE_TTL = TimeSpan.FromMinutes(5);
        private static readonly IPAddress PRIMARY_DNS = IPAddress.Parse("1.1.1.1");
        private static readonly IPAddress FALLBACK_DNS = IPAddress.Parse("8.8.8.8");
        private sealed class CacheEntry
        {
            public IPAddress Address;
            public DateTime ExpiresUtc;
        }
        private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, CacheEntry> _cache =
            new System.Collections.Concurrent.ConcurrentDictionary<string, CacheEntry>(StringComparer.OrdinalIgnoreCase);
        public static async Task<IPAddress> ResolveAsync(string hostname, CancellationToken ct)
        {
            if (string.IsNullOrEmpty(hostname)) throw new ArgumentNullException("hostname");
            IPAddress literal;
            if (IPAddress.TryParse(hostname, out literal)) return literal;
            CacheEntry existing;
            if (_cache.TryGetValue(hostname, out existing))
            {
                if (DateTime.UtcNow < existing.ExpiresUtc)
                {
                    return existing.Address;
                }
                CacheEntry ignored;
                _cache.TryRemove(hostname, out ignored);
            }
            IPAddress result = null;
            try { result = await QueryAsync(PRIMARY_DNS, hostname, ct).ConfigureAwait(false); } catch { }
            if (result == null)
            {
                try { result = await QueryAsync(FALLBACK_DNS, hostname, ct).ConfigureAwait(false); } catch { }
            }
            if (result == null)
            {
                IPAddress[] sys = null;
                try { sys = await Dns.GetHostAddressesAsync(hostname, AddressFamily.InterNetwork, ct).ConfigureAwait(false); } catch { }
                if (sys != null && sys.Length > 0) result = sys[0];
            }
            if (result == null)
            {
                throw new System.Net.Sockets.SocketException(11001);
            }
            CacheEntry entry = new CacheEntry();
            entry.Address = result;
            entry.ExpiresUtc = DateTime.UtcNow.Add(CACHE_TTL);
            _cache[hostname] = entry;
            return result;
        }
        private static async Task<IPAddress> QueryAsync(IPAddress server, string hostname, CancellationToken ct)
        {
            byte[] query = BuildQueryPacket(hostname);
            using (UdpClient client = new UdpClient())
            {
                client.Client.SendTimeout = TIMEOUT_MS;
                client.Client.ReceiveTimeout = TIMEOUT_MS;
                await client.SendAsync(query, query.Length, new IPEndPoint(server, DNS_PORT)).ConfigureAwait(false);
                Task<UdpReceiveResult> recvTask = client.ReceiveAsync();
                Task timeoutTask = Task.Delay(TIMEOUT_MS, ct);
                Task completed = await Task.WhenAny(recvTask, timeoutTask).ConfigureAwait(false);
                if (completed == timeoutTask)
                {
                    throw new TimeoutException("DNS query to " + server + " timed out.");
                }
                UdpReceiveResult recv = await recvTask.ConfigureAwait(false);
                return ParseAnswer(recv.Buffer, query.Length);
            }
        }
        private static byte[] BuildQueryPacket(string hostname)
        {
            System.IO.MemoryStream ms = new System.IO.MemoryStream();
            byte[] idBytes = new byte[2];
            RandomNumberGenerator.Fill(idBytes);
            ms.Write(idBytes, 0, 2);
            ms.WriteByte(0x01); ms.WriteByte(0x00);  
            ms.WriteByte(0x00); ms.WriteByte(0x01);  
            ms.WriteByte(0x00); ms.WriteByte(0x00);  
            ms.WriteByte(0x00); ms.WriteByte(0x00);  
            ms.WriteByte(0x00); ms.WriteByte(0x00);  
            string[] labels = hostname.Split('.');
            foreach (string label in labels)
            {
                if (label.Length == 0 || label.Length > 63)
                    throw new ArgumentException("Invalid DNS label: '" + label + "'");
                byte[] labelBytes = System.Text.Encoding.ASCII.GetBytes(label);
                ms.WriteByte((byte)labelBytes.Length);
                ms.Write(labelBytes, 0, labelBytes.Length);
            }
            ms.WriteByte(0x00);  
            ms.WriteByte(0x00); ms.WriteByte(0x01);  
            ms.WriteByte(0x00); ms.WriteByte(0x01);  
            return ms.ToArray();
        }
        private static IPAddress ParseAnswer(byte[] resp, int queryLen)
        {
            if (resp == null || resp.Length < 12) return null;
            int ancount = (resp[6] << 8) | resp[7];
            if (ancount == 0) return null;
            int offset = queryLen;
            if (offset >= resp.Length) return null;
            for (int i = 0; i < ancount; i++)
            {
                if (offset >= resp.Length) return null;
                if ((resp[offset] & 0xc0) == 0xc0)
                {
                    offset += 2;
                }
                else
                {
                    while (offset < resp.Length && resp[offset] != 0)
                    {
                        offset += resp[offset] + 1;
                    }
                    offset++;
                }
                if (offset + 10 > resp.Length) return null;
                int type = (resp[offset] << 8) | resp[offset + 1];
                int cls = (resp[offset + 2] << 8) | resp[offset + 3];
                int rdlength = (resp[offset + 8] << 8) | resp[offset + 9];
                offset += 10;
                if (type == 1 && cls == 1 && rdlength == 4 && offset + 4 <= resp.Length)
                {
                    byte[] ipBytes = new byte[4];
                    Array.Copy(resp, offset, ipBytes, 0, 4);
                    return new IPAddress(ipBytes);
                }
                offset += rdlength;
            }
            return null;
        }
    }
    public static class ClientSettingsDictionaryCache
    {
        private const string DICTIONARY_HOST = "clientsettings.roblox.com";
        private const string DICTIONARY_PATH_PREFIX = "/v2/compression-dictionaries/";
        private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, byte[]> _cache =
            new System.Collections.Concurrent.ConcurrentDictionary<string, byte[]>(StringComparer.OrdinalIgnoreCase);
        public static int CacheEntryCount { get { return _cache.Count; } }
        public static long TotalCacheBytes
        {
            get
            {
                long total = 0;
                foreach (System.Collections.Generic.KeyValuePair<string, byte[]> kv in _cache)
                {
                    if (kv.Value != null) { total += kv.Value.Length; }
                }
                return total;
            }
        }
        public static string ExtractHashFromPath(string urlPath)
        {
            if (string.IsNullOrEmpty(urlPath)) return null;
            int lastSlash = urlPath.LastIndexOf('/');
            if (lastSlash < 0 || lastSlash + 1 >= urlPath.Length) return null;
            string leaf = urlPath.Substring(lastSlash + 1);
            int dot = leaf.IndexOf('.');
            string candidate = (dot > 0) ? leaf.Substring(0, dot) : leaf;
            if (candidate.Length != 64) return null;
            for (int i = 0; i < candidate.Length; i++)
            {
                char c = candidate[i];
                bool isHex = ((c >= '0' && c <= '9') ||
                              (c >= 'a' && c <= 'f') ||
                              (c >= 'A' && c <= 'F'));
                if (!isHex) return null;
            }
            return candidate.ToLowerInvariant();
        }
        public static byte[] TryGetCached(string sha256hex)
        {
            if (string.IsNullOrEmpty(sha256hex)) return null;
            byte[] hit;
            if (_cache.TryGetValue(sha256hex, out hit)) { return hit; }
            return null;
        }
        public static bool TryPutVerified(string sha256hex, byte[] dictBytes)
        {
            if (string.IsNullOrEmpty(sha256hex) || dictBytes == null) return false;
            string computed = ComputeSha256Hex(dictBytes);
            if (!string.Equals(computed, sha256hex, StringComparison.OrdinalIgnoreCase)) return false;
            _cache[sha256hex] = dictBytes;
            return true;
        }
        public static void Clear() { _cache.Clear(); }
        public static HttpClient CreateStandaloneHttpClient()
        {
            SocketsHttpHandler handler = new SocketsHttpHandler();
            handler.AutomaticDecompression = DecompressionMethods.None;
            handler.PooledConnectionLifetime = TimeSpan.FromMinutes(15);
            handler.UseProxy = false;
            handler.AllowAutoRedirect = false;
            handler.ConnectCallback = new Func<SocketsHttpConnectionContext, CancellationToken, ValueTask<System.IO.Stream>>(async (ctx, ct) =>
            {
                IPAddress ip = await RawDnsResolver.ResolveAsync(ctx.DnsEndPoint.Host, ct).ConfigureAwait(false);
                Socket socket = new Socket(SocketType.Stream, ProtocolType.Tcp);
                socket.NoDelay = true;
                try
                {
                    await socket.ConnectAsync(ip, ctx.DnsEndPoint.Port, ct).ConfigureAwait(false);
                    return (System.IO.Stream)new NetworkStream(socket, ownsSocket: true);
                }
                catch
                {
                    socket.Dispose();
                    throw;
                }
            });
            HttpClient client = new HttpClient(handler);
            client.Timeout = TimeSpan.FromSeconds(30);
            return client;
        }
        public static async Task<byte[]> FetchAsync(string sha256hex, HttpClient upstream, CancellationToken ct)
        {
            if (string.IsNullOrEmpty(sha256hex))
                throw new ArgumentNullException("sha256hex");
            if (upstream == null)
                throw new ArgumentNullException("upstream");
            byte[] cached = TryGetCached(sha256hex);
            if (cached != null) return cached;
            string url = "https://" + DICTIONARY_HOST + DICTIONARY_PATH_PREFIX + sha256hex.ToLowerInvariant();
            HttpRequestMessage req = new HttpRequestMessage(HttpMethod.Get, url);
            try { req.Headers.TryAddWithoutValidation("Accept-Encoding", "identity"); } catch { }
            HttpResponseMessage resp = null;
            byte[] body = null;
            try
            {
                resp = await upstream.SendAsync(req, HttpCompletionOption.ResponseContentRead, ct).ConfigureAwait(false);
                if (!resp.IsSuccessStatusCode)
                {
                    throw new System.IO.IOException(
                        "Dictionary fetch failed: HTTP " + (int)resp.StatusCode + " for " + url);
                }
                body = await resp.Content.ReadAsByteArrayAsync(ct).ConfigureAwait(false);
            }
            finally
            {
                if (resp != null) { try { resp.Dispose(); } catch { } }
            }
            if (body == null || body.Length == 0)
            {
                throw new System.IO.IOException("Dictionary fetch returned empty body for " + url);
            }
            string computed = ComputeSha256Hex(body);
            if (!string.Equals(computed, sha256hex, StringComparison.OrdinalIgnoreCase))
            {
                throw new System.IO.IOException(
                    "Dictionary SHA-256 mismatch: expected " + sha256hex +
                    ", got " + computed + " (body length " + body.Length + " bytes)");
            }
            _cache[sha256hex.ToLowerInvariant()] = body;
            return body;
        }
        private static string ComputeSha256Hex(byte[] data)
        {
            using (System.Security.Cryptography.SHA256 sha = System.Security.Cryptography.SHA256.Create())
            {
                byte[] hash = sha.ComputeHash(data);
                System.Text.StringBuilder sb = new System.Text.StringBuilder(hash.Length * 2);
                for (int i = 0; i < hash.Length; i++)
                {
                    sb.Append(hash[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }
    }
    public static class HttpsPipelineLogger
    {
        private static readonly object _logLock = new object();
        private static bool _sessionHeaderWritten = false;
        private static string _logPath = null;
        private const long P1233A_MAX_LOG_BYTES = 5L * 1024L * 1024L;   
        private const int  P1233A_MAX_ROTATIONS = 3;                   
        private static void P1233a_MaybeRotate(string p)
        {
            try
            {
                System.IO.FileInfo fi = new System.IO.FileInfo(p);
                if (!fi.Exists) { return; }
                if (fi.Length < P1233A_MAX_LOG_BYTES) { return; }
                string oldest = p + "." + P1233A_MAX_ROTATIONS.ToString();
                if (System.IO.File.Exists(oldest)) { System.IO.File.Delete(oldest); }
                for (int i = P1233A_MAX_ROTATIONS - 1; i >= 1; i--)
                {
                    string src = p + "." + i.ToString();
                    string dst = p + "." + (i + 1).ToString();
                    if (System.IO.File.Exists(src))
                    {
                        if (System.IO.File.Exists(dst)) { System.IO.File.Delete(dst); }
                        System.IO.File.Move(src, dst);
                    }
                }
                string firstRot = p + ".1";
                if (System.IO.File.Exists(firstRot)) { System.IO.File.Delete(firstRot); }
                System.IO.File.Move(p, firstRot);
                _sessionHeaderWritten = false;
            }
            catch { }
        }
        private static string GetLogPath()
        {
            if (_logPath != null) { return _logPath; }
            try
            {
                string dir = System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData),
                    "Allium");
                if (!System.IO.Directory.Exists(dir))
                {
                    System.IO.Directory.CreateDirectory(dir);
                }
                _logPath = System.IO.Path.Combine(dir, "https-pipeline.log");
                return _logPath;
            }
            catch
            {
                return null;
            }
        }
        public static string LogPath { get { return GetLogPath(); } }
        private static void EnsureSessionHeader()
        {
            if (_sessionHeaderWritten) { return; }
            _sessionHeaderWritten = true;
            string p = GetLogPath();
            if (p == null) { return; }
            try
            {
                int pid = System.Diagnostics.Process.GetCurrentProcess().Id;
                string ts = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ");
                string line = "=== SESSION " + ts + " pid=" + pid + " ===\n";
                System.IO.File.AppendAllText(p, line);
            }
            catch { }
        }
        public static void Log(int status, int bytesIn, int bytesOut, bool isDcz,
                               string outcome, string urlPath)
        {
            string p = GetLogPath();
            if (p == null) { return; }
            try
            {
                lock (_logLock)
                {
                    P1233a_MaybeRotate(p);
                    EnsureSessionHeader();
                    string ts = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                    string dczTag = isDcz ? "dcz" : "raw";
                    string safeOutcome = outcome == null ? "" : outcome.Replace('\n', ' ').Replace('\r', ' ');
                    string safePath = urlPath == null ? "" : urlPath.Replace('\n', ' ').Replace('\r', ' ');
                    string line = ts + "  " + status + "  in=" + bytesIn + "  out=" + bytesOut
                                + "  " + dczTag + "  " + safeOutcome + "  " + safePath + "\n";
                    System.IO.File.AppendAllText(p, line);
                }
            }
            catch { }
        }
    }
    public sealed class HttpsInterceptor : IDisposable
    {
        private const int RING_CAPACITY = 200;
        private TcpListener _listener;
        private CancellationTokenSource _cts;
        private Task _acceptTask;
        private int _port;
        private volatile bool _running;
        private readonly object _stateLock = new object();
        private volatile Dictionary<string, string> _flagOverrides =
            new Dictionary<string, string>(StringComparer.Ordinal);
        private readonly ConcurrentQueue<RequestRecord> _ringBuffer =
            new ConcurrentQueue<RequestRecord>();
        private readonly HttpClient _upstream;
        public volatile bool BandwidthSaverEnabled = true;
        private long _overridesVersion = 0;
        private const int BANDWIDTH_CACHE_CAP = 4;
        private readonly object _bwLock = new object();
        private readonly LinkedList<string> _bwLru = new LinkedList<string>();
        private readonly Dictionary<string, BandwidthEntry> _bwCache =
            new Dictionary<string, BandwidthEntry>(StringComparer.Ordinal);
        private sealed class BandwidthEntry
        {
            public string ETag;
            public string LastModified;   
            public byte[] MergedBody;
            public Dictionary<string, string> MergedHeaders;
            public long OverridesVersion;
            public string UpstreamJson;   
            public bool WasDcz;
            public string DictSha;
        }
        private long _bwHits304 = 0;
        private long _bwRemerges = 0;
        private long _bwFullFetches = 0;
        public long BandwidthHitCount { get { return System.Threading.Interlocked.Read(ref _bwHits304); } }
        public long BandwidthRemergeCount { get { return System.Threading.Interlocked.Read(ref _bwRemerges); } }
        public long BandwidthFullFetchCount { get { return System.Threading.Interlocked.Read(ref _bwFullFetches); } }
        public int BandwidthCacheCount { get { lock (_bwLock) { return _bwCache.Count; } } }
        public bool IsRunning { get { return _running; } }
        public int Port { get { return _port; } }
        public int FlagOverrideCount { get { return _flagOverrides.Count; } }
        public int RecordCount { get { return _ringBuffer.Count; } }
        public HttpsInterceptor()
        {
            SocketsHttpHandler handler = new SocketsHttpHandler();
            handler.AutomaticDecompression = DecompressionMethods.None;
            handler.PooledConnectionLifetime = TimeSpan.FromMinutes(15);
            handler.UseProxy = false;
            handler.AllowAutoRedirect = false;
            handler.ConnectCallback = new Func<SocketsHttpConnectionContext, CancellationToken, ValueTask<System.IO.Stream>>(async (ctx, ct) =>
            {
                IPAddress ip = await RawDnsResolver.ResolveAsync(ctx.DnsEndPoint.Host, ct).ConfigureAwait(false);
                Socket socket = new Socket(SocketType.Stream, ProtocolType.Tcp);
                socket.NoDelay = true;
                try
                {
                    await socket.ConnectAsync(ip, ctx.DnsEndPoint.Port, ct).ConfigureAwait(false);
                    return (System.IO.Stream)new NetworkStream(socket, ownsSocket: true);
                }
                catch
                {
                    socket.Dispose();
                    throw;
                }
            });
            _upstream = new HttpClient(handler);
            _upstream.Timeout = TimeSpan.FromSeconds(30);
        }
        public void SetFlagOverrides(System.Collections.IDictionary overrides)
        {
            Dictionary<string, string> copy = new Dictionary<string, string>(StringComparer.Ordinal);
            if (overrides != null)
            {
                foreach (object k in overrides.Keys)
                {
                    if (k == null) continue;
                    object v = overrides[k];
                    if (v == null) continue;
                    string sk = k.ToString();
                    string sv = v.ToString();
                    if (!string.IsNullOrEmpty(sk))
                    {
                        copy[sk] = sv;
                    }
                }
            }
            _flagOverrides = copy;
            System.Threading.Interlocked.Increment(ref _overridesVersion);
        }
        public RequestRecord[] GetRecentRequests()
        {
            return _ringBuffer.ToArray();
        }
        private static Dictionary<string, string> CloneHeaders(Dictionary<string, string> src)
        {
            Dictionary<string, string> d = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (src != null)
            {
                foreach (KeyValuePair<string, string> kv in src) { d[kv.Key] = kv.Value; }
            }
            return d;
        }
        private BandwidthEntry BwTryGet(string url)
        {
            if (string.IsNullOrEmpty(url)) return null;
            lock (_bwLock)
            {
                BandwidthEntry e;
                if (_bwCache.TryGetValue(url, out e))
                {
                    _bwLru.Remove(url);
                    _bwLru.AddLast(url);
                    return e;
                }
                return null;
            }
        }
        private void BwPut(string url, BandwidthEntry e)
        {
            if (string.IsNullOrEmpty(url) || e == null) return;
            lock (_bwLock)
            {
                if (_bwCache.ContainsKey(url)) { _bwLru.Remove(url); }
                _bwCache[url] = e;
                _bwLru.AddLast(url);
                while (_bwLru.Count > BANDWIDTH_CACHE_CAP)
                {
                    LinkedListNode<string> oldest = _bwLru.First;
                    if (oldest == null) break;
                    _bwLru.RemoveFirst();
                    _bwCache.Remove(oldest.Value);
                }
            }
        }
        private void BwRemove(string url)
        {
            if (string.IsNullOrEmpty(url)) return;
            lock (_bwLock)
            {
                if (_bwCache.Remove(url)) { _bwLru.Remove(url); }
            }
        }
        private void BwClear()
        {
            lock (_bwLock)
            {
                _bwCache.Clear();
                _bwLru.Clear();
            }
        }
        public void Start(int port)
        {
            lock (_stateLock)
            {
                if (_running) return;
                if (!HttpsLeafCertFactory.HasRootCa)
                {
                    throw new InvalidOperationException(
                        "Root CA not set. Call HttpsLeafCertFactory.SetRootCa first.");
                }
                _port = 443;
                _cts = new CancellationTokenSource();
                _listener = new TcpListener(IPAddress.Loopback, 443);
                _listener.Start();
                _running = true;
                CancellationToken tok = _cts.Token;
                _acceptTask = Task.Run(new Func<Task>(delegate { return AcceptLoop(tok); }));
            }
        }
        public void Stop()
        {
            lock (_stateLock)
            {
                if (!_running) return;
                _running = false;
                try { _cts.Cancel(); } catch { }
                try { _listener.Stop(); } catch { }
            }
            BwClear();
        }
        public void Dispose()
        {
            Stop();
            try { _upstream.Dispose(); } catch { }
        }
        private async Task AcceptLoop(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                TcpClient client = null;
                try
                {
                    client = await _listener.AcceptTcpClientAsync(ct).ConfigureAwait(false);
                }
                catch (OperationCanceledException) { break; }
                catch (ObjectDisposedException) { break; }
                catch (Exception)
                {
                    if (ct.IsCancellationRequested) break;
                    continue;
                }
                TcpClient captured = client;
                Task ignored = Task.Run(new Func<Task>(delegate { return HandleClient(captured, ct); }));
            }
        }
        private async Task HandleClient(TcpClient client, CancellationToken ct)
        {
            SslStream ssl = null;
            try
            {
                client.NoDelay = true;
                NetworkStream ns = client.GetStream();
                ssl = new SslStream(ns, false);
                SslServerAuthenticationOptions opts = new SslServerAuthenticationOptions();
                opts.ServerCertificateSelectionCallback = new ServerCertificateSelectionCallback(SelectCert);
                List<SslApplicationProtocol> alpn = new List<SslApplicationProtocol>();
                alpn.Add(SslApplicationProtocol.Http11);
                opts.ApplicationProtocols = alpn;
                opts.EnabledSslProtocols =
                    System.Security.Authentication.SslProtocols.Tls12 |
                    System.Security.Authentication.SslProtocols.Tls13;
                opts.ClientCertificateRequired = false;
                await ssl.AuthenticateAsServerAsync(opts, ct).ConfigureAwait(false);
                await HandleHttpRequest(ssl, ct).ConfigureAwait(false);
            }
            catch (Exception) {   }
            finally
            {
                if (ssl != null) { try { ssl.Dispose(); } catch { } }
                try { client.Close(); } catch { }
            }
        }
        private static X509Certificate2 SelectCert(object sender, string hostname)
        {
            if (string.IsNullOrEmpty(hostname)) hostname = "localhost";
            return HttpsLeafCertFactory.GetOrCreateLeaf(hostname);
        }
        private async Task HandleHttpRequest(SslStream ssl, CancellationToken ct)
        {
            string requestLine = await ReadLineAsync(ssl, ct).ConfigureAwait(false);
            if (string.IsNullOrEmpty(requestLine)) return;
            string[] parts = requestLine.Split(' ');
            if (parts.Length < 3) return;
            string method = parts[0];
            string path = parts[1];
            Dictionary<string, string> headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            while (true)
            {
                string headerLine = await ReadLineAsync(ssl, ct).ConfigureAwait(false);
                if (string.IsNullOrEmpty(headerLine)) break;
                int colon = headerLine.IndexOf(':');
                if (colon <= 0) continue;
                string k = headerLine.Substring(0, colon).Trim();
                string v = headerLine.Substring(colon + 1).Trim();
                headers[k] = v;
            }
            string host = "";
            if (headers.ContainsKey("Host")) host = headers["Host"];
            if (string.IsNullOrEmpty(host)) return;
            byte[] requestBody = null;
            if (headers.ContainsKey("Content-Length"))
            {
                int cl = 0;
                int.TryParse(headers["Content-Length"], out cl);
                if (cl > 0 && cl < 10000000)
                {
                    requestBody = new byte[cl];
                    int read = 0;
                    while (read < cl)
                    {
                        int n = await ssl.ReadAsync(requestBody, read, cl - read, ct).ConfigureAwait(false);
                        if (n <= 0) break;
                        read += n;
                    }
                }
            }
            bool isIntercept = IsInterceptTarget(host, path);
            string upstreamUrl = "https://" + host + path;
            HttpRequestMessage upstreamReq = new HttpRequestMessage(new HttpMethod(method), upstreamUrl);
            foreach (KeyValuePair<string, string> kv in headers)
            {
                string k = kv.Key;
                if (k.Equals("Host", StringComparison.OrdinalIgnoreCase)) continue;
                if (k.Equals("Connection", StringComparison.OrdinalIgnoreCase)) continue;
                if (k.Equals("Content-Length", StringComparison.OrdinalIgnoreCase)) continue;
                if (k.Equals("Content-Type", StringComparison.OrdinalIgnoreCase)) continue;
                if (isIntercept && k.Equals("Accept-Encoding", StringComparison.OrdinalIgnoreCase)) continue;
                if (isIntercept && k.Equals("If-None-Match", StringComparison.OrdinalIgnoreCase)) continue;
                if (isIntercept && k.Equals("If-Modified-Since", StringComparison.OrdinalIgnoreCase)) continue;
                if (isIntercept && k.Equals("If-Match", StringComparison.OrdinalIgnoreCase)) continue;
                if (isIntercept && k.Equals("If-Unmodified-Since", StringComparison.OrdinalIgnoreCase)) continue;
                try { upstreamReq.Headers.TryAddWithoutValidation(k, kv.Value); } catch { }
            }
            if (isIntercept)
            {
                try { upstreamReq.Headers.TryAddWithoutValidation("Accept-Encoding", "identity"); } catch { }
            }
            BandwidthEntry __bwEntry = null;
            if (isIntercept && BandwidthSaverEnabled)
            {
                __bwEntry = BwTryGet(upstreamUrl);
                if (__bwEntry != null)
                {
                    if (!string.IsNullOrEmpty(__bwEntry.ETag))
                    {
                        try { upstreamReq.Headers.TryAddWithoutValidation("If-None-Match", __bwEntry.ETag); } catch { }
                    }
                    if (!string.IsNullOrEmpty(__bwEntry.LastModified))
                    {
                        try { upstreamReq.Headers.TryAddWithoutValidation("If-Modified-Since", __bwEntry.LastModified); } catch { }
                    }
                }
            }
            if (requestBody != null)
            {
                ByteArrayContent content = new ByteArrayContent(requestBody);
                if (headers.ContainsKey("Content-Type"))
                {
                    try { content.Headers.TryAddWithoutValidation("Content-Type", headers["Content-Type"]); } catch { }
                }
                upstreamReq.Content = content;
            }
            int respStatus = 502;
            byte[] respBody = new byte[0];
            Dictionary<string, string> respHeaders = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            bool modified = false;
            string note = "";
            HttpResponseMessage resp = null;
            try
            {
                resp = await _upstream.SendAsync(
                    upstreamReq, HttpCompletionOption.ResponseHeadersRead, ct).ConfigureAwait(false);
                respStatus = (int)resp.StatusCode;
                foreach (KeyValuePair<string, IEnumerable<string>> h in resp.Headers)
                {
                    respHeaders[h.Key] = string.Join(", ", h.Value);
                }
                foreach (KeyValuePair<string, IEnumerable<string>> h in resp.Content.Headers)
                {
                    respHeaders[h.Key] = string.Join(", ", h.Value);
                }
                respBody = await resp.Content.ReadAsByteArrayAsync(ct).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                respStatus = 502;
                respBody = System.Text.Encoding.UTF8.GetBytes("Allium upstream error: " + ex.Message);
                respHeaders.Clear();
                respHeaders["Content-Type"] = "text/plain";
                note = "upstream error";
            }
            finally
            {
                if (resp != null) { try { resp.Dispose(); } catch { } }
            }
            int __bytesInBeforeMerge = (respBody == null) ? 0 : respBody.Length;
            bool __wasDcz = isIntercept && HttpsPipelineLogger.LogPath != null &&
                (respHeaders.ContainsKey("Content-Encoding") &&
                 respHeaders["Content-Encoding"].IndexOf("dcz", StringComparison.OrdinalIgnoreCase) >= 0);
            if (isIntercept && respStatus == 304 && BandwidthSaverEnabled && __bwEntry != null)
            {
                long __curVer = System.Threading.Interlocked.Read(ref _overridesVersion);
                if (__bwEntry.OverridesVersion == __curVer && __bwEntry.MergedBody != null)
                {
                    respStatus = 200;
                    respBody = __bwEntry.MergedBody;
                    respHeaders = CloneHeaders(__bwEntry.MergedHeaders);
                    modified = true;
                    System.Threading.Interlocked.Increment(ref _bwHits304);
                    __wasDcz = __bwEntry.WasDcz;
                    note = "bw:304-hit";
                }
                else
                {
                    byte[] __rb; Dictionary<string, string> __rh; string __rn;
                    if (TryRemergeFromCache(__bwEntry, out __rb, out __rh, out __rn))
                    {
                        respStatus = 200;
                        respBody = __rb;
                        respHeaders = __rh;
                        modified = true;
                        BandwidthEntry __ne = new BandwidthEntry();
                        __ne.ETag = __bwEntry.ETag;
                        __ne.MergedBody = __rb;
                        __ne.MergedHeaders = CloneHeaders(__rh);
                        __ne.OverridesVersion = __curVer;
                        __ne.UpstreamJson = __bwEntry.UpstreamJson;
                        __ne.WasDcz = __bwEntry.WasDcz;
                        __ne.DictSha = __bwEntry.DictSha;
                        BwPut(upstreamUrl, __ne);
                        System.Threading.Interlocked.Increment(ref _bwRemerges);
                        __wasDcz = __bwEntry.WasDcz;   
                        note = "bw:304-remerge(" + __rn + ")";
                    }
                    else if (__bwEntry.MergedBody != null)
                    {
                        respStatus = 200;
                        respBody = __bwEntry.MergedBody;
                        respHeaders = CloneHeaders(__bwEntry.MergedHeaders);
                        modified = true;
                        BwRemove(upstreamUrl);
                        __wasDcz = __bwEntry.WasDcz;   
                        note = "bw:304-remerge-fail-evict(" + (__rn ?? "unknown") + ")";
                    }
                    else
                    {
                        BwRemove(upstreamUrl);
                        note = "bw:304-uncacheable-evict";
                    }
                }
            }
            else if (isIntercept && respStatus == 200 && respBody != null && respBody.Length > 0)
            {
                string __upstreamETag = null;
                if (respHeaders.ContainsKey("ETag")) { __upstreamETag = respHeaders["ETag"]; }
                else if (respHeaders.ContainsKey("etag")) { __upstreamETag = respHeaders["etag"]; }
                string __upstreamLastMod = null;
                if (respHeaders.ContainsKey("Last-Modified")) { __upstreamLastMod = respHeaders["Last-Modified"]; }
                else if (respHeaders.ContainsKey("last-modified")) { __upstreamLastMod = respHeaders["last-modified"]; }
                try
                {
                    byte[][] bodyBox = new byte[][] { respBody };
                    bool[] modBox = new bool[] { false };
                    BandwidthEntry __cap = (BandwidthSaverEnabled &&
                            (!string.IsNullOrEmpty(__upstreamETag) || !string.IsNullOrEmpty(__upstreamLastMod)))
                        ? new BandwidthEntry() : null;
                    string mergeNote = await PerformDczMerge(path, bodyBox, respHeaders, modBox, __cap, ct).ConfigureAwait(false);
                    if (modBox[0])
                    {
                        respBody = bodyBox[0];
                        modified = true;
                    }
                    note = mergeNote;
                    if (__cap != null)
                    {
                        __cap.ETag = __upstreamETag;
                        __cap.LastModified = __upstreamLastMod;   
                        __cap.MergedBody = respBody;
                        __cap.MergedHeaders = CloneHeaders(respHeaders);
                        __cap.OverridesVersion = System.Threading.Interlocked.Read(ref _overridesVersion);
                        BwPut(upstreamUrl, __cap);
                        System.Threading.Interlocked.Increment(ref _bwFullFetches);
                    }
                }
                catch (Exception ex)
                {
                    note = "pipeline exception: " + ex.Message;
                }
            }
            else if (isIntercept)
            {
                if (respStatus == 304) { note = "passthrough:304-not-modified"; }
                else if (respStatus != 200) { note = "passthrough:non-200-status(" + respStatus + ")"; }
                else if (respBody == null || respBody.Length == 0) { note = "passthrough:empty-body"; }
                else { note = "passthrough:unknown"; }
            }
            if (isIntercept)
            {
                try
                {
                    int __bytesOutAfterMerge = (respBody == null) ? 0 : respBody.Length;
                    HttpsPipelineLogger.Log(respStatus, __bytesInBeforeMerge,
                                            __bytesOutAfterMerge, __wasDcz, note, path);
                }
                catch { }
            }
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("HTTP/1.1 ").Append(respStatus).Append(' ').Append(StatusText(respStatus)).Append("\r\n");
            foreach (KeyValuePair<string, string> kv in respHeaders)
            {
                string k = kv.Key;
                if (k.Equals("Transfer-Encoding", StringComparison.OrdinalIgnoreCase)) continue;
                if (k.Equals("Content-Length", StringComparison.OrdinalIgnoreCase)) continue;
                if (k.Equals("Connection", StringComparison.OrdinalIgnoreCase)) continue;
                sb.Append(k).Append(": ").Append(kv.Value).Append("\r\n");
            }
            sb.Append("Content-Length: ").Append(respBody.Length).Append("\r\n");
            sb.Append("Connection: close\r\n");
            sb.Append("\r\n");
            byte[] headerBytes = System.Text.Encoding.UTF8.GetBytes(sb.ToString());
            await ssl.WriteAsync(headerBytes, 0, headerBytes.Length, ct).ConfigureAwait(false);
            if (respBody.Length > 0)
            {
                await ssl.WriteAsync(respBody, 0, respBody.Length, ct).ConfigureAwait(false);
            }
            await ssl.FlushAsync(ct).ConfigureAwait(false);
            RequestRecord rec = new RequestRecord();
            rec.UtcTimestamp = DateTime.UtcNow;
            rec.Method = method;
            rec.Host = host;
            rec.PathAndQuery = path;
            rec.UpstreamStatus = respStatus;
            rec.UpstreamBytes = respBody != null ? respBody.Length : 0;
            rec.Modified = modified;
            rec.Note = note;
            _ringBuffer.Enqueue(rec);
            while (_ringBuffer.Count > RING_CAPACITY)
            {
                RequestRecord dropped;
                _ringBuffer.TryDequeue(out dropped);
            }
        }
        private static bool IsInterceptTarget(string host, string path)
        {
            bool hostMatches =
                host.Equals("clientsettingscdn.roblox.com", StringComparison.OrdinalIgnoreCase) ||
                host.Equals("clientsettings.roblox.com", StringComparison.OrdinalIgnoreCase);
            if (!hostMatches) return false;
            if (string.IsNullOrEmpty(path)) return false;
            if (path.StartsWith("/v2/settings/application/", StringComparison.OrdinalIgnoreCase)) return true;
            if (path.StartsWith("/v2/settings-compressed/application/", StringComparison.OrdinalIgnoreCase)) return true;
            return false;
        }
        private string MergeFlagOverrides(string bodyText, ref int changed)
        {
            changed = 0;
            Dictionary<string, string> overrides = _flagOverrides;
            if (overrides == null || overrides.Count == 0) return bodyText;
            System.Text.Json.Nodes.JsonNode root = System.Text.Json.Nodes.JsonNode.Parse(bodyText);
            if (root == null) return bodyText;
            System.Text.Json.Nodes.JsonObject appSettings =
                root["applicationSettings"] as System.Text.Json.Nodes.JsonObject;
            if (appSettings == null) return bodyText;
            foreach (KeyValuePair<string, string> kv in overrides)
            {
                string existing = null;
                if (appSettings.ContainsKey(kv.Key))
                {
                    System.Text.Json.Nodes.JsonNode ex = appSettings[kv.Key];
                    if (ex != null) existing = ex.ToString();
                }
                if (existing == kv.Value) continue;
                appSettings[kv.Key] = kv.Value;
                changed++;
            }
            return root.ToJsonString();
        }
        private const string COMPANION_FLAG_KEY = "DFIntSecondsBetweenDynamicVariableReloading";
        private const string COMPANION_FLAG_VALUE = "1";
        private const int MAX_DECOMPRESSED_BYTES = 64 * 1024 * 1024;
        private const int DCZ_RECOMPRESS_LEVEL = 9;
        private static bool TryDecompressWithDict(byte[] frameBytes, byte[] dictBytes, out byte[] decompressed, out string errorNote)
        {
            decompressed = null;
            errorNote = null;
            long expected = 0;
            try
            {
                ulong hint = ZstdSharp.Decompressor.GetDecompressedSize(frameBytes, 0, frameBytes.Length);
                if (hint > 0 && hint < (ulong)MAX_DECOMPRESSED_BYTES) { expected = (long)hint; }
            }
            catch { }
            if (expected <= 0) { expected = MAX_DECOMPRESSED_BYTES; }
            try
            {
                using (ZstdSharp.Decompressor dctx = new ZstdSharp.Decompressor())
                {
                    dctx.LoadDictionary(dictBytes);
                    byte[] destBuf = new byte[expected];
                    int written = dctx.Unwrap(frameBytes, destBuf, 0);
                    if (written > 0)
                    {
                        if (written == destBuf.Length)
                        {
                            decompressed = destBuf;
                        }
                        else
                        {
                            decompressed = new byte[written];
                            Array.Copy(destBuf, 0, decompressed, 0, written);
                        }
                        return true;
                    }
                }
            }
            catch (Exception ex1)
            {
                errorNote = "LoadDict: " + ex1.Message;
            }
            return false;
        }
        private static bool TryCompressWithDict(byte[] plainBytes, byte[] dictBytes, out byte[] compressed, out string errorNote)
        {
            compressed = null;
            errorNote = null;
            int bound = 0;
            try { bound = ZstdSharp.Compressor.GetCompressBound(plainBytes.Length); }
            catch (Exception exB) { errorNote = "GetCompressBound: " + exB.Message; return false; }
            try
            {
                using (ZstdSharp.Compressor cctx = new ZstdSharp.Compressor(DCZ_RECOMPRESS_LEVEL))
                {
                    cctx.LoadDictionary(dictBytes);
                    byte[] destBuf = new byte[bound];
                    int written = cctx.Wrap(plainBytes, destBuf, 0);
                    if (written > 0)
                    {
                        compressed = new byte[written];
                        Array.Copy(destBuf, 0, compressed, 0, written);
                        return true;
                    }
                }
            }
            catch (Exception ex1)
            {
                errorNote = "LoadDict compress: " + ex1.Message;
            }
            return false;
        }
        private static bool IsDczEncoding(Dictionary<string, string> respHeaders)
        {
            if (respHeaders == null) return false;
            string enc = null;
            if (respHeaders.ContainsKey("Content-Encoding"))
            {
                enc = respHeaders["Content-Encoding"];
            }
            else if (respHeaders.ContainsKey("content-encoding"))
            {
                enc = respHeaders["content-encoding"];
            }
            if (string.IsNullOrEmpty(enc)) return false;
            return enc.IndexOf("dcz", StringComparison.OrdinalIgnoreCase) >= 0;
        }
        private static void StripHeadersForModifiedResponse(Dictionary<string, string> respHeaders)
        {
            if (respHeaders == null) return;
            List<string> toRemove = new List<string>();
            foreach (KeyValuePair<string, string> kv in respHeaders)
            {
                string k = kv.Key;
                if (k.Equals("content-md5", StringComparison.OrdinalIgnoreCase) ||
                    k.Equals("etag", StringComparison.OrdinalIgnoreCase) ||
                    k.Equals("x-signature-ed25519", StringComparison.OrdinalIgnoreCase) ||
                    k.Equals("transfer-encoding", StringComparison.OrdinalIgnoreCase))
                {
                    toRemove.Add(k);
                }
            }
            foreach (string k in toRemove) { respHeaders.Remove(k); }
        }
        private bool TryRemergeFromCache(BandwidthEntry e, out byte[] body,
            out Dictionary<string, string> headers, out string note)
        {
            body = null; headers = null; note = null;
            if (e == null || e.UpstreamJson == null) { note = "no cached json"; return false; }
            System.Text.Json.Nodes.JsonNode root;
            try { root = System.Text.Json.Nodes.JsonNode.Parse(e.UpstreamJson); }
            catch (Exception exP) { note = "parse: " + exP.Message; return false; }
            if (root == null) { note = "json null"; return false; }
            System.Text.Json.Nodes.JsonObject appSettings =
                root["applicationSettings"] as System.Text.Json.Nodes.JsonObject;
            if (appSettings == null) { note = "no applicationSettings root"; return false; }
            int changed = 0;
            Dictionary<string, string> overrides = _flagOverrides;
            if (overrides != null)
            {
                foreach (KeyValuePair<string, string> kv in overrides)
                {
                    string existing = null;
                    if (appSettings.ContainsKey(kv.Key))
                    {
                        System.Text.Json.Nodes.JsonNode ex = appSettings[kv.Key];
                        if (ex != null) existing = ex.ToString();
                    }
                    if (existing == kv.Value) continue;
                    appSettings[kv.Key] = kv.Value;
                    changed++;
                }
            }
            bool userHasCompanion = (overrides != null && overrides.ContainsKey(COMPANION_FLAG_KEY));
            if (!userHasCompanion)
            {
                string currentVal = null;
                if (appSettings.ContainsKey(COMPANION_FLAG_KEY))
                {
                    System.Text.Json.Nodes.JsonNode ex = appSettings[COMPANION_FLAG_KEY];
                    if (ex != null) currentVal = ex.ToString();
                }
                if (currentVal != COMPANION_FLAG_VALUE)
                {
                    appSettings[COMPANION_FLAG_KEY] = COMPANION_FLAG_VALUE;
                    changed++;
                }
            }
            byte[] mergedBytes;
            try { mergedBytes = System.Text.Encoding.UTF8.GetBytes(root.ToJsonString()); }
            catch (Exception exE) { note = "utf8 encode: " + exE.Message; return false; }
            Dictionary<string, string> h = CloneHeaders(e.MergedHeaders);
            if (e.WasDcz)
            {
                byte[] dictBytes = null;
                if (!string.IsNullOrEmpty(e.DictSha))
                {
                    dictBytes = ClientSettingsDictionaryCache.TryGetCached(e.DictSha);
                }
                if (dictBytes == null) { note = "dict not cached"; return false; }
                byte[] recompressed; string cErr;
                if (!TryCompressWithDict(mergedBytes, dictBytes, out recompressed, out cErr))
                { note = "recompress: " + (cErr ?? "unknown"); return false; }
                body = recompressed;
                h["Content-Encoding"] = "dcz";
            }
            else
            {
                body = mergedBytes;
                h["Content-Type"] = "application/json";
                h.Remove("Content-Encoding");
            }
            StripHeadersForModifiedResponse(h);
            headers = h;
            note = changed.ToString() + " remerged (" + (e.WasDcz ? "dcz" : "json") + ")";
            return true;
        }
        private async Task<string> PerformDczMerge(
            string urlPath,
            byte[][] respBodyBox,
            Dictionary<string, string> respHeaders,
            bool[] modifiedBox,
            BandwidthEntry captureInto,
            CancellationToken ct)
        {
            byte[] respBody = respBodyBox[0];
            if (respBody == null || respBody.Length == 0) { return "empty body"; }
            bool isDcz = IsDczEncoding(respHeaders);
            byte[] dictBytes = null;
            string jsonText = null;
            string dictSha = null;   
            if (isDcz)
            {
                string sha = ClientSettingsDictionaryCache.ExtractHashFromPath(urlPath);
                if (string.IsNullOrEmpty(sha)) { return "dcz: no hash in URL"; }
                dictSha = sha;
                try
                {
                    dictBytes = await ClientSettingsDictionaryCache.FetchAsync(sha, _upstream, ct).ConfigureAwait(false);
                }
                catch (Exception exDict)
                {
                    return "dcz dict fetch failed: " + exDict.Message;
                }
                if (dictBytes == null || dictBytes.Length == 0) { return "dcz dict empty"; }
                byte[] decompressed;
                string decompressErr;
                if (!TryDecompressWithDict(respBody, dictBytes, out decompressed, out decompressErr))
                {
                    return "dcz decompress failed: " + (decompressErr ?? "unknown");
                }
                try { jsonText = System.Text.Encoding.UTF8.GetString(decompressed); }
                catch (Exception exDec) { return "dcz utf8 decode: " + exDec.Message; }
            }
            else
            {
                try { jsonText = System.Text.Encoding.UTF8.GetString(respBody); }
                catch (Exception exDec) { return "utf8 decode: " + exDec.Message; }
            }
            System.Text.Json.Nodes.JsonNode root;
            try
            {
                root = System.Text.Json.Nodes.JsonNode.Parse(jsonText);
            }
            catch (Exception exParse)
            {
                return "json parse: " + exParse.Message;
            }
            if (root == null) { return "json null"; }
            System.Text.Json.Nodes.JsonObject appSettings =
                root["applicationSettings"] as System.Text.Json.Nodes.JsonObject;
            if (appSettings == null) { return "no applicationSettings root"; }
            if (captureInto != null)
            {
                captureInto.UpstreamJson = jsonText;
                captureInto.WasDcz = isDcz;
                captureInto.DictSha = dictSha;
            }
            int changed = 0;
            Dictionary<string, string> overrides = _flagOverrides;
            if (overrides != null)
            {
                foreach (KeyValuePair<string, string> kv in overrides)
                {
                    string existing = null;
                    if (appSettings.ContainsKey(kv.Key))
                    {
                        System.Text.Json.Nodes.JsonNode ex = appSettings[kv.Key];
                        if (ex != null) existing = ex.ToString();
                    }
                    if (existing == kv.Value) continue;
                    appSettings[kv.Key] = kv.Value;
                    changed++;
                }
            }
            bool userHasCompanion = false;
            if (overrides != null && overrides.ContainsKey(COMPANION_FLAG_KEY)) { userHasCompanion = true; }
            if (!userHasCompanion)
            {
                string currentVal = null;
                if (appSettings.ContainsKey(COMPANION_FLAG_KEY))
                {
                    System.Text.Json.Nodes.JsonNode ex = appSettings[COMPANION_FLAG_KEY];
                    if (ex != null) currentVal = ex.ToString();
                }
                if (currentVal != COMPANION_FLAG_VALUE)
                {
                    appSettings[COMPANION_FLAG_KEY] = COMPANION_FLAG_VALUE;
                    changed++;
                }
            }
            if (changed == 0) { return "no changes needed"; }
            string mergedJson = root.ToJsonString();
            byte[] mergedBytes;
            try { mergedBytes = System.Text.Encoding.UTF8.GetBytes(mergedJson); }
            catch (Exception exEnc) { return "utf8 encode: " + exEnc.Message; }
            byte[] finalBody;
            string kindNote;
            if (isDcz && dictBytes != null)
            {
                byte[] recompressed;
                string compressErr;
                if (!TryCompressWithDict(mergedBytes, dictBytes, out recompressed, out compressErr))
                {
                    return "dcz recompress failed: " + (compressErr ?? "unknown");
                }
                finalBody = recompressed;
                respHeaders["Content-Encoding"] = "dcz";
                kindNote = "dcz";
            }
            else
            {
                finalBody = mergedBytes;
                respHeaders["Content-Type"] = "application/json";
                respHeaders.Remove("Content-Encoding");
                kindNote = "json";
            }
            StripHeadersForModifiedResponse(respHeaders);
            respBodyBox[0] = finalBody;
            modifiedBox[0] = true;
            return changed.ToString() + " merged (" + kindNote + ")";
        }
        private static string StatusText(int code)
        {
            switch (code)
            {
                case 200: return "OK";
                case 204: return "No Content";
                case 301: return "Moved Permanently";
                case 302: return "Found";
                case 400: return "Bad Request";
                case 404: return "Not Found";
                case 500: return "Internal Server Error";
                case 502: return "Bad Gateway";
                case 503: return "Service Unavailable";
                default: return "";
            }
        }
        private static async Task<string> ReadLineAsync(Stream s, CancellationToken ct)
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            byte[] buf = new byte[1];
            while (!ct.IsCancellationRequested)
            {
                int n = await s.ReadAsync(buf, 0, 1, ct).ConfigureAwait(false);
                if (n <= 0) return sb.ToString();
                char c = (char)buf[0];
                if (c == '\r') continue;
                if (c == '\n') return sb.ToString();
                sb.Append(c);
                if (sb.Length > 8192) throw new InvalidOperationException("Header line too long");
            }
            return sb.ToString();
        }
    }
}
'@
} catch {
$script:HttpsInterceptorCompileError = $_.Exception.Message
Write-Host ('[HTTPS Proxy] Add-Type FAILED: ' + $_.Exception.Message) -ForegroundColor Yellow
Write-Host '[HTTPS Proxy] Details captured in $script:HttpsInterceptorCompileError' -ForegroundColor Yellow
}
}
$script:AppVersion = "1.0.0"
$script:AppTitle = "Allium"
$_scriptRoot = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $PSScriptRoot }
$script:AlliumScriptPath = if ([string]::IsNullOrWhiteSpace($PSCommandPath)) { $MyInvocation.MyCommand.Path } else { $PSCommandPath }
$script:DataRoot = Join-Path $_scriptRoot "data"
$script:IconPath = Join-Path $script:DataRoot "allium-icon.ico"
$script:ProfilesRoot = Join-Path $script:DataRoot "profiles"
$script:FlagsFile = Join-Path $script:DataRoot "flags.json"
$script:SettingsFile = Join-Path $script:DataRoot "settings.json"
$script:BootstrappersFile = Join-Path $script:DataRoot "bootstrappers.json"
$script:DebugLogFile = Join-Path $script:DataRoot "debug.log"
$script:HttpsInterceptCaDir = Join-Path $script:DataRoot "proxy_ca"
$script:HttpsInterceptCaPfxFile = Join-Path $script:HttpsInterceptCaDir "allium-ca.pfx"
$script:HttpsInterceptCaPemFile = Join-Path $script:HttpsInterceptCaDir "allium-ca.pem"
$script:HttpsInterceptRulesFile = Join-Path $script:DataRoot "https-rules.json"
$script:DepsDir = Join-Path $script:DataRoot "deps"
$script:ZstdSharpDllPath = Join-Path $script:DepsDir "ZstdSharp.dll"
$script:ZstdSharpLoaded = $false
$script:ZstdSharpCompileError = $null
$script:FallbackAccentColor = "#C45B7C"
$script:MaxUndoDepth = 50
$script:ConsoleLogCap = 500
$script:AutoReapplyDefaultInterval = 30
$script:BandwidthSaverMode = $true
$script:RobloxFflagAllowlist = @(
"DFIntCSGLevelOfDetailSwitchingDistance",
"DFIntCSGLevelOfDetailSwitchingDistanceL12",
"DFIntCSGLevelOfDetailSwitchingDistanceL23",
"DFIntCSGLevelOfDetailSwitchingDistanceL34",
"FFlagHandleAltEnterFullscreenManually",
"DFFlagTextureQualityOverrideEnabled",
"DFIntTextureQualityOverride",
"FIntDebugForceMSAASamples",
"DFFlagDisableDPIScale",
"FFlagDebugGraphicsPreferD3D11",
"FFlagDebugSkyGray",
"DFFlagDebugPauseVoxelizer",
"DFIntDebugFRMQualityLevelOverride",
"FIntFRMMaxGrassDistance",
"FIntFRMMinGrassDistance",
"FFlagDebugGraphicsPreferVulkan",
"FFlagDebugGraphicsPreferOpenGL",
"FIntGrassMovementReducedMotionFactor"
)
$script:DefaultSettings = @{
selectedBootstrapper = ""
autoDetectBootstrappers = $true
minimizeToTray = $false
autoReapplyEnabled = $false
autoReapplyIntervalSeconds = 30
showPrefixIndicators = $false
consoleLogVisible = $false
fflagBrowserVisible = $false
debugLogging = $false
watchdogEnabled = $false
watchdogAutoReapplyOnRestart = $true
watchdogMonitorFile = $true
watchdogMonitorVersion = $true
httpInterceptEnabled = $false
httpInterceptCaInstalled = $false
httpInterceptDiagnosticsLive = $false
httpInterceptCaThumbprint = ''
httpInterceptCaGeneratedUtc = ''
memoryWriteMode = $true
pinnedFlags = @()
lastEditorSize = $null
settingsLastViewedTab = 'General'
dumperDiagnosticsMode = $false
warnIfRobloxRunning = $true
desktopShortcutEnabled = $false
robloxMultiInstance = $false
}
function Center-Window {
param([object]$AppWindow, [int]$Width, [int]$Height)
try {
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$x = [math]::Max(0, [math]::Floor(($screen.Width - $Width) / 2) + $screen.Left)
$y = [math]::Max(0, [math]::Floor(($screen.Height - $Height) / 2) + $screen.Top)
$AppWindow.Move([WinUIShell.Windows.Graphics.PointInt32]::new($x, $y))
} catch { Write-ConsoleLog -Message "Failed to center window: $_" -Level "WARN" }
}
function New-UITimeSpan {
param([long]$Milliseconds)
$ticks = $Milliseconds * 10000
try {
return [WinUIShell.System.TimeSpan]::new($ticks)
} catch {
try {
$ts = New-Object WinUIShell.System.TimeSpan
$ts.Duration = $ticks
return $ts
} catch {
return $ticks
}
}
}
function Show-FileDialogWithOwner {
param([System.Windows.Forms.CommonDialog]$Dialog)
try {
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
} catch {}
$owner = [System.Windows.Forms.Form]::new()
$owner.TopMost = $true
$owner.ShowInTaskbar = $false
$owner.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$owner.Size = [System.Drawing.Size]::new(1, 1)
$owner.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$owner.Opacity = 0
$owner.Show()
[System.Windows.Forms.Application]::DoEvents()
try {
[Allium.DialogFocus]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero)
[Allium.DialogFocus]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
} catch {}
$owner.Activate()
$owner.BringToFront()
try {
$SWP_NOMOVE = 0x0002; $SWP_NOSIZE = 0x0001; $swpFlags = $SWP_NOMOVE -bor $SWP_NOSIZE
[void][Allium.DialogFocus]::SetWindowPos($owner.Handle, [IntPtr]::new(-1), 0, 0, 0, 0, $swpFlags)
[void][Allium.DialogFocus]::SetWindowPos($owner.Handle, [IntPtr]::new(-2), 0, 0, 0, 0, $swpFlags)
} catch {}
[System.Windows.Forms.Application]::DoEvents()
$result = $Dialog.ShowDialog($owner)
$owner.Close()
$owner.Dispose()
return $result
}
function Ensure-DataFolder {
if (-not (Test-Path $script:DataRoot)) {
New-Item -Path $script:DataRoot -ItemType Directory | Out-Null
}
return $script:DataRoot
}
function Ensure-ProfilesFolder {
$profPath = $script:ProfilesRoot
if (-not (Test-Path $profPath)) {
Ensure-DataFolder | Out-Null
New-Item -Path $profPath -ItemType Directory | Out-Null
}
return $profPath
}
function Ensure-Icons {
Ensure-DataFolder | Out-Null
$icoPath = Join-Path $script:DataRoot "allium-icon.ico"
$pngPath = Join-Path $script:DataRoot "allium-icon.png"
$icoUrl = "https://github.com/fwOnion/Log-v1.0/releases/download/ico/new.ico"
$pngUrl = "https://github.com/fwOnion/Log-v1.0/releases/download/ico/new.png"
if (-not (Test-Path $icoPath)) {
try {
Invoke-WebRequest -Uri $icoUrl -OutFile $icoPath -UseBasicParsing -ErrorAction Stop
} catch { Write-ConsoleLog -Message "Failed to download icon: $_" -Level "WARN" }
}
if (-not (Test-Path $pngPath)) {
try {
Invoke-WebRequest -Uri $pngUrl -OutFile $pngPath -UseBasicParsing -ErrorAction Stop
} catch { Write-ConsoleLog -Message "Failed to download PNG icon: $_" -Level "WARN" }
}
$scriptRoot = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { $PSScriptRoot }
$oldIco = Join-Path $scriptRoot "allium-icon.ico"
$oldPng = Join-Path $scriptRoot "allium-icon.png"
if ((Test-Path $oldIco) -and ($oldIco -ne $icoPath)) {
try { Remove-Item $oldIco -Force -ErrorAction SilentlyContinue } catch {}
}
if ((Test-Path $oldPng) -and ($oldPng -ne $pngPath)) {
try { Remove-Item $oldPng -Force -ErrorAction SilentlyContinue } catch {}
}
}
function Read-Json {
param([string]$Path)
if (-not (Test-Path $Path)) { return $null }
try {
$raw = [System.IO.File]::ReadAllText($Path)
if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
return $raw | ConvertFrom-Json -AsHashtable
} catch {
return $null
}
}
function Write-Json {
param(
[string]$Path,
$Data
)
try {
$dir = Split-Path $Path -Parent
if (-not (Test-Path $dir)) {
New-Item -Path $dir -ItemType Directory -Force | Out-Null
}
$json = $Data | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($Path, $json)
} catch {
Write-ConsoleLog -Message "Write-Json failed for ${Path}: $_" -Level "ERROR"
}
}
function Set-ControlVisible {
param(
[object]$Control,
[bool]$IsVisible
)
if ($null -eq $Control) { return }
try {
if ($IsVisible) {
$Control.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
} else {
$Control.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
}
} catch {
}
}
function Get-RobloxPlayerPath {
$selected = Get-SelectedBootstrapper
$searchPaths = @()
if ($null -ne $selected -and $selected.Found) {
$bsName = $selected.Name
$bsVersionsDir = Join-Path $env:LOCALAPPDATA "$bsName\Versions"
$searchPaths += $bsVersionsDir
}
$searchPaths += (Join-Path $env:LOCALAPPDATA "Roblox\Versions")
foreach ($versionsDir in $searchPaths) {
if (-not (Test-Path $versionsDir)) { continue }
$versionFolders = Get-ChildItem $versionsDir -Directory -Filter "version-*" |
Sort-Object LastWriteTime -Descending
foreach ($vf in $versionFolders) {
$exe = Join-Path $vf.FullName "RobloxPlayerBeta.exe"
if (Test-Path $exe) {
return $exe
}
}
}
return $null
}
function Get-RobloxClientSettingsPath {
$selected = Get-SelectedBootstrapper
$searchPaths = @()
if ($null -ne $selected -and $selected.Found) {
$bsName = $selected.Name
$bsVersionsDir = Join-Path $env:LOCALAPPDATA "$bsName\Versions"
$searchPaths += $bsVersionsDir
}
$searchPaths += (Join-Path $env:LOCALAPPDATA "Roblox\Versions")
foreach ($versionsDir in $searchPaths) {
if (-not (Test-Path $versionsDir)) { continue }
$versionFolders = Get-ChildItem $versionsDir -Directory -Filter "version-*" |
Sort-Object LastWriteTime -Descending
foreach ($vf in $versionFolders) {
$exe = Join-Path $vf.FullName "RobloxPlayerBeta.exe"
if (Test-Path $exe) {
$settingsDir = Join-Path $vf.FullName "ClientSettings"
if (-not (Test-Path $settingsDir)) {
New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
}
$settingsPath = Join-Path $settingsDir "ClientAppSettings.json"
return $settingsPath
}
}
}
return $null
}
function Load-Settings {
$saved = Read-Json -Path $script:SettingsFile
if ($null -eq $saved) {
$script:Settings = $script:DefaultSettings.Clone()
return
}
$script:Settings = @{}
foreach ($key in $script:DefaultSettings.Keys) {
if ($saved.ContainsKey($key)) {
$script:Settings[$key] = $saved[$key]
} else {
$script:Settings[$key] = $script:DefaultSettings[$key]
}
}
if ($script:Settings.autoReapplyIntervalSeconds -lt 5) {
$script:Settings.autoReapplyIntervalSeconds = 5
}
}
function Save-Settings {
Write-ConsoleLog -Message "Saving settings to $($script:SettingsFile)" -Level "INFO"
Write-Json -Path $script:SettingsFile -Data $script:Settings
}
function Load-Flags {
$saved = Read-Json -Path $script:FlagsFile
if ($null -eq $saved) {
$script:Flags = @{}
return
}
$script:Flags = @{}
if ($saved -is [hashtable]) {
$script:Flags = $saved
} elseif ($saved -is [System.Collections.Specialized.OrderedDictionary]) {
foreach ($key in $saved.Keys) {
$script:Flags[$key] = $saved[$key]
}
} else {
foreach ($prop in $saved.PSObject.Properties) {
$script:Flags[$prop.Name] = $prop.Value
}
}
}
function Update-InterceptorOverrides {
if ($null -ne $script:HttpsInterceptorInstance) {
try {
if ($null -eq $script:FlagPrefixCache) {
$__cache = @{}
try {
if ($null -ne $global:FVariablesCache -and (Test-Path $global:FVariablesCache)) {
$__fv = Read-Json -Path $global:FVariablesCache
if ($null -ne $__fv -and $__fv.ContainsKey('flags') -and $__fv['flags'] -is [hashtable]) {
foreach ($__rn in @($__fv['flags'].Keys)) {
$__v = $__fv['flags'][$__rn]
$__pref = $null
if ($__v -is [hashtable] -and $__v.ContainsKey('Prefixed')) { $__pref = [string]$__v['Prefixed'] }
elseif ($__v -is [string]) { $__pref = [string]$__v }
if (-not [string]::IsNullOrWhiteSpace($__pref)) { $__cache[([string]$__rn).ToLower()] = $__pref }
}
}
}
} catch { }
try {
if ($null -ne $script:BrowserRawNameMap) {
foreach ($__rk in @($script:BrowserRawNameMap.Keys)) {
$__pk = [string]$script:BrowserRawNameMap[$__rk]
if ((-not [string]::IsNullOrWhiteSpace($__pk)) -and (-not $__cache.ContainsKey([string]$__rk))) {
$__cache[[string]$__rk] = $__pk
}
}
}
} catch { }
$script:FlagPrefixCache = $__cache
}
$__push = @{}
foreach ($__fk in @($script:Flags.Keys)) {
$__ok = [string]$__fk
if (-not ($__ok -match '^(D?F|SF)(Flag|Int|String|Log)(.+)$')) {
$__lk = $__ok.ToLower()
if ($script:FlagPrefixCache.ContainsKey($__lk)) { $__ok = [string]$script:FlagPrefixCache[$__lk] }
}
$__push[$__ok] = $script:Flags[$__fk]
}
$script:HttpsInterceptorInstance.SetFlagOverrides($__push)
} catch {
Write-ConsoleLog -Message ('SetFlagOverrides push failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
}
function Save-Flags {
Ensure-DataFolder | Out-Null
Write-Json -Path $script:FlagsFile -Data $script:Flags
Update-InterceptorOverrides
}
function Write-ClientAppSettings {
$settingsPath = Get-RobloxClientSettingsPath
if (-not $settingsPath) { return $false }
$output = @{}
foreach ($key in $script:Flags.Keys) {
$output[$key] = $script:Flags[$key]
}
try {
if ($null -ne $script:WatchdogFileWatcher) {
$script:WatchdogFileWatcher.EnableRaisingEvents = $false
}
$json = $output | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($settingsPath, $json)
if ($null -ne $script:WatchdogFileWatcher) {
Start-Sleep -Milliseconds 200
$script:WatchdogFileWatcher.EnableRaisingEvents = $true
}
return $true
} catch {
if ($null -ne $script:WatchdogFileWatcher) {
try { $script:WatchdogFileWatcher.EnableRaisingEvents = $true } catch {}
}
return $false
}
}
function Backup-AlliumFileOnce {
param([Parameter(Mandatory)][string]$Path)
if (-not (Test-Path $Path -PathType Leaf)) { return $false }
$backup = "$Path.allium.bak"
if (Test-Path $backup -PathType Leaf) { return $true }
try {
Copy-Item -LiteralPath $Path -Destination $backup -Force -ErrorAction Stop
return $true
} catch {
Write-ConsoleLog -Message "Backup-AlliumFileOnce failed for $Path : $_" -Level 'WARN'
return $false
}
}
function Restore-AlliumBackup {
param([Parameter(Mandatory)][string]$Path)
$backup = "$Path.allium.bak"
if (-not (Test-Path $backup -PathType Leaf)) { return $false }
try {
Copy-Item -LiteralPath $backup -Destination $Path -Force -ErrorAction Stop
Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue
return $true
} catch {
Write-ConsoleLog -Message "Restore-AlliumBackup failed for $Path : $_" -Level 'WARN'
return $false
}
}
function Ensure-HttpsInterceptDataDirs {
if (-not (Test-Path $script:HttpsInterceptCaDir)) {
try {
New-Item -Path $script:HttpsInterceptCaDir -ItemType Directory -Force | Out-Null
} catch {
Write-ConsoleLog -Message "Failed to create $script:HttpsInterceptCaDir : $_" -Level 'WARN'
}
}
}
function Import-AlliumDependencies {
$script:ZstdSharpLoaded = $false
$script:ZstdSharpCompileError = $null
if (-not (Test-Path $script:ZstdSharpDllPath -PathType Leaf)) {
Write-ConsoleLog -Message ('ZstdSharp.dll not found at ' + $script:ZstdSharpDllPath + '; HTTPS Interception zstd decompression unavailable until Allium-Setup.ps1 is re-run.') -Level 'INFO'
return $false
}
if ($null -ne ('ZstdSharp.Decompressor' -as [type])) {
$script:ZstdSharpLoaded = $true
Write-ConsoleLog -Message 'ZstdSharp.Decompressor already loaded in this runspace; skipping Add-Type.' -Level 'INFO'
return $true
}
try {
Add-Type -Path $script:ZstdSharpDllPath -ErrorAction Stop
if ($null -ne ('ZstdSharp.Decompressor' -as [type])) {
$script:ZstdSharpLoaded = $true
Write-ConsoleLog -Message ('ZstdSharp.Decompressor loaded from ' + $script:ZstdSharpDllPath) -Level 'INFO'
return $true
}
$script:ZstdSharpCompileError = 'Add-Type completed but ZstdSharp.Decompressor type still not resolvable.'
Write-Host ('[ZstdSharp] Load FAILED: ' + $script:ZstdSharpCompileError) -ForegroundColor Yellow
return $false
} catch {
$script:ZstdSharpCompileError = $_.Exception.Message
Write-Host ('[ZstdSharp] Add-Type FAILED: ' + $_.Exception.Message) -ForegroundColor Yellow
Write-Host '[ZstdSharp] Details captured in $script:ZstdSharpCompileError' -ForegroundColor Yellow
return $false
}
}
function Test-AlliumZstdSharp {
if (-not $script:ZstdSharpLoaded) {
return @{
Success = $false
Reason = 'ZstdSharp not loaded. Call Import-AlliumDependencies first, or re-run Allium-Setup.ps1.'
Loaded = $false
}
}
try {
$srcText = 'Hello Allium, this is a ZstdSharp smoke-test payload. Repeat: Hello Allium, this is a ZstdSharp smoke-test payload.'
$srcBytes = [System.Text.Encoding]::UTF8.GetBytes($srcText)
$compressBound = [ZstdSharp.Compressor]::GetCompressBound($srcBytes.Length)
$compressedBuf = New-Object byte[] $compressBound
$compressor = [ZstdSharp.Compressor]::new()
try {
$compressedLen = $compressor.Wrap($srcBytes, $compressedBuf, 0)
} finally {
try { $compressor.Dispose() } catch {}
}
$compressed = New-Object byte[] $compressedLen
[System.Array]::Copy($compressedBuf, 0, $compressed, 0, $compressedLen)
$expectedLen = [ZstdSharp.Decompressor]::GetDecompressedSize($compressed, 0, $compressed.Length)
$decompressedBuf = New-Object byte[] ([int]$expectedLen)
$decompressor = [ZstdSharp.Decompressor]::new()
try {
$decompressedLen = $decompressor.Unwrap($compressed, $decompressedBuf, 0)
} finally {
try { $decompressor.Dispose() } catch {}
}
$decompressedText = [System.Text.Encoding]::UTF8.GetString($decompressedBuf, 0, $decompressedLen)
$roundtripOk = ($decompressedText -eq $srcText)
return @{
Success = $roundtripOk
Loaded = $true
SrcLen = $srcBytes.Length
CompressedLen = $compressedLen
DecompressedLen = $decompressedLen
RoundtripOk = $roundtripOk
Reason = if ($roundtripOk) { 'roundtrip verified' } else { 'decompressed bytes did not match source' }
}
} catch {
return @{
Success = $false
Loaded = $true
Reason = ('Exception during roundtrip: ' + $_.Exception.Message)
}
}
}
function Test-AlliumDictionaryFetch {
param(
[Parameter(Mandatory)][string]$Sha256Hex,
[int]$TimeoutSeconds = 15
)
if ($null -eq ('Allium.ClientSettingsDictionaryCache' -as [type])) {
return @{
Success = $false
Reason = 'Allium.ClientSettingsDictionaryCache type not loaded. Are the U1e-b C# changes applied and Allium dot-sourced?'
}
}
$wasCached = $false
try {
$wasCached = ($null -ne [Allium.ClientSettingsDictionaryCache]::TryGetCached($Sha256Hex))
} catch {}
$client = $null
$cts = New-Object System.Threading.CancellationTokenSource
$cts.CancelAfter([TimeSpan]::FromSeconds($TimeoutSeconds))
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
$client = [Allium.ClientSettingsDictionaryCache]::CreateStandaloneHttpClient()
$task = [Allium.ClientSettingsDictionaryCache]::FetchAsync($Sha256Hex, $client, $cts.Token)
$task.Wait()
$bytes = $task.Result
$sw.Stop()
return @{
Success = $true
Sha256 = $Sha256Hex
WasCached = $wasCached
BytesReceived = $bytes.Length
ElapsedMs = $sw.ElapsedMilliseconds
CacheEntryCount = [Allium.ClientSettingsDictionaryCache]::CacheEntryCount
TotalCacheBytes = [Allium.ClientSettingsDictionaryCache]::TotalCacheBytes
Reason = if ($wasCached) { 'cache hit' } else { 'fresh fetch + SHA-256 verified' }
}
} catch {
$sw.Stop()
$inner = $_.Exception
while ($null -ne $inner.InnerException) { $inner = $inner.InnerException }
return @{
Success = $false
Sha256 = $Sha256Hex
WasCached = $wasCached
ElapsedMs = $sw.ElapsedMilliseconds
Reason = ('Fetch failed: ' + $inner.Message)
}
} finally {
try { $cts.Dispose() } catch {}
if ($null -ne $client) { try { $client.Dispose() } catch {} }
}
}
$script:HttpsInterceptorInstance = $null
$script:HttpsWatchdogRefreshTimer = $null
$script:HttpsHostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$script:HttpsWatchdogTaskName = 'Allium-HostsWatchdog'
function Install-AlliumHosts {
if (-not (Test-Path $script:HttpsHostsPath -PathType Leaf)) {
Write-ConsoleLog -Message ('Install-AlliumHosts: hosts file missing at ' + $script:HttpsHostsPath) -Level 'ERROR'
return $false
}
try {
$existing = [System.IO.File]::ReadAllText($script:HttpsHostsPath)
if ($existing.Contains('# ==== BEGIN ALLIUM HOSTS')) {
Write-ConsoleLog -Message 'Install-AlliumHosts: sentinel already present; idempotent skip.' -Level 'INFO'
return $true
}
Backup-AlliumFileOnce -Path $script:HttpsHostsPath | Out-Null
$nowIso = ([datetime]::UtcNow).ToString('yyyy-MM-ddTHH:mm:ssZ')
$block = "`n# ==== BEGIN ALLIUM HOSTS ====`n" +
"# Generated: $nowIso`n" +
"# Source:    Allium HTTPS Interception (Phase U1)`n" +
"127.0.0.1 clientsettings.roblox.com`n" +
"127.0.0.1 clientsettingscdn.roblox.com`n" +
"# ==== END ALLIUM HOSTS ====`n"
[System.IO.File]::AppendAllText($script:HttpsHostsPath, $block)
Write-ConsoleLog -Message 'Install-AlliumHosts: sentinel block appended.' -Level 'INFO'
return $true
} catch {
Write-ConsoleLog -Message ('Install-AlliumHosts failed: ' + $_.Exception.Message) -Level 'ERROR'
return $false
}
}
function Uninstall-AlliumHosts {
if (-not (Test-Path $script:HttpsHostsPath -PathType Leaf)) { return $false }
try {
$existing = [System.IO.File]::ReadAllText($script:HttpsHostsPath)
if ($existing.Contains('# ==== BEGIN ALLIUM HOSTS')) {
$pattern = '(?s)\r?\n?# ==== BEGIN ALLIUM HOSTS ====.*?# ==== END ALLIUM HOSTS ====\r?\n?'
$stripped = [regex]::Replace($existing, $pattern, '')
[System.IO.File]::WriteAllText($script:HttpsHostsPath, $stripped)
try { Remove-Item -LiteralPath ($script:HttpsHostsPath + '.allium.bak') -Force -ErrorAction SilentlyContinue } catch {}
Write-ConsoleLog -Message 'Uninstall-AlliumHosts: sentinel block stripped.' -Level 'INFO'
return $true
}
if (Restore-AlliumBackup -Path $script:HttpsHostsPath) {
Write-ConsoleLog -Message 'Uninstall-AlliumHosts: restored from backup (sentinel was missing).' -Level 'INFO'
return $true
}
return $false
} catch {
Write-ConsoleLog -Message ('Uninstall-AlliumHosts failed: ' + $_.Exception.Message) -Level 'ERROR'
return $false
}
}
function Register-AlliumHostsWatchdog {
$__wdDir = Join-Path $env:ProgramData 'Allium'
try {
if (-not (Test-Path $__wdDir)) {
New-Item -Path $__wdDir -ItemType Directory -Force | Out-Null
}
} catch {
Write-ConsoleLog -Message ('Register-AlliumHostsWatchdog: cannot create ' + $__wdDir + ': ' + $_.Exception.Message) -Level 'ERROR'
return
}
$script:HttpsCleanupScriptPath = Join-Path $__wdDir 'watchdog-cleanup.ps1'
$script:HttpsHeartbeatPath = Join-Path $__wdDir 'watchdog-heartbeat.txt'
$__logPath = Join-Path $__wdDir 'watchdog.log'
$__hostsLit = $script:HttpsHostsPath -replace "'", "''"
$__hbLit = $script:HttpsHeartbeatPath -replace "'", "''"
$__taskLit = $script:HttpsWatchdogTaskName -replace "'", "''"
$__logLit = $__logPath -replace "'", "''"
$__cleanupBody = @"
`$logPath = '$__logLit'
`$hostsPath = '$__hostsLit'
`$heartbeatPath = '$__hbLit'
`$taskName = '$__taskLit'
function Wlog(`$m) { try { Add-Content -LiteralPath `$logPath -Value ((([datetime]::UtcNow).ToString('yyyy-MM-ddTHH:mm:ssZ')) + '  ' + `$m) -ErrorAction SilentlyContinue } catch {} }
Wlog 'fire begin'
try {
    `$stale = `$true
    if (Test-Path `$heartbeatPath -PathType Leaf) {
        `$raw = (Get-Content -LiteralPath `$heartbeatPath -Raw -ErrorAction SilentlyContinue) -replace '\s',''
        `$ticks = [long]0
        if ([long]::TryParse(`$raw, [ref]`$ticks)) {
            `$ageSec = ([datetime]::UtcNow - [datetime]`$ticks).TotalSeconds
            Wlog ('heartbeat age = ' + [int]`$ageSec + 's')
            if (`$ageSec -lt 30) { `$stale = `$false }
        } else {
            Wlog 'heartbeat unparseable'
        }
    } else {
        Wlog 'heartbeat missing'
    }
    if (-not `$stale) { Wlog 'alive; skip'; exit 0 }
    Wlog 'stale; cleaning up'
    if (Test-Path `$hostsPath -PathType Leaf) {
        `$c = [System.IO.File]::ReadAllText(`$hostsPath)
        `$before = `$c.Length
        `$s = [regex]::Replace(`$c, '(?s)\r?\n?# ==== BEGIN ALLIUM HOSTS ====.*?# ==== END ALLIUM HOSTS ====\r?\n?', '')
        [System.IO.File]::WriteAllText(`$hostsPath, `$s)
        Wlog ('hosts stripped: ' + (`$before - `$s.Length) + ' bytes removed')
        Remove-Item -LiteralPath (`$hostsPath + '.allium.bak') -Force -ErrorAction SilentlyContinue
    }
    `$out = & schtasks.exe /Delete /F /TN `$taskName 2>&1 | Out-String
    Wlog ('schtasks delete: ' + `$out.Trim())
    Remove-Item -LiteralPath `$heartbeatPath -Force -ErrorAction SilentlyContinue
    Wlog 'cleanup complete'
} catch {
    Wlog ('ERROR: ' + `$_.Exception.Message)
}
"@
Set-Content -LiteralPath $script:HttpsCleanupScriptPath -Value $__cleanupBody -Force -Encoding utf8
try {
[System.IO.File]::WriteAllText($script:HttpsHeartbeatPath, ([datetime]::UtcNow.Ticks).ToString())
} catch {}
& schtasks.exe /Delete /F /TN $script:HttpsWatchdogTaskName 2>&1 | Out-Null
$__pwshCmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue
$__pwshPath = if ($null -ne $__pwshCmd) { $__pwshCmd.Source } else { 'pwsh.exe' }
$__tr = "'$__pwshPath' -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File '" + $script:HttpsCleanupScriptPath + "'"
$__createOut = & schtasks.exe /Create /F /TN $script:HttpsWatchdogTaskName /SC MINUTE /MO 1 /RU SYSTEM /RL HIGHEST /TR $__tr 2>&1 | Out-String
$__createExit = $LASTEXITCODE
if ($__createExit -ne 0) {
Write-ConsoleLog -Message ('Register-AlliumHostsWatchdog: schtasks.exe /Create failed (exit ' + $__createExit + '): ' + $__createOut.Trim()) -Level 'ERROR'
return
}
if ($null -ne $script:HttpsWatchdogRefreshTimer) {
try { $script:HttpsWatchdogRefreshTimer.Stop(); $script:HttpsWatchdogRefreshTimer.Dispose() } catch {}
$script:HttpsWatchdogRefreshTimer = $null
}
$script:HttpsWatchdogRefreshTimer = New-Object System.Timers.Timer
$script:HttpsWatchdogRefreshTimer.Interval = 5000
$script:HttpsWatchdogRefreshTimer.AutoReset = $true
Register-ObjectEvent -InputObject $script:HttpsWatchdogRefreshTimer -EventName Elapsed -SourceIdentifier 'AlliumHostsWatchdogHeartbeat' -MessageData $script:HttpsHeartbeatPath -Action {
try {
[System.IO.File]::WriteAllText($Event.MessageData, ([datetime]::UtcNow.Ticks).ToString())
} catch {}
} | Out-Null
$script:HttpsWatchdogRefreshTimer.Start()
Write-ConsoleLog -Message ('Hosts watchdog registered (task ' + $script:HttpsWatchdogTaskName + ', schtasks /SC MINUTE, heartbeat 5s at ' + $script:HttpsHeartbeatPath + ', log at ' + $__logPath + ').') -Level 'INFO'
}
function Unregister-AlliumHostsWatchdog {
if ($null -ne $script:HttpsWatchdogRefreshTimer) {
try { $script:HttpsWatchdogRefreshTimer.Stop() } catch {}
try { $script:HttpsWatchdogRefreshTimer.Dispose() } catch {}
$script:HttpsWatchdogRefreshTimer = $null
}
try { Unregister-Event -SourceIdentifier 'AlliumHostsWatchdogHeartbeat' -ErrorAction SilentlyContinue } catch {}
try { Unregister-Event -SourceIdentifier 'AlliumHostsWatchdogRefresh' -ErrorAction SilentlyContinue } catch {}
try { & schtasks.exe /Delete /F /TN $script:HttpsWatchdogTaskName 2>&1 | Out-Null } catch {}
if (-not [string]::IsNullOrEmpty([string]$script:HttpsCleanupScriptPath)) {
try { Remove-Item -LiteralPath $script:HttpsCleanupScriptPath -Force -ErrorAction SilentlyContinue } catch {}
}
if (-not [string]::IsNullOrEmpty([string]$script:HttpsHeartbeatPath)) {
try { Remove-Item -LiteralPath $script:HttpsHeartbeatPath -Force -ErrorAction SilentlyContinue } catch {}
}
$script:HttpsCleanupScriptPath = $null
$script:HttpsHeartbeatPath = $null
Write-ConsoleLog -Message 'Hosts watchdog unregistered.' -Level 'INFO'
}
function Install-AlliumProxyCA {
Ensure-HttpsInterceptDataDirs
$cert = $null
try {
if (Test-Path $script:HttpsInterceptCaPfxFile -PathType Leaf) {
$cert = [Allium.HttpsCaGenerator]::LoadPfx($script:HttpsInterceptCaPfxFile)
Write-ConsoleLog -Message 'HTTPS CA: loaded existing PFX' -Level 'INFO'
} else {
$cert = [Allium.HttpsCaGenerator]::GenerateRootCa(10)
$pfxBytes = [Allium.HttpsCaGenerator]::ExportPfx($cert)
[System.IO.File]::WriteAllBytes($script:HttpsInterceptCaPfxFile, $pfxBytes)
$pem = [Allium.HttpsCaGenerator]::ExportPem($cert)
[System.IO.File]::WriteAllText($script:HttpsInterceptCaPemFile, $pem)
Write-ConsoleLog -Message ('HTTPS CA: generated new 10-year root CA (thumbprint ' + [Allium.HttpsCaGenerator]::FormatThumbprint($cert) + ')') -Level 'INFO'
}
} catch {
Write-ConsoleLog -Message ('Install-AlliumProxyCA: failed to load or generate CA: ' + $_.Exception.Message) -Level 'ERROR'
return @{ Success = $false; Installed = 0; Skipped = 0; Failed = 0; Thumbprint = ""; Error = $_.Exception.Message }
}
$thumb = [Allium.HttpsCaGenerator]::FormatThumbprint($cert)
$pemText = $null
try {
$pemText = [Allium.HttpsCaGenerator]::ExportPem($cert)
} catch {
Write-ConsoleLog -Message ('Install-AlliumProxyCA: failed to encode PEM: ' + $_.Exception.Message) -Level 'ERROR'
return @{ Success = $false; Installed = 0; Skipped = 0; Failed = 0; Thumbprint = $thumb; Error = $_.Exception.Message }
}
$sentinelBegin = '# ==== BEGIN ALLIUM CA (thumbprint ' + $thumb + ') ===='
$sentinelEnd = '# ==== END ALLIUM CA ===='
$nowIso = ([datetime]::UtcNow).ToString("yyyy-MM-ddTHH:mm:ssZ")
$block = "`n$sentinelBegin`n# Generated: $nowIso`n# Source:    Allium HTTPS Interception (Phase U1)`n$pemText$sentinelEnd`n"
$installs = @(Find-RobloxInstallations)
$installed = 0
$skipped = 0
$failed = 0
foreach ($inst in $installs) {
$cacert = $inst.CacertPath
if (-not (Test-Path $cacert -PathType Leaf)) {
Write-ConsoleLog -Message ('HTTPS CA: skipping ' + $inst.Name + ' (cacert.pem missing at ' + $cacert + ')') -Level 'WARN'
$failed += 1
continue
}
try {
$existing = [System.IO.File]::ReadAllText($cacert)
if ($existing.Contains('# ==== BEGIN ALLIUM CA')) {
$skipped += 1
Write-ConsoleLog -Message ('HTTPS CA: already installed in ' + $inst.Name) -Level 'INFO'
continue
}
Backup-AlliumFileOnce -Path $cacert | Out-Null
[System.IO.File]::AppendAllText($cacert, $block)
$installed += 1
Write-ConsoleLog -Message ('HTTPS CA: installed into ' + $inst.Name) -Level 'INFO'
} catch {
$failed += 1
Write-ConsoleLog -Message ('HTTPS CA: install into ' + $inst.Name + ' failed: ' + $_.Exception.Message) -Level 'ERROR'
}
}
$script:Settings.httpInterceptCaInstalled = ($installed -gt 0 -or ($skipped -gt 0 -and $failed -eq 0))
$script:Settings.httpInterceptCaThumbprint = $thumb
if ([string]::IsNullOrEmpty([string]$script:Settings.httpInterceptCaGeneratedUtc)) {
$script:Settings.httpInterceptCaGeneratedUtc = $nowIso
}
Save-Settings
try { $cert.Dispose() } catch {}
$ok = ($failed -eq 0 -and $installs.Count -gt 0)
return @{
Success = $ok
Installed = $installed
Skipped = $skipped
Failed = $failed
Thumbprint = $thumb
Discovered = $installs.Count
}
}
function Uninstall-AlliumProxyCA {
$installs = @(Find-RobloxInstallations)
$stripped = 0
$restored = 0
$failed = 0
$sentinelPattern = '(?s)\r?\n?# ==== BEGIN ALLIUM CA[^\r\n]*\r?\n.*?# ==== END ALLIUM CA ====\r?\n?'
foreach ($inst in $installs) {
$cacert = $inst.CacertPath
if (-not (Test-Path $cacert -PathType Leaf)) {
$failed += 1
continue
}
try {
$existing = [System.IO.File]::ReadAllText($cacert)
if ($existing.Contains('# ==== BEGIN ALLIUM CA')) {
$rewritten = [regex]::Replace($existing, $sentinelPattern, '')
[System.IO.File]::WriteAllText($cacert, $rewritten)
try { Remove-Item -LiteralPath ($cacert + '.allium.bak') -Force -ErrorAction SilentlyContinue } catch {}
$stripped += 1
Write-ConsoleLog -Message ('HTTPS CA: stripped from ' + $inst.Name) -Level 'INFO'
} elseif (Restore-AlliumBackup -Path $cacert) {
$restored += 1
Write-ConsoleLog -Message ('HTTPS CA: restored backup for ' + $inst.Name) -Level 'INFO'
}
} catch {
$failed += 1
Write-ConsoleLog -Message ('HTTPS CA: uninstall from ' + $inst.Name + ' failed: ' + $_.Exception.Message) -Level 'ERROR'
}
}
$script:Settings.httpInterceptCaInstalled = $false
$script:Settings.httpInterceptCaThumbprint = ''
$script:Settings.httpInterceptCaGeneratedUtc = ''
Save-Settings
return @{
Success = ($failed -eq 0)
Stripped = $stripped
Restored = $restored
Failed = $failed
}
}
function Get-AccentColorVariants {
param([string]$HexColor)
$hex = $HexColor.TrimStart("#")
$r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
$g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
$b = [Convert]::ToInt32($hex.Substring(4, 2), 16)
function Adjust-Lightness {
param([int]$R, [int]$G, [int]$B, [double]$Factor)
if ($Factor -gt 0) {
$nr = [int]($R + (255 - $R) * $Factor)
$ng = [int]($G + (255 - $G) * $Factor)
$nb = [int]($B + (255 - $B) * $Factor)
} else {
$nr = [int]($R * (1 + $Factor))
$ng = [int]($G * (1 + $Factor))
$nb = [int]($B * (1 + $Factor))
}
$nr = [Math]::Clamp($nr, 0, 255)
$ng = [Math]::Clamp($ng, 0, 255)
$nb = [Math]::Clamp($nb, 0, 255)
return "#{0:X2}{1:X2}{2:X2}" -f $nr, $ng, $nb
}
return @{
Base = $HexColor
Hover = Adjust-Lightness $r $g $b 0.15
Pressed = Adjust-Lightness $r $g $b -0.15
}
}
function Get-SystemTimeFormat {
try {
$s = Get-ItemPropertyValue "HKCU:\Control Panel\International" "sShortTime" -ErrorAction Stop
if ($s -match "H") { return $true }
if ($s -match "h") { return $false }
} catch {}
return ((Get-Culture).DateTimeFormat.ShortTimePattern -match "H")
}
function Get-FormattedTimestamp {
if ($script:Use24HourTime) {
return (Get-Date).ToString("HH:mm:ss")
} else {
return (Get-Date).ToString("h:mm:ss tt")
}
}
$script:UndoStack = [System.Collections.Stack]::new()
$script:RedoStack = [System.Collections.Stack]::new()
function Push-UndoState {
param(
[string]$Action,
[hashtable]$Snapshot
)
$entry = @{
Action = $Action
Snapshot = $Snapshot.Clone()
Time = Get-FormattedTimestamp
}
$script:UndoStack.Push($entry)
$script:RedoStack.Clear()
if ($script:UndoStack.Count -gt $script:MaxUndoDepth) {
$arr = $script:UndoStack.ToArray()
$script:UndoStack.Clear()
for ($i = $script:MaxUndoDepth - 1; $i -ge 0; $i--) {
$script:UndoStack.Push($arr[$i])
}
}
}
function Get-CurrentFlagSnapshot {
return $script:Flags.Clone()
}
function Invoke-Undo {
if ($script:UndoStack.Count -eq 0) { return $false }
$entry = $script:UndoStack.Pop()
$currentSnapshot = $script:Flags.Clone()
$redoEntry = @{
Action = "Redo: $($entry.Action)"
Snapshot = $currentSnapshot
Time = Get-FormattedTimestamp
}
$script:RedoStack.Push($redoEntry)
$script:Flags = $entry.Snapshot.Clone()
return $true
}
function Invoke-Redo {
if ($script:RedoStack.Count -eq 0) { return $false }
$entry = $script:RedoStack.Pop()
$currentSnapshot = $script:Flags.Clone()
$undoEntry = @{
Action = "Undo: $($entry.Action)"
Snapshot = $currentSnapshot
Time = Get-FormattedTimestamp
}
$script:UndoStack.Push($undoEntry)
$script:Flags = $entry.Snapshot.Clone()
return $true
}
$script:BootstrapperDefs = @(
@{
Name = "Froststrap"
RegKey = "HKCU:\Software\Froststrap"
RegValue = "InstallLocation"
DefaultPath = Join-Path $env:LOCALAPPDATA "Froststrap"
Exe = "Froststrap.exe"
Priority = 3
},
@{
Name = "Fishstrap"
RegKey = "HKCU:\Software\Fishstrap"
RegValue = "InstallLocation"
DefaultPath = Join-Path $env:LOCALAPPDATA "Fishstrap"
Exe = "Fishstrap.exe"
Priority = 2
},
@{
Name = "Bloxstrap"
RegKey = "HKCU:\Software\Bloxstrap"
RegValue = "InstallLocation"
DefaultPath = Join-Path $env:LOCALAPPDATA "Bloxstrap"
Exe = "Bloxstrap.exe"
Priority = 1
}
)
$script:DetectedBootstrappers = @()
$script:CustomBootstrappers = @()
function Find-Bootstrapper {
param([hashtable]$Def)
$installPath = $null
try {
$installPath = Get-ItemPropertyValue $Def.RegKey $Def.RegValue -ErrorAction Stop
} catch {}
if (-not $installPath) {
$installPath = $Def.DefaultPath
}
$exePath = Join-Path $installPath $Def.Exe
if (Test-Path $exePath -PathType Leaf) {
return @{
Name = $Def.Name
Path = $exePath
Found = $true
Priority = $Def.Priority
}
}
return @{
Name = $Def.Name
Path = $exePath
Found = $false
Priority = $Def.Priority
}
}
function Detect-Bootstrappers {
$script:DetectedBootstrappers = @()
foreach ($def in $script:BootstrapperDefs) {
$result = Find-Bootstrapper -Def $def
$script:DetectedBootstrappers += $result
}
$script:DetectedBootstrappers = $script:DetectedBootstrappers |
Sort-Object -Property Priority -Descending
$customData = Read-Json -Path $script:BootstrappersFile
$script:CustomBootstrappers = @()
if ($null -ne $customData) {
if ($customData -is [hashtable]) {
foreach ($key in $customData.Keys) {
$exists = Test-Path $customData[$key] -PathType Leaf -ErrorAction SilentlyContinue
$script:CustomBootstrappers += @{
Name = $key
Path = $customData[$key]
Found = $exists
Priority = 0
}
}
} else {
foreach ($prop in $customData.PSObject.Properties) {
$exists = Test-Path $prop.Value -PathType Leaf -ErrorAction SilentlyContinue
$script:CustomBootstrappers += @{
Name = $prop.Name
Path = $prop.Value
Found = $exists
Priority = 0
}
}
}
}
}
function Get-AllBootstrappers {
$all = @()
$all += $script:DetectedBootstrappers
$all += $script:CustomBootstrappers
return $all
}
function Get-SelectedBootstrapper {
$selected = $script:Settings.selectedBootstrapper
if ([string]::IsNullOrWhiteSpace($selected)) {
$found = $script:DetectedBootstrappers | Where-Object { $_.Found } | Select-Object -First 1
if ($null -ne $found) { return $found }
return $null
}
$all = Get-AllBootstrappers
$match = $all | Where-Object { $_.Name -eq $selected -and $_.Found } | Select-Object -First 1
if ($null -ne $match) { return $match }
$found = $script:DetectedBootstrappers | Where-Object { $_.Found } | Select-Object -First 1
if ($null -ne $found) { return $found }
return $null
}
function Add-CustomBootstrapper {
param(
[string]$Name,
[string]$Path
)
Ensure-DataFolder | Out-Null
$custom = @{}
foreach ($b in $script:CustomBootstrappers) {
$custom[$b.Name] = $b.Path
}
$custom[$Name] = $Path
Write-Json -Path $script:BootstrappersFile -Data $custom
Detect-Bootstrappers
}
function Remove-CustomBootstrapper {
param([string]$Name)
$custom = @{}
foreach ($b in $script:CustomBootstrappers) {
if ($b.Name -ne $Name) {
$custom[$b.Name] = $b.Path
}
}
if (Test-Path $script:BootstrappersFile) {
if ($custom.Count -eq 0) {
Remove-Item $script:BootstrappersFile -Force
} else {
Write-Json -Path $script:BootstrappersFile -Data $custom
}
}
Detect-Bootstrappers
}
function Find-RobloxInstallations {
$results = [System.Collections.Generic.List[hashtable]]::new()
$vanillaVersions = Join-Path $env:LOCALAPPDATA "Roblox\Versions"
if (Test-Path $vanillaVersions) {
Get-ChildItem $vanillaVersions -Directory -ErrorAction SilentlyContinue |
Where-Object { Test-Path (Join-Path $_.FullName "RobloxPlayerBeta.exe") -PathType Leaf } |
ForEach-Object {
$results.Add(@{
Name = "Roblox ($($_.Name))"
Root = $_.FullName
VersionHash = $_.Name
CacertPath = Join-Path $_.FullName "ssl\cacert.pem"
ClientSettingsDir = Join-Path $_.FullName "ClientSettings"
Source = 'roblox'
Discovered = $true
})
}
}
foreach ($def in $script:BootstrapperDefs) {
$bsBase = $null
try {
$bsBase = Get-ItemPropertyValue $def.RegKey $def.RegValue -ErrorAction Stop
} catch {}
if ([string]::IsNullOrWhiteSpace($bsBase)) { $bsBase = $def.DefaultPath }
if ([string]::IsNullOrWhiteSpace($bsBase)) { continue }
$bsVersions = Join-Path $bsBase "Versions"
if (-not (Test-Path $bsVersions)) { continue }
$sourceKey = $def.Name.ToLowerInvariant()
Get-ChildItem $bsVersions -Directory -ErrorAction SilentlyContinue |
Where-Object { Test-Path (Join-Path $_.FullName "RobloxPlayerBeta.exe") -PathType Leaf } |
ForEach-Object {
$results.Add(@{
Name = "$($def.Name) ($($_.Name))"
Root = $_.FullName
VersionHash = $_.Name
CacertPath = Join-Path $_.FullName "ssl\cacert.pem"
ClientSettingsDir = Join-Path $_.FullName "ClientSettings"
Source = $sourceKey
Discovered = $true
})
}
}
return $results.ToArray()
}
$script:ThemeColors = @{
WindowTint = "#1c0808"
SidebarTint = "#1f0d0d"
MiddleLayer = "#25121A"
CardLayer = "#3A1F2A"
Surface = "#3D1A28"
SurfaceOpacity = 0.85
TextPrimary = "#FFFFFF"
TextSecondary = "#C0B0B8"
Dividers = "#4A2A38"
TableHeader = "#3A1525"
TableRowHover = "#4D2838"
ButtonSurface = "#4D2632"
InputSurface = "#4D2632"
InputSurfaceFocused = "#381A26"
ConsoleLogBg = "#2A0E1A"
Success = "#6BCB77"
Error = "#E74C4C"
Warning = "#FFC000"
WatchdogTeal = "#4EC9B0"
PrefixBool = "#5B9BD5"
PrefixInt = "#70AD47"
PrefixString = "#FFC000"
PrefixLog = "#A0A0A0"
PrefixUnknown = "#808080"
}
$script:AppFontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Nunito, Segoe UI, sans-serif")
$script:IconFontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Segoe Fluent Icons, Segoe MDL2 Assets")
function Set-SafeFontFamily {
[OutputType([void])]
param($Target, $Family)
if ($null -eq $Target) { return }
if ($null -eq $Family) { return }
try {
$src = [string]$Family.Source
if ([string]::IsNullOrWhiteSpace($src)) { return }
} catch { return }
try { $Target.FontFamily = $Family } catch { }
}
$script:BrushCache = @{}
function New-Color {
param([string]$Hex)
$clean = $Hex.TrimStart("#")
if ($clean.Length -eq 6) {
return [WinUIShell.Windows.UI.Color]::FromArgb(255,
[Convert]::ToByte($clean.Substring(0, 2), 16),
[Convert]::ToByte($clean.Substring(2, 2), 16),
[Convert]::ToByte($clean.Substring(4, 2), 16))
}
if ($clean.Length -eq 8) {
return [WinUIShell.Windows.UI.Color]::FromArgb(
[Convert]::ToByte($clean.Substring(0, 2), 16),
[Convert]::ToByte($clean.Substring(2, 2), 16),
[Convert]::ToByte($clean.Substring(4, 2), 16),
[Convert]::ToByte($clean.Substring(6, 2), 16))
}
return [WinUIShell.Windows.UI.Color]::FromArgb(255, 255, 255, 255)
}
function New-SolidBrush {
param([string]$Hex)
if ($script:BrushCache.ContainsKey($Hex)) { return $script:BrushCache[$Hex] }
$color = New-Color -Hex $Hex
$brush = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new($color)
$script:BrushCache[$Hex] = $brush
return $brush
}
function New-AccentBrush {
$color = New-Color -Hex $script:AccentColor
return [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new($color)
}
function Set-AccentResourceOverrides {
param([object]$ResourceDictionary)
if ($false) { return }
try {
$accentBrush = New-AccentBrush
$accentHoverBrush = New-SolidBrush -Hex $script:AccentVariants.Hover
$accentPressedBrush = New-SolidBrush -Hex $script:AccentVariants.Pressed
$whiteBrush = New-SolidBrush -Hex "#FFFFFF"
$focusThickness = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0,0,0,2)
$rd = $ResourceDictionary
$themeDict = $null
try {
$themeDict = [WinUIShell.Microsoft.UI.Xaml.ResourceDictionary]::new()
} catch { $themeDict = $null }
if ($null -ne $themeDict) {
try {
$themeDict["ToggleSwitchFillOn"] = $accentBrush
$themeDict["ToggleSwitchFillOnPointerOver"] = $accentHoverBrush
$themeDict["ToggleSwitchFillOnPressed"] = $accentPressedBrush
$themeDict["ToggleSwitchStrokeOn"] = $accentBrush
$themeDict["ToggleSwitchStrokeOnPointerOver"] = $accentHoverBrush
$themeDict["ToggleSwitchStrokeOnPressed"] = $accentPressedBrush
$themeDict["SliderTrackValueFill"] = $accentBrush
$themeDict["SliderTrackValueFillPointerOver"] = $accentHoverBrush
$themeDict["SliderTrackValueFillPressed"] = $accentPressedBrush
$themeDict["SliderThumbBackground"] = $accentBrush
$themeDict["SliderThumbBackgroundPointerOver"] = $accentHoverBrush
$themeDict["SliderThumbBackgroundPressed"] = $accentPressedBrush
$themeDict["ListViewItemSelectionIndicatorBrush"] = $accentBrush
$themeDict["ListViewItemSelectionIndicatorPointerOverBrush"] = $accentHoverBrush
$themeDict["ListViewItemSelectionIndicatorPressedBrush"] = $accentPressedBrush
$themeDict["ComboBoxItemPillFillBrush"] = $accentBrush
$themeDict["NavigationViewSelectionIndicatorForeground"] = $accentBrush
$themeDict["CheckBoxCheckBackgroundFillChecked"] = $accentBrush
$themeDict["CheckBoxCheckBackgroundFillCheckedPointerOver"] = $accentHoverBrush
$themeDict["CheckBoxCheckBackgroundFillCheckedPressed"] = $accentPressedBrush
$themeDict["TextControlBorderBrushFocused"] = $accentBrush
$themeDict["TextControlBorderThemeThicknessFocused"] = $focusThickness
$themeDict["ListViewItemCheckBrush"] = $whiteBrush
$themeDict["ListViewItemCheckPressedBrush"] = $whiteBrush
$themeDict["ListViewItemCheckBoxSelectedBrush"] = $accentBrush
$themeDict["ListViewItemCheckBoxSelectedPointerOverBrush"] = $accentHoverBrush
$themeDict["ListViewItemCheckBoxSelectedPressedBrush"] = $accentPressedBrush
$rd.ThemeDictionaries["Dark"] = $themeDict
} catch { }
}
$rd["ToggleSwitchFillOn"] = $accentBrush
$rd["ToggleSwitchFillOnPointerOver"] = $accentHoverBrush
$rd["ToggleSwitchFillOnPressed"] = $accentPressedBrush
$rd["ToggleSwitchStrokeOn"] = $accentBrush
$rd["ToggleSwitchStrokeOnPointerOver"] = $accentHoverBrush
$rd["ToggleSwitchStrokeOnPressed"] = $accentPressedBrush
$rd["SliderTrackValueFill"] = $accentBrush
$rd["SliderTrackValueFillPointerOver"] = $accentHoverBrush
$rd["SliderTrackValueFillPressed"] = $accentPressedBrush
$rd["SliderThumbBackground"] = $accentBrush
$rd["SliderThumbBackgroundPointerOver"] = $accentHoverBrush
$rd["SliderThumbBackgroundPressed"] = $accentPressedBrush
$rd["ListViewItemSelectionIndicatorBrush"] = $accentBrush
$rd["ListViewItemSelectionIndicatorPointerOverBrush"] = $accentHoverBrush
$rd["ListViewItemSelectionIndicatorPressedBrush"] = $accentPressedBrush
$rd["ComboBoxItemPillFillBrush"] = $accentBrush
$rd["NavigationViewSelectionIndicatorForeground"] = $accentBrush
$rd["CheckBoxCheckBackgroundFillChecked"] = $accentBrush
$rd["CheckBoxCheckBackgroundFillCheckedPointerOver"] = $accentHoverBrush
$rd["CheckBoxCheckBackgroundFillCheckedPressed"] = $accentPressedBrush
$rd["TextControlBorderBrushFocused"] = $accentBrush
$rd["TextControlBorderThemeThicknessFocused"] = $focusThickness
$rd["ListViewItemCheckBrush"] = $whiteBrush
$rd["ListViewItemCheckPressedBrush"] = $whiteBrush
$rd["ListViewItemCheckBoxSelectedBrush"] = $accentBrush
$rd["ListViewItemCheckBoxSelectedPointerOverBrush"] = $accentHoverBrush
$rd["ListViewItemCheckBoxSelectedPressedBrush"] = $accentPressedBrush
} catch {}
}
function Set-ThemedTextBoxResources {
param([object]$Control)
if ($null -eq $Control) { return }
if ($false) { return }
try {
$bgBrush = New-SolidBrush -Hex $script:ThemeColors.InputSurface
$focusBrush = New-SolidBrush -Hex $script:ThemeColors.InputSurfaceFocused
$rd = $Control.Resources
$rd["TextControlBackground"] = $bgBrush
$rd["TextControlBackgroundPointerOver"] = $bgBrush
$rd["TextControlBackgroundFocused"] = $focusBrush
$rd["TextControlBorderBrushFocused"] = New-AccentBrush
$rd["TextControlBorderThemeThicknessFocused"] = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0,0,0,2)
} catch {}
}
function Set-ThemedComboBoxResources {
param([object]$Control)
if ($null -eq $Control) { return }
if ($false) { return }
try {
$cbBg = New-SolidBrush -Hex $script:ThemeColors.InputSurface
$cbFocus = New-SolidBrush -Hex $script:ThemeColors.InputSurfaceFocused
$cbSurface = New-SolidBrush -Hex $script:ThemeColors.Surface
$Control.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$rd = $Control.Resources
$rd["ComboBoxBackground"] = $cbBg
$rd["ComboBoxBackgroundPointerOver"] = $cbBg
$rd["ComboBoxBackgroundPressed"] = $cbFocus
$rd["ComboBoxBackgroundFocused"] = $cbFocus
$rd["ComboBoxBackgroundUnfocused"] = $cbBg
$rd["ComboBoxDropDownBackground"] = $cbSurface
$rd["ComboBoxItemPillFillBrush"] = New-AccentBrush
$cbAc = New-Color -Hex $script:AccentColor
foreach ($aKey in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$rd[$aKey] = $cbAc
}
Set-AccentResourceOverrides -ResourceDictionary $rd
} catch {}
}
function Set-ThemedRadioButtonResources {
param([object]$Control)
if ($null -eq $Control) { return }
if ($false) { return }
try {
$accentBrush = New-AccentBrush
$rd = $Control.Resources
$rd["RadioButtonOuterEllipseCheckedStroke"] = $accentBrush
$rd["RadioButtonOuterEllipseCheckedStrokePointerOver"] = $accentBrush
$rd["RadioButtonOuterEllipseCheckedStrokePressed"] = $accentBrush
$rd["RadioButtonOuterEllipseCheckedFill"] = $accentBrush
$rd["RadioButtonOuterEllipseCheckedFillPointerOver"] = $accentBrush
$rd["RadioButtonOuterEllipseCheckedFillPressed"] = $accentBrush
} catch {}
}
function Set-ThemedDialogResources {
param([object]$Dialog)
if ($null -eq $Dialog) { return }
if ($false) { return }
try {
$Dialog.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$Dialog.Background = New-SolidBrush -Hex $script:ThemeColors.Surface
$ac = New-Color -Hex $script:AccentColor
$rd = $Dialog.Resources
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$rd[$key] = $ac
}
Set-AccentResourceOverrides -ResourceDictionary $rd
} catch {}
}
function Set-WindowTheme {
param(
[WinUIShell.Microsoft.UI.Xaml.Window]$Window
)
$iconFile = $script:IconPath
$iconFile = (Resolve-Path $iconFile).Path
try { $Window.AppWindow.SetIcon($iconFile) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$content = $Window.Content
if ($null -ne $content) {
$content.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
}
try {
$Window.SystemBackdrop = [WinUIShell.Microsoft.UI.Xaml.Media.DesktopAcrylicBackdrop]::new()
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
try {
$tb = $Window.AppWindow.TitleBar
$tb.ButtonBackgroundColor = [WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0)
$tb.ButtonInactiveBackgroundColor = [WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0)
$tb.ButtonHoverBackgroundColor = New-Color -Hex $script:ThemeColors.TableRowHover
$tb.ButtonPressedBackgroundColor = New-Color -Hex $script:ThemeColors.Surface
$tb.ButtonForegroundColor = New-Color -Hex $script:ThemeColors.TextPrimary
$tb.ButtonHoverForegroundColor = New-Color -Hex $script:ThemeColors.TextPrimary
$tb.ButtonInactiveForegroundColor = New-Color -Hex $script:ThemeColors.TextSecondary
} catch { Write-ConsoleLog -Message "Error setting caption colors: $_" -Level "ERROR" }
try {
$rd = $content.Resources
$ac = New-Color -Hex $script:AccentColor
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$rd[$key] = $ac
}
} catch { Write-ConsoleLog -Message "ResourceDictionary accent override not supported: $_" -Level "WARN" }
try { Set-AccentResourceOverrides -ResourceDictionary $rd } catch {}
}
function New-ThemedButton {
param(
[string]$Content,
[string]$Glyph = "",
[string]$ForegroundHex = "",
[string]$BackgroundHex = "",
[double]$FontSize = 14,
[switch]$AccentStyle,
[switch]$ToolbarStyle,
[switch]$IconOnly
)
$btn = [WinUIShell.Microsoft.UI.Xaml.Controls.Button]::new()
if ($IconOnly -and -not [string]::IsNullOrWhiteSpace($Glyph)) {
$stack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$stack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$stack.Spacing = 0
$icon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$icon.Glyph = $Glyph
Set-SafeFontFamily -Target $icon -Family $script:IconFontFamily
$icon.FontSize = $FontSize
$icon.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$stack.Children.Add($icon) | Out-Null
$anchor = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$anchor.Text = ' '
Set-SafeFontFamily -Target $anchor -Family $script:AppFontFamily
$anchor.FontSize = $FontSize
$anchor.Width = 0
$anchor.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$stack.Children.Add($anchor) | Out-Null
$btn.Content = $stack
} elseif (-not [string]::IsNullOrWhiteSpace($Glyph)) {
$stack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$stack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$stack.Spacing = 8
$icon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$icon.Glyph = $Glyph
Set-SafeFontFamily -Target $icon -Family $script:IconFontFamily
$icon.FontSize = $FontSize
$stack.Children.Add($icon) | Out-Null
$text = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$text.Text = $Content
Set-SafeFontFamily -Target $text -Family $script:AppFontFamily
$text.FontSize = $FontSize
$text.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::NoWrap
$text.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$stack.Children.Add($text) | Out-Null
$btn.Content = $stack
} else {
$txt = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$txt.Text = $Content
Set-SafeFontFamily -Target $txt -Family $script:AppFontFamily
$txt.FontSize = $FontSize
$txt.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::NoWrap
$btn.Content = $txt
}
Set-SafeFontFamily -Target $btn -Family $script:AppFontFamily
$btn.FontSize = $FontSize
if (-not [string]::IsNullOrWhiteSpace($ForegroundHex)) {
$btn.Foreground = New-SolidBrush -Hex $ForegroundHex
}
if (-not [string]::IsNullOrWhiteSpace($BackgroundHex)) {
$btn.Background = New-SolidBrush -Hex $BackgroundHex
}
if ($AccentStyle) {
$btn.Foreground = New-SolidBrush -Hex "#FFFFFF"
$btn.Background = New-AccentBrush
}
if ($ToolbarStyle) {
$btn.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$btn.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$btn.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 4, 8, 4)
$btn.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(4)
}
return $btn
}
function New-ThemedTextBox {
param(
[string]$Placeholder = "",
[string]$Text = "",
[double]$FontSize = 14
)
$tb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBox]::new()
Set-SafeFontFamily -Target $tb -Family $script:AppFontFamily
$tb.FontSize = $FontSize
$tb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$tb.Background = New-SolidBrush -Hex $script:ThemeColors.InputSurface
Set-ThemedTextBoxResources -Control $tb
$tb.PlaceholderText = $Placeholder
if (-not [string]::IsNullOrWhiteSpace($Text)) {
$tb.Text = $Text
}
return $tb
}
function New-ThemedToggleSwitch {
param(
[string]$Header = "",
[bool]$IsOn = $false
)
$ts = [WinUIShell.Microsoft.UI.Xaml.Controls.ToggleSwitch]::new()
Set-SafeFontFamily -Target $ts -Family $script:AppFontFamily
$ts.FontSize = 14
$ts.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
if (-not [string]::IsNullOrWhiteSpace($Header)) {
$ts.Header = $Header
}
$ts.IsOn = $IsOn
try { Set-AccentResourceOverrides -ResourceDictionary $ts.Resources } catch { }
return $ts
}
function New-ThemedListView {
param(
[double]$FontSize = 14
)
$lv = [WinUIShell.Microsoft.UI.Xaml.Controls.ListView]::new()
Set-SafeFontFamily -Target $lv -Family $script:AppFontFamily
$lv.FontSize = $FontSize
$lv.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$lv.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new([WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0))
$lv.SelectionMode = [WinUIShell.Microsoft.UI.Xaml.Controls.ListViewSelectionMode]::Extended
$ac = New-Color -Hex $script:AccentColor
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$lv.Resources[$key] = $ac
}
try { Set-AccentResourceOverrides -ResourceDictionary $lv.Resources } catch {}
return $lv
}
function New-ThemedProgressBar {
param([switch]$Indeterminate)
$pb = [WinUIShell.Microsoft.UI.Xaml.Controls.ProgressBar]::new()
$pb.Foreground = New-AccentBrush
if ($Indeterminate) {
$pb.IsIndeterminate = $true
}
return $pb
}
function Show-CustomDialog {
param(
[WinUIShell.Microsoft.UI.Xaml.XamlRoot]$XamlRoot,
[string]$Title,
[object]$Content,
[string]$PrimaryButtonText = "",
[string]$SecondaryButtonText = "",
[string]$CloseButtonText = "Close",
[switch]$NoCloseButton,
[double]$MaxWidth = 0
)
$dialog = [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialog]::new()
$dialog.XamlRoot = $XamlRoot
$dialog.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$dialog.Title = $Title
$dialog.Content = $Content
Set-SafeFontFamily -Target $dialog -Family $script:AppFontFamily
Set-ThemedDialogResources -Dialog $dialog
if ($MaxWidth -gt 0) {
try { $dialog.Resources["ContentDialogMaxWidth"] = [double]$MaxWidth } catch { }
}
if (-not [string]::IsNullOrWhiteSpace($PrimaryButtonText)) {
$dialog.PrimaryButtonText = $PrimaryButtonText
}
if (-not [string]::IsNullOrWhiteSpace($SecondaryButtonText)) {
$dialog.SecondaryButtonText = $SecondaryButtonText
}
if (-not $NoCloseButton) {
$dialog.CloseButtonText = $CloseButtonText
}
$resultValue = $dialog.ShowAsync().WaitForCompleted()
if ($resultValue -eq 1 -or "$resultValue" -eq "Primary" -or $resultValue -eq [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialogResult]::Primary) {
return "Primary"
} elseif ($resultValue -eq 2 -or "$resultValue" -eq "Secondary" -or $resultValue -eq [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialogResult]::Secondary) {
return "Secondary"
}
return "None"
}
function Show-TeachingTip {
param(
[WinUIShell.Microsoft.UI.Xaml.FrameworkElement]$Target = $null,
[WinUIShell.Microsoft.UI.Xaml.XamlRoot]$XamlRoot = $null,
[string]$Title = "",
[string]$Subtitle = "",
[string]$Message = "",
[bool]$IsLightDismissEnabled = $true
)
$tip = [WinUIShell.Microsoft.UI.Xaml.Controls.TeachingTip]::new()
if ($null -ne $Target) {
$tip.Target = $Target
} elseif ($null -ne $XamlRoot) {
$tip.XamlRoot = $XamlRoot
}
$tip.Title = $Title
if (-not [string]::IsNullOrWhiteSpace($Message)) {
$tip.Subtitle = $Message
} elseif (-not [string]::IsNullOrWhiteSpace($Subtitle)) {
$tip.Subtitle = $Subtitle
}
$tip.IsLightDismissEnabled = $IsLightDismissEnabled
Set-SafeFontFamily -Target $tip -Family $script:AppFontFamily
$tip.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$tip.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$tip.IsOpen = $true
if ($null -eq $script:ActiveTeachingTips) {
$script:ActiveTeachingTips = [System.Collections.Generic.List[object]]::new()
}
$script:ActiveTeachingTips.Add($tip)
$dt = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$dt.Interval = New-UITimeSpan -Milliseconds 2000
$tipRefLocal = $tip
$tipsRefLocal = $script:ActiveTeachingTips
$dt.AddTick({
param($argumentList, $s, $e)
$s.Stop()
try { $tipRefLocal.IsOpen = $false } catch {}
try { $tipsRefLocal.Remove($tipRefLocal) } catch {}
}.GetNewClosure())
$dt.Start()
}
function Show-ConfirmDialog {
param(
[WinUIShell.Microsoft.UI.Xaml.XamlRoot]$XamlRoot,
[string]$Title,
[string]$Message,
[string]$ConfirmText = "Confirm",
[string]$CancelText = "Cancel"
)
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 12
$msg = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$msg.Text = $Message
Set-SafeFontFamily -Target $msg -Family $script:AppFontFamily
$msg.FontSize = 14
$msg.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$msg.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$panel.Children.Add($msg) | Out-Null
$result = Show-CustomDialog -XamlRoot $XamlRoot -Title $Title -Content $panel -PrimaryButtonText $ConfirmText -CloseButtonText $CancelText
return ($result -eq "Primary")
}
function Show-InputDialog {
param(
[WinUIShell.Microsoft.UI.Xaml.XamlRoot]$XamlRoot,
[string]$Title,
[string]$Label = "",
[string]$DefaultValue = "",
[string]$Placeholder = ""
)
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 12
if (-not [string]::IsNullOrWhiteSpace($Label)) {
$lbl = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$lbl.Text = $Label
Set-SafeFontFamily -Target $lbl -Family $script:AppFontFamily
$lbl.FontSize = 14
$lbl.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$panel.Children.Add($lbl) | Out-Null
}
$input = New-ThemedTextBox -Placeholder $Placeholder -Text $DefaultValue
$input.Name = "InputDialogField"
$panel.Children.Add($input) | Out-Null
$result = Show-CustomDialog -XamlRoot $XamlRoot -Title $Title -Content $panel -PrimaryButtonText "OK" -CloseButtonText "Cancel"
if ($result -eq "Primary") {
return @{ Success = $true; Value = $input.Text }
}
return @{ Success = $false; Value = "" }
}
function New-FontIcon {
param(
[string]$Glyph,
[double]$Size = 16
)
$icon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$icon.Glyph = $Glyph
Set-SafeFontFamily -Target $icon -Family $script:IconFontFamily
$icon.FontSize = $Size
$icon.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
return $icon
}
function New-AccentFontIcon {
param(
[string]$Glyph,
[double]$Size = 16
)
$icon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$icon.Glyph = $Glyph
Set-SafeFontFamily -Target $icon -Family $script:IconFontFamily
$icon.FontSize = $Size
$icon.Foreground = New-AccentBrush
return $icon
}
function New-MenuFlyoutItem {
param(
[string]$Text,
[string]$Glyph = "",
[bool]$IsEnabled = $true,
[scriptblock]$OnClick
)
$item = [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyoutItem]::new()
if ($PSBoundParameters.ContainsKey('IsEnabled')) {
$item.IsEnabled = $IsEnabled
}
$item.Text = $Text
Set-SafeFontFamily -Target $item -Family $script:AppFontFamily
$item.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
if (-not [string]::IsNullOrWhiteSpace($Glyph)) {
$icon = New-FontIcon -Glyph $Glyph
$item.Icon = $icon
}
if ($null -ne $OnClick) {
$item.AddClick($OnClick)
}
return $item
}
function New-MenuFlyoutSeparator {
return [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyoutSeparator]::new()
}
function New-MenuFlyoutSubItem {
param(
[string]$Text,
[string]$Glyph = ""
)
$sub = [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyoutSubItem]::new()
$sub.Text = $Text
Set-SafeFontFamily -Target $sub -Family $script:AppFontFamily
$sub.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
if (-not [string]::IsNullOrWhiteSpace($Glyph)) {
$icon = New-FontIcon -Glyph $Glyph
$sub.Icon = $icon
}
return $sub
}
function New-ToggleMenuFlyoutItem {
param(
[string]$Text,
[string]$Glyph = "",
[bool]$IsChecked = $false,
[scriptblock]$OnClick
)
$item = [WinUIShell.Microsoft.UI.Xaml.Controls.ToggleMenuFlyoutItem]::new()
$item.Text = $Text
Set-SafeFontFamily -Target $item -Family $script:AppFontFamily
$item.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$item.IsChecked = $IsChecked
if (-not [string]::IsNullOrWhiteSpace($Glyph)) {
$icon = New-FontIcon -Glyph $Glyph
$item.Icon = $icon
}
if ($null -ne $OnClick) {
$item.AddClick($OnClick)
}
return $item
}
function New-ContextMenu {
param(
[System.Collections.Generic.List[object]]$Items
)
$flyout = [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyout]::new()
if ($null -ne $Items) {
foreach ($item in $Items) {
$flyout.Items.Add($item) | Out-Null
}
}
return $flyout
}
function New-KeyboardAccelerator {
param(
[WinUIShell.Windows.System.VirtualKey]$Key,
[WinUIShell.Windows.System.VirtualKeyModifiers]$Modifiers = [WinUIShell.Windows.System.VirtualKeyModifiers]::None,
[scriptblock]$Action
)
$ka = [WinUIShell.Microsoft.UI.Xaml.Input.KeyboardAccelerator]::new()
$ka.Key = $Key
$ka.Modifiers = $Modifiers
if ($null -ne $Action) {
$ka.AddInvoked({
param($argumentList, $s, $e)
& $Action
$e.Handled = $true
}.GetNewClosure())
}
return $ka
}
$script:TrayNotifyIcon = $null
$script:TrayHwnd = [IntPtr]::Zero
$script:TrayIconHandle = [IntPtr]::Zero
$script:TrayClassAtom = 0
$script:TrayClassName = "AlliumTrayClass_" + [System.Guid]::NewGuid().ToString("N")
$script:TrayWndProcDelegate = $null
$script:AutoReapplyTimer = $null
$script:AutoReapplyEventJob = $null
function Initialize-SystemTray {
if ($null -ne $script:TrayNotifyIcon) { return }
$hInstance = [Allium.Win32Tray]::GetModuleHandleW($null)
$script:TrayIconHandle = [IntPtr]::Zero
if (Test-Path $script:IconPath) {
try {
$iconAbs = (Resolve-Path $script:IconPath).Path
$script:TrayIconHandle = [Allium.Win32Tray]::LoadImageW(
[IntPtr]::Zero, $iconAbs,
[Allium.Win32Tray]::IMAGE_ICON, 0, 0,
([Allium.Win32Tray]::LR_LOADFROMFILE -bor [Allium.Win32Tray]::LR_DEFAULTSIZE))
if ([IntPtr]::Zero -eq $script:TrayIconHandle) {
Write-ConsoleLog -Message "Tray icon LoadImageW returned NULL; using default." -Level "WARN"
}
} catch {
Write-ConsoleLog -Message "Tray icon load failed: $_" -Level "WARN"
}
}
$script:TrayWndProcDelegate = [Allium.Win32Tray+WndProcDelegate]{
param([IntPtr]$hwnd, [uint32]$msg, [IntPtr]$wp, [IntPtr]$lp)
try {
if ($msg -eq [Allium.Win32Tray]::WM_TRAYCALLBACK) {
$event = ($lp.ToInt64()) -band 0xFFFF
if ($event -eq [Allium.Win32Tray]::NIN_SELECT -or $event -eq [Allium.Win32Tray]::NIN_KEYSELECT -or $event -eq [Allium.Win32Tray]::WM_LBUTTONUP) {
Invoke-TrayClickHandler -Kind 'Left' -WParam $wp
return [IntPtr]::Zero
}
if ($event -eq [Allium.Win32Tray]::WM_CONTEXTMENU -or $event -eq [Allium.Win32Tray]::WM_RBUTTONUP) {
Invoke-TrayClickHandler -Kind 'Right' -WParam $wp
return [IntPtr]::Zero
}
}
} catch {
try { Write-ConsoleLog -Message "Tray WndProc error: $_" -Level "ERROR" } catch {}
}
return [Allium.Win32Tray]::DefWindowProcW($hwnd, $msg, $wp, $lp)
}
$wndClass = [Allium.Win32Tray+WNDCLASSW]::new()
$wndClass.style = 0
$wndClass.lpfnWndProc = $script:TrayWndProcDelegate
$wndClass.cbClsExtra = 0
$wndClass.cbWndExtra = 0
$wndClass.hInstance = $hInstance
$wndClass.hIcon = [IntPtr]::Zero
$wndClass.hCursor = [IntPtr]::Zero
$wndClass.hbrBackground = [IntPtr]::Zero
$wndClass.lpszMenuName = $null
$wndClass.lpszClassName = $script:TrayClassName
$script:TrayClassAtom = [Allium.Win32Tray]::RegisterClassW([ref]$wndClass)
if (0 -eq $script:TrayClassAtom) {
Write-ConsoleLog -Message "Tray RegisterClassW failed; aborting tray init." -Level "ERROR"
$script:TrayWndProcDelegate = $null
return
}
$script:TrayHwnd = [Allium.Win32Tray]::CreateWindowExW(
0, $script:TrayClassName, "AlliumTrayMsgWnd", 0,
0, 0, 0, 0,
[Allium.Win32Tray]::HWND_MESSAGE, [IntPtr]::Zero, $hInstance, [IntPtr]::Zero)
if ([IntPtr]::Zero -eq $script:TrayHwnd) {
Write-ConsoleLog -Message "Tray CreateWindowExW failed; aborting tray init." -Level "ERROR"
[void][Allium.Win32Tray]::UnregisterClassW($script:TrayClassName, $hInstance)
$script:TrayClassAtom = 0
$script:TrayWndProcDelegate = $null
return
}
Enable-TrayDarkMode -Hwnd $script:TrayHwnd
$nid = [Allium.Win32Tray+NOTIFYICONDATAW]::new()
$nid.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type][Allium.Win32Tray+NOTIFYICONDATAW])
$nid.hWnd = $script:TrayHwnd
$nid.uID = 1
$nid.uFlags = ([Allium.Win32Tray]::NIF_MESSAGE -bor [Allium.Win32Tray]::NIF_ICON -bor [Allium.Win32Tray]::NIF_TIP -bor [Allium.Win32Tray]::NIF_SHOWTIP)
$nid.uCallbackMessage = [Allium.Win32Tray]::WM_TRAYCALLBACK
$nid.hIcon = $script:TrayIconHandle
$nid.szTip = "Allium - FFlag Engine"
$nid.dwState = 0
$nid.dwStateMask = 0
$nid.szInfo = ""
$nid.uVersion = 0
$nid.szInfoTitle = ""
$nid.dwInfoFlags = 0
$nid.guidItem = [System.Guid]::Empty
$nid.hBalloonIcon = [IntPtr]::Zero
$added = [Allium.Win32Tray]::Shell_NotifyIconW([Allium.Win32Tray]::NIM_ADD, [ref]$nid)
if (-not $added) {
Write-ConsoleLog -Message "Tray Shell_NotifyIcon(NIM_ADD) failed; rolling back." -Level "ERROR"
[void][Allium.Win32Tray]::DestroyWindow($script:TrayHwnd)
[void][Allium.Win32Tray]::UnregisterClassW($script:TrayClassName, $hInstance)
$script:TrayHwnd = [IntPtr]::Zero
$script:TrayClassAtom = 0
$script:TrayWndProcDelegate = $null
return
}
$nid.uVersion = [Allium.Win32Tray]::NOTIFYICON_VERSION_4
$verOk = [Allium.Win32Tray]::Shell_NotifyIconW([Allium.Win32Tray]::NIM_SETVERSION, [ref]$nid)
if (-not $verOk) {
Write-ConsoleLog -Message "Tray NIM_SETVERSION failed (non-fatal)." -Level "WARN"
}
$script:TrayNotifyIcon = [PSCustomObject]@{
Hwnd = $script:TrayHwnd
IconHandle = $script:TrayIconHandle
ClassName = $script:TrayClassName
Added = $true
Visible = $true
}
Write-ConsoleLog -Message "System tray icon initialized." -Level "INFO"
}
function Show-TrayIcon {
if ($null -eq $script:TrayNotifyIcon) { return }
$nid = [Allium.Win32Tray+NOTIFYICONDATAW]::new()
$nid.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type][Allium.Win32Tray+NOTIFYICONDATAW])
$nid.hWnd = $script:TrayHwnd
$nid.uID = 1
$nid.uFlags = [Allium.Win32Tray]::NIF_STATE
$nid.dwState = 0
$nid.dwStateMask = [Allium.Win32Tray]::NIS_HIDDEN
[void][Allium.Win32Tray]::Shell_NotifyIconW([Allium.Win32Tray]::NIM_MODIFY, [ref]$nid)
$script:TrayNotifyIcon.Visible = $true
}
function Hide-TrayIcon {
if ($null -eq $script:TrayNotifyIcon) { return }
$nid = [Allium.Win32Tray+NOTIFYICONDATAW]::new()
$nid.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type][Allium.Win32Tray+NOTIFYICONDATAW])
$nid.hWnd = $script:TrayHwnd
$nid.uID = 1
$nid.uFlags = [Allium.Win32Tray]::NIF_STATE
$nid.dwState = [Allium.Win32Tray]::NIS_HIDDEN
$nid.dwStateMask = [Allium.Win32Tray]::NIS_HIDDEN
[void][Allium.Win32Tray]::Shell_NotifyIconW([Allium.Win32Tray]::NIM_MODIFY, [ref]$nid)
$script:TrayNotifyIcon.Visible = $false
}
function Restore-AlliumFromTray {
try {
if ($null -ne $script:EditorWindow) {
$script:EditorWindow.AppWindow.Show()
$script:EditorWindow.Activate()
} elseif ($null -ne $script:LauncherWindow) {
$script:LauncherWindow.AppWindow.Show()
$script:LauncherWindow.Activate()
}
Hide-TrayIcon
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}
function Remove-SystemTray {
if ($null -eq $script:TrayNotifyIcon) { return }
$nid = [Allium.Win32Tray+NOTIFYICONDATAW]::new()
$nid.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type][Allium.Win32Tray+NOTIFYICONDATAW])
$nid.hWnd = $script:TrayHwnd
$nid.uID = 1
[void][Allium.Win32Tray]::Shell_NotifyIconW([Allium.Win32Tray]::NIM_DELETE, [ref]$nid)
if ([IntPtr]::Zero -ne $script:TrayHwnd) {
[void][Allium.Win32Tray]::DestroyWindow($script:TrayHwnd)
}
$hInstance = [Allium.Win32Tray]::GetModuleHandleW($null)
[void][Allium.Win32Tray]::UnregisterClassW($script:TrayClassName, $hInstance)
$script:TrayHwnd = [IntPtr]::Zero
$script:TrayIconHandle = [IntPtr]::Zero
$script:TrayClassAtom = 0
$script:TrayNotifyIcon = $null
$script:TrayWndProcDelegate = $null
}
function Process-TrayMessages {
if ([IntPtr]::Zero -eq $script:TrayHwnd) { return }
$msg = [Allium.Win32Tray+MSG]::new()
$drained = 0
while ($drained -lt 5 -and [Allium.Win32Tray]::PeekMessageW([ref]$msg, $script:TrayHwnd, 0, 0, [Allium.Win32Tray]::PM_REMOVE)) {
[void][Allium.Win32Tray]::TranslateMessage([ref]$msg)
[void][Allium.Win32Tray]::DispatchMessageW([ref]$msg)
$drained++
}
}
function Enable-TrayDarkMode {
param([Parameter(Mandatory)] [IntPtr]$Hwnd)
$build = [System.Environment]::OSVersion.Version.Build
if ($build -lt [Allium.Win32Tray]::WIN_BUILD_MIN_DARK) {
Write-ConsoleLog -Message "Tray dark mode skipped: Windows build $build < 18362 (1903)." -Level "INFO"
return
}
if ([IntPtr]::Zero -eq $Hwnd) {
Write-ConsoleLog -Message "Tray dark mode skipped: null Hwnd." -Level "WARN"
return
}
try {
[void][Allium.Win32Tray]::SetPreferredAppMode([Allium.Win32Tray]::PREFERRED_APP_MODE_FORCE_DARK)
[void][Allium.Win32Tray]::AllowDarkModeForWindow($Hwnd, $true)
[void][Allium.Win32Tray]::SetWindowTheme($Hwnd, "DarkMode_Explorer", $null)
[Allium.Win32Tray]::FlushMenuThemes()
[Allium.Win32Tray]::RefreshImmersiveColorPolicyState()
Write-ConsoleLog -Message "Tray dark mode enabled." -Level "INFO"
} catch {
Write-ConsoleLog -Message "Tray dark mode failed (non-fatal, menu will use system default): $_" -Level "WARN"
}
}
function Invoke-TrayClickHandler {
param(
[Parameter(Mandatory)] [string]$Kind,
[Parameter(Mandatory)] [IntPtr]$WParam
)
try {
if ($Kind -eq 'Left') {
Restore-AlliumFromTray
return
}
if ($Kind -eq 'Right') {
$raw = $WParam.ToInt64()
$xRaw = $raw -band 0xFFFF
$yRaw = ($raw -shr 16) -band 0xFFFF
if ($xRaw -ge 0x8000) { $xRaw = $xRaw - 0x10000 }
if ($yRaw -ge 0x8000) { $yRaw = $yRaw - 0x10000 }
Show-TrayContextMenu -X $xRaw -Y $yRaw
return
}
} catch {
try { Write-ConsoleLog -Message "Invoke-TrayClickHandler error: $_" -Level "ERROR" } catch {}
}
}
function Show-TrayContextMenu {
param(
[Parameter(Mandatory)] [int]$X,
[Parameter(Mandatory)] [int]$Y
)
if ([IntPtr]::Zero -eq $script:TrayHwnd) { return }
$hMenu = [Allium.Win32Tray]::CreatePopupMenu()
if ([IntPtr]::Zero -eq $hMenu) {
Write-ConsoleLog -Message "CreatePopupMenu failed." -Level "ERROR"
return
}
$cmd = 0
try {
[void][Allium.Win32Tray]::AppendMenuW($hMenu, [Allium.Win32Tray]::MF_STRING, [UIntPtr]::new(0x1001), "Open Allium")
[void][Allium.Win32Tray]::AppendMenuW($hMenu, [Allium.Win32Tray]::MF_STRING, [UIntPtr]::new(0x1002), "Reapply FFlags Now")
[void][Allium.Win32Tray]::AppendMenuW($hMenu, [Allium.Win32Tray]::MF_SEPARATOR, [UIntPtr]::new(0), $null)
[void][Allium.Win32Tray]::AppendMenuW($hMenu, [Allium.Win32Tray]::MF_STRING, [UIntPtr]::new(0x1003), "Exit Allium")
[void][Allium.Win32Tray]::SetForegroundWindow($script:TrayHwnd)
$flags = [Allium.Win32Tray]::TPM_RIGHTBUTTON -bor [Allium.Win32Tray]::TPM_RETURNCMD -bor [Allium.Win32Tray]::TPM_NONOTIFY -bor [Allium.Win32Tray]::TPM_BOTTOMALIGN
$cmd = [Allium.Win32Tray]::TrackPopupMenu($hMenu, $flags, $X, $Y, 0, $script:TrayHwnd, [IntPtr]::Zero)
[void][Allium.Win32Tray]::PostMessageW($script:TrayHwnd, [Allium.Win32Tray]::WM_NULL, [IntPtr]::Zero, [IntPtr]::Zero)
} finally {
[void][Allium.Win32Tray]::DestroyMenu($hMenu)
}
switch ($cmd) {
0x1001 {
try { Restore-AlliumFromTray }
catch { Write-ConsoleLog -Message "Tray 'Open Allium' failed: $_" -Level "ERROR" }
}
0x1002 {
try {
$result = Write-ClientAppSettings
if ($result) {
Write-ConsoleLog -Message "Reapplied FFlags from tray menu." -Level "INFO"
} else {
Write-ConsoleLog -Message "Reapply from tray returned false (no settings path?)." -Level "WARN"
}
} catch { Write-ConsoleLog -Message "Reapply from tray failed: $_" -Level "ERROR" }
}
0x1003 {
try { Exit-Allium }
catch { Write-ConsoleLog -Message "Tray 'Exit Allium' failed: $_" -Level "ERROR" }
}
default { }
}
}
function Start-AutoReapplyTimer {
if ($null -ne $script:AutoReapplyTimer) { return }
$interval = $script:Settings.autoReapplyIntervalSeconds
if ($interval -lt 5) { $interval = 5 }
if ($interval -gt 300) { $interval = 300 }
$timer = [System.Timers.Timer]::new($interval * 1000)
$timer.AutoReset = $true
$script:AutoReapplyEventJob = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
$result = Write-ClientAppSettings
if ($result) {
Write-ConsoleLog -Message "Auto-reapply: FFlags written to ClientAppSettings.json" -Level "WATCHDOG"
}
try {
$memStats = Invoke-WatchdogAutoApplyMemory
if ($null -ne $memStats -and ($memStats.Applied -gt 0 -or $memStats.Failed -gt 0)) {
Write-ConsoleLog -Message ('Auto-reapply: memory applied=' + $memStats.Applied + ' missing=' + $memStats.Missing + ' failed=' + $memStats.Failed) -Level "WATCHDOG"
}
} catch { }
Update-InterceptorOverrides
}
$timer.Start()
$script:AutoReapplyTimer = $timer
Write-ConsoleLog -Message "Auto-reapply timer started (interval: ${interval}s)." -Level "INFO"
}
function Stop-AutoReapplyTimer {
if ($null -ne $script:AutoReapplyTimer) {
try {
$script:AutoReapplyTimer.Stop()
$script:AutoReapplyTimer.Dispose()
} catch {}
$script:AutoReapplyTimer = $null
}
if ($null -ne $script:AutoReapplyEventJob) {
try {
$script:AutoReapplyEventJob | Stop-Job -PassThru | Remove-Job -Force
} catch {}
$script:AutoReapplyEventJob = $null
}
}
function Exit-Allium {
Stop-Watchdog
Stop-AutoReapplyTimer
Remove-SystemTray
try {
if ($null -ne $script:EditorWindow) { $script:EditorWindow.Close() }
} catch {}
try {
if ($null -ne $script:BrowserWindow) { $script:BrowserWindow.Close() }
} catch {}
try {
if ($null -ne $script:LauncherWindow) { $script:LauncherWindow.Close() }
} catch {}
}
$script:ConsoleLogEntries = [System.Collections.Generic.List[hashtable]]::new()
$script:ConsoleLogLastRenderedIndex = 0
$script:ConsoleLogUseRichTextBlock = $false
$script:EditorConsoleRichTextBlock = $null
$script:EditorConsoleScrollViewer = $null
function Write-ConsoleLog {
param(
[string]$Message,
[ValidateSet("INFO", "WARN", "ERROR", "WATCHDOG")]
[string]$Level = "INFO"
)
$entry = @{
Time = Get-FormattedTimestamp
Level = $Level
Message = $Message
}
$script:ConsoleLogEntries.Add($entry)
while ($script:ConsoleLogEntries.Count -gt $script:ConsoleLogCap) {
$script:ConsoleLogEntries.RemoveAt(0)
if ($null -ne $script:ConsoleLogLastRenderedIndex -and $script:ConsoleLogLastRenderedIndex -gt 0) {
$script:ConsoleLogLastRenderedIndex--
}
}
if ($script:Settings.debugLogging) {
try {
Ensure-DataFolder | Out-Null
$line = "[$($entry.Time)] [$($entry.Level)] $($entry.Message)"
Add-Content -Path $script:DebugLogFile -Value $line -ErrorAction SilentlyContinue
} catch {}
}
}
function Get-LogColor {
param([string]$Level)
$color = $script:ThemeColors.TextPrimary
switch ($Level) {
"INFO" { $color = $script:ThemeColors.TextPrimary }
"WARN" { $color = $script:ThemeColors.Warning }
"ERROR" { $color = $script:ThemeColors.Error }
"WATCHDOG" { $color = $script:ThemeColors.WatchdogTeal }
}
return $color
}
function Update-ConsoleLogDisplay {
if ($script:ConsoleLogUseRichTextBlock) {
if ($null -eq $script:EditorConsoleRichTextBlock) { return }
$rendered = if ($null -eq $script:ConsoleLogLastRenderedIndex) { 0 } else { $script:ConsoleLogLastRenderedIndex }
$total = $script:ConsoleLogEntries.Count
if ($rendered -gt $total) {
try { $script:EditorConsoleRichTextBlock.Blocks.Clear() } catch {}
$rendered = 0
}
if ($rendered -ge $total) { return }
for ($i = $rendered; $i -lt $total; $i++) {
$entry = $script:ConsoleLogEntries[$i]
$line = "[$($entry.Time)] [$($entry.Level)] $($entry.Message)"
$color = Get-LogColor -Level $entry.Level
try {
$run = [WinUIShell.Microsoft.UI.Xaml.Documents.Run]::new()
$run.Text = $line
$run.Foreground = New-SolidBrush -Hex $color
$para = [WinUIShell.Microsoft.UI.Xaml.Documents.Paragraph]::new()
$para.Inlines.Add($run)
$script:EditorConsoleRichTextBlock.Blocks.Add($para)
} catch {
}
}
try {
while ($script:EditorConsoleRichTextBlock.Blocks.Count -gt $script:ConsoleLogCap) {
$script:EditorConsoleRichTextBlock.Blocks.RemoveAt(0)
}
} catch {}
$script:ConsoleLogLastRenderedIndex = $total
if ($null -ne $script:EditorConsoleScrollViewer) {
try {
$script:EditorConsoleScrollViewer.ChangeView($null, $script:EditorConsoleScrollViewer.ScrollableHeight, $null)
} catch {
try { $script:EditorConsoleScrollViewer.ScrollToVerticalOffset($script:EditorConsoleScrollViewer.ScrollableHeight) } catch {}
}
}
} else {
if ($null -eq $script:EditorConsoleTextBox) { return }
$rendered = if ($null -eq $script:ConsoleLogLastRenderedIndex) { 0 } else { $script:ConsoleLogLastRenderedIndex }
$total = $script:ConsoleLogEntries.Count
if ($rendered -gt $total) {
$script:EditorConsoleTextBox.Text = ""
$rendered = 0
}
if ($rendered -ge $total) { return }
$shouldAutoScroll = $true
try {
if ($script:EditorConsoleTextBox.SelectionLength -gt 0) { $shouldAutoScroll = $false }
} catch {}
$sb = [System.Text.StringBuilder]::new()
for ($i = $rendered; $i -lt $total; $i++) {
$entry = $script:ConsoleLogEntries[$i]
$line = "[$($entry.Time)] [$($entry.Level)] $($entry.Message)"
if ($i -gt 0 -or $script:EditorConsoleTextBox.Text.Length -gt 0) {
[void]$sb.Append("`r`n")
}
[void]$sb.Append($line)
}
$currentEntryCount = $script:ConsoleLogEntries.Count
if ($currentEntryCount -le $script:ConsoleLogCap) {
$current = $script:EditorConsoleTextBox.Text
if ([string]::IsNullOrEmpty($current)) {
$script:EditorConsoleTextBox.Text = $sb.ToString()
} else {
$script:EditorConsoleTextBox.Text = $current + $sb.ToString()
}
} else {
$fullSb = [System.Text.StringBuilder]::new()
$startIdx = $currentEntryCount - $script:ConsoleLogCap
for ($j = $startIdx; $j -lt $currentEntryCount; $j++) {
$e = $script:ConsoleLogEntries[$j]
if ($j -gt $startIdx) { [void]$fullSb.Append("`r`n") }
[void]$fullSb.Append("[$($e.Time)] [$($e.Level)] $($e.Message)")
}
$script:EditorConsoleTextBox.Text = $fullSb.ToString()
}
$script:ConsoleLogLastRenderedIndex = $total
if ($shouldAutoScroll) {
try {
$tLen = $script:EditorConsoleTextBox.Text.Length
$script:EditorConsoleTextBox.SelectionStart = $tLen
$script:EditorConsoleTextBox.SelectionLength = 0
} catch {}
}
}
}
function Clear-ConsoleLog {
$script:ConsoleLogEntries.Clear()
$script:ConsoleLogLastRenderedIndex = 0
if ($script:ConsoleLogUseRichTextBlock -and $null -ne $script:EditorConsoleRichTextBlock) {
try { $script:EditorConsoleRichTextBlock.Blocks.Clear() } catch {}
}
if ($null -ne $script:EditorConsoleTextBox) {
$script:EditorConsoleTextBox.Text = ""
}
Write-ConsoleLog -Message "Console cleared." -Level "INFO"
}
function Copy-ConsoleLog {
$text = ""
if ($script:ConsoleLogUseRichTextBlock -and $null -ne $script:EditorConsoleRichTextBlock) {
try {
$sel = $script:EditorConsoleRichTextBlock.SelectedText
if (-not [string]::IsNullOrWhiteSpace($sel)) { $text = $sel }
} catch {}
}
if ($null -ne $script:EditorConsoleTextBox) {
try {
$sel = $script:EditorConsoleTextBox.SelectedText
if (-not [string]::IsNullOrWhiteSpace($sel)) { $text = $sel }
} catch {}
}
if ([string]::IsNullOrWhiteSpace($text)) {
$sb = [System.Text.StringBuilder]::new()
foreach ($entry in $script:ConsoleLogEntries) {
[void]$sb.AppendLine("[$($entry.Time)] [$($entry.Level)] $($entry.Message)")
}
$text = $sb.ToString().TrimEnd()
}
if (-not [string]::IsNullOrWhiteSpace($text)) {
Set-Clipboard -Value $text
}
}
function Start-ConsoleFlushTimer {
if ($null -ne $script:ConsoleFlushTimer) { return }
$timer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$timer.Interval = New-UITimeSpan -Milliseconds 100
$timer.AddTick({
param($argumentList, $s, $e)
Process-KeyboardPolling
Process-TrayMessages
try { Update-ConsoleLogDisplay } catch {}
})
$timer.Start()
$script:ConsoleFlushTimer = $timer
}
function Stop-ConsoleFlushTimer {
if ($null -ne $script:ConsoleFlushTimer) {
try { $script:ConsoleFlushTimer.Stop() } catch {}
$script:ConsoleFlushTimer = $null
}
}
function Test-TextInputFocused {
try {
if ($null -ne $script:EditorSearchBox) {
$fs = $script:EditorSearchBox.FocusState
if ($fs -ne [WinUIShell.Microsoft.UI.Xaml.FocusState]::Unfocused) { return $true }
}
if (-not $script:ConsoleLogUseRichTextBlock -and $null -ne $script:EditorConsoleTextBox) {
$fs = $script:EditorConsoleTextBox.FocusState
if ($fs -ne [WinUIShell.Microsoft.UI.Xaml.FocusState]::Unfocused) { return $true }
}
return $false
} catch {
return $false
}
}
function Process-KeyboardPolling {
if ($script:EditorHwnd -eq [System.IntPtr]::Zero) {
$title = "$($script:AppTitle) - FFlag Editor"
$script:EditorHwnd = [Allium.KbdState]::FindWindowW([System.IntPtr]::Zero, $title)
}
if ($script:EditorHwnd -ne [System.IntPtr]::Zero) {
if ([Allium.KbdState]::GetForegroundWindow() -ne $script:EditorHwnd) { return }
}
if (-not $script:KbdEditorActive) { return }
$script:KbdFocusCheckCounter++
if ($script:KbdFocusCheckCounter -ge 5) {
$script:KbdFocusCheckCounter = 0
$script:KbdTextFocused = Test-TextInputFocused
}
if ($script:KbdTextFocused) {
if (-not (Test-TextInputFocused)) {
$script:KbdTextFocused = $false
$script:KbdFocusCheckCounter = 0
} else {
$escNow = ([Allium.KbdState]::GetAsyncKeyState(0x1B) -band 0x8000) -ne 0
if ($escNow -and -not $script:KbdLastEsc) {
Write-ConsoleLog -Message "KBD: Escape (unfocus)" -Level "INFO"
try {
if ($null -ne $script:EditorSearchBox) {
$script:EditorSearchBox.IsEnabled = $false
$script:EditorSearchBox.IsEnabled = $true
}
$script:EditorFlagListView.Focus([WinUIShell.Microsoft.UI.Xaml.FocusState]::Programmatic)
} catch {}
$script:KbdTextFocused = $false
}
$script:KbdLastEsc = $escNow
return
}
}
try {
$ctrl = ([Allium.KbdState]::GetAsyncKeyState(0x11) -band 0x8000) -ne 0
if ($ctrl) {
$script:KbdCtrlUp = 0
$czNow = ([Allium.KbdState]::GetAsyncKeyState(0x5A) -band 0x8000) -ne 0
if ($czNow -and -not $script:KbdLastCtrlZ) { Write-ConsoleLog -Message "KBD: Ctrl+Z" -Level "INFO"; if (Invoke-Undo) { Save-Flags; Editor-RefreshFlagList } }
$script:KbdLastCtrlZ = $czNow
$cyNow = ([Allium.KbdState]::GetAsyncKeyState(0x59) -band 0x8000) -ne 0
if ($cyNow -and -not $script:KbdLastCtrlY) { Write-ConsoleLog -Message "KBD: Ctrl+Y" -Level "INFO"; if (Invoke-Redo) { Save-Flags; Editor-RefreshFlagList } }
$script:KbdLastCtrlY = $cyNow
$cfNow = ([Allium.KbdState]::GetAsyncKeyState(0x46) -band 0x8000) -ne 0
if ($cfNow -and -not $script:KbdLastCtrlF) {
Write-ConsoleLog -Message "KBD: Ctrl+F" -Level "INFO"
if ($null -ne $script:EditorSearchBox) {
try { $script:EditorSearchBox.Focus([WinUIShell.Microsoft.UI.Xaml.FocusState]::Programmatic) }
catch { try { $script:EditorSearchBox.Focus() } catch {} }
}
}
$script:KbdLastCtrlF = $cfNow
$ccNow = ([Allium.KbdState]::GetAsyncKeyState(0x43) -band 0x8000) -ne 0
if ($ccNow -and -not $script:KbdLastCtrlC) {
$consoleCopied = $false
$hasSelection = $false
try { $hasSelection = $script:EditorFlagListView.SelectedRanges.Count -gt 0 } catch { $hasSelection = $script:EditorSelectedNames.Count -gt 0 }
if (-not $hasSelection) {
if ($script:ConsoleLogUseRichTextBlock -and $null -ne $script:EditorConsoleRichTextBlock) {
try {
$sel = $script:EditorConsoleRichTextBlock.SelectedText
if (-not [string]::IsNullOrWhiteSpace($sel)) {
Set-Clipboard -Value $sel
Write-ConsoleLog -Message "KBD: Ctrl+C (console text)" -Level "INFO"
$consoleCopied = $true
}
} catch {}
}
}
if (-not $consoleCopied) {
Write-ConsoleLog -Message "KBD: Ctrl+C" -Level "INFO"
Editor-CopySelectedAsJson
}
}
$script:KbdLastCtrlC = $ccNow
$cvNow = ([Allium.KbdState]::GetAsyncKeyState(0x56) -band 0x8000) -ne 0
if ($cvNow -and -not $script:KbdLastCtrlV) { Write-ConsoleLog -Message "KBD: Ctrl+V" -Level "INFO"; Editor-PasteJson }
$script:KbdLastCtrlV = $cvNow
$ceNow = ([Allium.KbdState]::GetAsyncKeyState(0x45) -band 0x8000) -ne 0
if ($ceNow -and -not $script:KbdLastCtrlE) { Write-ConsoleLog -Message "KBD: Ctrl+E" -Level "INFO"; Editor-BatchEditSelected }
$script:KbdLastCtrlE = $ceNow
} else {
$script:KbdCtrlUp++
if (([Allium.KbdState]::GetAsyncKeyState(0x5A) -band 0x8000) -eq 0) { $script:KbdLastCtrlZ = $false }
if (([Allium.KbdState]::GetAsyncKeyState(0x59) -band 0x8000) -eq 0) { $script:KbdLastCtrlY = $false }
if (([Allium.KbdState]::GetAsyncKeyState(0x46) -band 0x8000) -eq 0) { $script:KbdLastCtrlF = $false }
if (([Allium.KbdState]::GetAsyncKeyState(0x43) -band 0x8000) -eq 0) { $script:KbdLastCtrlC = $false }
if (([Allium.KbdState]::GetAsyncKeyState(0x56) -band 0x8000) -eq 0) { $script:KbdLastCtrlV = $false }
if (([Allium.KbdState]::GetAsyncKeyState(0x45) -band 0x8000) -eq 0) { $script:KbdLastCtrlE = $false }
$delNow = ([Allium.KbdState]::GetAsyncKeyState(0x2E) -band 0x8000) -ne 0
if ($delNow -and -not $script:KbdLastDel) { Write-ConsoleLog -Message "KBD: Delete" -Level "INFO"; Editor-DeleteSelected }
$script:KbdLastDel = $delNow
$escNow = ([Allium.KbdState]::GetAsyncKeyState(0x1B) -band 0x8000) -ne 0
if ($escNow -and -not $script:KbdLastEsc) { Write-ConsoleLog -Message "KBD: Escape" -Level "INFO"; Editor-DeselectAll }
$script:KbdLastEsc = $escNow
$enterNow = ([Allium.KbdState]::GetAsyncKeyState(0x0D) -band 0x8000) -ne 0
if ($enterNow -and -not $script:KbdLastEnter) { Write-ConsoleLog -Message "KBD: Enter" -Level "INFO"; Editor-EditSelected }
$script:KbdLastEnter = $enterNow
}
} catch {}
}
$script:WatchdogRunning = $false
$script:WatchdogRunspace = $null
$script:WatchdogPowerShell = $null
$script:WatchdogAsyncResult = $null
$script:WatchdogProcessTimer = $null
$script:WatchdogProcessEventJob = $null
$script:WatchdogFileWatcher = $null
$script:WatchdogVersionTimer = $null
$script:WatchdogVersionEventJob = $null
$script:WatchdogLastVersionFolders = @()
$script:WatchdogRobloxWasRunning = $false
function Set-RobloxMultiInstance {
param([bool] $Enabled)
try {
if ($Enabled) {
if ($null -ne $script:RobloxMultiInstanceMutexes -and $script:RobloxMultiInstanceMutexes.Count -gt 0) {
return
}
$held = New-Object System.Collections.Generic.List[object]
foreach ($mutexName in @('ROBLOX_singletonMutex', 'ROBLOX_singletonEvent')) {
try {
$m = New-Object System.Threading.Mutex($true, $mutexName)
$held.Add($m)
} catch {
Write-ConsoleLog -Message ('[multi-instance] Could not claim ' + $mutexName + ': ' + $_.Exception.Message) -Level 'WARN'
}
}
$script:RobloxMultiInstanceMutexes = $held
Write-ConsoleLog -Message '[multi-instance] Enabled: singleton lock held; multiple Roblox clients can launch.' -Level 'INFO'
} else {
if ($null -ne $script:RobloxMultiInstanceMutexes) {
foreach ($m in $script:RobloxMultiInstanceMutexes) {
try { $m.Dispose() } catch { }
}
}
$script:RobloxMultiInstanceMutexes = $null
Write-ConsoleLog -Message '[multi-instance] Disabled: singleton lock released.' -Level 'INFO'
}
} catch {
Write-ConsoleLog -Message ('[multi-instance] Set-RobloxMultiInstance failed: ' + $_.Exception.Message) -Level 'ERROR'
}
}
function Start-Watchdog {
if ($script:WatchdogRunning) { return }
if (-not $script:Settings.watchdogEnabled) { return }
$script:WatchdogRunning = $true
Write-ConsoleLog -Message "Watchdog starting..." -Level "WATCHDOG"
if ($script:Settings.watchdogMonitorFile) {
Watchdog-StartFileMonitor
}
Watchdog-StartProcessMonitor
if ($script:Settings.watchdogMonitorVersion) {
Watchdog-StartVersionMonitor
}
Write-ConsoleLog -Message "Watchdog active." -Level "WATCHDOG"
}
function Stop-Watchdog {
if (-not $script:WatchdogRunning) { return }
Watchdog-StopProcessMonitor
Watchdog-StopFileMonitor
Watchdog-StopVersionMonitor
$script:WatchdogRunning = $false
Write-ConsoleLog -Message "Watchdog stopped." -Level "WATCHDOG"
}
function Watchdog-StartProcessMonitor {
if ($null -ne $script:WatchdogProcessTimer) { return }
$script:WatchdogRobloxWasRunning = $null -ne (Get-Process -Name "RobloxPlayerBeta" -ErrorAction SilentlyContinue)
$timer = [System.Timers.Timer]::new(2000)
$timer.AutoReset = $true
$script:WatchdogProcessEventJob = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
$currentlyRunning = $null -ne (Get-Process -Name "RobloxPlayerBeta" -ErrorAction SilentlyContinue)
$wasRunning = $Event.MessageData.WasRunning
if ($currentlyRunning -and -not $wasRunning) {
Write-ConsoleLog -Message "Roblox process detected (started)." -Level "WATCHDOG"
if ($Event.MessageData.AutoReapplyOnRestart) {
$result = Write-ClientAppSettings
if ($result) {
Write-ConsoleLog -Message "Auto-reapplied FFlags on Roblox start (JSON)." -Level "WATCHDOG"
}
Start-Sleep -Milliseconds 1500
try {
$memStats = Invoke-WatchdogAutoApplyMemory
if ($null -ne $memStats) {
Write-ConsoleLog -Message ('Auto-reapplied FFlags on Roblox start (memory): applied=' + $memStats.Applied + ' missing=' + $memStats.Missing + ' failed=' + $memStats.Failed) -Level "WATCHDOG"
}
} catch {
Write-ConsoleLog -Message ('Memory auto-reapply failed: ' + $_.Exception.Message) -Level "WATCHDOG"
}
Update-InterceptorOverrides
}
$Event.MessageData.WasRunning = $true
}
elseif (-not $currentlyRunning -and $wasRunning) {
Write-ConsoleLog -Message "Roblox process ended (closed/crashed)." -Level "WATCHDOG"
$Event.MessageData.WasRunning = $false
}
} -MessageData @{
WasRunning = $script:WatchdogRobloxWasRunning
AutoReapplyOnRestart = $script:Settings.watchdogAutoReapplyOnRestart
}
$timer.Start()
$script:WatchdogProcessTimer = $timer
Write-ConsoleLog -Message "Process monitor active (2s poll)." -Level "WATCHDOG"
}
function Watchdog-StopProcessMonitor {
if ($null -ne $script:WatchdogProcessTimer) {
try {
$script:WatchdogProcessTimer.Stop()
$script:WatchdogProcessTimer.Dispose()
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:WatchdogProcessTimer = $null
}
if ($null -ne $script:WatchdogProcessEventJob) {
try {
$script:WatchdogProcessEventJob | Stop-Job -PassThru | Remove-Job -Force
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:WatchdogProcessEventJob = $null
}
}
function Watchdog-StartFileMonitor {
if ($null -ne $script:WatchdogFileWatcher) { return }
$settingsPath = Get-RobloxClientSettingsPath
if (-not $settingsPath) {
Write-ConsoleLog -Message "Cannot start file monitor: Roblox ClientSettings path not found." -Level "WATCHDOG"
return
}
$settingsDir = Split-Path $settingsPath -Parent
if (-not (Test-Path $settingsDir)) {
try {
New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
} catch {
Write-ConsoleLog -Message "Cannot create ClientSettings dir for file monitor: $_" -Level "ERROR"
return
}
}
try {
$watcher = [System.IO.FileSystemWatcher]::new($settingsDir, "ClientAppSettings.json")
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::Size -bor [System.IO.NotifyFilters]::FileName
$watcher.EnableRaisingEvents = $true
$action = {
$changeType = $Event.SourceEventArgs.ChangeType
$fileName = $Event.SourceEventArgs.Name
Write-ConsoleLog -Message "ClientAppSettings.json ${changeType} detected (external modification)." -Level "WATCHDOG"
Start-Sleep -Milliseconds 500
$result = Write-ClientAppSettings
if ($result) {
Write-ConsoleLog -Message "FFlags rewritten after external file change." -Level "WATCHDOG"
} else {
Write-ConsoleLog -Message "Failed to rewrite FFlags after external file change." -Level "ERROR"
}
}
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action -SourceIdentifier "WatchdogFileChanged" | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action -SourceIdentifier "WatchdogFileDeleted" | Out-Null
$script:WatchdogFileWatcher = $watcher
Write-ConsoleLog -Message "File monitor active on $settingsDir." -Level "WATCHDOG"
} catch {
Write-ConsoleLog -Message "Failed to start file monitor: $_" -Level "ERROR"
}
}
function Watchdog-StopFileMonitor {
if ($null -ne $script:WatchdogFileWatcher) {
try {
$script:WatchdogFileWatcher.EnableRaisingEvents = $false
$script:WatchdogFileWatcher.Dispose()
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:WatchdogFileWatcher = $null
}
try {
Get-EventSubscriber -SourceIdentifier "WatchdogFileChanged" -ErrorAction SilentlyContinue | Unregister-Event
Get-EventSubscriber -SourceIdentifier "WatchdogFileDeleted" -ErrorAction SilentlyContinue | Unregister-Event
Get-Job -Name "WatchdogFileChanged" -ErrorAction SilentlyContinue | Remove-Job -Force
Get-Job -Name "WatchdogFileDeleted" -ErrorAction SilentlyContinue | Remove-Job -Force
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}
function Watchdog-StartVersionMonitor {
if ($null -ne $script:WatchdogVersionTimer) { return }
try {
$versionsDir = Join-Path $env:LOCALAPPDATA "Roblox\Versions"
if (Test-Path $versionsDir) {
$script:WatchdogLastVersionFolders = @(Get-ChildItem $versionsDir -Directory -Filter "version-*" | ForEach-Object { $_.Name })
} else {
$script:WatchdogLastVersionFolders = @()
}
} catch {
$script:WatchdogLastVersionFolders = @()
}
$timer = [System.Timers.Timer]::new(5000)
$timer.AutoReset = $true
$script:WatchdogVersionEventJob = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
try {
$versionsDir = Join-Path $env:LOCALAPPDATA "Roblox\Versions"
if (-not (Test-Path $versionsDir)) { return }
$currentFolders = @(Get-ChildItem $versionsDir -Directory -Filter "version-*" | ForEach-Object { $_.Name })
$previousFolders = $Event.MessageData.PreviousFolders
foreach ($folder in $currentFolders) {
if ($folder -notin $previousFolders) {
Write-ConsoleLog -Message "New Roblox version detected: $folder." -Level "WATCHDOG"
$newDir = Join-Path $versionsDir $folder
$clientSettingsDir = Join-Path $newDir "ClientSettings"
if (-not (Test-Path $clientSettingsDir)) {
New-Item -Path $clientSettingsDir -ItemType Directory -Force | Out-Null
}
$clientAppSettings = Join-Path $clientSettingsDir "ClientAppSettings.json"
$output = @{}
foreach ($key in $script:Flags.Keys) {
$output[$key] = $script:Flags[$key]
}
$json = $output | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($clientAppSettings, $json)
Write-ConsoleLog -Message "FFlags preloaded to new version folder." -Level "WATCHDOG"
}
}
$Event.MessageData.PreviousFolders = $currentFolders
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
} -MessageData @{
PreviousFolders = $script:WatchdogLastVersionFolders
}
$timer.Start()
$script:WatchdogVersionTimer = $timer
Write-ConsoleLog -Message "Version monitor active (5s poll)." -Level "WATCHDOG"
}
function Watchdog-StopVersionMonitor {
if ($null -ne $script:WatchdogVersionTimer) {
try {
$script:WatchdogVersionTimer.Stop()
$script:WatchdogVersionTimer.Dispose()
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:WatchdogVersionTimer = $null
}
if ($null -ne $script:WatchdogVersionEventJob) {
try {
$script:WatchdogVersionEventJob | Stop-Job -PassThru | Remove-Job -Force
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:WatchdogVersionEventJob = $null
}
}
function Show-EditorNotification {
param([string]$Title, [string]$Message)
if ($null -eq $script:EditorWindow -or $null -eq $script:EditorWindow.Content) { return }
$root = $script:EditorWindow.Content
if ($null -ne $script:EditorNotificationBar) {
try { $root.Children.Remove($script:EditorNotificationBar) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:EditorNotificationBar = $null
}
$bar = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$bar.Background = New-AccentBrush
$bar.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$bar.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 8, 12, 8)
$bar.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 64)
$bar.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$bar.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Bottom
$bar.MaxWidth = 600
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($bar, 5)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRowSpan($bar, 3)
$inner = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colC = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colC.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$colX = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colX.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(0, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$inner.ColumnDefinitions.Add($colC) | Out-Null
$inner.ColumnDefinitions.Add($colX) | Out-Null
$cs = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$cs.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$cs.Spacing = 8
$ci = New-FontIcon -Glyph ([char]0xE73E) -Size 16
$ci.Foreground = New-SolidBrush -Hex "#FFFFFF"
$ci.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$cs.Children.Add($ci) | Out-Null
$tb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$tb.Text = $Title; Set-SafeFontFamily -Target $tb -Family $script:AppFontFamily; $tb.FontSize = 13
$tb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$tb.Foreground = New-SolidBrush -Hex "#FFFFFF"
$tb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$cs.Children.Add($tb) | Out-Null
$mb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$mb.Text = $Message; Set-SafeFontFamily -Target $mb -Family $script:AppFontFamily; $mb.FontSize = 13
$mb.Foreground = New-SolidBrush -Hex "#FFFFFF"; $mb.Opacity = 0.9
$mb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$cs.Children.Add($mb) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($cs, 0)
$inner.Children.Add($cs) | Out-Null
$xb = [WinUIShell.Microsoft.UI.Xaml.Controls.Button]::new()
$xi = New-FontIcon -Glyph ([char]0xE711) -Size 12
$xi.Foreground = New-SolidBrush -Hex "#FFFFFF"
$xb.Content = $xi
$xb.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new([WinUIShell.Windows.UI.Color]::FromArgb(0,0,0,0))
$xb.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4)
$xb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$barRef = $bar; $rootRef = $root
$xb.AddClick({ param($argumentList, $s, $e)
try { $rootRef.Children.Remove($barRef) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:EditorNotificationBar = $null
}.GetNewClosure())
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($xb, 1)
$inner.Children.Add($xb) | Out-Null
$bar.Child = $inner
$root.Children.Add($bar) | Out-Null
$script:EditorNotificationBar = $bar
$dt = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$dt.Interval = New-UITimeSpan -Milliseconds 3000
$lb = $bar; $lr = $root
$dt.AddTick({ param($argumentList, $s, $e)
$s.Stop(); try { $lr.Children.Remove($lb) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }; $script:EditorNotificationBar = $null
}.GetNewClosure())
$dt.Start()
}
function Show-LaunchStatusPopup {
param([string]$Message)
$win = [WinUIShell.Microsoft.UI.Xaml.Window]::new()
$win.Title = "Allium - Launching"
$win.ExtendsContentIntoTitleBar = $true
try {
$win.AppWindow.Resize(320, 180)
Center-Window -AppWindow $win.AppWindow -Width 320 -Height 180
$iconFile = (Resolve-Path $script:IconPath).Path
$win.AppWindow.SetIcon($iconFile)
$win.AppWindow.TitleBar.PreferredTheme = [WinUIShell.Microsoft.UI.Windowing.TitleBarTheme]::Dark
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$root = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$root.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$root.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(210, 0x1c, 0x08, 0x08)
)
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$panel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$panel.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 20, 0, 0)
$panel.Spacing = 16
$txt = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$txt.Text = $Message
Set-SafeFontFamily -Target $txt -Family $script:AppFontFamily
$txt.FontSize = 14
$txt.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$txt.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$pb = New-ThemedProgressBar -Indeterminate
$pb.Width = 200
$panel.Children.Add($txt) | Out-Null
$panel.Children.Add($pb) | Out-Null
$root.Children.Add($panel) | Out-Null
$win.Content = $root
$win.Activate()
return @{ Window = $win; TextBlock = $txt; Panel = $panel }
}
function Invoke-LaunchRoblox {
$script:LaunchCancelled = $false
$popup = Show-LaunchStatusPopup -Message "Preparing FFlags..."
$script:LaunchCancelled = $false
$popupWin = $popup.Window
$popupTxt = $popup.TextBlock
$popupPanel = $popup.Panel
$cancelBtn = New-ThemedButton -Content "Cancel" -ToolbarStyle
$cancelBtn.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$cancelBtn.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 8, 0, 0)
$cancelBtn.AddClick({
param($argumentList, $s, $e)
$script:LaunchCancelled = $true
try { $popupWin.Close() } catch { }
}.GetNewClosure())
try { $popupPanel.Children.Add($cancelBtn) | Out-Null } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
Write-ConsoleLog -Message "Calling Invoke-LaunchRoblox" -Level "INFO"
Save-Flags
$success = Write-ClientAppSettings
if (-not $success) { Write-ConsoleLog -Message "Failed to write ClientAppSettings.json before launch." -Level "ERROR" }
if ($script:LaunchCancelled) { try { $popupWin.Close() } catch {}; return }
try { $popupTxt.Text = "Detecting Roblox..." } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$launchPath = Get-RobloxPlayerPath
$selected = Get-SelectedBootstrapper
$launchName = if ($null -ne $selected -and $selected.Found) { "Roblox ($($selected.Name))" } else { "Roblox" }
if ($null -eq $launchPath) {
try { $popupWin.Close() } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
Write-ConsoleLog -Message "No bootstrapper or Roblox installation found." -Level "ERROR"
if ($null -ne $script:EditorWindow) {
$null = Show-CustomDialog -XamlRoot $script:EditorWindow.Content.XamlRoot -Title "Launch Error" -Content "Roblox not found. Install Roblox or a bootstrapper first." -CloseButtonText "OK"
}
return
}
if ($script:LaunchCancelled) { try { $popupWin.Close() } catch {}; return }
try { $popupTxt.Text = "Launching $launchName..." } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
try {
Start-Process $launchPath -ErrorAction Stop
Write-ConsoleLog -Message "Launched $launchName." -Level "INFO"
} catch {
try { $popupWin.Close() } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
Write-ConsoleLog -Message "Failed to launch: $_" -Level "ERROR"
return
}
if ($script:LaunchCancelled) { try { $popupWin.Close() } catch {}; return }
try { $popupTxt.Text = "Waiting for Roblox..." } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:LaunchPollCount = 0
$maxPolls = 60
$pollTimer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$pollTimer.Interval = New-UITimeSpan -Milliseconds 500
$pollTimer.AddTick({
param($argumentList, $s, $e)
try {
$script:LaunchPollCount++
if ($script:LaunchCancelled) {
$s.Stop()
try { $popupWin.Close() } catch {}
return
}
$running = $null -ne (Get-Process -Name "RobloxPlayerBeta" -ErrorAction SilentlyContinue)
if ($running) {
$s.Stop()
Write-ConsoleLog -Message "Roblox process detected." -Level "INFO"
if ($script:Settings.watchdogEnabled) { Start-Watchdog }
try { $popupWin.Close() } catch {}
} elseif ($script:LaunchPollCount -ge $maxPolls) {
$s.Stop()
Write-ConsoleLog -Message "Timed out waiting for Roblox process." -Level "WARN"
try { $popupWin.Close() } catch {}
}
} catch {
$s.Stop()
}
}.GetNewClosure())
$pollTimer.Start()
}
$script:BrowserWindow = $null
$script:FlagBrowserCache = @{}
$script:BrowserListView = $null
$script:BrowserSearchBox = $null
$script:BrowserCurrentSearch = ""
$script:BrowserSelectedItems = @()
$script:BrowserProgressBar = $null
$script:BrowserStatusText = $null
$script:BrowserSearchDebounceTimer = $null
$script:BrowserMonoFont = $null
$script:BrowserTableBorder = $null
$script:BrowserDisplayOrder = $null
$script:BrowserSelectedNames = [System.Collections.Generic.List[string]]::new()
$script:BrowserSelectionDirty = $false
$script:BrowserLoadingOverlay = $null
$script:BrowserTypeFilter = "All"
$script:BrowserRawNameMap = @{}
$script:BrowserSortColumn = "Name"
$script:BrowserSortDirection = "Ascending"
$script:BrowserThName = $null
$script:BrowserThDefault = $null
$script:DragPayload = $null
function Browser-InstallDragSource {
if ($null -eq $script:BrowserListView) {
Write-ConsoleLog -Message "Browser-InstallDragSource: ListView not yet created." -Level "WARN"
return
}
try {
$script:BrowserListView.CanDragItems = $true
$script:BrowserListView.AddDragItemsStarting({
param($argumentList, $s, $e)
try {
$names = @()
try { Browser-ResolveSelection } catch {
try { Write-ConsoleLog -Message "Drag: Browser-ResolveSelection failed: $_" -Level "WARN" } catch {}
}
if ($null -ne $script:BrowserSelectedNames -and $script:BrowserSelectedNames.Count -gt 0) {
$names = @($script:BrowserSelectedNames)
}
if ($names.Count -eq 0) {
$e.Cancel = $true
return
}
try {
$jsonNames = $names | ConvertTo-Json -Compress
$e.Data.Properties["AlliumFFlagNames"] = $jsonNames
} catch {
try { Write-ConsoleLog -Message "Drag Properties write failed (will use carrier): $_" -Level "WARN" } catch {}
}
try { $e.Data.SetText(($names -join ", ")) } catch {}
$script:DragPayload = @{
Source = "Browser"
Names = $names
Timestamp = (Get-Date)
}
try { Write-ConsoleLog -Message "Drag started: $($names.Count) FFlag(s)" -Level "INFO" } catch {}
} catch {
try { Write-ConsoleLog -Message "Browser DragItemsStarting error: $_" -Level "ERROR" } catch {}
}
})
Write-ConsoleLog -Message "Browser drag source installed." -Level "INFO"
} catch {
Write-ConsoleLog -Message "Browser-InstallDragSource failed: $_" -Level "WARN"
}
}
function Editor-ToggleBrowser {
try {
if ($null -ne $script:BrowserWindow) {
try { $script:BrowserWindow.Activate() } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
return
}
$win = New-FlagBrowserWindow
$script:BrowserWindow = $win
$win.Activate()
try { Browser-InstallKeyboardShortcuts -Window $win } catch { Write-ConsoleLog -Message "Browser keyboard shortcuts failed: $_" -Level "WARN" }
if ($script:FlagBrowserCache.Count -gt 0) {
Browser-RefreshList
} else {
Browser-StartFetch
}
} catch { Write-ConsoleLog -Message "Browser failed: $_" -Level "ERROR" }
}
function New-FlagBrowserWindow {
$window = [WinUIShell.Microsoft.UI.Xaml.Window]::new()
$window.Title = "$($script:AppTitle) - FFlag Browser"
$window.ExtendsContentIntoTitleBar = $true
try {
$window.AppWindow.Resize(900, 600)
Center-Window -AppWindow $window.AppWindow -Width 900 -Height 600
$iconFile = (Resolve-Path $script:IconPath).Path
$window.AppWindow.SetIcon($iconFile)
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
try {
$presenter = $window.AppWindow.Presenter
$presenter.PreferredMinimumWidth = 600
$presenter.PreferredMinimumHeight = 450
} catch {
Write-ConsoleLog -Message "OverlappedPresenter min size not available: $_" -Level "WARN"
}
$titleRegion = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$titleRegion.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 12, 0, 10)
$titleRegion.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0)
)
$titleStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$titleStack.Spacing = 2
$titleText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$titleText.Text = "FFlag Browser"
Set-SafeFontFamily -Target $titleText -Family $script:AppFontFamily
$titleText.FontSize = 20
$titleText.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$titleText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$subtitleText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$subtitleText.Text = "Browse all known Roblox FFlags"
Set-SafeFontFamily -Target $subtitleText -Family $script:AppFontFamily
$subtitleText.FontSize = 13
$subtitleText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$titleStack.Children.Add($titleText) | Out-Null
$titleStack.Children.Add($subtitleText) | Out-Null
$titleRegion.Children.Add($titleStack) | Out-Null
$window.SetTitleBar($titleRegion)
$root = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$root.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$root.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(210, 0x1c, 0x08, 0x08)
)
$root.RowSpacing = 0
$rowTitleBar = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowTitleBar.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowSpacer = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowSpacer.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(8, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Pixel)
$rowToolbar = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowToolbar.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowSearch = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowSearch.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowTable = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowTable.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$rowBottom = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowBottom.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$root.RowDefinitions.Add($rowTitleBar) | Out-Null
$root.RowDefinitions.Add($rowSpacer) | Out-Null
$root.RowDefinitions.Add($rowToolbar) | Out-Null
$root.RowDefinitions.Add($rowSearch) | Out-Null
$rowHeader = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowHeader.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$root.RowDefinitions.Add($rowHeader) | Out-Null
$root.RowDefinitions.Add($rowTable) | Out-Null
$root.RowDefinitions.Add($rowBottom) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($titleRegion, 0)
$root.Children.Add($titleRegion) | Out-Null
$toolbar = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$toolbar.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$toolbar.Spacing = 4
$toolbar.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 4)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($toolbar, 2)
$btnRefresh = New-ThemedButton -Content "Refresh" -Glyph ([char]0xE72C) -ToolbarStyle
$btnRefresh.AddClick({ try { Browser-StartFetch } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" } })
$toolbar.Children.Add($btnRefresh) | Out-Null
$typeFilter = [WinUIShell.Microsoft.UI.Xaml.Controls.ComboBox]::new()
Set-SafeFontFamily -Target $typeFilter -Family $script:AppFontFamily
$typeFilter.FontSize = 12
$typeFilter.MinWidth = 130
$typeFilter.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$typeFilter.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4, 0, 0, 0)
foreach ($ft in @("All Types", "Bool", "Int", "String", "Log", "Unknown")) {
$typeFilter.Items.Add($ft) | Out-Null
}
$typeFilter.SelectedIndex = 0
Set-ThemedComboBoxResources -Control $typeFilter
$typeFilter.AddSelectionChanged({
param($argumentList, $s, $e)
try {
$sel = $s.SelectedItem
if ($null -ne $sel) {
$script:BrowserTypeFilter = if ($sel -eq "All Types") { "All" } else { $sel.ToString().ToLower() }
} else {
$script:BrowserTypeFilter = "All"
}
Browser-RefreshList
} catch { Write-ConsoleLog -Message "Type filter error: $_" -Level "ERROR" }
})
$toolbar.Children.Add($typeFilter) | Out-Null
$statusText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
Set-SafeFontFamily -Target $statusText -Family $script:AppFontFamily
$statusText.FontSize = 12
$statusText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$statusText.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$statusText.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 0, 0)
$statusText.Text = if ($script:FlagBrowserCache.Count -gt 0) {
"Cached: $($script:FlagBrowserCache.Count) FFlags"
} else {
"No cache - click Refresh"
}
$script:BrowserStatusText = $statusText
$toolbar.Children.Add($statusText) | Out-Null
$root.Children.Add($toolbar) | Out-Null
$searchPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$searchPanel.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 4, 12, 4)
$searchPanel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($searchPanel, 3)
$searchBox = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBox]::new()
$searchBox.PlaceholderText = "Search FFlags..."
Set-SafeFontFamily -Target $searchBox -Family $script:AppFontFamily
$searchBox.FontSize = 13
$searchBox.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$searchBox.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$searchBox.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(32, 6, 6, 6)
Set-ThemedTextBoxResources -Control $searchBox
$script:BrowserSearchBox = $searchBox
$searchBox.AddTextChanged({
param($argumentList, $s, $e)
$script:BrowserCurrentSearch = $s.Text
Browser-ResetSearchDebounce
})
$searchContainer = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$searchIcon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$searchIcon.Glyph = [char]0xE721
Set-SafeFontFamily -Target $searchIcon -Family $script:IconFontFamily
$searchIcon.FontSize = 14
$searchIcon.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$searchIcon.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$searchIcon.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$searchIcon.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(10, 0, 0, 0)
$searchIcon.IsHitTestVisible = $false
$searchContainer.Children.Add($searchBox) | Out-Null
$searchContainer.Children.Add($searchIcon) | Out-Null
$searchPanel.Children.Add($searchContainer) | Out-Null
$root.Children.Add($searchPanel) | Out-Null
$browserHeaderBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$browserHeaderBorder.Background = New-SolidBrush -Hex $script:ThemeColors.TableHeader
$browserHeaderBorder.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 0)
$browserHeaderBorder.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4, 6, 4, 6)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($browserHeaderBorder, 4)
$browserHeaderGrid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$bhColName = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$bhColName.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(675, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Pixel)
$bhColDefault = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$bhColDefault.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$browserHeaderGrid.ColumnDefinitions.Add($bhColName) | Out-Null
$browserHeaderGrid.ColumnDefinitions.Add($bhColDefault) | Out-Null
$bhName = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$bhName.Text = if ($script:BrowserSortColumn -eq "Name") { $bArr = if ($script:BrowserSortDirection -eq "Ascending") { "▲" } else { "▼" }; "Name $bArr" } else { "Name" }
Set-SafeFontFamily -Target $bhName -Family $script:AppFontFamily
$bhName.FontSize = 13
$bhName.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$bhName.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$bhName.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 0, 0, 0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($bhName, 0)
$browserHeaderGrid.Children.Add($bhName) | Out-Null
$script:BrowserThName = $bhName
$bhDefault = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$bhDefault.Text = if ($script:BrowserSortColumn -eq "Default") { $bArr = if ($script:BrowserSortDirection -eq "Ascending") { "▲" } else { "▼" }; "Default Value $bArr" } else { "Default Value" }
Set-SafeFontFamily -Target $bhDefault -Family $script:AppFontFamily
$bhDefault.FontSize = 13
$bhDefault.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$bhDefault.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$bhDefault.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$bhDefault.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 0, 0, 0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($bhDefault, 1)
$browserHeaderGrid.Children.Add($bhDefault) | Out-Null
$script:BrowserThDefault = $bhDefault
try {
$bhName.AddTapped({
param($argumentList, $s, $e)
try {
if ($script:BrowserSortColumn -eq "Name") {
$script:BrowserSortDirection = if ($script:BrowserSortDirection -eq "Ascending") { "Descending" } else { "Ascending" }
} else {
$script:BrowserSortColumn = "Name"
$script:BrowserSortDirection = "Ascending"
}
$arrow = if ($script:BrowserSortDirection -eq "Ascending") { "▲" } else { "▼" }
$script:BrowserThName.Text = "Name $arrow"
$script:BrowserThDefault.Text = "Default Value"
Browser-RefreshList
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$bhDefault.AddTapped({
param($argumentList, $s, $e)
try {
if ($script:BrowserSortColumn -eq "Default") {
$script:BrowserSortDirection = if ($script:BrowserSortDirection -eq "Ascending") { "Descending" } else { "Ascending" }
} else {
$script:BrowserSortColumn = "Default"
$script:BrowserSortDirection = "Ascending"
}
$arrow = if ($script:BrowserSortDirection -eq "Ascending") { "▲" } else { "▼" }
$script:BrowserThDefault.Text = "Default Value $arrow"
$script:BrowserThName.Text = "Name"
Browser-RefreshList
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
} catch { Write-ConsoleLog -Message "Browser header tap handlers failed: $_" -Level "WARN" }
$browserHeaderBorder.Child = $browserHeaderGrid
$root.Children.Add($browserHeaderBorder) | Out-Null
$progressBar = New-ThemedProgressBar -Indeterminate
Set-ControlVisible -Control $progressBar -IsVisible $false
$progressBar.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 0)
$progressBar.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Top
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($progressBar, 5)
$script:BrowserProgressBar = $progressBar
$root.Children.Add($progressBar) | Out-Null
$loadingOverlay = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$loadingOverlay.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new([WinUIShell.Windows.UI.Color]::FromArgb(200, 0x1c, 0x08, 0x08))
$loadingOverlay.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$loadingOverlay.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Stretch
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($loadingOverlay, 5)
$loadingStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$loadingStack.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$loadingStack.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$loadingStack.Spacing = 12
$loadingRing = [WinUIShell.Microsoft.UI.Xaml.Controls.ProgressRing]::new()
$loadingRing.IsActive = $true
$loadingRing.Width = 40
$loadingRing.Height = 40
$loadingRing.Foreground = New-AccentBrush
$loadingStack.Children.Add($loadingRing) | Out-Null
$loadingText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$loadingText.Text = "Loading FFlags..."
Set-SafeFontFamily -Target $loadingText -Family $script:AppFontFamily
$loadingText.FontSize = 13
$loadingText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$loadingText.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$loadingStack.Children.Add($loadingText) | Out-Null
$loadingOverlay.Children.Add($loadingStack) | Out-Null
Set-ControlVisible -Control $loadingOverlay -IsVisible $false
try { [WinUIShell.Microsoft.UI.Xaml.Controls.Canvas]::SetZIndex($loadingOverlay, 10) } catch { Write-ConsoleLog -Message "ZIndex not available: $_" -Level "WARN" }
$root.Children.Add($loadingOverlay) | Out-Null
$script:BrowserLoadingOverlay = $loadingOverlay
$tableBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$tableBorder.BorderBrush = New-SolidBrush -Hex $script:ThemeColors.Dividers
$tableBorder.BorderThickness = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 1, 0, 0)
$tableBorder.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($tableBorder, 5)
$browserListView = New-ThemedListView -FontSize 13
$browserListView.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$browserListView.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Stretch
$browserListView.SelectionMode = [WinUIShell.Microsoft.UI.Xaml.Controls.ListViewSelectionMode]::Extended
$script:BrowserListView = $browserListView
$browserListView.AddSelectionChanged({
param($argumentList, $s, $e)
$script:BrowserSelectionDirty = $true
})
try {
$browserListView.ContextFlyout = New-BrowserContextMenu
} catch {
$browserCm = New-BrowserContextMenu
$browserListView.AddRightTapped({
param($argumentList, $s, $e)
try { $browserCm.ShowAt($s) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
}
try {
$browserListView.ItemContainerTransitions = [WinUIShell.Microsoft.UI.Xaml.Media.Animation.TransitionCollection]::new()
$browserListView.Transitions = [WinUIShell.Microsoft.UI.Xaml.Media.Animation.TransitionCollection]::new()
} catch { Write-ConsoleLog -Message "Could not clear item/entrance transitions: $_" -Level "WARN" }
$tableBorder.Child = $browserListView
$script:BrowserTableBorder = $tableBorder
$root.Children.Add($tableBorder) | Out-Null
$bottomBar = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$bottomBar.BorderBrush = New-SolidBrush -Hex $script:ThemeColors.Dividers
$bottomBar.BorderThickness = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 1, 0, 0)
$bottomBar.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 8, 12, 8)
$bottomBar.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($bottomBar, 6)
$bottomPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$bottomPanel.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$bottomPanel.Spacing = 8
$bottomPanel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$btnAddSelected = New-ThemedButton -Content "Add Selected to Editor" -AccentStyle -FontSize 14
$btnAddSelected.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$btnAddSelected.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnAddSelected.AddClick({
try { Browser-AddSelectedToEditor } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$bottomPanel.Children.Add($btnAddSelected) | Out-Null
$btnCloseBrowser = New-ThemedButton -Content "Close" -FontSize 14
$btnCloseBrowser.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$btnCloseBrowser.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$btnCloseBrowser.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$btnCloseBrowser.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnCloseBrowser.AddClick({
try { $script:BrowserWindow.Close() } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$bottomPanel.Children.Add($btnCloseBrowser) | Out-Null
$bottomBar.Child = $bottomPanel
$root.Children.Add($bottomBar) | Out-Null
$window.Content = $root
Set-WindowTheme -Window $window
try {
$window.AppWindow.TitleBar.PreferredTheme = [WinUIShell.Microsoft.UI.Windowing.TitleBarTheme]::Dark
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$window.AddClosed({
if ($null -ne $script:BrowserSearchDebounceTimer) {
$script:BrowserSearchDebounceTimer.Stop()
$script:BrowserSearchDebounceTimer = $null
}
$script:BrowserWindow = $null
$script:BrowserThName = $null
$script:BrowserThDefault = $null
$script:BrowserListView = $null
$script:BrowserSearchBox = $null
$script:BrowserProgressBar = $null
$script:BrowserStatusText = $null
$script:BrowserSelectedItems = @()
$script:BrowserTableBorder = $null
$script:BrowserDisplayOrder = $null
$script:BrowserSelectedNames = [System.Collections.Generic.List[string]]::new()
$script:BrowserSelectionDirty = $false
$script:BrowserLoadingOverlay = $null
$script:BrowserRawNameMap = @{}
$script:BrowserCurrentSearch = ""
})
Browser-InstallDragSource
return $window
}
function New-BrowserContextMenu {
$flyout = [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyout]::new()
$addItem = New-MenuFlyoutItem -Text "Add to Editor" -Glyph ([char]0xE710) -OnClick {
Browser-AddSelectedToEditor
}
$flyout.Items.Add($addItem) | Out-Null
$flyout.Items.Add((New-MenuFlyoutSeparator)) | Out-Null
$copyNameItem = New-MenuFlyoutItem -Text "Copy Name" -Glyph ([char]0xE8C8) -OnClick {
Browser-CopySelectedNames
}
$flyout.Items.Add($copyNameItem) | Out-Null
$copyDefaultItem = New-MenuFlyoutItem -Text "Copy Default Value" -Glyph ([char]0xE8C8) -OnClick { Browser-CopySelectedDefaultValues }
$flyout.Items.Add($copyDefaultItem) | Out-Null
$copyOffsetItem = New-MenuFlyoutItem -Text "Copy Offset" -Glyph ([char]0xE8C8) -OnClick {
Browser-CopySelectedOffsets
}
$flyout.Items.Add($copyOffsetItem) | Out-Null
$copyJsonItem = New-MenuFlyoutItem -Text "Copy as JSON" -Glyph ([char]0xE8C8) -OnClick {
Browser-CopySelectedAsJson
}
$flyout.Items.Add($copyJsonItem) | Out-Null
$flyout.Items.Add((New-MenuFlyoutSeparator)) | Out-Null
$selectAllItem = New-MenuFlyoutItem -Text "Select All" -OnClick {
if ($null -ne $script:BrowserListView) {
$script:BrowserListView.SelectAll()
}
}
$flyout.Items.Add($selectAllItem) | Out-Null
return $flyout
}
function Browser-StartFetch {
if ($null -ne $script:BrowserProgressBar) {
Set-ControlVisible -Control $script:BrowserProgressBar -IsVisible $true
}
if ($null -ne $script:BrowserStatusText) {
$script:BrowserStatusText.Text = "Fetching FFlags..."
}
$script:BrowserFetchError = $null
$__browserDebug = $false
try { $__browserDebug = [bool]$script:Settings['debugLogging'] } catch { $__browserDebug = $false }
if ($__browserDebug) {
Write-ConsoleLog -Message "[browser-fetch] initiating fetch runspace" -Level "INFO"
}
try {
$fetchRunspace = [runspacefactory]::CreateRunspace()
$fetchRunspace.ApartmentState = 'STA'
$fetchRunspace.ThreadOptions = 'ReuseThread'
$fetchRunspace.Open()
$fetchPowerShell = [powershell]::Create()
$fetchPowerShell.Runspace = $fetchRunspace
$scriptRef = $script:FlagBrowserCache
$errorRef = ""
$gasBody = ${function:Get-AlliumFlagSources}.ToString()
$fetchRunspace.SessionStateProxy.SetVariable('GasFunctionBody', $gasBody)
[void]$fetchPowerShell.AddScript({
try { [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12 } catch {}
${function:Get-AlliumFlagSources} = $GasFunctionBody
try {
$result = Get-AlliumFlagSources
return $result
} catch {
return @(@{}, "Fetch runspace failure: $($_.Exception.Message)")
}
})
$asyncResult = $fetchPowerShell.BeginInvoke()
} catch {
$__setupExc = $_.Exception.Message
Write-ConsoleLog -Message "Browser fetch setup failed: $__setupExc" -Level "ERROR"
$script:BrowserFetchError = "Fetch setup failed: $__setupExc"
try { Browser-SetFetchResult -Cache $null -ErrorMsg $script:BrowserFetchError } catch {}
try { Browser-OnFetchComplete } catch { Write-ConsoleLog -Message "Browser-OnFetchComplete failed: $($_.Exception.Message)" -Level "WARN" }
return
}
$checkTimer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$checkTimer.Interval = New-UITimeSpan -Milliseconds 300
$localPs = $fetchPowerShell
$localAsync = $asyncResult
$localDebug = $__browserDebug
$checkTimer.AddTick({
param($argumentList, $s, $e)
try {
if ($localAsync.IsCompleted) {
$s.Stop()
try {
$results = $localPs.EndInvoke($localAsync)
$cache = $results[0]
$errorMsg = if ($results.Count -gt 1) { $results[1] } else { "" }
Browser-SetFetchResult -Cache $cache -ErrorMsg $errorMsg
if ($localDebug) {
$__cnt = if ($null -ne $cache) { $cache.Count } else { 0 }
Write-ConsoleLog -Message "[browser-fetch] complete; entries=$__cnt" -Level "INFO"
}
} catch {
Browser-SetFetchResult -Cache $null -ErrorMsg "Fetch failed: $_"
}
$localPs.Dispose()
Browser-OnFetchComplete
}
} catch { Write-ConsoleLog -Message "Error in browser fetch poll: $_" -Level "ERROR" }
}.GetNewClosure())
$checkTimer.Start()
}
function Get-AlliumFlagSources {
$errorMsg = ""
$cache = @{}
$browserUA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
function Get-FlagMeta {
param([string]$PrefixedName)
if ($PrefixedName -match '^(D?F|SF)(Flag|Int|String|Log)(.+)$') {
$typeWord = $Matches[2]
$rawName = $Matches[3]
$typeLabel = switch ($typeWord) {
'Flag' { 'bool' }
'Int' { 'int' }
'String' { 'string' }
'Log' { 'log' }
default { 'unknown' }
}
return @{ RawName = $rawName; Type = $typeLabel }
}
return @{ RawName = $PrefixedName; Type = 'unknown' }
}
$sovJsonRaw = $null
$sovHpp = $null
$sovJsonError = ""
$sovHppError = ""
try {
$sovJsonRaw = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/souloveryall/DataBase.json/refs/heads/main/database.json" -TimeoutSec 30 -UserAgent $browserUA -UseBasicParsing -ErrorAction Stop).Content
} catch {
$sovJsonError = "souloveryall JSON failed: $($_.Exception.Message)"
}
try {
$sovHpp = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/souloveryall/offsets.hpp/refs/heads/main/Offsets.hpp" -TimeoutSec 30 -UserAgent $browserUA -UseBasicParsing -ErrorAction Stop).Content
} catch {
$sovHppError = "souloveryall HPP failed: $($_.Exception.Message)"
}
$hppLookup = @{}
if ($null -ne $sovHpp) {
$hppLines = $sovHpp -split "`n"
foreach ($line in $hppLines) {
if ($line -match 'inline\s+constexpr\s+uintptr_t\s+(\w+)\s*=\s*(0x[0-9A-Fa-f]+)\s*;\s*//\s*(.+?)\s+\((\w+)\)\s*$') {
$hppLookup[$Matches[1]] = @{
Offset = $Matches[2]
DefaultValue = $Matches[3].Trim()
TypeLabel = $Matches[4].ToLower()
}
}
}
}
$sovJson = $null
if ($null -ne $sovJsonRaw) {
try {
$jsonStart = $sovJsonRaw.IndexOf('{')
if ($jsonStart -ge 0) {
$sovJsonClean = $sovJsonRaw.Substring($jsonStart)
$sovJson = $sovJsonClean | ConvertFrom-Json -AsHashtable
}
} catch {
$sovJsonError = "souloveryall JSON parse error: $($_.Exception.Message)"
}
}
if ($null -ne $sovJson -and $sovJson.Count -gt 0) {
$sovProps = if ($sovJson -is [hashtable]) { $sovJson.GetEnumerator() } else { $sovJson.PSObject.Properties }
foreach ($sp in $sovProps) {
try {
$displayName = if ($sp -is [System.Collections.DictionaryEntry]) { $sp.Key } else { $sp.Name }
$defaultVal = if ($sp -is [System.Collections.DictionaryEntry]) { $sp.Value } else { $sp.Value }
$defaultStr = if ($null -ne $defaultVal) { $defaultVal.ToString() } else { "" }
if ($defaultStr.Length -ge 2 -and $defaultStr.StartsWith('"') -and $defaultStr.EndsWith('"')) {
$defaultStr = $defaultStr.Substring(1, $defaultStr.Length - 2)
}
$meta = Get-FlagMeta -PrefixedName $displayName
$offset = ""
$typeFromHpp = $null
if ($hppLookup.ContainsKey($displayName)) {
$offset = $hppLookup[$displayName].Offset
$typeFromHpp = $hppLookup[$displayName].TypeLabel
}
$finalType = if ($meta.Type -ne 'unknown') { $meta.Type } elseif ($null -ne $typeFromHpp) { $typeFromHpp } else { 'unknown' }
$cache[$displayName] = @{
DefaultValue = $defaultStr
Offset = $offset
Type = $finalType
RawName = $meta.RawName
Prefix = $true
}
} catch {}
}
}
if ($cache.Count -eq 0 -and $hppLookup.Count -gt 0) {
foreach ($hppName in $hppLookup.Keys) {
$hppEntry = $hppLookup[$hppName]
$meta = Get-FlagMeta -PrefixedName $hppName
$cache[$hppName] = @{
DefaultValue = $(if ($hppEntry.DefaultValue.Length -ge 2 -and $hppEntry.DefaultValue.StartsWith('"') -and $hppEntry.DefaultValue.EndsWith('"')) { $hppEntry.DefaultValue.Substring(1, $hppEntry.DefaultValue.Length - 2) } else { $hppEntry.DefaultValue })
Offset = $hppEntry.Offset
Type = if ($meta.Type -ne 'unknown') { $meta.Type } elseif (-not [string]::IsNullOrWhiteSpace($hppEntry.TypeLabel)) { $hppEntry.TypeLabel } else { 'unknown' }
RawName = $meta.RawName
Prefix = $true
}
}
}
if (-not [string]::IsNullOrWhiteSpace($sovJsonError)) { $errorMsg += "$sovJsonError`n" }
if (-not [string]::IsNullOrWhiteSpace($sovHppError)) { $errorMsg += "$sovHppError`n" }
if ($cache.Count -eq 0) {
$theoJson = $null
$theoData = $null
$fvarData = $null
try {
$theoJson = (Invoke-WebRequest -Uri "https://offsets.imtheo.lol/FFlagsHex.json" -TimeoutSec 30 -UserAgent $browserUA -UseBasicParsing -ErrorAction Stop).Content | ConvertFrom-Json -AsHashtable
} catch {
try {
$theoData = Invoke-RestMethod -Uri "https://offsets.imtheo.lol/FFlags.hpp" -TimeoutSec 30 -UserAgent $browserUA -ErrorAction Stop
} catch {
$errorMsg += "Theo fallback failed: $($_.Exception.Message)`n"
}
}
try {
$fvarData = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/FVariables.txt" -TimeoutSec 30 -UserAgent $browserUA -ErrorAction Stop
} catch {
$errorMsg += "FVariables.txt failed: $($_.Exception.Message)`n"
}
$fvarLookup = @{}
if ($null -ne $fvarData) {
$fvarLines = $fvarData -split "`n"
foreach ($line in $fvarLines) {
if ($line -match '^\[C\+\+\]\s+((DF|F)(Flag|Int|String|Log))(.+)$') {
$prefix = $Matches[1]
$rawName = $Matches[4].Trim()
if (-not $fvarLookup.ContainsKey($rawName)) {
$fvarLookup[$rawName] = $prefix + $rawName
}
}
}
}
if ($null -ne $theoJson) {
$theoContainer = $null
if ($theoJson.ContainsKey('FFlagOffsets')) {
$theoContainer = $theoJson['FFlagOffsets']
if ($theoContainer -is [hashtable] -and $theoContainer.ContainsKey('FFlags')) {
$theoContainer = $theoContainer['FFlags']
}
} elseif ($theoJson.ContainsKey('FFlags')) {
$theoContainer = $theoJson['FFlags']
} else {
$theoContainer = $theoJson
}
if ($null -ne $theoContainer) {
$theoProps = if ($theoContainer -is [hashtable]) { $theoContainer.GetEnumerator() } else { $theoContainer.PSObject.Properties }
foreach ($p in $theoProps) {
try {
$rawName = if ($p -is [System.Collections.DictionaryEntry]) { $p.Key } else { $p.Name }
$val = if ($p -is [System.Collections.DictionaryEntry]) { $p.Value } else { $p.Value }
if ($null -eq $val -or $val -is [hashtable] -or $val -is [System.Management.Automation.PSCustomObject]) { continue }
$offset = $val.ToString()
if ($offset -notmatch '^0x') {
try { $offset = "0x{0:X}" -f [int64]$val } catch { continue }
}
$displayName = if ($fvarLookup.ContainsKey($rawName)) { $fvarLookup[$rawName] } else { $rawName }
$hasPrefix = $fvarLookup.ContainsKey($rawName)
$meta = Get-FlagMeta -PrefixedName $displayName
$cache[$displayName] = @{
DefaultValue = ""
Offset = $offset
Type = $meta.Type
RawName = $rawName
Prefix = $hasPrefix
}
} catch {}
}
}
}
if ($cache.Count -eq 0) {
if ($null -eq $theoData) {
try {
$theoData = Invoke-RestMethod -Uri "https://offsets.imtheo.lol/FFlags.hpp" -TimeoutSec 30 -UserAgent $browserUA -ErrorAction Stop
} catch {
$errorMsg += "Theo HPP fallback failed: $($_.Exception.Message)`n"
}
}
}
if ($cache.Count -eq 0 -and $null -ne $theoData) {
$theoLines = $theoData -split "`n"
foreach ($line in $theoLines) {
if ($line -match 'inline\s+constexpr\s+uintptr_t\s+(\w+)\s*=\s*(0x[0-9A-Fa-f]+)') {
$rawName = $Matches[1]
$offset = $Matches[2]
$displayName = if ($fvarLookup.ContainsKey($rawName)) { $fvarLookup[$rawName] } else { $rawName }
$meta = Get-FlagMeta -PrefixedName $displayName
$cache[$displayName] = @{
DefaultValue = ""
Offset = $offset
Type = $meta.Type
RawName = $rawName
Prefix = $fvarLookup.ContainsKey($rawName)
}
}
}
}
}
return @($cache, $errorMsg)
}
function Browser-SetFetchResult {
param($Cache, $ErrorMsg)
if ($null -ne $Cache) {
$script:FlagBrowserCache = $Cache
} else {
$script:FlagBrowserCache = @{}
}
$script:BrowserValueColPadWidth = $null
if (-not [string]::IsNullOrWhiteSpace($ErrorMsg) -and $script:FlagBrowserCache.Count -eq 0) {
$script:BrowserFetchError = $ErrorMsg
} else {
$script:BrowserFetchError = $null
}
}
function Browser-OnFetchComplete {
if ($null -ne $script:BrowserProgressBar) {
Set-ControlVisible -Control $script:BrowserProgressBar -IsVisible $false
}
if ($null -ne $script:BrowserFetchError -and $script:FlagBrowserCache.Count -eq 0) {
if ($null -ne $script:BrowserStatusText) {
$script:BrowserStatusText.Text = "Fetch failed"
}
Write-ConsoleLog -Message "FFlag Browser fetch failed: $($script:BrowserFetchError)" -Level "ERROR"
if ($null -ne $script:BrowserWindow) {
$xamlRoot = $script:BrowserWindow.Content.XamlRoot
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 8
$msg = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$msg.Text = $script:BrowserFetchError
Set-SafeFontFamily -Target $msg -Family $script:AppFontFamily
$msg.FontSize = 13
$msg.Foreground = New-SolidBrush -Hex $script:ThemeColors.Error
$msg.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$panel.Children.Add($msg) | Out-Null
$result = Show-CustomDialog -XamlRoot $xamlRoot -Title "Fetch Error" -Content $panel -PrimaryButtonText "Retry" -CloseButtonText "Close"
if ($result -eq "Primary") {
Browser-StartFetch
}
}
return
}
$count = $script:FlagBrowserCache.Count
if ($null -ne $script:BrowserStatusText) {
$script:BrowserStatusText.Text = "Cached: $count FFlags"
}
Write-ConsoleLog -Message "FFlag Browser fetched $count FFlags." -Level "INFO"
$script:BrowserRawNameMap = @{}
foreach ($bKey in $script:FlagBrowserCache.Keys) {
$bEntry = $script:FlagBrowserCache[$bKey]
if ($null -ne $bEntry -and -not [string]::IsNullOrWhiteSpace($bEntry.RawName)) {
$rawLower = $bEntry.RawName.ToLower()
if (-not $script:BrowserRawNameMap.ContainsKey($rawLower)) {
$script:BrowserRawNameMap[$rawLower] = $bKey
}
}
}
Write-ConsoleLog -Message "Built RawName map: $($script:BrowserRawNameMap.Count) entries." -Level "INFO"
$script:FlagPrefixCache = $null
Browser-RefreshList
}
function Browser-InstallKeyboardShortcuts {
param([WinUIShell.Microsoft.UI.Xaml.Window]$Window)
$ctrl = [WinUIShell.Windows.System.VirtualKeyModifiers]::Control
$none = [WinUIShell.Windows.System.VirtualKeyModifiers]::None
$shortcuts = @(
@{ Key = [WinUIShell.Windows.System.VirtualKey]::F; Mod = $ctrl; Action = { if ($null -ne $script:BrowserSearchBox) { $script:BrowserSearchBox.Focus() } } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::A; Mod = $ctrl; Action = { Browser-SelectAllVisible } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::C; Mod = $ctrl; Action = { Browser-CopySelectedNames } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::Enter; Mod = $none; Action = { Browser-AddSelectedToEditor } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::Escape; Mod = $none; Action = { Browser-DeselectAll } }
)
foreach ($sc in $shortcuts) {
try {
$ka = New-KeyboardAccelerator -Key $sc.Key -Modifiers $sc.Mod -Action $sc.Action
if ($null -ne $Window.KeyboardAccelerators) {
$Window.KeyboardAccelerators.Add($ka) | Out-Null
}
} catch { Write-ConsoleLog -Message "Failed to install browser shortcut: $_" -Level "WARN" }
}
}
function Browser-SelectAllVisible {
if ($null -eq $script:BrowserListView) { return }
$script:BrowserListView.SelectAll()
$script:BrowserSelectionDirty = $true
}
function Browser-DeselectAll {
if ($null -eq $script:BrowserListView) { return }
try {
$count = $script:BrowserListView.Items.Count
if ($count -gt 0) {
$range = [WinUIShell.Microsoft.UI.Xaml.Data.ItemIndexRange]::new(0, [uint32]$count)
$script:BrowserListView.DeselectRange($range)
}
} catch {
try { $script:BrowserListView.SelectedItems.Clear() } catch {}
}
$script:BrowserSelectedItems = @()
}
function Browser-RefreshList {
if ($null -eq $script:BrowserListView -and $null -eq $script:BrowserTableBorder) { return }
$sw = [System.Diagnostics.Stopwatch]::StartNew()
if ($script:BrowserSortColumn -eq "Default") {
$descending = ($script:BrowserSortDirection -eq "Descending")
$sorted = @($script:FlagBrowserCache.Keys | Sort-Object @{Expression={
$fe = $script:FlagBrowserCache[$_]
$dv = if ($null -ne $fe -and $null -ne $fe.DefaultValue) { $fe.DefaultValue.ToString() } else { "" }
$dv
}; Ascending=(-not $descending)}, @{Expression={$_}; Ascending=$true})
} else {
if ($script:BrowserSortDirection -eq "Descending") {
$sorted = @($script:FlagBrowserCache.Keys | Sort-Object -Descending)
} else {
$sorted = @($script:FlagBrowserCache.Keys | Sort-Object)
}
}
$filtered = [System.Collections.Generic.List[string]]::new()
foreach ($name in $sorted) {
if (-not [string]::IsNullOrWhiteSpace($script:BrowserCurrentSearch)) {
if ($name -notlike "*$($script:BrowserCurrentSearch)*") {
$fe = $script:FlagBrowserCache[$name]
if ($null -eq $fe -or $null -eq $fe.RawName -or $fe.RawName -notlike "*$($script:BrowserCurrentSearch)*") {
continue
}
}
}
$filtered.Add($name)
}
if ($script:BrowserTypeFilter -ne "All") {
$typeFiltered = [System.Collections.Generic.List[string]]::new()
foreach ($fn in $filtered) {
$fe = $script:FlagBrowserCache[$fn]
if ($null -ne $fe -and $fe.Type -eq $script:BrowserTypeFilter) {
$typeFiltered.Add($fn)
}
}
$filtered = $typeFiltered
}
$script:BrowserDisplayOrder = $filtered
$showOverlay = ($filtered.Count -gt 500)
if ($showOverlay -and $null -ne $script:BrowserLoadingOverlay) {
try {
$script:BrowserLoadingOverlay.Children[0].Children[1].Text = "Loading $($filtered.Count) FFlags..."
} catch {}
Set-ControlVisible -Control $script:BrowserLoadingOverlay -IsVisible $true
}
$xamlSuccess = $false
if ($null -ne $script:BrowserTableBorder) {
try {
$xamlString = Browser-BuildListViewXaml -FlagNames $filtered
$newListView = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($xamlString)
if ($null -ne $newListView) {
if ($null -ne $script:BrowserLoadingOverlay) {
Set-ControlVisible -Control $script:BrowserLoadingOverlay -IsVisible $false
}
$script:BrowserTableBorder.Child = $newListView
$script:BrowserListView = $newListView
Browser-AttachListViewHandlers
$xamlSuccess = $true
}
} catch {
Write-ConsoleLog -Message "Browser XamlReader failed: $($_.Exception.Message)" -Level "WARN"
}
}
if (-not $xamlSuccess) {
if ($null -ne $script:BrowserListView) {
$script:BrowserListView.Items.Clear()
if ($null -eq $script:BrowserMonoFont) {
$script:BrowserMonoFont = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Sono, Cascadia Mono, Consolas")
}
$script:BrowserListView.FontFamily = $script:BrowserMonoFont
$script:BrowserListView.FontSize = 12
$script:BrowserListView.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Normal
if ($null -eq $script:BrowserValueColPadWidth) {
$maxDisplayLenFb = 0
foreach ($cachedName in $script:FlagBrowserCache.Keys) {
if (($cachedName.Length + 4) -gt $maxDisplayLenFb) { $maxDisplayLenFb = $cachedName.Length + 4 }
}
$pwFb = $maxDisplayLenFb + 2
if ($pwFb -lt 20) { $pwFb = 20 }
if ($pwFb -gt 90) { $pwFb = 90 }
$script:BrowserValueColPadWidth = $pwFb
}
$padWidthFb = $script:BrowserValueColPadWidth
foreach ($name in $filtered) {
$entry = $script:FlagBrowserCache[$name]
$offset = if ($null -ne $entry) { $entry.DefaultValue } else { "" }
$padded = $name.PadRight($padWidthFb)
$script:BrowserListView.Items.Add("$padded $offset") | Out-Null
}
}
}
if ($null -ne $script:BrowserLoadingOverlay) {
Set-ControlVisible -Control $script:BrowserLoadingOverlay -IsVisible $false
}
if ($null -ne $script:BrowserStatusText) {
$unknownCount = 0
foreach ($fn in $filtered) {
$fe = $script:FlagBrowserCache[$fn]
if ($null -eq $fe -or $fe.Type -eq 'unknown') { $unknownCount++ }
}
$statusMsg = "Showing $($filtered.Count) of $($script:FlagBrowserCache.Count) FFlags"
if ($unknownCount -gt 0) { $statusMsg += " ($unknownCount unknown)" }
$script:BrowserStatusText.Text = $statusMsg
}
$sw.Stop()
$method = if ($xamlSuccess) { "XamlReader" } else { "Legacy" }
Write-ConsoleLog -Message "Browser: $($filtered.Count) items ($method, $($sw.ElapsedMilliseconds)ms)" -Level "INFO"
}
function Browser-BuildListViewXaml {
param([System.Collections.Generic.List[string]]$FlagNames)
$sb = [System.Text.StringBuilder]::new($FlagNames.Count * 100 + 500)
if ($null -eq $script:BrowserValueColPadWidth) {
$maxDisplayLen = 0
foreach ($cachedName in $script:FlagBrowserCache.Keys) {
$displayLen = $cachedName.Length + 4
if ($displayLen -gt $maxDisplayLen) { $maxDisplayLen = $displayLen }
}
$pw = $maxDisplayLen + 2
if ($pw -lt 20) { $pw = 20 }
if ($pw -gt 90) { $pw = 90 }
$script:BrowserValueColPadWidth = $pw
}
$padWidth = $script:BrowserValueColPadWidth
[void]$sb.Append('<ListView xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"')
[void]$sb.Append(' xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"')
[void]$sb.Append(' SelectionMode="Extended"')
[void]$sb.Append(' CanDragItems="True"')
[void]$sb.Append(' FontFamily="Sono, Cascadia Mono, Consolas"')
[void]$sb.Append(' FontWeight="Normal"')
[void]$sb.Append(' FontSize="12"')
[void]$sb.Append(' HorizontalAlignment="Stretch"')
[void]$sb.Append(' VerticalAlignment="Stretch"')
[void]$sb.Append(" Foreground=`"$($script:ThemeColors.TextPrimary)`"")
[void]$sb.Append(' Background="Transparent">')
[void]$sb.Append('<ListView.ItemContainerTransitions><TransitionCollection/></ListView.ItemContainerTransitions>')
[void]$sb.Append('<ListView.Transitions><TransitionCollection/></ListView.Transitions>')
[void]$sb.Append('<ListView.ItemTemplate><DataTemplate>')
[void]$sb.Append('<TextBlock Text="{Binding}"')
[void]$sb.Append(' FontFamily="Sono, Cascadia Mono, Consolas"')
[void]$sb.Append(' FontWeight="Normal"')
[void]$sb.Append(' FontSize="12"')
[void]$sb.Append(' TextWrapping="NoWrap"')
[void]$sb.Append(' xml:space="preserve"/>')
[void]$sb.Append('</DataTemplate></ListView.ItemTemplate>')
foreach ($name in $FlagNames) {
$entry = $script:FlagBrowserCache[$name]
$offset = if ($null -ne $entry) { $entry.DefaultValue } else { "" }
$prefix = switch ($entry.Type) {
'bool' { '[B]' }
'int' { '[I]' }
'string' { '[S]' }
'log' { '[L]' }
default { '[?]' }
}
$displayStr = "$prefix $name"
$padded = $displayStr.PadRight($padWidth)
$escapedLine = [System.Security.SecurityElement]::Escape("$padded $offset")
[void]$sb.Append("<x:String xml:space=`"preserve`">$escapedLine</x:String>")
}
[void]$sb.Append('</ListView>')
return $sb.ToString()
}
function Browser-AttachListViewHandlers {
if ($null -eq $script:BrowserListView) { return }
$lv = $script:BrowserListView
$ac = New-Color -Hex $script:AccentColor
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$lv.Resources[$key] = $ac
}
try { Set-AccentResourceOverrides -ResourceDictionary $lv.Resources } catch { Write-ConsoleLog -Message "Browser accent resource failed: $_" -Level "WARN" }
$lv.AddSelectionChanged({
param($argumentList, $s, $e)
$script:BrowserSelectionDirty = $true
})
try {
$lv.ContextFlyout = New-BrowserContextMenu
} catch {
$browserCm = New-BrowserContextMenu
$lv.AddRightTapped({
param($argumentList, $s, $e)
try { $browserCm.ShowAt($s) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
}
try {
$lv.CanDragItems = $true
$lv.AddDragItemsStarting({
param($argumentList, $s, $e)
try {
$names = @()
try { Browser-ResolveSelection } catch {
try { Write-ConsoleLog -Message "Drag: Browser-ResolveSelection failed: $_" -Level "WARN" } catch {}
}
if ($null -ne $script:BrowserSelectedNames -and $script:BrowserSelectedNames.Count -gt 0) {
$names = @($script:BrowserSelectedNames)
}
if ($names.Count -eq 0) {
$e.Cancel = $true
return
}
try {
$jsonNames = $names | ConvertTo-Json -Compress
$e.Data.Properties["AlliumFFlagNames"] = $jsonNames
} catch {
try { Write-ConsoleLog -Message "Drag Properties write failed (will use carrier): $_" -Level "WARN" } catch {}
}
try { $e.Data.SetText(($names -join ", ")) } catch {}
$script:DragPayload = @{
Source = "Browser"
Names = $names
Timestamp = (Get-Date)
}
try { Write-ConsoleLog -Message "Drag started: $($names.Count) FFlag(s)" -Level "INFO" } catch {}
} catch {
try { Write-ConsoleLog -Message "Browser DragItemsStarting error: $_" -Level "ERROR" } catch {}
}
})
} catch {
Write-ConsoleLog -Message "Drag source reattach failed: $_" -Level "WARN"
}
}
function Browser-ResolveSelection {
if (-not $script:BrowserSelectionDirty) { return }
$script:BrowserSelectionDirty = $false
if ($null -eq $script:BrowserListView -or $null -eq $script:BrowserDisplayOrder) {
$script:BrowserSelectedNames = [System.Collections.Generic.List[string]]::new()
return
}
$names = [System.Collections.Generic.List[string]]::new()
try {
$maxIdx = $script:BrowserDisplayOrder.Count - 1
foreach ($range in $script:BrowserListView.SelectedRanges) {
$first = $range.FirstIndex
$last = $range.LastIndex
for ($i = $first; $i -le $last; $i++) {
if ($i -ge 0 -and $i -le $maxIdx) {
$names.Add($script:BrowserDisplayOrder[$i])
}
}
}
} catch { Write-ConsoleLog -Message "Browser ResolveSelection error: $_" -Level "WARN" }
$script:BrowserSelectedNames = $names
}
function Browser-ResetSearchDebounce {
if ($null -ne $script:BrowserSearchDebounceTimer) {
$script:BrowserSearchDebounceTimer.Stop()
$script:BrowserSearchDebounceTimer.Start()
return
}
$timer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$timer.Interval = New-UITimeSpan -Milliseconds 300
$timer.AddTick({
param($argumentList, $s, $e)
$s.Stop()
Browser-RefreshList
})
$timer.Start()
$script:BrowserSearchDebounceTimer = $timer
}
function Browser-AddSelectedToEditor {
Browser-ResolveSelection
$added = 0
$preSnapshot = Get-CurrentFlagSnapshot
foreach ($name in $script:BrowserSelectedNames) {
if ($null -eq $name) { continue }
if ($script:Flags.ContainsKey($name)) { continue }
$entry = $script:FlagBrowserCache[$name]
if ($null -eq $entry) { continue }
$defaultValue = if (-not [string]::IsNullOrWhiteSpace($entry.DefaultValue)) { $entry.DefaultValue } elseif ($name -like "FFlag*") { "True" } else { "" }
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 12; $panel.MinWidth = 400
$nl = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nl.Text = $name
$nl.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Cascadia Code, Consolas, monospace")
$nl.FontSize = 13; $nl.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$vl = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$vl.Text = "Value"; Set-SafeFontFamily -Target $vl -Family $script:AppFontFamily; $vl.FontSize = 14
$vl.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$vb = New-ThemedTextBox -Text $defaultValue -Placeholder "Enter value"
$vb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$panel.Children.Add($nl) | Out-Null
$panel.Children.Add($vl) | Out-Null
$panel.Children.Add($vb) | Out-Null
$dialogResult = Show-CustomDialog -XamlRoot $script:BrowserWindow.Content.XamlRoot -Title "Add FFlag" -Content $panel -PrimaryButtonText "Add" -CloseButtonText "Cancel"
if ($dialogResult -ne "Primary") { continue }
$val = $vb.Text.Trim()
if ([string]::IsNullOrWhiteSpace($val)) { continue }
$script:Flags[$name] = $val
$added++
}
if ($added -gt 0) {
Push-UndoState -Action "Add $added FFlag(s) from Browser" -Snapshot $preSnapshot
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Added $added FFlag(s) from Browser." -Level "INFO"
}
}
function Browser-CopySelectedNames {
Browser-ResolveSelection
Set-Clipboard -Value ($script:BrowserSelectedNames -join "`r`n")
Write-ConsoleLog -Message "Copied $($script:BrowserSelectedNames.Count) FFlag name(s) from Browser." -Level "INFO"
}
function Browser-CopySelectedDefaultValues {
Browser-ResolveSelection
$values = [System.Collections.Generic.List[string]]::new()
foreach ($name in $script:BrowserSelectedNames) {
if ($null -ne $name -and $script:FlagBrowserCache.ContainsKey($name)) {
$dv = $script:FlagBrowserCache[$name].DefaultValue
$values.Add($(if ($null -ne $dv) { $dv.ToString() } else { "" }))
}
}
Set-Clipboard -Value ($values -join "`r`n")
Write-ConsoleLog -Message "Copied $($values.Count) default value(s) from Browser." -Level "INFO"
}
function Browser-CopySelectedOffsets {
Browser-ResolveSelection
$offsets = [System.Collections.Generic.List[string]]::new()
foreach ($name in $script:BrowserSelectedNames) {
if ($null -ne $name -and $script:FlagBrowserCache.ContainsKey($name)) {
$offsets.Add($script:FlagBrowserCache[$name].Offset)
}
}
Set-Clipboard -Value ($offsets -join "`r`n")
Write-ConsoleLog -Message "Copied $($offsets.Count) offset(s) from Browser." -Level "INFO"
}
function Browser-CopySelectedAsJson {
Browser-ResolveSelection
$count = 0
$sb = [System.Text.StringBuilder]::new($script:BrowserSelectedNames.Count * 80)
[void]$sb.Append('{')
$first = $true
foreach ($name in $script:BrowserSelectedNames) {
if ($null -ne $name -and $script:FlagBrowserCache.ContainsKey($name)) {
if (-not $first) { [void]$sb.Append(',') }
$ek = $name.Replace('\', '\\').Replace('"', '\"')
$dv = $script:FlagBrowserCache[$name].DefaultValue
$ev = if ($null -ne $dv) { $dv.ToString().Replace('\', '\\').Replace('"', '\"') } else { "" }
[void]$sb.Append("`n  `"$ek`": `"$ev`"")
$first = $false
$count++
}
}
[void]$sb.Append("`n}")
Set-Clipboard -Value $sb.ToString()
Write-ConsoleLog -Message "Copied $count FFlag(s) as JSON from Browser." -Level "INFO"
}
function New-FlagDiff {
param(
[hashtable]$Current,
[hashtable]$Incoming,
[switch]$IsReplace
)
$additions = @()
$removals = @()
$changes = @()
foreach ($key in $Incoming.Keys) {
if (-not $Current.ContainsKey($key)) {
$additions += $key
} elseif ($Current[$key] -ne $Incoming[$key]) {
$changes += $key
}
}
if ($IsReplace) {
foreach ($key in $Current.Keys) {
if (-not $Incoming.ContainsKey($key)) {
$removals += $key
}
}
}
return @{
Additions = $additions | Sort-Object
Removals = $removals | Sort-Object
Changes = $changes | Sort-Object
}
}
function Show-FlagDiffDialog {
param(
[hashtable]$Diff,
[hashtable]$Current,
[hashtable]$Incoming,
[string]$DialogTitle = "FFlag Diff"
)
if ($null -eq $script:EditorWindow) { return $false }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 12
$panel.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4)
$panel.MaxHeight = 500
$addCount = $Diff.Additions.Count
$remCount = $Diff.Removals.Count
$chgCount = $Diff.Changes.Count
$summary = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
Set-SafeFontFamily -Target $summary -Family $script:AppFontFamily
$summary.FontSize = 13
$summary.Text = "$addCount addition$(if($addCount -ne 1){'s'}), $remCount removal$(if($remCount -ne 1){'s'}), $chgCount change$(if($chgCount -ne 1){'s'})"
$summary.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$panel.Children.Add($summary) | Out-Null
$appFont = 'Nunito, Segoe UI, sans-serif'
$cPrimary = $script:ThemeColors.TextPrimary
$cSuccess = $script:ThemeColors.Success
$cError = $script:ThemeColors.Error
$cWarning = $script:ThemeColors.Warning
$maxNameLen = 0
foreach ($k in $Diff.Additions) { if ($k.Length -gt $maxNameLen) { $maxNameLen = $k.Length } }
foreach ($k in $Diff.Changes) { if ($k.Length -gt $maxNameLen) { $maxNameLen = $k.Length } }
foreach ($k in $Diff.Removals) { if ($k.Length -gt $maxNameLen) { $maxNameLen = $k.Length } }
$nameColPx = ($maxNameLen * 8) + 24
if ($nameColPx -lt 240) { $nameColPx = 240 }
if ($nameColPx -gt 560) { $nameColPx = 560 }
$panelMinW = 24 + $nameColPx + 200 + 40
if ($panelMinW -lt 480) { $panelMinW = 480 }
if ($panelMinW -gt 800) { $panelMinW = 800 }
$panel.MinWidth = $panelMinW
$sb = [System.Text.StringBuilder]::new((($addCount + $remCount + $chgCount) * 260) + 512)
[void]$sb.Append('<ListView xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"')
[void]$sb.Append(' xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"')
[void]$sb.Append(' SelectionMode="None"')
[void]$sb.Append(" FontFamily=`"$appFont`"")
[void]$sb.Append(' FontSize="12"')
[void]$sb.Append(' MaxHeight="400"')
[void]$sb.Append(' Background="Transparent">')
[void]$sb.Append('<ListView.ItemContainerTransitions><TransitionCollection/></ListView.ItemContainerTransitions>')
[void]$sb.Append('<ListView.Transitions><TransitionCollection/></ListView.Transitions>')
$emit = {
param($name, $valueText, $badge, $badgeColor, $valueColor)
$en = [System.Security.SecurityElement]::Escape([string]$name)
$ev = [System.Security.SecurityElement]::Escape([string]$valueText)
[void]$sb.Append('<Grid Padding="4,2,4,2" ColumnSpacing="8">')
[void]$sb.Append('<Grid.ColumnDefinitions>')
[void]$sb.Append('<ColumnDefinition Width="24"/>')
[void]$sb.Append("<ColumnDefinition Width=`"$nameColPx`"/>")
[void]$sb.Append('<ColumnDefinition Width="*"/>')
[void]$sb.Append('</Grid.ColumnDefinitions>')
[void]$sb.Append("<TextBlock Grid.Column=`"0`" Text=`"$badge`" FontWeight=`"Bold`" Foreground=`"$badgeColor`" HorizontalAlignment=`"Center`" VerticalAlignment=`"Center`"/>")
[void]$sb.Append("<TextBlock Grid.Column=`"1`" Text=`"$en`" Foreground=`"$cPrimary`" VerticalAlignment=`"Center`" TextTrimming=`"CharacterEllipsis`"/>")
[void]$sb.Append("<TextBlock Grid.Column=`"2`" Text=`"$ev`" Foreground=`"$valueColor`" VerticalAlignment=`"Center`" TextTrimming=`"CharacterEllipsis`"/>")
[void]$sb.Append('</Grid>')
}
foreach ($key in $Diff.Additions) {
& $emit $key ([string]$Incoming[$key]) '+' $cSuccess $cSuccess
}
foreach ($key in $Diff.Changes) {
& $emit $key ("$($Current[$key])  ->  $($Incoming[$key])") '~' $cWarning $cWarning
}
foreach ($key in $Diff.Removals) {
& $emit $key ([string]$Current[$key]) '-' $cError $cError
}
[void]$sb.Append('</ListView>')
$listView = $null
try {
$listView = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($sb.ToString())
} catch {
Write-ConsoleLog -Message "Diff XamlReader failed: $($_.Exception.Message)" -Level "WARN"
}
if ($null -ne $listView) {
$panel.Children.Add($listView) | Out-Null
}
$result = Show-CustomDialog -XamlRoot $xamlRoot -Title $DialogTitle -Content $panel -PrimaryButtonText "Apply" -CloseButtonText "Cancel" -MaxWidth 860
return ($result -eq "Primary")
}
$script:EditorWindow = $null
$script:EditorNotificationBar = $null
$script:EditorFlagListView = $null
$script:EditorBtnDeleteSelected = $null
$script:EditorBtnBatchEdit = $null
$script:EditorBtnDeleteAll = $null
$script:EditorSearchBox = $null
$script:EditorConsoleStack = $null
$script:EditorConsoleScroll = $null
$script:EditorConsoleTextBox = $null
$script:EditorConsoleRichTextBlock = $null
$script:EditorConsoleScrollViewer = $null
$script:ConsoleLogUseRichTextBlock = $false
$script:EditorConsoleListView = $null
$script:ConsoleFlushTimer = $null
$script:KbdLastCtrlZ = $false
$script:KbdLastCtrlY = $false
$script:KbdLastCtrlF = $false
$script:KbdLastCtrlA = $false
$script:KbdLastCtrlC = $false
$script:KbdLastCtrlV = $false
$script:KbdLastCtrlE = $false
$script:KbdLastDel = $false
$script:KbdLastEsc = $false
$script:KbdLastEnter = $false
$script:KbdEditorActive = $false
$script:KbdCtrlUp = 0
$script:KbdTextFocused = $false
$script:KbdFocusCheckCounter = 0
$script:EditorWindowActive = $false
$script:EditorHwnd = [System.IntPtr]::Zero
$script:EditorConsolePanel = $null
$script:EditorFlagCountText = $null
$script:EditorLoadingText = $null
$script:EditorEmptyStateText = $null
$script:EditorSelectedItems = @()
$script:EditorCurrentSearch = ""
$script:EditorSortColumn = "Name"
$script:EditorSortDirection = "Ascending"
$script:EditorThName = $null
$script:EditorThValue = $null
$script:EditorDisplayOrder = $null
$script:EditorSelectedNames = [System.Collections.Generic.List[string]]::new()
$script:EditorTableBorder = $null
$script:XamlReaderSupported = $null
$script:EditorSelectionDirty = $false
$script:EditorSearchDebounceTimer = $null
$script:EditorFlagStatus = @{}
$script:EditorFlagAppliedValue = @{}
function Open-FFlagEditor {
if ($null -ne $script:EditorWindow) {
try { $script:EditorWindow.Activate() } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
return
}
$win = New-FFlagEditorWindow
$script:EditorWindow = $win
$win.Activate()
Editor-PopulateToolbar
}
function New-FFlagEditorWindow {
$window = [WinUIShell.Microsoft.UI.Xaml.Window]::new()
$window.Title = "$($script:AppTitle) - FFlag Editor"
$window.ExtendsContentIntoTitleBar = $true
try {
$savedSize = $script:Settings.lastEditorSize
if ($null -ne $savedSize -and $savedSize.Width -gt 0 -and $savedSize.Height -gt 0) {
$window.AppWindow.Resize($savedSize.Width, $savedSize.Height)
Center-Window -AppWindow $window.AppWindow -Width $savedSize.Width -Height $savedSize.Height
} else {
$window.AppWindow.Resize(1375, 750)
Center-Window -AppWindow $window.AppWindow -Width 1375 -Height 750
}
try {
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
if ($screen.Width -lt 1920 -or $screen.Height -lt 1080) {
$scaleW = $screen.Width / 1920.0
$scaleH = $screen.Height / 1080.0
$scale = [math]::Min($scaleW, $scaleH)
$w = 1375 * $scale
$h = 750 * $scale
$window.AppWindow.Resize($w, $h)
}
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$iconFile = (Resolve-Path $script:IconPath).Path
try { $window.AppWindow.SetIcon($iconFile) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
try {
$presenter = $window.AppWindow.Presenter
$presenter.PreferredMinimumWidth = 1375
$presenter.PreferredMinimumHeight = 750
} catch {
Write-ConsoleLog -Message "OverlappedPresenter min size not available: $_" -Level "WARN"
}
$titleRegion = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$titleRegion.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 12, 0, 10)
$titleRegion.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0)
)
$titleStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$titleStack.Spacing = 2
$titleText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$titleText.Text = "Allium Editor"
Set-SafeFontFamily -Target $titleText -Family $script:AppFontFamily
$titleText.FontSize = 20
$titleText.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$titleText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$subtitleText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$subtitleText.Text = "Manage your FastFlags here."
Set-SafeFontFamily -Target $subtitleText -Family $script:AppFontFamily
$subtitleText.FontSize = 13
$subtitleText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$titleStack.Children.Add($titleText) | Out-Null
$titleStack.Children.Add($subtitleText) | Out-Null
$titleRegion.Children.Add($titleStack) | Out-Null
$window.SetTitleBar($titleRegion)
$root = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$root.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$root.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(210, 0x1c, 0x08, 0x08)
)
$root.RowSpacing = 0
$rowTitleBar = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowTitleBar.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowSpacer = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowSpacer.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(8, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Pixel)
$rowToolbar = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowToolbar.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowSearch = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowSearch.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowHeader = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowHeader.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowTable = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowTable.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$rowConsole = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowConsole.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowBottom = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowBottom.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$root.RowDefinitions.Add($rowTitleBar) | Out-Null
$root.RowDefinitions.Add($rowSpacer) | Out-Null
$root.RowDefinitions.Add($rowToolbar) | Out-Null
$root.RowDefinitions.Add($rowSearch) | Out-Null
$root.RowDefinitions.Add($rowHeader) | Out-Null
$root.RowDefinitions.Add($rowTable) | Out-Null
$root.RowDefinitions.Add($rowConsole) | Out-Null
$root.RowDefinitions.Add($rowBottom) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($titleRegion, 0)
$root.Children.Add($titleRegion) | Out-Null
$loadingText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$loadingText.Text = "Loading..."
Set-SafeFontFamily -Target $loadingText -Family $script:AppFontFamily
$loadingText.FontSize = 13
$loadingText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$loadingText.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$loadingText.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($loadingText, 5)
$root.Children.Add($loadingText) | Out-Null
$script:EditorLoadingText = $loadingText
$window.Content = $root
Set-WindowTheme -Window $window
try {
$window.AppWindow.TitleBar.PreferredTheme = [WinUIShell.Microsoft.UI.Windowing.TitleBarTheme]::Dark
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$window.AddClosed({
$script:EditorWindow = $null
$script:KbdEditorActive = $false
$script:EditorWindowActive = $false
$script:EditorHwnd = [System.IntPtr]::Zero
$script:KbdTextFocused = $false
$script:KbdFocusCheckCounter = 0
$script:EditorNotificationBar = $null
$script:EditorFlagListView = $null
$script:EditorSearchBox = $null
$script:EditorConsoleStack = $null
$script:EditorConsoleScroll = $null
$script:EditorConsoleTextBox = $null
$script:EditorConsoleListView = $null
Stop-ConsoleFlushTimer
$script:EditorConsolePanel = $null
$script:EditorFlagCountText = $null
$script:EditorLoadingText = $null
$script:EditorEmptyStateText = $null
$script:EditorBtnDeleteSelected = $null
$script:EditorBtnDeleteAll = $null
$script:EditorThName = $null
$script:EditorThValue = $null
$script:EditorTableBorder = $null
$script:EditorSelectionDirty = $false
if ($null -ne $script:EditorSearchDebounceTimer) {
$script:EditorSearchDebounceTimer.Stop()
$script:EditorSearchDebounceTimer = $null
}
$script:EditorDisplayOrder = $null
$script:EditorSelectedNames = [System.Collections.Generic.List[string]]::new()
$script:EditorSelectedItems = @()
})
try {
$window.AppWindow.AddClosing({
param($argumentList, $s, $e)
try {
$size = $window.AppWindow.Size
$script:Settings.lastEditorSize = @{ Width = $size.Width; Height = $size.Height }
Save-Settings
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
if ($script:Settings.minimizeToTray -and $null -ne $script:TrayNotifyIcon) {
$e.Cancel = $true
$window.AppWindow.Hide()
Show-TrayIcon
Write-ConsoleLog -Message "Minimized to system tray." -Level "INFO"
}
})
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
return $window
}
function Editor-PopulateToolbar {
if ($null -eq $script:EditorWindow) { return }
$root = $script:EditorWindow.Content
if ($null -eq $root) { return }
if ($null -ne $script:EditorLoadingText) {
try { $root.Children.Remove($script:EditorLoadingText) } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$script:EditorLoadingText = $null
}
$toolbarGrid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$toolbarGrid.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 4)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($toolbarGrid, 2)
$col0 = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$col0.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$toolbarGrid.ColumnDefinitions.Add($col0) | Out-Null
$col1 = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$col1.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$toolbarGrid.ColumnDefinitions.Add($col1) | Out-Null
$toolbarOuter = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$toolbarOuter.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$toolbarOuter.Spacing = 4
$btnUndo = New-ThemedButton -Glyph ([char]0xE7A7) -IconOnly -ToolbarStyle
$btnUndo.AddClick({ param($argumentList, $s, $e)
try { if (Invoke-Undo) { Save-Flags; Editor-RefreshFlagList; Write-ConsoleLog -Message "Undo." -Level "INFO" } }
catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnUndo) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnUndo, "Undo last action (Ctrl+Z)")
$btnRedo = New-ThemedButton -Glyph ([char]0xE7A6) -IconOnly -ToolbarStyle
$btnRedo.AddClick({ param($argumentList, $s, $e)
try { if (Invoke-Redo) { Save-Flags; Editor-RefreshFlagList; Write-ConsoleLog -Message "Redo." -Level "INFO" } }
catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnRedo) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnRedo, "Redo last undone action (Ctrl+Y)")
$toolbarOuter.Children.Add((New-ToolbarSeparator)) | Out-Null
$btnAddNew = New-ThemedButton -Content "Add New" -Glyph ([char]0xE710) -ToolbarStyle
$btnAddNew.AddClick({
try { Editor-AddNewFlag } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnAddNew) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnAddNew, "Add a single FFlag or import from JSON")
$btnBatchEdit = New-ThemedButton -Content "Batch Edit" -Glyph ([char]0xE70F) -ToolbarStyle
$btnBatchEdit.AddClick({
try { Editor-BatchEditSelected } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$script:EditorBtnBatchEdit = $btnBatchEdit
$toolbarOuter.Children.Add($btnBatchEdit) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnBatchEdit, "Batch-edit values for multiple selected FFlags (Ctrl+E)")
$btnDeleteSelected = New-ThemedButton -Content "Delete Selected" -Glyph ([char]0xE74D) -ToolbarStyle
$btnDeleteSelected.AddClick({
try { Editor-DeleteSelected } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$script:EditorBtnDeleteSelected = $btnDeleteSelected
$toolbarOuter.Children.Add($btnDeleteSelected) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnDeleteSelected, "Delete selected FFlags (Del key)")
$btnDeleteAll = New-ThemedButton -Content "Delete All" -Glyph ([char]0xE74D) -ToolbarStyle
$btnDeleteAll.AddClick({
try { Editor-DeleteAll } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$script:EditorBtnDeleteAll = $btnDeleteAll
$toolbarOuter.Children.Add($btnDeleteAll) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnDeleteAll, "Delete all FFlags from the list")
$toolbarOuter.Children.Add((New-ToolbarSeparator)) | Out-Null
$btnCopyAll = New-ThemedButton -Content "Copy All" -Glyph ([char]0xE8C8) -ToolbarStyle
$btnCopyAll.AddClick({
try { Editor-CopyAll } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnCopyAll) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnCopyAll, "Copy all FFlags to clipboard as JSON")
$btnExport = New-ThemedButton -Content "Export List" -Glyph ([char]0xE896) -ToolbarStyle
$btnExport.AddClick({
try { Editor-ExportJson } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnExport) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnExport, "Export all FFlags to a .json file")
$toolbarOuter.Children.Add((New-ToolbarSeparator)) | Out-Null
$btnProfiles = New-ThemedButton -Content "Profiles" -Glyph ([char]0xE70F) -ToolbarStyle
$btnProfiles.AddClick({
param($argumentList, $s, $e)
$__profileClickT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:Profiles] toolbar click' -Level 'INFO'
$flyout = Profile-NewFlyout
Write-ConsoleLog -Message ('[editor-menu:Profiles] build-returned=' + [int]([datetime]::UtcNow - $__profileClickT0).TotalMilliseconds + 'ms') -Level 'INFO'
$flyout.ShowAt($s)
Write-ConsoleLog -Message ('[editor-menu:Profiles] ShowAt-returned=' + [int]([datetime]::UtcNow - $__profileClickT0).TotalMilliseconds + 'ms') -Level 'INFO'
})
$toolbarOuter.Children.Add($btnProfiles) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnProfiles, "Save, load, or merge FFlag profiles")
$btnAdvanced = New-ThemedButton -Content "Settings" -Glyph ([char]0xE713) -ToolbarStyle
$btnAdvanced.AddClick({
try { Editor-AdvancedSettings } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnAdvanced) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnAdvanced, "Open advanced settings")
$btnCleanList = New-ThemedButton -Content "Clean List" -Glyph ([char]0xE90F) -ToolbarStyle
$btnCleanList.AddClick({
try { Editor-CleanList } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnCleanList) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnCleanList, "Remove empty, duplicate, or invalid FFlags")
$btnBrowser = New-ThemedButton -Content "FFlag Browser" -Glyph ([char]0xE774) -ToolbarStyle
$btnBrowser.AddClick({
try { Editor-ToggleBrowser } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$toolbarOuter.Children.Add($btnBrowser) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnBrowser, "Browse all known Roblox FFlags and add them")
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($toolbarOuter, 0)
$toolbarScrollViewer = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollViewer]::new()
$toolbarScrollViewer.HorizontalScrollBarVisibility = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollBarVisibility]::Auto
$toolbarScrollViewer.VerticalScrollBarVisibility = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollBarVisibility]::Disabled
$toolbarScrollViewer.Content = $toolbarOuter
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($toolbarScrollViewer, 0)
$toolbarGrid.Children.Add($toolbarScrollViewer) | Out-Null
$flagCountText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
Set-SafeFontFamily -Target $flagCountText -Family $script:AppFontFamily
$flagCountText.FontSize = 12
$flagCountText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$flagCountText.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$flagCountText.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$flagCountText.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 0, 0, 0)
$flagCountText.Text = "Total Flags: $($script:Flags.Count)"
$script:EditorFlagCountText = $flagCountText
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($flagCountText, 1)
$toolbarGrid.Children.Add($flagCountText) | Out-Null
$root.Children.Add($toolbarGrid) | Out-Null
$searchPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$searchPanel.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 4, 12, 4)
$searchPanel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($searchPanel, 3)
$searchBox = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBox]::new()
$searchBox.PlaceholderText = "Search FFlags..."
Set-SafeFontFamily -Target $searchBox -Family $script:AppFontFamily
$searchBox.FontSize = 13
$searchBox.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$searchBox.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$searchBox.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(32, 6, 6, 6)
Set-ThemedTextBoxResources -Control $searchBox
$script:EditorSearchBox = $searchBox
$searchBox.AddTextChanged({
param($argumentList, $s, $e)
$script:EditorCurrentSearch = $s.Text
Editor-ResetSearchDebounce
})
$searchContainer = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$searchIcon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$searchIcon.Glyph = [char]0xE721
Set-SafeFontFamily -Target $searchIcon -Family $script:IconFontFamily
$searchIcon.FontSize = 14
$searchIcon.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$searchIcon.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$searchIcon.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$searchIcon.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(10, 0, 0, 0)
$searchIcon.IsHitTestVisible = $false
$searchContainer.Children.Add($searchBox) | Out-Null
$searchContainer.Children.Add($searchIcon) | Out-Null
$searchPanel.Children.Add($searchContainer) | Out-Null
$root.Children.Add($searchPanel) | Out-Null
$tableHeaderBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$tableHeaderBorder.Background = New-SolidBrush -Hex $script:ThemeColors.TableHeader
$tableHeaderBorder.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 0)
$tableHeaderBorder.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4, 6, 4, 6)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($tableHeaderBorder, 4)
$root.Children.Add($tableHeaderBorder) | Out-Null
$tableHeaderGrid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$thColPin = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$thColPin.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(24, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Pixel)
$thColName = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$thColName.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(3, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$thColValue = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$thColValue.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$tableHeaderGrid.ColumnDefinitions.Add($thColPin) | Out-Null
$tableHeaderGrid.ColumnDefinitions.Add($thColName) | Out-Null
$tableHeaderGrid.ColumnDefinitions.Add($thColValue) | Out-Null
$thName = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$thName.Text = "Name ▲"
Set-SafeFontFamily -Target $thName -Family $script:AppFontFamily
$thName.FontSize = 13
$thName.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$thName.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($thName, 1)
$tableHeaderGrid.Children.Add($thName) | Out-Null
$script:EditorThName = $thName
$thValue = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$thValue.Text = "Value"
Set-SafeFontFamily -Target $thValue -Family $script:AppFontFamily
$thValue.FontSize = 13
$thValue.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$thValue.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($thValue, 2)
$tableHeaderGrid.Children.Add($thValue) | Out-Null
$script:EditorThValue = $thValue
try {
$thName.AddTapped({
param($argumentList, $s, $e)
try {
if ($script:EditorSortColumn -eq "Name") {
$script:EditorSortDirection = if ($script:EditorSortDirection -eq "Ascending") { "Descending" } else { "Ascending" }
} else {
$script:EditorSortColumn = "Name"
$script:EditorSortDirection = "Ascending"
}
$arrow = if ($script:EditorSortDirection -eq "Ascending") { "▲" } else { "▼" }
$script:EditorThName.Text = "Name $arrow"
$script:EditorThValue.Text = "Value"
Editor-RefreshFlagList
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$thValue.AddTapped({
param($argumentList, $s, $e)
try {
if ($script:EditorSortColumn -eq "Value") {
$script:EditorSortDirection = if ($script:EditorSortDirection -eq "Ascending") { "Descending" } else { "Ascending" }
} else {
$script:EditorSortColumn = "Value"
$script:EditorSortDirection = "Ascending"
}
$arrow = if ($script:EditorSortDirection -eq "Ascending") { "▲" } else { "▼" }
$script:EditorThValue.Text = "Value $arrow"
$script:EditorThName.Text = "Name"
Editor-RefreshFlagList
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$tableHeaderBorder.Child = $tableHeaderGrid
$tableBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$tableBorder.BorderBrush = New-SolidBrush -Hex $script:ThemeColors.Dividers
$tableBorder.BorderThickness = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 1, 0, 0)
$tableBorder.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 0)
$tableBorder.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($tableBorder, 5)
$root.Children.Add($tableBorder) | Out-Null
$flagListView = New-ThemedListView -FontSize 13
$flagListView.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$flagListView.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Stretch
$flagListView.SelectionMode = [WinUIShell.Microsoft.UI.Xaml.Controls.ListViewSelectionMode]::Extended
$script:EditorFlagListView = $flagListView
$flagListView.AddSelectionChanged({
param($argumentList, $s, $e)
try {
$script:EditorSelectionDirty = $true
$hasSelection = $s.SelectedRanges.Count -gt 0
if ($null -ne $script:EditorBtnDeleteSelected) {
$script:EditorBtnDeleteSelected.Foreground = if ($hasSelection) { New-SolidBrush -Hex $script:ThemeColors.Error } else { New-SolidBrush -Hex $script:ThemeColors.TextPrimary }
}
if ($null -ne $script:EditorBtnDeleteAll) {
$script:EditorBtnDeleteAll.Foreground = if ($hasSelection) { New-SolidBrush -Hex $script:ThemeColors.Error } else { New-SolidBrush -Hex $script:ThemeColors.TextPrimary }
}
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$flagListView.AddRightTapped({
param($argumentList, $s, $e)
try {
Editor-ResolveSelection
$flyout = [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyout]::new()
$selCount = $script:EditorSelectedNames.Count
$editItem = New-MenuFlyoutItem -Text "Edit" -Glyph ([char]0xE70F) -OnClick { Editor-EditSelected }
if ($selCount -ne 1) { $editItem.IsEnabled = $false }
$flyout.Items.Add($editItem) | Out-Null
$delText = if ($selCount -gt 0) { "Delete ($selCount selected)" } else { "Delete" }
$flyout.Items.Add((New-MenuFlyoutItem -Text $delText -Glyph ([char]0xE74D) -OnClick { Editor-DeleteSelected })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutSeparator)) | Out-Null
$flyout.Items.Add((New-MenuFlyoutItem -Text "Copy Name" -Glyph ([char]0xE8C8) -OnClick { Editor-CopySelectedNames })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutItem -Text "Copy Value" -Glyph ([char]0xE8C8) -OnClick { Editor-CopySelectedValues })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutItem -Text "Copy as JSON" -Glyph ([char]0xE8C8) -OnClick { Editor-CopySelectedAsJson })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutSeparator)) | Out-Null
$isPinned = $false
if ($selCount -ge 1) {
$isPinned = $true
foreach ($selName in $script:EditorSelectedNames) {
if ($script:Settings.pinnedFlags -notcontains $selName) { $isPinned = $false; break }
}
}
$pinText = if ($isPinned) { "Unpin from Top" } else { "Pin to Top" }
$pinGlyph = if ($isPinned) { [char]0xE77A } else { [char]0xE718 }
$flyout.Items.Add((New-MenuFlyoutItem -Text $pinText -Glyph $pinGlyph -OnClick { Editor-TogglePinSelected })) | Out-Null
try {
$pos = $e.GetPosition($s)
$opts = [WinUIShell.Microsoft.UI.Xaml.Controls.Primitives.FlyoutShowOptions]::new()
$opts.Position = [WinUIShell.Windows.Foundation.Point]::new($pos.X, $pos.Y)
$flyout.ShowAt($s, $opts)
} catch {
$flyout.ShowAt($s)
}
} catch { Write-ConsoleLog -Message "Error building context menu: $_" -Level "ERROR" }
})
try {
$flagListView.ItemContainerTransitions = [WinUIShell.Microsoft.UI.Xaml.Media.Animation.TransitionCollection]::new()
$flagListView.Transitions = [WinUIShell.Microsoft.UI.Xaml.Media.Animation.TransitionCollection]::new()
} catch { Write-ConsoleLog -Message "Could not clear item/entrance transitions: $_" -Level "WARN" }
$script:EditorTableBorder = $tableBorder
$tableBorder.Child = $flagListView
$consolePanel = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$consolePanel.BorderBrush = New-SolidBrush -Hex $script:ThemeColors.Dividers
$consolePanel.BorderThickness = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 1, 0, 0)
$consolePanel.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 12, 0)
$consolePanel.Background = New-SolidBrush -Hex $script:ThemeColors.ConsoleLogBg
$consolePanel.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0)
if ($script:Settings.consoleLogVisible) {
$consolePanel.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
} else {
$consolePanel.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
}
$consolePanel.Height = 120
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($consolePanel, 6)
$script:EditorConsolePanel = $consolePanel
$consoleInner = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$consoleInner.RowSpacing = 0
$rowConsoleHeader = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowConsoleHeader.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowConsoleList = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowConsoleList.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$consoleInner.RowDefinitions.Add($rowConsoleHeader) | Out-Null
$consoleInner.RowDefinitions.Add($rowConsoleList) | Out-Null
$consoleHeader = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$consoleHeader.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 4, 8, 4)
$consoleHeader.Background = New-SolidBrush -Hex $script:ThemeColors.Surface
$consoleHeader.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6, 6, 0, 0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($consoleHeader, 0)
$consoleHeaderLeft = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$consoleHeaderLeft.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$consoleHeaderLeft.Spacing = 8
$consoleHeaderLeft.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$consoleHeaderLeft.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$consoleTitle = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$consoleTitle.Text = "Console Log"
$consoleTitle.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
Set-SafeFontFamily -Target $consoleTitle -Family $script:AppFontFamily
$consoleTitle.FontSize = 11
$consoleTitle.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$consoleTitle.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$consoleHeaderLeft.Children.Add($consoleTitle) | Out-Null
$btnClearLog = New-ThemedButton -Content "Clear" -FontSize 11 -ToolbarStyle
$btnClearLog.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(6, 2, 6, 2)
$btnClearLog.AddClick({ try { Clear-ConsoleLog } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" } })
$consoleHeaderLeft.Children.Add($btnClearLog) | Out-Null
$btnCopyLog = New-ThemedButton -Content "Copy" -FontSize 11 -ToolbarStyle
$btnCopyLog.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(6, 2, 6, 2)
$btnCopyLog.AddClick({ try { Copy-ConsoleLog; Write-ConsoleLog -Message "Log copied to clipboard." -Level "INFO" } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" } })
$consoleHeaderLeft.Children.Add($btnCopyLog) | Out-Null
$consoleHeader.Children.Add($consoleHeaderLeft) | Out-Null
$dragPill = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$dragPill.Width = 40
$dragPill.Height = 4
$dragPill.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(2)
$dragPill.Background = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$dragPill.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$dragPill.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Top
$dragPill.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 2, 0, 0)
$dragPill.Opacity = 0.5
$dragPill.IsHitTestVisible = $true
$consoleHeader.Children.Add($dragPill) | Out-Null
$script:ConsoleDragPill = $dragPill
$consoleHeader.ManipulationMode = 'TranslateY'
$script:ConsoleDragActive = $false
$script:ConsoleDragStartH = 120
$script:ConsoleDragMaxH = 450
$msCallback = [WinUIShell.EventCallback]::new()
$msCallback.RunspaceMode = [WinUIShell.EventCallbackRunspaceMode]::MainRunspaceSyncUI
$msCallback.ScriptBlock = {
param($argumentList, $s, $e)
$script:ConsoleDragActive = $true
$startH = [double]$script:EditorConsolePanel.Height
if ([double]::IsNaN($startH) -or [double]::IsInfinity($startH)) { $startH = 120 }
$script:ConsoleDragStartH = $startH
$maxH = 450
try {
$rootH = $script:EditorWindow.Content.ActualHeight
if ($rootH -gt 0) { $maxH = $rootH - 330; if ($maxH -lt 100) { $maxH = 100 } }
} catch {}
$script:ConsoleDragMaxH = $maxH
$script:ConsoleDragPill.Opacity = 1.0
}
$consoleHeader.AddManipulationStarted($msCallback)
$mdCallback = [WinUIShell.EventCallback]::new()
$mdCallback.RunspaceMode = [WinUIShell.EventCallbackRunspaceMode]::MainRunspaceSyncUI
$mdCallback.ScriptBlock = {
param($argumentList, $s, $e)
$cumY = $e.Cumulative.Translation.Y
$newH = $script:ConsoleDragStartH - $cumY
if ($newH -lt 31) { $newH = 31 }
if ($newH -le 31) {
try { if ($null -ne $script:EditorConsoleTextBox) { $script:EditorConsoleTextBox.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed } } catch {}
try { if ($null -ne $script:EditorConsoleRichTextBlock) { $script:EditorConsoleRichTextBlock.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed } } catch {}
try { if ($null -ne $script:EditorConsoleScrollViewer) { $script:EditorConsoleScrollViewer.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed } } catch {}
} else {
try { if ($null -ne $script:EditorConsoleTextBox) { $script:EditorConsoleTextBox.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible } } catch {}
try { if ($null -ne $script:EditorConsoleRichTextBlock) { $script:EditorConsoleRichTextBlock.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible } } catch {}
try { if ($null -ne $script:EditorConsoleScrollViewer) { $script:EditorConsoleScrollViewer.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible } } catch {}
}
if ($newH -gt $script:ConsoleDragMaxH) { $newH = $script:ConsoleDragMaxH }
$script:EditorConsolePanel.Height = $newH
}
$consoleHeader.AddManipulationDelta($mdCallback)
$mcCallback = [WinUIShell.EventCallback]::new()
$mcCallback.RunspaceMode = [WinUIShell.EventCallbackRunspaceMode]::MainRunspaceSyncUI
$mcCallback.ScriptBlock = {
param($argumentList, $s, $e)
$script:ConsoleDragActive = $false
$script:ConsoleDragPill.Opacity = 0.5
}
$consoleHeader.AddManipulationCompleted($mcCallback)
$peCallback = [WinUIShell.EventCallback]::new()
$peCallback.RunspaceMode = [WinUIShell.EventCallbackRunspaceMode]::MainRunspaceSyncUI
$peCallback.ScriptBlock = {
param($argumentList, $s, $e)
try { if (-not $script:ConsoleDragActive) { $script:ConsoleDragPill.Opacity = 0.8 } } catch {}
}
$consoleHeader.AddPointerEntered($peCallback)
$pxCallback = [WinUIShell.EventCallback]::new()
$pxCallback.RunspaceMode = [WinUIShell.EventCallbackRunspaceMode]::MainRunspaceSyncUI
$pxCallback.ScriptBlock = {
param($argumentList, $s, $e)
try { if (-not $script:ConsoleDragActive) { $script:ConsoleDragPill.Opacity = 0.5 } } catch {}
}
$consoleHeader.AddPointerExited($pxCallback)
$consoleInner.Children.Add($consoleHeader) | Out-Null
$script:ConsoleLogUseRichTextBlock = $false
try {
$richTextBlock = [WinUIShell.Microsoft.UI.Xaml.Controls.RichTextBlock]::new()
$richTextBlock.IsTextSelectionEnabled = $true
$richTextBlock.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Cascadia Code, Consolas, monospace")
$richTextBlock.FontSize = 11
$richTextBlock.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 4, 8, 4)
$richTextBlock.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::NoWrap
$testPara = [WinUIShell.Microsoft.UI.Xaml.Documents.Paragraph]::new()
$testRun = [WinUIShell.Microsoft.UI.Xaml.Documents.Run]::new()
$testRun.Text = "probe"
$testPara.Inlines.Add($testRun)
$richTextBlock.Blocks.Add($testPara)
$richTextBlock.Blocks.Clear()
$consoleScrollViewer = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollViewer]::new()
$consoleScrollViewer.Content = $richTextBlock
$consoleScrollViewer.VerticalScrollBarVisibility = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollBarVisibility]::Auto
$consoleScrollViewer.HorizontalScrollBarVisibility = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollBarVisibility]::Auto
$consoleScrollViewer.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new([WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0))
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($consoleScrollViewer, 1)
$script:EditorConsoleRichTextBlock = $richTextBlock
$script:EditorConsoleScrollViewer = $consoleScrollViewer
$script:EditorConsoleTextBox = $null
$script:ConsoleLogUseRichTextBlock = $true
$consoleInner.Children.Add($consoleScrollViewer) | Out-Null
} catch {
$script:ConsoleLogUseRichTextBlock = $false
$script:EditorConsoleRichTextBlock = $null
$script:EditorConsoleScrollViewer = $null
$consoleTextBox = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBox]::new()
$consoleTextBox.AcceptsReturn = $true
$consoleTextBox.IsReadOnly = $true
$consoleTextBox.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::NoWrap
$consoleTextBox.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Cascadia Code, Consolas, monospace")
$consoleTextBox.FontSize = 11
$consoleTextBox.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$consoleTextBox.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new([WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0))
$consoleTextBox.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 4, 8, 4)
$consoleTextBox.BorderThickness = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0)
try {
$consoleBgBrush = New-SolidBrush -Hex $script:ThemeColors.ConsoleLogBg
$transparentBrush = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new([WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0))
$consoleTextBox.Resources["TextControlBackground"] = $consoleBgBrush
$consoleTextBox.Resources["TextControlBackgroundPointerOver"] = $consoleBgBrush
$consoleTextBox.Resources["TextControlBackgroundFocused"] = $consoleBgBrush
$consoleTextBox.Resources["TextControlBorderBrush"] = $transparentBrush
$consoleTextBox.Resources["TextControlBorderBrushPointerOver"] = $transparentBrush
$consoleTextBox.Resources["TextControlBorderBrushFocused"] = $transparentBrush
} catch {}
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($consoleTextBox, 1)
$script:EditorConsoleTextBox = $consoleTextBox
$consoleInner.Children.Add($consoleTextBox) | Out-Null
}
$script:EditorConsoleListView = $null
$script:EditorConsoleStack = $null
$script:EditorConsoleScroll = $null
$consolePanel.Child = $consoleInner
$root.Children.Add($consolePanel) | Out-Null
Start-ConsoleFlushTimer
Update-ConsoleLogDisplay
$emptyStateText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$emptyStateText.Text = "No FFlags configured. Click 'Add New' to get started."
Set-SafeFontFamily -Target $emptyStateText -Family $script:AppFontFamily
$emptyStateText.FontSize = 14
$emptyStateText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$emptyStateText.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$emptyStateText.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$emptyStateText.Opacity = 0.6
Set-ControlVisible -Control $emptyStateText -IsVisible $false
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($emptyStateText, 5)
$root.Children.Add($emptyStateText) | Out-Null
$script:EditorEmptyStateText = $emptyStateText
$bottomBar = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$bottomBar.BorderBrush = New-SolidBrush -Hex $script:ThemeColors.Dividers
$bottomBar.BorderThickness = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 1, 0, 0)
$bottomBar.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 8, 12, 8)
$bottomBar.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($bottomBar, 7)
$bottomPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$bottomPanel.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$bottomPanel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$bottomPanel.Spacing = 8
$script:ApplyEditorFFlagsToMemory = {
$memStats = @{
Applied = 0; Missing = 0; Failed = 0; MissingNames = @()
Total = 0; WasCache = 'None'
}
if (-not ($script:Flags -is [hashtable]) -or $script:Flags.Count -eq 0) {
return $memStats
}
$memStats.Total = $script:Flags.Count
try {
try {
$currentPid = 0
$currProc = Get-Process -Name 'RobloxPlayerBeta' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -ne $currProc) { $currentPid = [int]$currProc.Id }
if ($null -eq $script:LastRobloxPid) { $script:LastRobloxPid = 0 }
if ($currentPid -ne 0 -and $currentPid -ne $script:LastRobloxPid) {
if ($null -ne $script:EditorFlagStatus) { $script:EditorFlagStatus.Clear() }
if ($null -ne $script:EditorFlagAppliedValue) { $script:EditorFlagAppliedValue.Clear() }
Write-ConsoleLog -Message ('Apply: Roblox pid changed (' + $script:LastRobloxPid + ' -> ' + $currentPid + '); color state reset.') -Level 'INFO'
$script:LastRobloxPid = $currentPid
} elseif ($currentPid -ne 0 -and $script:LastRobloxPid -eq 0) {
$script:LastRobloxPid = $currentPid
}
} catch { }
$robloxRunning = $false
try { $robloxRunning = Test-RobloxRunning } catch { $robloxRunning = $false }
if (-not $robloxRunning) {
if ($null -ne $script:EditorFlagStatus) { $script:EditorFlagStatus.Clear() }
if ($null -ne $script:EditorFlagAppliedValue) { $script:EditorFlagAppliedValue.Clear() }
$memStats.WasCache = 'NoProcess'
return $memStats
}
$cacheHasEntries = ($null -ne $script:LastFvmDump) -and ($script:LastFvmDump.Flags -is [hashtable]) -and ($script:LastFvmDump.Flags.Count -gt 0)
if (-not $cacheHasEntries) {
Write-ConsoleLog -Message 'Apply: no local dump found. Priming fvm cache from external offsets (imtheo)...' -Level 'INFO'
$primeResult = Initialize-AlliumFvmFromExternalOffsets
if ($primeResult.Success) {
Write-ConsoleLog -Message ('External offsets primed: ' + $primeResult.EntryCount + ' flags (Version=' + $primeResult.Version + ')') -Level 'INFO'
$memStats.WasCache = 'External'
if ($primeResult.VersionMismatch) {
Write-ConsoleLog -Message ('External offsets version (' + $primeResult.Version + ') differs from live Roblox version; RVAs may be stale.') -Level 'WARN'
}
} else {
Write-ConsoleLog -Message ('External offsets prime failed: ' + $primeResult.Error + '. Memory writes will report Missing for all flags.') -Level 'WARN'
$memStats.WasCache = 'None'
}
} else {
if ($null -ne $script:LastFvmDump -and $script:LastFvmDump.ContainsKey('IsFromExternal') -and [bool]$script:LastFvmDump.IsFromExternal) {
$memStats.WasCache = 'External'
} else {
$memStats.WasCache = 'Live'
}
}
$debugOn = $false
try { $debugOn = [bool]$script:Settings['debugLogging'] } catch { $debugOn = $false }
$__debugBuf = $null
if ($debugOn) {
try { $__debugBuf = [System.Collections.Generic.List[string]]::new() }
catch { $__debugBuf = $null }
}
$__batchResults = @{}
try { $__batchResults = Set-AlliumFlagValueBatch -Flags $script:Flags } catch { $__batchResults = @{} }
$__knownFlagSet = @{}
$__canValidate = $false
$__addKnown = {
param($n)
if ([string]::IsNullOrWhiteSpace([string]$n)) { return }
$__ln = ([string]$n).ToLower()
$__knownFlagSet[$__ln] = $true
if ($__ln -match '^(d?f|sf)(flag|int|string|log)(.+)$') { $__knownFlagSet[$Matches[3]] = $true }
}
try {
if ($null -ne $script:LastFvmDump -and $script:LastFvmDump.Flags -is [hashtable] -and $script:LastFvmDump.Flags.Count -gt 0) {
foreach ($__k in @($script:LastFvmDump.Flags.Keys)) {
if ($null -eq $__k) { continue }
& $__addKnown $__k
$__e = $script:LastFvmDump.Flags[$__k]
$__rn = $null
try { $__rn = $__e.RawName } catch { $__rn = $null }
& $__addKnown $__rn
}
$__canValidate = $true
}
} catch { }
if (-not $__canValidate) {
try {
if ($null -ne $script:FlagBrowserCache -and $script:FlagBrowserCache.Count -gt 0) {
foreach ($__k in @($script:FlagBrowserCache.Keys)) { & $__addKnown $__k }
if ($null -ne $script:BrowserRawNameMap) {
foreach ($__rk in @($script:BrowserRawNameMap.Keys)) { & $__addKnown $__rk }
}
$__canValidate = $true
}
} catch { }
}
$__unvalidatedShown = $false
foreach ($name in @($script:Flags.Keys)) {
$val = $script:Flags[$name]
$wr = $null
$wrExc = $null
if ($__batchResults.ContainsKey($name)) {
$wr = $__batchResults[$name]
} else {
try { $wr = Set-AlliumFlagValue -Name $name -Value $val -Force -Quiet } catch { $wr = $null; $wrExc = $_.Exception.Message }
}
$branch = ''
if ($null -eq $wr) {
$script:EditorFlagStatus[$name] = 'Failed'; $memStats.Failed++; $branch = '1-null'
} elseif ($null -ne $wr.Type -and $wr.Type -eq 'MemoryDisabled') {
if (-not $__canValidate) {
$script:EditorFlagStatus.Remove($name)
$branch = '2m-noval'
if (-not $__unvalidatedShown) {
Write-ConsoleLog -Message 'Apply: cannot validate flag names (no FFlag map loaded). Open the FFlag Browser once, or run an FFlag dump in Settings, to enable green/red validation.' -Level 'WARN'
$__unvalidatedShown = $true
}
} else {
$__raw = if ($name -match '^(D?F|SF)(Flag|Int|String|Log)(.+)$') { $Matches[3] } else { $name }
if ($__knownFlagSet.ContainsKey($name.ToLower()) -or $__knownFlagSet.ContainsKey($__raw.ToLower())) {
$script:EditorFlagStatus[$name] = 'Applied'; $script:EditorFlagAppliedValue[$name] = [string]$val; $memStats.Applied++; $branch = '2m-known'
} else {
$script:EditorFlagStatus[$name] = 'Missing'; $memStats.Missing++; $branch = '2m-unknown'
if ($memStats.MissingNames.Count -lt 32) { $memStats.MissingNames += $name }
}
}
} elseif ($wr.Success) {
$script:EditorFlagStatus[$name] = 'Applied'; $script:EditorFlagAppliedValue[$name] = [string]$val; $memStats.Applied++; $branch = '2-success'
} elseif ($null -ne $wr.Type -and $wr.Type -eq 'String') {
$script:EditorFlagStatus[$name] = 'Applied'; $script:EditorFlagAppliedValue[$name] = [string]$val; $memStats.Applied++; $branch = '3-string-type'
} elseif ($null -ne $wr.Type -and $wr.Type -eq 'TypeMismatch') {
$script:EditorFlagStatus[$name] = 'Failed'; $memStats.Failed++; $branch = '4a-typemismatch'
} elseif ($null -ne $wr.Type -and $wr.Type -eq 'NotFound') {
$script:EditorFlagStatus[$name] = 'Missing'; $memStats.Missing++; $branch = '4-missing'
if ($memStats.MissingNames.Count -lt 32) { $memStats.MissingNames += $name }
} elseif ($null -ne $wr.Error -and ($wr.Error -match 'Flag not found|Flag lookup failed|dump returned no flags')) {
$script:EditorFlagStatus[$name] = 'Missing'; $memStats.Missing++; $branch = '4b-missing-legacy'
if ($memStats.MissingNames.Count -lt 32) { $memStats.MissingNames += $name }
} elseif ($null -ne $wr.Rva -and ($wr.Rva -eq 'inline-sso' -or $wr.Rva -like 'unknown*' -or $wr.Rva -like 'out-of-*')) {
$script:EditorFlagStatus[$name] = 'Applied'; $script:EditorFlagAppliedValue[$name] = [string]$val; $memStats.Applied++; $branch = '5-inline-sso'
} else {
$script:EditorFlagStatus[$name] = 'Failed'; $memStats.Failed++; $branch = '6-other'
}
if ($debugOn) {
$wrSuccess = if ($null -ne $wr) { [string]$wr.Success } else { '<null>' }
$wrType = if ($null -ne $wr -and $null -ne $wr.Type) { [string]$wr.Type } else { '<none>' }
$wrRva = if ($null -ne $wr -and $null -ne $wr.Rva) { [string]$wr.Rva } else { '<none>' }
$wrError = if ($null -ne $wr -and $null -ne $wr.Error) { ([string]$wr.Error).Substring(0, [Math]::Min(60, ([string]$wr.Error).Length)) } else { '<none>' }
$wrExcStr = if ($null -ne $wrExc) { [string]$wrExc } else { '<none>' }
if ($null -ne $__debugBuf) {
$__debugBuf.Add('  [apply-debug] ' + $name + ' -> branch=' + $branch + ' Success=' + $wrSuccess + ' Type=' + $wrType + ' Rva=' + $wrRva + ' Error=' + $wrError + ' Exception=' + $wrExcStr) | Out-Null
}
}
}
if ($null -ne $__debugBuf -and $__debugBuf.Count -gt 0) {
$__joined = $__debugBuf -join [System.Environment]::NewLine
Write-ConsoleLog -Message ("[apply-debug] " + $__debugBuf.Count + " flag(s):" + [System.Environment]::NewLine + $__joined) -Level 'INFO'
}
return $memStats
} catch {
$__exMsg = $_.Exception.Message
$__exType = $_.Exception.GetType().FullName
$__stackTrace = ''
try { $__stackTrace = $_.ScriptStackTrace } catch { }
try {
Write-ConsoleLog -Message ('[apply-wrap] UNCAUGHT: ' + $__exType + ': ' + $__exMsg) -Level 'ERROR'
if (-not [string]::IsNullOrEmpty($__stackTrace)) {
Write-ConsoleLog -Message ('[apply-wrap] stack: ' + $__stackTrace) -Level 'ERROR'
}
} catch { }
$memStats.WasCache = 'Error: ' + $__exMsg
return $memStats
}
}
$btnApply = New-ThemedButton -Content "Apply Now" -FontSize 14
$btnApply.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$btnApply.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$btnApply.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnApply.AddClick({
param($argumentList, $s, $e)
try {
$xr = $null
try { $xr = $s.XamlRoot } catch { }
if ($null -eq $xr) { try { $xr = $script:EditorWindow.Content.XamlRoot } catch { } }
$script:LastApplyResult = $null
$script:LastApplyJsonOk = $false
Invoke-AlliumDumperAsync -Title 'Applying FFlags' -Message 'Saving and applying your changes...' -XamlRoot $xr -Work {
Save-Flags
$script:LastApplyJsonOk = Write-ClientAppSettings
if ($null -eq $script:LastFvmDump -or -not ($script:LastFvmDump.Flags -is [hashtable]) -or $script:LastFvmDump.Flags.Count -eq 0) {
Write-ConsoleLog -Message 'Apply: no cached FFlag map. Priming with a fresh dump (~12s).' -Level 'INFO'
}
$script:LastApplyResult = & $script:ApplyEditorFFlagsToMemory
} -OnComplete {
param($result)
try { Editor-RefreshFlagList } catch { Write-ConsoleLog -Message "Refresh after Apply failed: $_" -Level "WARN" }
$r = $script:LastApplyResult
$ok = $script:LastApplyJsonOk
if ($null -eq $r) {
Write-ConsoleLog -Message 'Apply produced no result (Work scriptblock crashed or returned null); see earlier "Dumper work failed" error for details.' -Level 'ERROR'
$r = @{ Applied = 0; Missing = 0; Failed = 0; MissingNames = @() }
}
if ($r.Missing -gt 0 -or $r.Failed -gt 0) {
$summary = 'Apply summary: applied=' + $r.Applied + ' missing=' + $r.Missing + ' failed=' + $r.Failed + ' (source=' + $r.WasCache + ')'
Write-ConsoleLog -Message $summary -Level 'WARN'
if ($r.MissingNames.Count -gt 0) {
$preview = $r.MissingNames -join ', '
if ($r.Missing -gt $r.MissingNames.Count) { $preview = $preview + ' (+' + ($r.Missing - $r.MissingNames.Count) + ' more)' }
Write-ConsoleLog -Message ('Missing flags (not in Roblox FFlag map): ' + $preview) -Level 'WARN'
}
}
if ($r.WasCache -eq 'External' -and $r.Total -gt 0) {
$missRatio = $r.Missing / [double]$r.Total
$missPct = ('{0:P1}' -f $missRatio)
Write-ConsoleLog -Message ('Apply diagnostic: source=External missing/total = ' + $r.Missing + '/' + $r.Total + ' (' + $missPct + ', stale-offsets popup threshold 90.0%)') -Level 'INFO'
}
if ($r.Total -gt 0 -and ($r.Missing / [double]$r.Total) -ge 0.9) {
try {
$xr2 = $null
try { $xr2 = $script:EditorWindow.Content.XamlRoot } catch { }
$dlgTitle = if ($r.WasCache -eq 'External') { 'External offsets look stale' } else { 'Most flags not found in live Roblox' }
$dlgContent = if ($r.WasCache -eq 'External') {
'Only ' + $r.Applied + ' of ' + $r.Total + " flags matched the external offset source (imtheo). This usually means the offsets don't line up with your live Roblox version. Would you like to run a local FFlag dump to refresh?"
} else {
'Only ' + $r.Applied + ' of ' + $r.Total + " flags were found in the live Roblox FFlag map. Check that the flag names are correct, or try re-dumping FFlags from Settings if Roblox was updated recently."
}
$dlgResult = Show-CustomDialog -XamlRoot $xr2 -Title $dlgTitle -Content $dlgContent -PrimaryButtonText 'Open Settings' -CloseButtonText 'Not now'
if ($dlgResult -eq 'Primary') {
Write-ConsoleLog -Message 'User accepted stale-flags suggestion; opening Settings...' -Level 'INFO'
try { Show-SettingsWindow } catch { Write-ConsoleLog -Message ('Show-SettingsWindow failed: ' + $_.Exception.Message) -Level 'WARN' }
}
} catch { Write-ConsoleLog -Message ('Stale-flags popup failed: ' + $_.Exception.Message) -Level 'WARN' }
}
if ($ok) {
Show-EditorNotification -Title "FFlags applied!" -Message ("Applied " + $r.Applied + " of " + $r.Total + "; " + $r.Missing + " missing; " + $r.Failed + " failed.")
} else {
Write-ConsoleLog -Message "Failed to write ClientAppSettings.json" -Level "ERROR"
}
}
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$bottomPanel.Children.Add($btnApply) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnApply, "Write FFlags to Roblox")
$btnSaveLaunch = New-ThemedButton -Content "Save and Launch" -FontSize 14
$btnSaveLaunch.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$btnSaveLaunch.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$btnSaveLaunch.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnSaveLaunch.AddClick({
param($argumentList, $s, $e)
try {
$xr = $null
try { $xr = $s.XamlRoot } catch { }
if ($null -eq $xr) { try { $xr = $script:EditorWindow.Content.XamlRoot } catch { } }
$robloxRunning = $false
try { $robloxRunning = Test-RobloxRunning } catch { $robloxRunning = $false }
$warnEnabled = $true
if ($null -ne $script:Settings -and $script:Settings.ContainsKey('warnIfRobloxRunning')) {
$warnEnabled = [bool]$script:Settings['warnIfRobloxRunning']
}
$multiInstanceOn = $false
if ($null -ne $script:Settings -and $script:Settings.ContainsKey('robloxMultiInstance')) {
$multiInstanceOn = [bool]$script:Settings['robloxMultiInstance']
}
if ($robloxRunning -and $warnEnabled -and -not $multiInstanceOn) {
$confirmResult = Show-CustomDialog -XamlRoot $xr -Title 'Roblox is already running' -Content 'A RobloxPlayerBeta process is already active. Clicking Relaunch will close the existing Roblox instance, then launch a fresh one with your FFlags saved to ClientAppSettings.json. Continue?' -PrimaryButtonText 'Relaunch' -CloseButtonText 'Cancel'
if ($confirmResult -ne 'Primary') {
Write-ConsoleLog -Message 'Save and Launch canceled by user (Roblox already running).' -Level 'INFO'
return
}
try {
$procs = @(Get-Process -Name 'RobloxPlayerBeta' -ErrorAction SilentlyContinue)
if ($procs.Count -gt 0) {
Write-ConsoleLog -Message ('Killing ' + $procs.Count + ' running RobloxPlayerBeta process(es) before relaunch...') -Level 'INFO'
foreach ($p in $procs) {
try { Stop-Process -Id $p.Id -Force -ErrorAction Stop } catch { Write-ConsoleLog -Message ('Stop-Process failed for pid ' + $p.Id + ': ' + $_.Exception.Message) -Level 'WARN' }
}
Start-Sleep -Milliseconds 500
}
} catch { Write-ConsoleLog -Message ('Roblox kill step failed: ' + $_.Exception.Message) -Level 'WARN' }
}
$script:LastApplyResult = $null
$script:LastApplyJsonOk = $false
Invoke-AlliumDumperAsync -Title 'Save and Launch' -Message 'Writing FFlags, then launching Roblox...' -XamlRoot $xr -Work {
Save-Flags
$script:LastApplyJsonOk = Write-ClientAppSettings
if ($null -eq $script:LastFvmDump -or -not ($script:LastFvmDump.Flags -is [hashtable]) -or $script:LastFvmDump.Flags.Count -eq 0) {
Write-ConsoleLog -Message 'Save and Launch: no cached FFlag map. Priming with a fresh dump.' -Level 'INFO'
}
$script:LastApplyResult = & $script:ApplyEditorFFlagsToMemory
} -OnComplete {
param($result)
try { Editor-RefreshFlagList } catch { }
$r = $script:LastApplyResult
if ($null -eq $r) { $r = @{ Applied = 0; Missing = 0; Failed = 0; MissingNames = @() } }
if ($r.Missing -gt 0 -or $r.Failed -gt 0) {
Write-ConsoleLog -Message ('Save and Launch apply summary: applied=' + $r.Applied + ' missing=' + $r.Missing + ' failed=' + $r.Failed) -Level 'WARN'
if ($r.MissingNames.Count -gt 0) {
$preview = $r.MissingNames -join ', '
if ($r.Missing -gt $r.MissingNames.Count) { $preview = $preview + ' (+' + ($r.Missing - $r.MissingNames.Count) + ' more)' }
Write-ConsoleLog -Message ('Missing flags (not in live Roblox map): ' + $preview) -Level 'WARN'
}
}
if ($script:LastApplyJsonOk) {
if ($null -ne $script:EditorFlagStatus) { $script:EditorFlagStatus.Clear() }
if ($null -ne $script:EditorFlagAppliedValue) { $script:EditorFlagAppliedValue.Clear() }
try { Editor-RefreshFlagList } catch { }
Write-ConsoleLog -Message "FFlags applied to memory + ClientAppSettings.json. Launching..." -Level "INFO"
Show-EditorNotification -Title "Saved!" -Message "Settings and FFlags saved. Launching Roblox..."
try { Invoke-LaunchRoblox } catch { Write-ConsoleLog -Message "Launch failed: $_" -Level "ERROR" }
} else {
Write-ConsoleLog -Message "Failed to write ClientAppSettings.json" -Level "ERROR"
}
}
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$bottomPanel.Children.Add($btnSaveLaunch) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnSaveLaunch, "Save FFlags, apply, and launch Roblox")
$btnSave = New-ThemedButton -Content "Save" -FontSize 14
$btnSave.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$btnSave.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$btnSave.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnSave.AddClick({
try {
Save-Flags
Write-ConsoleLog -Message "FFlags saved to flags.json" -Level "INFO"
Show-EditorNotification -Title "Saved!" -Message "Settings and FFlags saved to disk."
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$bottomPanel.Children.Add($btnSave) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnSave, "Save Settings and FFlags to disk")
$btnClose = New-ThemedButton -Content "Close" -FontSize 14
$btnClose.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$btnClose.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$btnClose.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$btnClose.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnClose.AddClick({
try { if ($null -ne $script:EditorWindow) { $script:EditorWindow.Close() } } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$bottomPanel.Children.Add($btnClose) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.ToolTipService]::SetToolTip($btnClose, "Close the FFlag Editor")
$bottomBar.Child = $bottomPanel
$root.Children.Add($bottomBar) | Out-Null
Editor-RefreshFlagList
Editor-InstallDropTarget -RootGrid $script:EditorWindow.Content
Editor-InstallKeyboardShortcuts
Write-ConsoleLog -Message "FFlag Editor opened." -Level "INFO"
}
function New-ToolbarSeparator {
$sep = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$sep.Width = 1
$sep.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4, 4, 4, 4)
$sep.Background = New-SolidBrush -Hex $script:ThemeColors.Dividers
$sep.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Stretch
return $sep
}
function Editor-InstallDropTarget {
param([Parameter(Mandatory)] [object]$RootGrid)
if ($null -eq $RootGrid) { return }
try {
$RootGrid.AllowDrop = $true
$dragOverCallback = [WinUIShell.EventCallback]::new()
$dragOverCallback.RunspaceMode = [WinUIShell.EventCallbackRunspaceMode]::MainRunspaceSyncUI
$dragOverCallback.ScriptBlock = {
param($argumentList, $s, $e)
try {
$e.AcceptedOperation = [WinUIShell.Windows.ApplicationModel.DataTransfer.DataPackageOperation]::Copy
} catch {
try { $e.AcceptedOperation = 1 } catch {}
}
}
$RootGrid.AddDragOver($dragOverCallback)
$dropCallback = [WinUIShell.EventCallback]::new()
$dropCallback.RunspaceMode = [WinUIShell.EventCallbackRunspaceMode]::MainRunspaceSyncUI
$dropCallback.ScriptBlock = {
param($argumentList, $s, $e)
try {
$names = $null
try {
$raw = $e.DataView.Properties["AlliumFFlagNames"]
if (-not [string]::IsNullOrWhiteSpace($raw)) {
$names = $raw | ConvertFrom-Json
}
} catch {
try { Write-ConsoleLog -Message "Drop Properties read failed (trying carrier): $_" -Level "WARN" } catch {}
}
if ($null -eq $names -or @($names).Count -eq 0) {
if ($null -ne $script:DragPayload -and $script:DragPayload.Source -eq "Browser") {
$age = (Get-Date) - $script:DragPayload.Timestamp
if ($age.TotalSeconds -lt 30) {
$names = $script:DragPayload.Names
}
}
}
if ($null -eq $names -or @($names).Count -eq 0) {
Write-ConsoleLog -Message "Drop: no payload found (ignored)." -Level "WARN"
return
}
$script:DragPayload = $null
Editor-AddFFlagsFromDrop -Names @($names)
} catch {
try { Write-ConsoleLog -Message "Editor Drop error: $_" -Level "ERROR" } catch {}
}
}
$RootGrid.AddDrop($dropCallback)
Write-ConsoleLog -Message "Editor drop target installed." -Level "INFO"
} catch {
Write-ConsoleLog -Message "Editor-InstallDropTarget failed: $_" -Level "WARN"
}
}
function Editor-InstallKeyboardShortcuts {
if ($null -eq $script:EditorWindow) { return }
$win = $script:EditorWindow
$script:KbdEditorActive = $true
Write-ConsoleLog -Message "Keyboard shortcuts enabled (polling)." -Level "INFO"
$ctrl = [WinUIShell.Windows.System.VirtualKeyModifiers]::Control
$none = [WinUIShell.Windows.System.VirtualKeyModifiers]::None
$shortcuts = @(
@{ Key = [WinUIShell.Windows.System.VirtualKey]::F; Mod = $ctrl; Action = { if ($null -ne $script:EditorSearchBox) { $script:EditorSearchBox.Focus() } } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::Z; Mod = $ctrl; Action = { if (Invoke-Undo) { Save-Flags; Editor-RefreshFlagList } } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::Y; Mod = $ctrl; Action = { if (Invoke-Redo) { Save-Flags; Editor-RefreshFlagList } } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::A; Mod = $ctrl; Action = { Editor-SelectAllVisible } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::C; Mod = $ctrl; Action = { Editor-CopySelectedAsJson } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::V; Mod = $ctrl; Action = { Editor-PasteJson } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::Delete; Mod = $none; Action = { Editor-DeleteSelected } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::Enter; Mod = $none; Action = { Editor-EditSelected } },
@{ Key = [WinUIShell.Windows.System.VirtualKey]::Escape; Mod = $none; Action = { Editor-DeselectAll } }
)
$__kbdAvailable = $false
try { $__kbdAvailable = ($null -ne $win.KeyboardAccelerators) } catch { $__kbdAvailable = $false }
if (-not $__kbdAvailable) {
Write-ConsoleLog -Message 'Keyboard shortcuts unavailable in this WinUIShell/WindowsAppSDK combo; in-app buttons and menu items work as expected.' -Level 'INFO'
} else {
$__kbdFailCount = 0
foreach ($sc in $shortcuts) {
try {
$ka = New-KeyboardAccelerator -Key $sc.Key -Modifiers $sc.Mod -Action $sc.Action
$win.KeyboardAccelerators.Add($ka) | Out-Null
} catch {
$__kbdFailCount++
}
}
if ($__kbdFailCount -gt 0) {
Write-ConsoleLog -Message ('Keyboard shortcuts: ' + $__kbdFailCount + ' of ' + $shortcuts.Count + ' accelerator(s) failed to attach; user can still use in-app buttons.') -Level 'WARN'
}
}
}
function Editor-SelectAllVisible {
if ($null -eq $script:EditorFlagListView) { return }
$script:EditorFlagListView.SelectAll()
$script:EditorSelectedItems = @($script:EditorFlagListView.SelectedItems)
}
function Editor-DeselectAll {
if ($null -eq $script:EditorFlagListView) { return }
try {
$count = $script:EditorFlagListView.Items.Count
if ($count -gt 0) {
$range = [WinUIShell.Microsoft.UI.Xaml.Data.ItemIndexRange]::new(0, [uint32]$count)
$script:EditorFlagListView.DeselectRange($range)
}
} catch {
try { $script:EditorFlagListView.SelectedItems.Clear() } catch {}
}
$script:EditorSelectedItems = @()
}
function Editor-PasteJson {
try {
$clipText = Get-Clipboard -Raw -ErrorAction SilentlyContinue
if ([string]::IsNullOrWhiteSpace($clipText)) { return }
$imported = $clipText | ConvertFrom-Json -AsHashtable -ErrorAction Stop
$incomingHash = @{}
if ($imported -is [hashtable]) {
$incomingHash = $imported
} else {
foreach ($prop in $imported.PSObject.Properties) {
$incomingHash[$prop.Name] = $prop.Value
}
}
if ($incomingHash.Count -eq 0) { return }
Push-UndoState -Action "Paste JSON" -Snapshot (Get-CurrentFlagSnapshot)
foreach ($key in $incomingHash.Keys) {
$script:Flags[$key] = $incomingHash[$key]
}
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Pasted $($incomingHash.Count) FFlag(s) from clipboard." -Level "INFO"
} catch {
Write-ConsoleLog -Message "Paste failed: clipboard does not contain valid JSON." -Level "WARN"
}
}
function Editor-ResolveSelection {
if (-not $script:EditorSelectionDirty) { return }
$script:EditorSelectionDirty = $false
if ($null -eq $script:EditorFlagListView -or $null -eq $script:EditorDisplayOrder) {
$script:EditorSelectedNames = [System.Collections.Generic.List[string]]::new()
return
}
$names = [System.Collections.Generic.List[string]]::new()
try {
$maxIdx = $script:EditorDisplayOrder.Count - 1
foreach ($range in $script:EditorFlagListView.SelectedRanges) {
$first = $range.FirstIndex
$last = $range.LastIndex
for ($i = $first; $i -le $last; $i++) {
if ($i -ge 0 -and $i -le $maxIdx) {
$names.Add($script:EditorDisplayOrder[$i])
}
}
}
} catch { Write-ConsoleLog -Message "ResolveSelection error: $_" -Level "WARN" }
$script:EditorSelectedNames = $names
}
function Editor-RefreshFlagList {
if ($null -eq $script:EditorFlagListView) { return }
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$pinnedFlags = @()
$unpinnedFlags = @()
foreach ($key in $script:Flags.Keys) {
if ($script:Settings.pinnedFlags -contains $key) {
$pinnedFlags += $key
} else {
$unpinnedFlags += $key
}
}
$typeIndexer = {
$n = $_
if ($n -cmatch '^DFFlag') { 1 }
elseif ($n -cmatch '^FFlag') { 0 }
elseif ($n -cmatch '^DFInt') { 3 }
elseif ($n -cmatch '^FInt') { 2 }
elseif ($n -cmatch '^DFString') { 5 }
elseif ($n -cmatch '^FString') { 4 }
elseif ($n -cmatch '^DFLog') { 7 }
elseif ($n -cmatch '^FLog') { 6 }
else { 99 }
}
$sortDesc = ($script:EditorSortDirection -eq "Descending")
if ($script:EditorSortColumn -eq "Name") {
$sortKeys = @(
@{ Expression = $typeIndexer; Ascending = $true },
@{ Expression = { $_ }; Descending = $sortDesc }
)
} else {
$sortKeys = @(
@{ Expression = { $script:Flags[$_].ToString() }; Descending = $sortDesc },
@{ Expression = $typeIndexer; Ascending = $true },
@{ Expression = { $_ }; Ascending = $true }
)
}
$pinnedSorted = $pinnedFlags | Sort-Object -Property $sortKeys
$unpinnedSorted = $unpinnedFlags | Sort-Object -Property $sortKeys
$allSorted = @() + $pinnedSorted + $unpinnedSorted
$filtered = [System.Collections.Generic.List[string]]::new()
foreach ($key in $allSorted) {
if (-not [string]::IsNullOrWhiteSpace($script:EditorCurrentSearch)) {
if ($key -notlike "*$($script:EditorCurrentSearch)*") { continue }
}
$filtered.Add($key)
}
$script:EditorDisplayOrder = $filtered
$xamlSuccess = $false
if ($script:XamlReaderSupported -ne $false -and $null -ne $script:EditorTableBorder) {
try {
$xamlString = Editor-BuildListViewXaml -FlagNames $filtered
$newListView = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($xamlString)
if ($null -ne $newListView) {
$script:EditorTableBorder.Child = $newListView
$script:EditorFlagListView = $newListView
Editor-AttachListViewHandlers
$xamlSuccess = $true
if ($null -eq $script:XamlReaderSupported) {
$script:XamlReaderSupported = $true
Write-ConsoleLog -Message "XamlReader rendering: SUPPORTED" -Level "INFO"
}
}
} catch {
if ($null -eq $script:XamlReaderSupported) {
$script:XamlReaderSupported = $false
Write-ConsoleLog -Message "XamlReader rendering: NOT SUPPORTED ($($_.Exception.Message))" -Level "WARN"
}
}
}
if (-not $xamlSuccess) {
$script:EditorFlagListView.Items.Clear()
$lv = $script:EditorFlagListView
foreach ($key in $filtered) {
$row = New-FlagListRow -Name $key -Value $script:Flags[$key] -IsPinned ($script:Settings.pinnedFlags -contains $key)
$lv.Items.Add($row) | Out-Null
}
}
if ($null -ne $script:EditorFlagCountText) {
$script:EditorFlagCountText.Text = "Total FFlags: $($script:Flags.Count)"
}
if ($null -ne $script:EditorEmptyStateText) {
Set-ControlVisible -Control $script:EditorEmptyStateText -IsVisible ($script:Flags.Count -eq 0)
}
$script:EditorFlagListView.Opacity = 1
$sw.Stop()
$method = if ($xamlSuccess) { "XamlReader" } else { "Legacy" }
Write-ConsoleLog -Message "Flag list: $($filtered.Count) rows ($method, $($sw.ElapsedMilliseconds)ms)" -Level "INFO"
}
function Editor-BuildListViewXaml {
param([System.Collections.Generic.List[string]]$FlagNames)
$sb = [System.Text.StringBuilder]::new(65536)
[void]$sb.Append('<ListView xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"')
[void]$sb.Append(' xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"')
[void]$sb.Append(' SelectionMode="Extended"')
[void]$sb.Append(" FontFamily=`"Nunito, Segoe UI, sans-serif`"")
[void]$sb.Append(' FontSize="13"')
[void]$sb.Append(' HorizontalAlignment="Stretch"')
[void]$sb.Append(' VerticalAlignment="Stretch"')
[void]$sb.Append(" Foreground=`"$($script:ThemeColors.TextPrimary)`"")
[void]$sb.Append(' Background="Transparent">')
[void]$sb.Append('<ListView.ItemContainerTransitions><TransitionCollection/></ListView.ItemContainerTransitions>')
[void]$sb.Append('<ListView.Transitions><TransitionCollection/></ListView.Transitions>')
$showPrefix = $script:Settings.showPrefixIndicators
$iconFontFamily = "Segoe Fluent Icons, Segoe MDL2 Assets"
$appFontFamily = "Nunito, Segoe UI, sans-serif"
foreach ($name in $FlagNames) {
$escapedName = [System.Security.SecurityElement]::Escape($name)
$value = if ($script:Flags.ContainsKey($name)) { $script:Flags[$name].ToString() } else { "" }
$escapedValue = [System.Security.SecurityElement]::Escape($value)
$isPinned = ($script:Settings.pinnedFlags -contains $name)
$nameColor = $script:ThemeColors.TextPrimary
if ($null -ne $script:EditorFlagStatus -and $script:EditorFlagStatus.ContainsKey($name)) {
$appliedVal = if ($null -ne $script:EditorFlagAppliedValue -and $script:EditorFlagAppliedValue.ContainsKey($name)) { [string]$script:EditorFlagAppliedValue[$name] } else { $null }
$curVal = [string]$value
$st = $script:EditorFlagStatus[$name]
if ($st -eq 'Missing' -or $st -eq 'Failed') { $nameColor = $script:ThemeColors.Error }
elseif ($st -eq 'Applied' -and $appliedVal -eq $curVal) { $nameColor = $script:ThemeColors.Success }
}
$valueColor = $script:ThemeColors.TextSecondary
if ($value -eq "True" -or $value -eq "False") { $valueColor = $script:ThemeColors.PrefixBool }
elseif ($value -match '^\d+$') { $valueColor = $script:ThemeColors.PrefixInt }
elseif (-not [string]::IsNullOrWhiteSpace($value)) { $valueColor = $script:ThemeColors.PrefixString }
[void]$sb.Append("<Grid Tag=`"$escapedName`" Padding=`"4,2,4,2`" HorizontalAlignment=`"Stretch`">")
[void]$sb.Append('<Grid.ColumnDefinitions>')
[void]$sb.Append('<ColumnDefinition Width="24"/>')
[void]$sb.Append('<ColumnDefinition Width="3*"/>')
[void]$sb.Append('<ColumnDefinition Width="1*"/>')
[void]$sb.Append('</Grid.ColumnDefinitions>')
if ($isPinned) {
[void]$sb.Append("<FontIcon Grid.Column=`"0`" Glyph=`"&#xE77A;`" FontSize=`"12`" FontFamily=`"$iconFontFamily`" Foreground=`"$($script:AccentColor)`" VerticalAlignment=`"Center`"/>")
}
if ($showPrefix) {
$prefixBadge = "[?]"; $prefixColor = $script:ThemeColors.PrefixUnknown
if ($name -match "^D?FFlag") { $prefixBadge = "[B]"; $prefixColor = $script:ThemeColors.PrefixBool }
elseif ($name -match "^D?FInt") { $prefixBadge = "[I]"; $prefixColor = $script:ThemeColors.PrefixInt }
elseif ($name -match "^D?FString") { $prefixBadge = "[S]"; $prefixColor = $script:ThemeColors.PrefixString }
elseif ($name -match "^D?FLog") { $prefixBadge = "[L]"; $prefixColor = $script:ThemeColors.PrefixLog }
[void]$sb.Append('<StackPanel Grid.Column="1" Orientation="Horizontal">')
[void]$sb.Append("<TextBlock Text=`"$prefixBadge`" FontSize=`"10`" FontWeight=`"Bold`" Foreground=`"$prefixColor`" Margin=`"0,0,6,0`" VerticalAlignment=`"Center`"/>")
[void]$sb.Append("<TextBlock Text=`"$escapedName`" FontSize=`"12`" FontFamily=`"$appFontFamily`" Foreground=`"$nameColor`" VerticalAlignment=`"Center`" TextTrimming=`"CharacterEllipsis`"/>")
[void]$sb.Append('</StackPanel>')
} else {
[void]$sb.Append("<TextBlock Grid.Column=`"1`" Text=`"$escapedName`" FontSize=`"12`" FontFamily=`"$appFontFamily`" Foreground=`"$nameColor`" VerticalAlignment=`"Center`" TextTrimming=`"CharacterEllipsis`"/>")
}
[void]$sb.Append("<TextBlock Grid.Column=`"2`" Text=`"$escapedValue`" FontSize=`"12`" FontFamily=`"$appFontFamily`" Foreground=`"$valueColor`" VerticalAlignment=`"Center`" TextTrimming=`"CharacterEllipsis`"/>")
[void]$sb.Append('</Grid>')
}
[void]$sb.Append('</ListView>')
return $sb.ToString()
}
function Editor-AttachListViewHandlers {
if ($null -eq $script:EditorFlagListView) { return }
$lv = $script:EditorFlagListView
$ac = New-Color -Hex $script:AccentColor
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$lv.Resources[$key] = $ac
}
try { Set-AccentResourceOverrides -ResourceDictionary $lv.Resources } catch { Write-ConsoleLog -Message "XamlReader accent resource failed: $_" -Level "WARN" }
$lv.AddSelectionChanged({
param($argumentList, $s, $e)
try {
$script:EditorSelectionDirty = $true
$hasSelection = $s.SelectedRanges.Count -gt 0
if ($null -ne $script:EditorBtnDeleteSelected) {
$script:EditorBtnDeleteSelected.Foreground = if ($hasSelection) { New-SolidBrush -Hex $script:ThemeColors.Error } else { New-SolidBrush -Hex $script:ThemeColors.TextPrimary }
}
if ($null -ne $script:EditorBtnDeleteAll) {
$script:EditorBtnDeleteAll.Foreground = if ($hasSelection) { New-SolidBrush -Hex $script:ThemeColors.Error } else { New-SolidBrush -Hex $script:ThemeColors.TextPrimary }
}
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$lv.AddRightTapped({
param($argumentList, $s, $e)
try {
Editor-ResolveSelection
$flyout = [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyout]::new()
$selCount = $script:EditorSelectedNames.Count
$editItem = New-MenuFlyoutItem -Text "Edit" -Glyph ([char]0xE70F) -OnClick { Editor-EditSelected }
if ($selCount -ne 1) { $editItem.IsEnabled = $false }
$flyout.Items.Add($editItem) | Out-Null
$delText = if ($selCount -gt 0) { "Delete ($selCount selected)" } else { "Delete" }
$flyout.Items.Add((New-MenuFlyoutItem -Text $delText -Glyph ([char]0xE74D) -OnClick { Editor-DeleteSelected })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutSeparator)) | Out-Null
$flyout.Items.Add((New-MenuFlyoutItem -Text "Copy Name" -Glyph ([char]0xE8C8) -OnClick { Editor-CopySelectedNames })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutItem -Text "Copy Value" -Glyph ([char]0xE8C8) -OnClick { Editor-CopySelectedValues })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutItem -Text "Copy as JSON" -Glyph ([char]0xE8C8) -OnClick { Editor-CopySelectedAsJson })) | Out-Null
$flyout.Items.Add((New-MenuFlyoutSeparator)) | Out-Null
$isPinned = $false
if ($selCount -ge 1) {
$isPinned = $true
foreach ($selName in $script:EditorSelectedNames) {
if ($script:Settings.pinnedFlags -notcontains $selName) { $isPinned = $false; break }
}
}
$pinText = if ($isPinned) { "Unpin from Top" } else { "Pin to Top" }
$pinGlyph = if ($isPinned) { [char]0xE77A } else { [char]0xE718 }
$flyout.Items.Add((New-MenuFlyoutItem -Text $pinText -Glyph $pinGlyph -OnClick { Editor-TogglePinSelected })) | Out-Null
try {
$pos = $e.GetPosition($s)
$opts = [WinUIShell.Microsoft.UI.Xaml.Controls.Primitives.FlyoutShowOptions]::new()
$opts.Position = [WinUIShell.Windows.Foundation.Point]::new($pos.X, $pos.Y)
$flyout.ShowAt($s, $opts)
} catch {
$flyout.ShowAt($s)
}
} catch { Write-ConsoleLog -Message "Error building context menu: $_" -Level "ERROR" }
})
}
function Editor-ResetSearchDebounce {
if ($null -ne $script:EditorSearchDebounceTimer) {
$script:EditorSearchDebounceTimer.Stop()
$script:EditorSearchDebounceTimer.Start()
return
}
$timer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$timer.Interval = New-UITimeSpan -Milliseconds 150
$timer.AddTick({
param($argumentList, $s, $e)
$s.Stop()
Editor-RefreshFlagList
})
$timer.Start()
$script:EditorSearchDebounceTimer = $timer
}
function New-FlagListRow {
param(
[string]$Name,
$Value,
[bool]$IsPinned
)
$row = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$row.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4, 2, 4, 2)
$row.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$colPin = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colPin.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(24, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Pixel)
$colName = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colName.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(3, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$colValue = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colValue.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$row.ColumnDefinitions.Add($colPin) | Out-Null
$row.ColumnDefinitions.Add($colName) | Out-Null
$row.ColumnDefinitions.Add($colValue) | Out-Null
if ($IsPinned) {
$pinIcon = New-AccentFontIcon -Glyph ([char]0xE77A) -Size 12
$pinIcon.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($pinIcon, 0)
$row.Children.Add($pinIcon) | Out-Null
}
$legacyNameColor = $script:ThemeColors.TextPrimary
if ($null -ne $script:EditorFlagStatus -and $script:EditorFlagStatus.ContainsKey($Name)) {
$applied = if ($null -ne $script:EditorFlagAppliedValue -and $script:EditorFlagAppliedValue.ContainsKey($Name)) { [string]$script:EditorFlagAppliedValue[$Name] } else { $null }
$curr = [string]$Value
$st = $script:EditorFlagStatus[$Name]
if ($st -eq 'Missing' -or $st -eq 'Failed') { $legacyNameColor = $script:ThemeColors.Error }
elseif ($st -eq 'Applied' -and $applied -eq $curr) { $legacyNameColor = $script:ThemeColors.Success }
}
$nameText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nameText.Text = $Name
Set-SafeFontFamily -Target $nameText -Family $script:AppFontFamily
$nameText.FontSize = 12
$nameText.Foreground = New-SolidBrush -Hex $legacyNameColor
$nameText.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$nameText.TextTrimming = [WinUIShell.Microsoft.UI.Xaml.TextTrimming]::CharacterEllipsis
if ($script:Settings.showPrefixIndicators) {
$prefixType = "Unknown"
if ($Name -match "^D?FFlag") { $prefixType = "Bool" }
elseif ($Name -match "^D?FInt") { $prefixType = "Int" }
elseif ($Name -match "^D?FString") { $prefixType = "String" }
elseif ($Name -match "^D?FLog") { $prefixType = "Log" }
$badgeText = switch ($prefixType) {
"Bool" { "[B]" }
"Int" { "[I]" }
"String" { "[S]" }
"Log" { "[L]" }
default { "[?]" }
}
$badgeColor = switch ($prefixType) {
"Bool" { $script:ThemeColors.PrefixBool }
"Int" { $script:ThemeColors.PrefixInt }
"String" { $script:ThemeColors.PrefixString }
"Log" { $script:ThemeColors.PrefixLog }
default { $script:ThemeColors.PrefixUnknown }
}
$badgeBlock = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$badgeBlock.Text = $badgeText
$badgeBlock.FontSize = 10
$badgeBlock.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Bold
$badgeBlock.Foreground = New-SolidBrush -Hex $badgeColor
$badgeBlock.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 6, 0)
$badgeBlock.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$nameStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$nameStack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$nameStack.Children.Add($badgeBlock) | Out-Null
$nameStack.Children.Add($nameText) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($nameStack, 1)
$row.Children.Add($nameStack) | Out-Null
} else {
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($nameText, 1)
$row.Children.Add($nameText) | Out-Null
}
$valueStr = if ($null -ne $Value) { $Value.ToString() } else { "" }
$valueColor = $script:ThemeColors.TextSecondary
if ($valueStr -eq "True" -or $valueStr -eq "False") {
$valueColor = $script:ThemeColors.PrefixBool
} elseif ($valueStr -match '^-?\d+$') {
$valueColor = $script:ThemeColors.PrefixInt
} elseif (-not [string]::IsNullOrWhiteSpace($valueStr)) {
$valueColor = $script:ThemeColors.PrefixString
}
$valueText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$valueText.Text = $valueStr
Set-SafeFontFamily -Target $valueText -Family $script:AppFontFamily
$valueText.FontSize = 12
$valueText.Foreground = New-SolidBrush -Hex $valueColor
$valueText.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$valueText.TextTrimming = [WinUIShell.Microsoft.UI.Xaml.TextTrimming]::CharacterEllipsis
if ($valueStr -eq "True" -or $valueStr -eq "False") {
$localName = $Name
$valueText.AddTapped({
param($argumentList, $s, $e)
if ($script:Flags.ContainsKey($localName)) {
Push-UndoState -Action "Toggle $localName" -Snapshot (Get-CurrentFlagSnapshot)
$current = $script:Flags[$localName].ToString()
if ($current -eq "True") {
$script:Flags[$localName] = "False"
} else {
$script:Flags[$localName] = "True"
}
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Toggled $localName to $($script:Flags[$localName])" -Level "INFO"
}
})
}
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($valueText, 2)
$row.Children.Add($valueText) | Out-Null
$row.Tag = $Name
return $row
}
function Editor-AddFFlagsFromDrop {
param([Parameter(Mandatory)] [string[]]$Names)
if ($Names.Count -eq 0) { return }
Push-UndoState -Action "Drag-and-drop add ($($Names.Count) FFlag(s))" -Snapshot (Get-CurrentFlagSnapshot)
$added = 0
$duplicates = 0
foreach ($name in $Names) {
if ([string]::IsNullOrWhiteSpace($name)) { continue }
if ($script:Flags.ContainsKey($name)) {
$duplicates++
continue
}
$defaultValue = ""
try {
if ($null -ne $script:FlagBrowserCache -and $script:FlagBrowserCache.ContainsKey($name)) {
$cached = $script:FlagBrowserCache[$name]
if ($null -ne $cached.DefaultValue) { $defaultValue = "$($cached.DefaultValue)" }
}
} catch {}
$script:Flags[$name] = $defaultValue
$added++
}
if ($added -gt 0) {
Save-Flags
Editor-RefreshFlagList
}
$title = if ($duplicates -eq 0) { "Added $added FFlag(s)" } else { "Added $added (skipped $duplicates duplicate(s))" }
Show-EditorNotification -Title $title -Message "Drag-and-drop from FFlag Browser."
Write-ConsoleLog -Message "$title -- drag-and-drop from Browser." -Level "INFO"
}
function Editor-AddNewFlagLegacy {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:AddNew] entered' -Level 'INFO'
if ($null -eq $script:EditorWindow -or $null -eq $script:EditorWindow.Content) { return }
if ($script:AddNewDialogOpen) { return }
$script:AddNewDialogOpen = $true
$xamlRoot = $script:EditorWindow.Content.XamlRoot
if ($null -eq $xamlRoot) { return }
$dialog = [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialog]::new()
$dialog.XamlRoot = $xamlRoot
$dialog.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$dialog.Title = "Add New FFlag"
Set-SafeFontFamily -Target $dialog -Family $script:AppFontFamily
$dialog.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$dialog.Background = New-SolidBrush -Hex $script:ThemeColors.Surface
$ac = New-Color -Hex $script:AccentColor
$rd = $dialog.Resources
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$rd[$key] = $ac
}
try { Set-AccentResourceOverrides -ResourceDictionary $dialog.Resources } catch {}
$dialog.CloseButtonText = "Cancel"
$dialog.PrimaryButtonText = "OK"
Write-ConsoleLog -Message ('[addnew-phase] dialog-shell=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$outerPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$outerPanel.Spacing = 16
$outerPanel.MinWidth = 400
$tabStrip = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$tabStrip.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$tabStrip.Spacing = 0
$addSinglePanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$addSinglePanel.Spacing = 12
Set-ControlVisible -Control $addSinglePanel -IsVisible $true
$importPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$importPanel.Spacing = 12
$tabAddSingle = [WinUIShell.Microsoft.UI.Xaml.Controls.Button]::new()
$tabAddSingleText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$tabAddSingleText.Text = "Add single"
Set-SafeFontFamily -Target $tabAddSingleText -Family $script:AppFontFamily
$tabAddSingleText.FontSize = 14
$tabAddSingle.Content = $tabAddSingleText
$tabAddSingle.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$tabAddSingle.Background = New-SolidBrush -Hex $script:ThemeColors.Surface
$tabImportJson = [WinUIShell.Microsoft.UI.Xaml.Controls.Button]::new()
$tabImportJsonText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$tabImportJsonText.Text = "Import JSON"
Set-SafeFontFamily -Target $tabImportJsonText -Family $script:AppFontFamily
$tabImportJsonText.FontSize = 14
$tabImportJson.Content = $tabImportJsonText
$tabImportJson.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 8, 16, 8)
$tabImportJson.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$script:AddNewSinglePanel = $addSinglePanel
$script:AddNewImportPanel = $importPanel
$script:AddNewTabSingle = $tabAddSingle
$script:AddNewTabImport = $tabImportJson
$tabAddSingle.AddClick({
param($argumentList, $s, $e)
try {
$script:AddNewDialogMode = "single"
if ($script:AddNewOuterPanel.Children.Count -gt 1) {
$script:AddNewOuterPanel.Children.RemoveAt($script:AddNewOuterPanel.Children.Count - 1)
}
$script:AddNewOuterPanel.Children.Add($script:AddNewSinglePanel) | Out-Null
$script:AddNewTabSingle.Background = New-SolidBrush -Hex $script:ThemeColors.Surface
$script:AddNewTabImport.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
} catch { Write-ConsoleLog -Message "Tab switch error: $_" -Level "ERROR" }
})
$tabImportJson.AddClick({
param($argumentList, $s, $e)
try {
$script:AddNewDialogMode = "import"
if ($script:AddNewOuterPanel.Children.Count -gt 1) {
$script:AddNewOuterPanel.Children.RemoveAt($script:AddNewOuterPanel.Children.Count - 1)
}
$script:AddNewOuterPanel.Children.Add($script:AddNewImportPanel) | Out-Null
$script:AddNewTabImport.Background = New-SolidBrush -Hex $script:ThemeColors.Surface
$script:AddNewTabSingle.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
} catch { Write-ConsoleLog -Message "Tab switch error: $_" -Level "ERROR" }
})
$tabStrip.Children.Add($tabAddSingle) | Out-Null
$tabStrip.Children.Add($tabImportJson) | Out-Null
$outerPanel.Children.Add($tabStrip) | Out-Null
Write-ConsoleLog -Message ('[addnew-phase] tabs-ready=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$nameLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nameLabel.Text = "Name"
Set-SafeFontFamily -Target $nameLabel -Family $script:AppFontFamily
$nameLabel.FontSize = 14
$nameLabel.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$addSinglePanel.Children.Add($nameLabel) | Out-Null
$nameBox = New-ThemedTextBox -Placeholder "FFlagExampleName"
Write-ConsoleLog -Message ('[addnew-fine] name-textbox-created=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$nameBox.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$addSinglePanel.Children.Add($nameBox) | Out-Null
$valueLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$valueLabel.Text = "Value"
Set-SafeFontFamily -Target $valueLabel -Family $script:AppFontFamily
$valueLabel.FontSize = 14
$valueLabel.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$addSinglePanel.Children.Add($valueLabel) | Out-Null
Write-ConsoleLog -Message ('[addnew-fine] name-field-attached=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$valueCombo = [WinUIShell.Microsoft.UI.Xaml.Controls.ComboBox]::new()
$valueCombo.IsEditable = $true
$valueCombo.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
Set-SafeFontFamily -Target $valueCombo -Family $script:AppFontFamily
$valueCombo.PlaceholderText = "Enter or select a value"
Write-ConsoleLog -Message ('[addnew-fine] combo-configured=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$presets = @("True", "False", "2147483647", "-2147483648")
foreach ($p in $presets) {
$valueCombo.Items.Add($p) | Out-Null
}
$addSinglePanel.Children.Add($valueCombo) | Out-Null
Write-ConsoleLog -Message ('[addnew-fine] presets-attached=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
try {
$cbBgBrush = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$cbFocusBrush = New-SolidBrush -Hex "#381A26"
$cbAccentBrush = New-AccentBrush
$cbSurfaceBrush = New-SolidBrush -Hex $script:ThemeColors.Surface
$valueCombo.Resources["ComboBoxBackground"] = $cbBgBrush
$valueCombo.Resources["ComboBoxBackgroundPointerOver"] = $cbBgBrush
$valueCombo.Resources["ComboBoxBackgroundPressed"] = $cbFocusBrush
$valueCombo.Resources["ComboBoxBackgroundFocused"] = $cbFocusBrush
$valueCombo.Resources["ComboBoxBackgroundUnfocused"] = $cbBgBrush
$valueCombo.Resources["TextControlBackground"] = $cbBgBrush
$valueCombo.Resources["TextControlBackgroundPointerOver"] = $cbBgBrush
$valueCombo.Resources["TextControlBackgroundFocused"] = $cbFocusBrush
$valueCombo.Resources["ComboBoxDropDownBackground"] = $cbSurfaceBrush
$valueCombo.Resources["ComboBoxItemPillFillBrush"] = $cbAccentBrush
$cbAccentColor = New-Color -Hex $script:AccentColor
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$valueCombo.Resources[$key] = $cbAccentColor
}
Write-ConsoleLog -Message ('[addnew-fine] combo-local-resources=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
Set-AccentResourceOverrides -ResourceDictionary $valueCombo.Resources
Write-ConsoleLog -Message ('[addnew-fine] combo-accent-overrides=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
} catch {}
$errorText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$errorText.Text = ""
Set-SafeFontFamily -Target $errorText -Family $script:AppFontFamily
$errorText.FontSize = 12
$errorText.Foreground = New-SolidBrush -Hex $script:ThemeColors.Error
Set-ControlVisible -Control $errorText -IsVisible $false
$errorText.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$addSinglePanel.Children.Add($errorText) | Out-Null
$script:AddNewOuterPanel = $outerPanel
$outerPanel.Children.Add($addSinglePanel) | Out-Null
Write-ConsoleLog -Message ('[addnew-fine] error-and-panel-attached=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
Write-ConsoleLog -Message ('[addnew-phase] single-panel-ready=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$importLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$importLabel.Text = "Paste your FFlags here:"
Set-SafeFontFamily -Target $importLabel -Family $script:AppFontFamily
$importLabel.FontSize = 14
$importLabel.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$importPanel.Children.Add($importLabel) | Out-Null
$importBox = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBox]::new()
$importBox.AcceptsReturn = $true
$importBox.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$importBox.MinHeight = 150
$importBox.MaxHeight = 300
$importBox.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Cascadia Code, Consolas, monospace")
$importBox.FontSize = 12
$importBox.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$importBox.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
Set-ThemedTextBoxResources -Control $importBox
try {
$phBrush = New-SolidBrush -Hex "#50A08090"
$importBox.Resources["TextControlPlaceholderForeground"] = $phBrush
$importBox.Resources["TextControlPlaceholderForegroundPointerOver"] = $phBrush
$importBox.Resources["TextControlPlaceholderForegroundFocused"] = $phBrush
} catch {}
$importBox.PlaceholderText = @"
{
  "FFlagExample": "True",
  "DFFlagExample": "False",
  "FIntExample": "67",
  "DFIntExample": "67",
  "FLogExample": "67",
  "DFLogExample": "67",
  "FStringExample": "onion"
  "DFStringExample": "IsSigma"
}
"@
$importBox.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$importPanel.Children.Add($importBox) | Out-Null
$browseBtn = New-ThemedButton -Content "Browse File..." -Glyph ([char]0xE8DA) -ToolbarStyle
$browseBtn.AddClick({
param($argumentList, $s, $e)
try {
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$owner = [System.Windows.Forms.Form]::new()
$owner.TopMost = $true
$owner.ShowInTaskbar = $false
$owner.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$owner.Size = [System.Drawing.Size]::new(1, 1)
$owner.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$owner.Opacity = 0
$owner.Show()
[System.Windows.Forms.Application]::DoEvents()
try {
[Allium.DialogFocus]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero)
[Allium.DialogFocus]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
} catch {}
$owner.Activate()
$owner.BringToFront()
try {
$SWP_NOMOVE = 0x0002; $SWP_NOSIZE = 0x0001; $swpFlags = $SWP_NOMOVE -bor $SWP_NOSIZE
[void][Allium.DialogFocus]::SetWindowPos($owner.Handle, [IntPtr]::new(-1), 0, 0, 0, 0, $swpFlags)
[void][Allium.DialogFocus]::SetWindowPos($owner.Handle, [IntPtr]::new(-2), 0, 0, 0, 0, $swpFlags)
} catch {}
[System.Windows.Forms.Application]::DoEvents()
$ofd = [System.Windows.Forms.OpenFileDialog]::new()
$ofd.Filter = "JSON files (*.json)|*.json|Text files (*.txt)|*.txt|All files (*.*)|*.*"
$ofd.Title = "Import FFlags JSON"
if ($ofd.ShowDialog($owner) -eq [System.Windows.Forms.DialogResult]::OK) {
$content = [System.IO.File]::ReadAllText($ofd.FileName)
$importBox.Text = $content
}
$owner.Close()
$owner.Dispose()
} catch { Write-ConsoleLog -Message "Browse error: $_" -Level "ERROR" }
})
$importPanel.Children.Add($browseBtn) | Out-Null
$importErrorText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$importErrorText.Text = ""
Set-SafeFontFamily -Target $importErrorText -Family $script:AppFontFamily
$importErrorText.FontSize = 12
$importErrorText.Foreground = New-SolidBrush -Hex $script:ThemeColors.Error
Set-ControlVisible -Control $importErrorText -IsVisible $false
$importErrorText.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$importPanel.Children.Add($importErrorText) | Out-Null
$script:AddNewDialogNameBox = $nameBox
$script:AddNewDialogValueCombo = $valueCombo
$script:AddNewDialogErrorText = $errorText
$script:AddNewDialogImportBox = $importBox
$script:AddNewDialogImportErrorText = $importErrorText
Write-ConsoleLog -Message ('[addnew-phase] import-panel-ready=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$dialog.Content = $outerPanel
$script:AddNewDialogMode = "single"
Write-ConsoleLog -Message ('[addnew-phase] content-attached=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$dialog.AddPrimaryButtonClick({
param($argumentList, $s, $e)
if ($script:AddNewDialogMode -eq "single") {
$flagName = $script:AddNewDialogNameBox.Text
if ([string]::IsNullOrWhiteSpace($flagName)) {
$script:AddNewDialogErrorText.Text = "Flag name cannot be empty."
Set-ControlVisible -Control $script:AddNewDialogErrorText -IsVisible $true
$e.Cancel = $true
return
}
$flagName = $flagName.Trim()
if ($script:Flags.ContainsKey($flagName)) {
$script:AddNewDialogErrorText.Text = "A flag with this name already exists."
Set-ControlVisible -Control $script:AddNewDialogErrorText -IsVisible $true
$e.Cancel = $true
return
}
$flagValue = ""
try { $flagValue = $script:AddNewDialogValueCombo.Text } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
if ([string]::IsNullOrWhiteSpace($flagValue)) {
try { $flagValue = $script:AddNewDialogValueCombo.SelectedItem } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}
if ([string]::IsNullOrWhiteSpace($flagValue)) {
$script:AddNewDialogErrorText.Text = "Value cannot be empty."
Set-ControlVisible -Control $script:AddNewDialogErrorText -IsVisible $true
$e.Cancel = $true
return
}
$flagValue = $flagValue.ToString().Trim()
Push-UndoState -Action "Add FFlag" -Snapshot (Get-CurrentFlagSnapshot)
$script:Flags[$flagName] = $flagValue
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Added FFlag: $flagName = $flagValue" -Level "INFO"
}
else {
$jsonText = $script:AddNewDialogImportBox.Text
if ([string]::IsNullOrWhiteSpace($jsonText)) {
$script:AddNewDialogImportErrorText.Text = "JSON input is empty."
Set-ControlVisible -Control $script:AddNewDialogImportErrorText -IsVisible $true
$e.Cancel = $true
return
}
try {
$imported = $jsonText | ConvertFrom-Json -AsHashtable -ErrorAction Stop
} catch {
$script:AddNewDialogImportErrorText.Text = "Invalid JSON syntax. Check your input."
Set-ControlVisible -Control $script:AddNewDialogImportErrorText -IsVisible $true
$e.Cancel = $true
return
}
$incomingHash = @{}
if ($imported -is [hashtable]) {
$incomingHash = $imported
} else {
foreach ($prop in $imported.PSObject.Properties) {
$incomingHash[$prop.Name] = $prop.Value
}
}
if ($incomingHash.Count -eq 0) {
$script:AddNewDialogImportErrorText.Text = "JSON contains no flags."
Set-ControlVisible -Control $script:AddNewDialogImportErrorText -IsVisible $true
$e.Cancel = $true
return
}
Push-UndoState -Action "Import JSON" -Snapshot (Get-CurrentFlagSnapshot)
foreach ($key in $incomingHash.Keys) {
$script:Flags[$key] = $incomingHash[$key]
}
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Imported $($incomingHash.Count) FFlag(s) from JSON." -Level "INFO"
}
})
Write-ConsoleLog -Message ('[editor-menu:AddNew] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$dialog.ShowAsync().WaitForCompleted() | Out-Null
$script:AddNewDialogOpen = $false
$script:AddNewOuterPanel = $null
$script:AddNewSinglePanel = $null
$script:AddNewImportPanel = $null
$script:AddNewTabSingle = $null
$script:AddNewTabImport = $null
}
function Editor-AddNewFlag {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:AddNew] entered' -Level 'INFO'
if ($null -eq $script:EditorWindow -or $null -eq $script:EditorWindow.Content) { return }
if ($script:AddNewDialogOpen) { return }
$script:AddNewDialogOpen = $true
$xamlRoot = $script:EditorWindow.Content.XamlRoot
if ($null -eq $xamlRoot) { $script:AddNewDialogOpen = $false; return }
$xPrimary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextPrimary)
$xSecondary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextSecondary)
$xSurface = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.Surface)
$xButtonSurface = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.ButtonSurface)
$xError = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.Error)
$xAccent = [System.Security.SecurityElement]::Escape([string]$script:AccentColor)
$xAppFont = [System.Security.SecurityElement]::Escape([string]$script:AppFontFamily.Source)
$addNewXamlLines = @(
'<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="AddNewOuterPanel" Spacing="16" MinWidth="400">',
'  <StackPanel Orientation="Horizontal" Spacing="0">',
'    <Button x:Name="AddNewTabSingle" Padding="16,8" Background="__SURFACE__"><TextBlock Text="Add single" FontFamily="__APPFONT__" FontSize="14"/></Button>',
'    <Button x:Name="AddNewTabImport" Padding="16,8" Background="__BUTTONSURFACE__"><TextBlock Text="Import JSON" FontFamily="__APPFONT__" FontSize="14"/></Button>',
'  </StackPanel>',
'  <StackPanel x:Name="AddNewSinglePanel" Spacing="12">',
'    <TextBlock Text="Name" FontFamily="__APPFONT__" FontSize="14" Foreground="__SECONDARY__"/>',
'    <TextBox x:Name="AddNewNameBox" PlaceholderText="FFlagExampleName" HorizontalAlignment="Stretch" FontFamily="__APPFONT__"/>',
'    <TextBlock Text="Value" FontFamily="__APPFONT__" FontSize="14" Foreground="__SECONDARY__"/>',
'    <ComboBox x:Name="AddNewValueCombo" IsEditable="True" HorizontalAlignment="Stretch" FontFamily="__APPFONT__" PlaceholderText="Enter or select a value">',
'      <ComboBox.Resources>',
'        <SolidColorBrush x:Key="ComboBoxBackground" Color="__BUTTONSURFACE__"/><SolidColorBrush x:Key="ComboBoxBackgroundPointerOver" Color="__BUTTONSURFACE__"/>',
'        <SolidColorBrush x:Key="ComboBoxBackgroundPressed" Color="#381A26"/><SolidColorBrush x:Key="ComboBoxBackgroundFocused" Color="#381A26"/>',
'        <SolidColorBrush x:Key="ComboBoxBackgroundUnfocused" Color="__BUTTONSURFACE__"/><SolidColorBrush x:Key="TextControlBackground" Color="__BUTTONSURFACE__"/>',
'        <SolidColorBrush x:Key="TextControlBackgroundPointerOver" Color="__BUTTONSURFACE__"/><SolidColorBrush x:Key="TextControlBackgroundFocused" Color="#381A26"/>',
'        <SolidColorBrush x:Key="ComboBoxDropDownBackground" Color="__SURFACE__"/><SolidColorBrush x:Key="ComboBoxItemPillFillBrush" Color="__ACCENT__"/>',
'        <Color x:Key="SystemAccentColor">__ACCENT__</Color><Color x:Key="SystemAccentColorLight1">__ACCENT__</Color><Color x:Key="SystemAccentColorLight2">__ACCENT__</Color><Color x:Key="SystemAccentColorLight3">__ACCENT__</Color>',
'        <Color x:Key="SystemAccentColorDark1">__ACCENT__</Color><Color x:Key="SystemAccentColorDark2">__ACCENT__</Color><Color x:Key="SystemAccentColorDark3">__ACCENT__</Color>',
'      </ComboBox.Resources>',
'    </ComboBox>',
'    <TextBlock x:Name="AddNewErrorText" Text="" FontFamily="__APPFONT__" FontSize="12" Foreground="__ERROR__" Visibility="Collapsed" TextWrapping="Wrap"/>',
'  </StackPanel>',
'  <StackPanel x:Name="AddNewImportPanel" Spacing="12" Visibility="Collapsed">',
'    <TextBlock Text="Paste your FFlags here:" FontFamily="__APPFONT__" FontSize="14" Foreground="__SECONDARY__"/>',
'    <TextBox x:Name="AddNewImportBox" AcceptsReturn="True" TextWrapping="Wrap" MinHeight="150" MaxHeight="300" FontFamily="Cascadia Code, Consolas, monospace" FontSize="12" Foreground="__PRIMARY__" Background="__BUTTONSURFACE__" PlaceholderText="Probe">',
'      <TextBox.Resources><SolidColorBrush x:Key="TextControlPlaceholderForeground" Color="#50A08090"/><SolidColorBrush x:Key="TextControlPlaceholderForegroundPointerOver" Color="#50A08090"/><SolidColorBrush x:Key="TextControlPlaceholderForegroundFocused" Color="#50A08090"/></TextBox.Resources>',
'    </TextBox>',
'    <StackPanel x:Name="AddNewBrowseHost"/>',
'    <TextBlock x:Name="AddNewImportErrorText" Text="" FontFamily="__APPFONT__" FontSize="12" Foreground="__ERROR__" Visibility="Collapsed" TextWrapping="Wrap"/>',
'  </StackPanel>',
'</StackPanel>'
)
$addNewXaml = [string]::Join([Environment]::NewLine,$addNewXamlLines)
$addNewXaml = $addNewXaml.Replace('__PRIMARY__',$xPrimary).Replace('__SECONDARY__',$xSecondary).Replace('__SURFACE__',$xSurface).Replace('__BUTTONSURFACE__',$xButtonSurface).Replace('__ERROR__',$xError).Replace('__ACCENT__',$xAccent).Replace('__APPFONT__',$xAppFont)
try {
$outerPanel = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($addNewXaml)
} catch {
Write-ConsoleLog -Message ('[addnew-xaml-staged] load failed; using exact P1281 fallback: ' + $_.Exception.Message) -Level 'ERROR'
$script:AddNewDialogOpen = $false
Editor-AddNewFlagLegacy
return
}
$tabAddSingle = $outerPanel.FindName('AddNewTabSingle'); $tabImportJson = $outerPanel.FindName('AddNewTabImport')
$addSinglePanel = $outerPanel.FindName('AddNewSinglePanel'); $importPanel = $outerPanel.FindName('AddNewImportPanel')
$nameBox = $outerPanel.FindName('AddNewNameBox'); $valueCombo = $outerPanel.FindName('AddNewValueCombo')
$errorText = $outerPanel.FindName('AddNewErrorText'); $importBox = $outerPanel.FindName('AddNewImportBox')
$browseHost = $outerPanel.FindName('AddNewBrowseHost'); $importErrorText = $outerPanel.FindName('AddNewImportErrorText')
$requiredParts = @($outerPanel,$tabAddSingle,$tabImportJson,$addSinglePanel,$nameBox,$valueCombo,$errorText,$importPanel,$importBox,$browseHost,$importErrorText)
if ($requiredParts.Count -ne 11 -or @($requiredParts | Where-Object { $null -eq $_ }).Count -ne 0) {
Write-ConsoleLog -Message '[addnew-xaml-staged] named-part validation failed; using exact P1281 fallback.' -Level 'ERROR'
$script:AddNewDialogOpen = $false
Editor-AddNewFlagLegacy
return
}
$importPlaceholderLines = @(
'{',
'  "FFlagExample": "True",',
'  "DFFlagExample": "False",',
'  "FIntExample": "67",',
'  "DFIntExample": "67",',
'  "FLogExample": "67",',
'  "DFLogExample": "67",',
'  "FStringExample": "onion"',
'  "DFStringExample": "IsSigma"',
'}'
)
$importBox.PlaceholderText = [string]::Join([Environment]::NewLine,$importPlaceholderLines)
Write-ConsoleLog -Message ('[addnew-xaml-staged] tree-loaded parts=11 placeholder-length=' + $importBox.PlaceholderText.Length + ' load-ms=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds) -Level 'INFO'
foreach ($part in @($tabAddSingle,$tabImportJson,$addSinglePanel,$importPanel,$nameBox,$valueCombo,$errorText,$importBox,$browseHost,$importErrorText)) { if ($null -eq $part) { throw 'P1282: Add New XAML named part missing' } }
Set-ThemedTextBoxResources -Control $nameBox; Set-ThemedTextBoxResources -Control $importBox
try {
$phBrush = New-SolidBrush -Hex "#50A08090"
$importBox.Resources["TextControlPlaceholderForeground"] = $phBrush
$importBox.Resources["TextControlPlaceholderForegroundPointerOver"] = $phBrush
$importBox.Resources["TextControlPlaceholderForegroundFocused"] = $phBrush
} catch {}
foreach ($preset in @("True", "False", "2147483647", "-2147483648")) { $valueCombo.Items.Add($preset) | Out-Null }
try { Set-AccentResourceOverrides -ResourceDictionary $valueCombo.Resources } catch {}
$browseBtn = New-ThemedButton -Content "Browse File..." -Glyph ([char]0xE8DA) -ToolbarStyle
$browseHost.Children.Add($browseBtn) | Out-Null
$dialog = [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialog]::new()
$dialog.XamlRoot = $xamlRoot; $dialog.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$dialog.Title = 'Add New FFlag'; Set-SafeFontFamily -Target $dialog -Family $script:AppFontFamily
$dialog.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary; $dialog.Background = New-SolidBrush -Hex $script:ThemeColors.Surface
try { Set-AccentResourceOverrides -ResourceDictionary $dialog.Resources } catch {}
$dialog.CloseButtonText = 'Cancel'; $dialog.PrimaryButtonText = 'OK'; $dialog.Content = $outerPanel
$script:AddNewOuterPanel = $outerPanel; $script:AddNewSinglePanel = $addSinglePanel; $script:AddNewImportPanel = $importPanel
$script:AddNewTabSingle = $tabAddSingle; $script:AddNewTabImport = $tabImportJson
$script:AddNewDialogNameBox = $nameBox; $script:AddNewDialogValueCombo = $valueCombo; $script:AddNewDialogErrorText = $errorText
$script:AddNewDialogImportBox = $importBox; $script:AddNewDialogImportErrorText = $importErrorText; $script:AddNewDialogMode = 'single'
$tabAddSingle.AddClick({
param($argumentList,$s,$e)
try {
$script:AddNewDialogMode='single'
$script:AddNewSinglePanel.Visibility=[WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
$script:AddNewImportPanel.Visibility=[WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$script:AddNewTabSingle.Background=New-SolidBrush -Hex $script:ThemeColors.Surface
$script:AddNewTabImport.Background=New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
} catch { Write-ConsoleLog -Message "Tab switch error: $_" -Level "ERROR" }
})
$tabImportJson.AddClick({
param($argumentList,$s,$e)
try {
$script:AddNewDialogMode='import'
$script:AddNewSinglePanel.Visibility=[WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$script:AddNewImportPanel.Visibility=[WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
$script:AddNewTabImport.Background=New-SolidBrush -Hex $script:ThemeColors.Surface
$script:AddNewTabSingle.Background=New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
} catch { Write-ConsoleLog -Message "Tab switch error: $_" -Level "ERROR" }
})
$browseBtn.AddClick({
param($argumentList, $s, $e)
try {
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$owner = [System.Windows.Forms.Form]::new()
$owner.TopMost = $true
$owner.ShowInTaskbar = $false
$owner.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$owner.Size = [System.Drawing.Size]::new(1, 1)
$owner.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$owner.Opacity = 0
$owner.Show()
[System.Windows.Forms.Application]::DoEvents()
try {
[Allium.DialogFocus]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero)
[Allium.DialogFocus]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
} catch {}
$owner.Activate()
$owner.BringToFront()
try {
$SWP_NOMOVE = 0x0002; $SWP_NOSIZE = 0x0001; $swpFlags = $SWP_NOMOVE -bor $SWP_NOSIZE
[void][Allium.DialogFocus]::SetWindowPos($owner.Handle, [IntPtr]::new(-1), 0, 0, 0, 0, $swpFlags)
[void][Allium.DialogFocus]::SetWindowPos($owner.Handle, [IntPtr]::new(-2), 0, 0, 0, 0, $swpFlags)
} catch {}
[System.Windows.Forms.Application]::DoEvents()
$ofd = [System.Windows.Forms.OpenFileDialog]::new()
$ofd.Filter = "JSON files (*.json)|*.json|Text files (*.txt)|*.txt|All files (*.*)|*.*"
$ofd.Title = "Import FFlags JSON"
if ($ofd.ShowDialog($owner) -eq [System.Windows.Forms.DialogResult]::OK) {
$content = [System.IO.File]::ReadAllText($ofd.FileName)
$importBox.Text = $content
}
$owner.Close()
$owner.Dispose()
} catch { Write-ConsoleLog -Message "Browse error: $_" -Level "ERROR" }
})
Write-ConsoleLog -Message ('[editor-menu:AddNew] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$dialog.AddPrimaryButtonClick({
param($argumentList, $s, $e)
if ($script:AddNewDialogMode -eq "single") {
$flagName = $script:AddNewDialogNameBox.Text
if ([string]::IsNullOrWhiteSpace($flagName)) {
$script:AddNewDialogErrorText.Text = "Flag name cannot be empty."
Set-ControlVisible -Control $script:AddNewDialogErrorText -IsVisible $true
$e.Cancel = $true
return
}
$flagName = $flagName.Trim()
if ($script:Flags.ContainsKey($flagName)) {
$script:AddNewDialogErrorText.Text = "A flag with this name already exists."
Set-ControlVisible -Control $script:AddNewDialogErrorText -IsVisible $true
$e.Cancel = $true
return
}
$flagValue = ""
try { $flagValue = $script:AddNewDialogValueCombo.Text } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
if ([string]::IsNullOrWhiteSpace($flagValue)) {
try { $flagValue = $script:AddNewDialogValueCombo.SelectedItem } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}
if ([string]::IsNullOrWhiteSpace($flagValue)) {
$script:AddNewDialogErrorText.Text = "Value cannot be empty."
Set-ControlVisible -Control $script:AddNewDialogErrorText -IsVisible $true
$e.Cancel = $true
return
}
$flagValue = $flagValue.ToString().Trim()
Push-UndoState -Action "Add FFlag" -Snapshot (Get-CurrentFlagSnapshot)
$script:Flags[$flagName] = $flagValue
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Added FFlag: $flagName = $flagValue" -Level "INFO"
}
else {
$jsonText = $script:AddNewDialogImportBox.Text
if ([string]::IsNullOrWhiteSpace($jsonText)) {
$script:AddNewDialogImportErrorText.Text = "JSON input is empty."
Set-ControlVisible -Control $script:AddNewDialogImportErrorText -IsVisible $true
$e.Cancel = $true
return
}
try {
$imported = $jsonText | ConvertFrom-Json -AsHashtable -ErrorAction Stop
} catch {
$script:AddNewDialogImportErrorText.Text = "Invalid JSON syntax. Check your input."
Set-ControlVisible -Control $script:AddNewDialogImportErrorText -IsVisible $true
$e.Cancel = $true
return
}
$incomingHash = @{}
if ($imported -is [hashtable]) {
$incomingHash = $imported
} else {
foreach ($prop in $imported.PSObject.Properties) {
$incomingHash[$prop.Name] = $prop.Value
}
}
if ($incomingHash.Count -eq 0) {
$script:AddNewDialogImportErrorText.Text = "JSON contains no flags."
Set-ControlVisible -Control $script:AddNewDialogImportErrorText -IsVisible $true
$e.Cancel = $true
return
}
Push-UndoState -Action "Import JSON" -Snapshot (Get-CurrentFlagSnapshot)
foreach ($key in $incomingHash.Keys) {
$script:Flags[$key] = $incomingHash[$key]
}
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Imported $($incomingHash.Count) FFlag(s) from JSON." -Level "INFO"
}
})
$dialog.ShowAsync().WaitForCompleted() | Out-Null
$script:AddNewDialogOpen = $false
$script:AddNewOuterPanel = $null
$script:AddNewSinglePanel = $null
$script:AddNewImportPanel = $null
$script:AddNewTabSingle = $null
$script:AddNewTabImport = $null
}
function Editor-DeleteSelected {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:DeleteSelected] entered' -Level 'INFO'
if ($null -eq $script:EditorFlagListView) { return }
Editor-ResolveSelection
$selected = $script:EditorSelectedNames
if ($selected.Count -eq 0) {
Write-ConsoleLog -Message "No FFlags selected for deletion." -Level "WARN"
return
}
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$count = $selected.Count
if ($count -ge 25) {
Write-ConsoleLog -Message ('[editor-menu:DeleteSelected] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$confirm = Show-ConfirmDialog -XamlRoot $xamlRoot -Title "Delete FFlags" -Message "Delete $count selected FFlag(s)? This can be undone with Ctrl+Z." -ConfirmText "Delete" -CancelText "Cancel"
if (-not $confirm) { return }
}
Push-UndoState -Action "Delete FFlags" -Snapshot (Get-CurrentFlagSnapshot)
foreach ($name in $selected) {
if ($null -ne $name -and $script:Flags.ContainsKey($name)) {
$script:Flags.Remove($name)
}
}
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Deleted $count FFlag(s)." -Level "INFO"
}
function Editor-DeleteAll {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:DeleteAll] entered' -Level 'INFO'
if ($script:Flags.Count -eq 0) { return }
if ($null -eq $script:EditorWindow) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
Write-ConsoleLog -Message ('[editor-menu:DeleteAll] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$confirm = Show-ConfirmDialog -XamlRoot $xamlRoot -Title "Delete All FFlags" -Message "Delete ALL $($script:Flags.Count) FFlags? This can be undone with Ctrl+Z." -ConfirmText "Delete All" -CancelText "Cancel"
if (-not $confirm) { return }
Push-UndoState -Action "Delete All FFlags" -Snapshot (Get-CurrentFlagSnapshot)
if ($script:Flags -isnot [hashtable]) { $script:Flags = @{} }
else { $script:Flags.Clear() }
Write-ConsoleLog -Message "Delete All: count=$($script:Flags.Count)" -Level "INFO"
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "All FFlags deleted." -Level "INFO"
}
function Editor-CopyAll {
$sb = [System.Text.StringBuilder]::new($script:Flags.Count * 80)
[void]$sb.Append('{')
$first = $true
foreach ($key in ($script:Flags.Keys | Sort-Object)) {
if (-not $first) { [void]$sb.Append(',') }
$ek = $key.Replace('\', '\\').Replace('"', '\"')
$ev = $script:Flags[$key].ToString().Replace('\', '\\').Replace('"', '\"')
[void]$sb.Append("`n  `"$ek`": `"$ev`"")
$first = $false
}
[void]$sb.Append("`n}")
Set-Clipboard -Value $sb.ToString()
Write-ConsoleLog -Message "All FFlags copied to clipboard as JSON." -Level "INFO"
if ($null -ne $script:EditorFlagCountText) {
Show-TeachingTip -Target $script:EditorFlagCountText -Title "Copied!" -Subtitle "All FFlags copied as JSON."
}
}
function Editor-CopySelectedNames {
Editor-ResolveSelection
Set-Clipboard -Value ($script:EditorSelectedNames -join "`r`n")
Write-ConsoleLog -Message "Copied $($script:EditorSelectedNames.Count) FFlag name(s)." -Level "INFO"
}
function Editor-CopySelectedValues {
Editor-ResolveSelection
$values = [System.Collections.Generic.List[string]]::new()
foreach ($name in $script:EditorSelectedNames) {
if ($null -ne $name -and $script:Flags.ContainsKey($name)) {
$values.Add($script:Flags[$name].ToString())
}
}
Set-Clipboard -Value ($values -join "`r`n")
Write-ConsoleLog -Message "Copied $($values.Count) FFlag value(s)." -Level "INFO"
}
function Editor-CopySelectedAsJson {
Editor-ResolveSelection
if ($script:EditorSelectedNames.Count -eq 0 -and $null -ne $script:EditorFlagListView -and $null -ne $script:EditorDisplayOrder) {
try {
$fresh = [System.Collections.Generic.List[string]]::new()
$maxIdx = $script:EditorDisplayOrder.Count - 1
foreach ($range in $script:EditorFlagListView.SelectedRanges) {
$first = $range.FirstIndex
$last = $range.LastIndex
for ($i = $first; $i -le $last; $i++) {
if ($i -ge 0 -and $i -le $maxIdx) {
$fresh.Add($script:EditorDisplayOrder[$i])
}
}
}
if ($fresh.Count -gt 0) { $script:EditorSelectedNames = $fresh }
} catch {}
}
$count = 0
$sb = [System.Text.StringBuilder]::new($script:EditorSelectedNames.Count * 80)
[void]$sb.Append('{')
$first = $true
foreach ($name in $script:EditorSelectedNames) {
if ($null -ne $name -and $script:Flags.ContainsKey($name)) {
if (-not $first) { [void]$sb.Append(',') }
$ek = $name.Replace('\', '\\').Replace('"', '\"')
$ev = $script:Flags[$name].ToString().Replace('\', '\\').Replace('"', '\"')
[void]$sb.Append("`n  `"$ek`": `"$ev`"")
$first = $false
$count++
}
}
[void]$sb.Append("`n}")
Set-Clipboard -Value $sb.ToString()
Write-ConsoleLog -Message "Copied $count FFlag(s) as JSON." -Level "INFO"
}
function Editor-EditSelected {
if ($null -eq $script:EditorWindow -or $null -eq $script:EditorWindow.Content) { return }
Editor-ResolveSelection
$selected = $script:EditorSelectedNames
if ($selected.Count -ne 1) { Write-ConsoleLog -Message "Select exactly one FFlag to edit." -Level "WARN"; return }
$oldName = $selected[0]
if ($null -eq $oldName -or -not $script:Flags.ContainsKey($oldName)) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$currentValue = $script:Flags[$oldName].ToString()
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 12; $panel.MinWidth = 400
$nl = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nl.Text = "Name"; Set-SafeFontFamily -Target $nl -Family $script:AppFontFamily; $nl.FontSize = 14
$nl.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$panel.Children.Add($nl) | Out-Null
$nb = New-ThemedTextBox -Text $oldName -Placeholder "FFlag name"
$nb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$panel.Children.Add($nb) | Out-Null
$vl = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$vl.Text = "Value"; Set-SafeFontFamily -Target $vl -Family $script:AppFontFamily; $vl.FontSize = 14
$vl.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$panel.Children.Add($vl) | Out-Null
$vb = New-ThemedTextBox -Text $currentValue -Placeholder "Value"
$vb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$panel.Children.Add($vb) | Out-Null
$result = Show-CustomDialog -XamlRoot $xamlRoot -Title "Edit FFlag" -Content $panel -PrimaryButtonText "Save" -CloseButtonText "Cancel"
if ($result -ne "Primary") { return }
$newName = $nb.Text.Trim(); $newValue = $vb.Text.Trim()
if ([string]::IsNullOrWhiteSpace($newName)) { return }
if ($newName -eq $oldName -and $newValue -eq $currentValue) { return }
Push-UndoState -Action "Edit FFlag" -Snapshot (Get-CurrentFlagSnapshot)
if ($newName -ne $oldName) {
$script:Flags.Remove($oldName)
if ($script:Settings.pinnedFlags -contains $oldName) {
$script:Settings.pinnedFlags = @($script:Settings.pinnedFlags | Where-Object { $_ -ne $oldName }) + @($newName)
Save-Settings
}
}
$script:Flags[$newName] = $newValue; Save-Flags; Editor-RefreshFlagList
Write-ConsoleLog -Message "Edited FFlag: $oldName -> $newName = $newValue" -Level "INFO"
}
function Editor-BatchEditSelected {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:BatchEdit] entered' -Level 'INFO'
if ($null -eq $script:EditorWindow -or $null -eq $script:EditorWindow.Content) { return }
Editor-ResolveSelection
$selected = @($script:EditorSelectedNames | Where-Object { $null -ne $_ -and $script:Flags.ContainsKey($_) })
if ($selected.Count -eq 0) {
Write-ConsoleLog -Message "No FFlags selected for batch edit." -Level "WARN"
return
}
$count = $selected.Count
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$outer = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$outer.Spacing = 12
$outer.MinWidth = 560
$subtitleTB = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
if ($count -eq 1) { $subtitleText = "1 FFlag" } else { $subtitleText = "$count FFlags" }
$subtitleTB.Text = $subtitleText
Set-SafeFontFamily -Target $subtitleTB -Family $script:AppFontFamily
$subtitleTB.FontSize = 12
$subtitleTB.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$subtitleTB.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$outer.Children.Add($subtitleTB) | Out-Null
$modePanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$modePanel.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$modePanel.Spacing = 8
$rbSingle = [WinUIShell.Microsoft.UI.Xaml.Controls.RadioButton]::new()
$rbSingle.Content = "Single value"
$rbSingle.GroupName = "BatchEditMode"
$rbSingle.IsChecked = $true
$rbToggle = [WinUIShell.Microsoft.UI.Xaml.Controls.RadioButton]::new()
$rbToggle.Content = "Toggle"
$rbToggle.GroupName = "BatchEditMode"
$rbToggle.IsChecked = $false
$rbPer = [WinUIShell.Microsoft.UI.Xaml.Controls.RadioButton]::new()
$rbPer.Content = "Per-flag"
$rbPer.GroupName = "BatchEditMode"
$rbPer.IsChecked = $false
Set-ThemedRadioButtonResources -Control $rbSingle
Set-ThemedRadioButtonResources -Control $rbToggle
Set-ThemedRadioButtonResources -Control $rbPer
$modePanel.Children.Add($rbSingle) | Out-Null
$modePanel.Children.Add($rbToggle) | Out-Null
$modePanel.Children.Add($rbPer) | Out-Null
$outer.Children.Add($modePanel) | Out-Null
$singlePanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$singlePanel.Spacing = 8
$singleLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$singleLabel.Text = "Apply this value to all selected FFlags:"
Set-SafeFontFamily -Target $singleLabel -Family $script:AppFontFamily
$singleLabel.FontSize = 13
$singleLabel.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$singleLabel.MaxWidth = 480
$singleLabel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$singleBox = New-ThemedTextBox -Placeholder "New value"
$singleBox.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$singlePanel.Children.Add($singleLabel) | Out-Null
$singlePanel.Children.Add($singleBox) | Out-Null
$outer.Children.Add($singlePanel) | Out-Null
$togglePanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$togglePanel.Spacing = 8
$toggleLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$toggleLabel.Text = "Will toggle selected FFlags.`nBoolean values (true/false) flip; non-boolean values are skipped."
Set-SafeFontFamily -Target $toggleLabel -Family $script:AppFontFamily
$toggleLabel.FontSize = 13
$toggleLabel.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$toggleLabel.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$toggleLabel.MaxWidth = 480
$toggleLabel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$togglePanel.Children.Add($toggleLabel) | Out-Null
$outer.Children.Add($togglePanel) | Out-Null
$perRowRefs = @{}
$perPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$perPanel.Spacing = 4
$perCapped = ($count -gt 100)
if ($perCapped) {
$rbPer.IsEnabled = $false
$perCapNote = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$perCapNote.Text = "Per-flag mode disabled when more than 100 FFlags are selected (you have $count)."
Set-SafeFontFamily -Target $perCapNote -Family $script:AppFontFamily
$perCapNote.FontSize = 12
$perCapNote.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$perCapNote.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$perCapNote.MaxWidth = 480
$perCapNote.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Left
$perPanel.Children.Add($perCapNote) | Out-Null
} else {
foreach ($name in $selected) {
$row = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$cName = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$cName.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(3, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$cVal = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$cVal.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$row.ColumnDefinitions.Add($cName) | Out-Null
$row.ColumnDefinitions.Add($cVal) | Out-Null
$nameTB = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nameTB.Text = $name
Set-SafeFontFamily -Target $nameTB -Family $script:AppFontFamily
$nameTB.FontSize = 13
$nameTB.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$nameTB.TextTrimming = [WinUIShell.Microsoft.UI.Xaml.TextTrimming]::CharacterEllipsis
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($nameTB, 0)
$row.Children.Add($nameTB) | Out-Null
$cur = $script:Flags[$name].ToString()
$valTB = New-ThemedTextBox -Text $cur -Placeholder "Value"
$valTB.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($valTB, 1)
$row.Children.Add($valTB) | Out-Null
$perRowRefs[$name] = $valTB
$perPanel.Children.Add($row) | Out-Null
}
}
$perScroll = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollViewer]::new()
$perScroll.Content = $perPanel
$perScroll.MaxHeight = 320
$perScroll.VerticalScrollBarVisibility = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollBarVisibility]::Auto
$perScroll.HorizontalScrollBarVisibility = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollBarVisibility]::Disabled
$outer.Children.Add($perScroll) | Out-Null
Set-ControlVisible -Control $singlePanel -IsVisible $true
Set-ControlVisible -Control $togglePanel -IsVisible $false
Set-ControlVisible -Control $perScroll -IsVisible $false
$rbSingle.AddChecked({
param($argumentList, $s, $e)
try {
Set-ControlVisible -Control $singlePanel -IsVisible $true
Set-ControlVisible -Control $togglePanel -IsVisible $false
Set-ControlVisible -Control $perScroll -IsVisible $false
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}.GetNewClosure())
$rbToggle.AddChecked({
param($argumentList, $s, $e)
try {
Set-ControlVisible -Control $singlePanel -IsVisible $false
Set-ControlVisible -Control $togglePanel -IsVisible $true
Set-ControlVisible -Control $perScroll -IsVisible $false
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}.GetNewClosure())
$rbPer.AddChecked({
param($argumentList, $s, $e)
try {
Set-ControlVisible -Control $singlePanel -IsVisible $false
Set-ControlVisible -Control $togglePanel -IsVisible $false
Set-ControlVisible -Control $perScroll -IsVisible $true
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}.GetNewClosure())
$titleText = "Batch Edit"
Write-ConsoleLog -Message ('[editor-menu:BatchEdit] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$result = Show-CustomDialog -XamlRoot $xamlRoot -Title $titleText -Content $outer -PrimaryButtonText "Apply" -CloseButtonText "Cancel"
if ($result -ne "Primary") { return }
Push-UndoState -Action "Batch Edit" -Snapshot (Get-CurrentFlagSnapshot)
$updated = 0
$skipped = 0
if ($rbSingle.IsChecked) {
$newValue = $singleBox.Text.Trim()
foreach ($name in $selected) {
if ($script:Flags.ContainsKey($name)) {
$script:Flags[$name] = $newValue
$updated++
}
}
} elseif ($rbToggle.IsChecked) {
foreach ($name in $selected) {
if (-not $script:Flags.ContainsKey($name)) { continue }
$cur = $script:Flags[$name].ToString()
$flipped = $null
if ($cur -ieq "true") { $flipped = "false" }
elseif ($cur -ieq "false") { $flipped = "true" }
if ($null -ne $flipped) {
$script:Flags[$name] = $flipped
$updated++
} else {
Write-ConsoleLog -Message "Batch Edit toggle: skipped non-boolean '$name' = '$cur'" -Level "INFO"
$skipped++
}
}
} else {
foreach ($name in $selected) {
$tb = $perRowRefs[$name]
if ($null -eq $tb) { continue }
$newValue = $tb.Text.Trim()
$oldValue = $script:Flags[$name].ToString()
if ($newValue -ne $oldValue) {
$script:Flags[$name] = $newValue
$updated++
}
}
}
try { Save-Flags } catch { Write-ConsoleLog -Message "Batch Edit: in-memory state updated but Save-Flags failed: $_" -Level "ERROR" }
Editor-RefreshFlagList
if ($skipped -gt 0) {
Write-ConsoleLog -Message "Batch edit: $updated FFlag(s) updated, $skipped skipped." -Level "INFO"
} else {
Write-ConsoleLog -Message "Batch edit: $updated FFlag(s) updated." -Level "INFO"
}
}
function Editor-TogglePinSelected {
Editor-ResolveSelection
$selNames = @($script:EditorSelectedNames | Where-Object { $null -ne $_ })
if ($selNames.Count -eq 0) { return }
$allPinned = $true
foreach ($name in $selNames) {
if ($script:Settings.pinnedFlags -notcontains $name) { $allPinned = $false; break }
}
if ($allPinned) {
foreach ($name in $selNames) {
$script:Settings.pinnedFlags = @($script:Settings.pinnedFlags | Where-Object { $_ -ne $name })
Write-ConsoleLog -Message "Unpinned: $name" -Level "INFO"
}
} else {
foreach ($name in $selNames) {
if ($script:Settings.pinnedFlags -notcontains $name) {
$script:Settings.pinnedFlags += $name
Write-ConsoleLog -Message "Pinned: $name" -Level "INFO"
}
}
}
Save-Settings
Editor-RefreshFlagList
}
function Editor-ExportJson {
if ($null -eq $script:EditorWindow -or $null -eq $script:EditorWindow.Content) { return }
if ($script:ExportDialogOpen) { return }
$script:ExportDialogOpen = $true
try {
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$sfd = [System.Windows.Forms.SaveFileDialog]::new()
$sfd.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*"
$sfd.FileName = "allium-fflags.json"
$sfd.Title = "Export FFlags"
if ((Show-FileDialogWithOwner -Dialog $sfd) -eq [System.Windows.Forms.DialogResult]::OK) {
try {
$json = $script:Flags | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($sfd.FileName, $json)
Write-ConsoleLog -Message "FFlags exported to $($sfd.FileName)" -Level "INFO"
Show-EditorNotification -Title "Exported!" -Message "FFlags saved to $($sfd.FileName)"
} catch {
Write-ConsoleLog -Message "Export write failed: $_" -Level "ERROR"
}
} else {
Write-ConsoleLog -Message "Export cancelled by user." -Level "INFO"
}
} finally {
$script:ExportDialogOpen = $false
}
}
function Profile-NewFlyout {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:Profiles] entered' -Level 'INFO'
$profDir = Join-Path (Ensure-DataFolder) "profiles"
$profiles = @()
if (Test-Path $profDir) {
$profiles = @(Get-ChildItem -Path $profDir -Filter "*.json" -File | Sort-Object Name)
}
$fingerprintParts = foreach ($pf in $profiles) {
$pf.Name + '|' + $pf.Length + '|' + $pf.LastWriteTimeUtc.Ticks
}
$profileFingerprint = ($fingerprintParts -join ';')
if ($null -ne $script:CachedProfilesFlyout -and $script:CachedProfilesFingerprint -ceq $profileFingerprint) {
Write-ConsoleLog -Message ('[editor-menu:Profiles] cache-hit=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
return $script:CachedProfilesFlyout
}
$items = [System.Collections.Generic.List[object]]::new()
$items.Add((New-MenuFlyoutItem -Text "Save Profile..." -Glyph ([char]0xE74E) -OnClick { Profile-Save }))
$items.Add((New-MenuFlyoutItem -Text "Load Profile..." -Glyph ([char]0xE8E5) -OnClick { Profile-Load }))
$items.Add((New-MenuFlyoutItem -Text "Merge Profiles..." -Glyph ([char]0xE8FD) -OnClick { Profile-Merge }))
$items.Add((New-MenuFlyoutSeparator))
if ($profiles.Count -gt 0) {
foreach ($pf in $profiles) {
$name = [System.IO.Path]::GetFileNameWithoutExtension($pf.Name)
$localName = $name
$sub = New-MenuFlyoutSubItem -Text $name -Glyph ([char]0xE8A5)
$sub.Items.Add((New-MenuFlyoutItem -Text "Load" -Glyph ([char]0xE8E5) -OnClick { Profile-LoadByName -Name $localName }.GetNewClosure())) | Out-Null
$sub.Items.Add((New-MenuFlyoutItem -Text "Update" -Glyph ([char]0xE72C) -OnClick { Profile-UpdateByName -Name $localName }.GetNewClosure())) | Out-Null
$sub.Items.Add((New-MenuFlyoutItem -Text "Delete" -Glyph ([char]0xE74D) -OnClick { Profile-DeleteByName -Name $localName }.GetNewClosure())) | Out-Null
$items.Add($sub)
}
} else {
$items.Add((New-MenuFlyoutItem -Text "(no profiles saved)" -IsEnabled $false))
}
$flyout = New-ContextMenu -Items $items
$script:CachedProfilesFlyout = $flyout
$script:CachedProfilesFingerprint = $profileFingerprint
Write-ConsoleLog -Message ('[editor-menu:Profiles] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
return $flyout
}
function Profile-Save {
Write-ConsoleLog -Message "Profile-Save: Flags=$($script:Flags.Count)" -Level "INFO"
if ($null -eq $script:EditorWindow) { return }
if ($script:Flags.Count -eq 0) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$result = Show-InputDialog -XamlRoot $xamlRoot -Title "Save Profile" -Label "Profile name:" -DefaultValue ""
Write-ConsoleLog -Message "Input: Success=$($result.Success) Value='$($result.Value)'" -Level "INFO"
if (-not $result.Success) { return }
$name = $result.Value.Trim()
if ([string]::IsNullOrWhiteSpace($name)) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Save Profile" -Content "Profile name cannot be empty." -CloseButtonText "OK"
return
}
$invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
foreach ($c in $name.ToCharArray()) {
if ($c -in $invalidChars) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Save Profile" -Content "Profile name contains invalid characters." -CloseButtonText "OK"
return
}
}
$profDir = Join-Path (Ensure-DataFolder) "profiles"
Ensure-ProfilesFolder | Out-Null
$profPath = Join-Path $profDir "$name.json"
if (Test-Path $profPath) {
$confirm = Show-ConfirmDialog -XamlRoot $xamlRoot -Title "Overwrite Profile?" -Message "Profile '$name' already exists. Overwrite?"
if (-not $confirm) { return }
}
$exportData = @{}
foreach ($key in $script:Flags.Keys) {
$exportData[$key] = $script:Flags[$key]
}
Write-Json -Path $profPath -Data $exportData
Write-ConsoleLog -Message "Profile '$name' saved `($($exportData.Count) FFlags`)." -Level "INFO"
Show-TeachingTip -XamlRoot $xamlRoot -Title "Profile Saved" -Message "'$name' saved with $($exportData.Count) FFlags."
}
function Profile-Load {
if ($null -eq $script:EditorWindow) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$profDir = Join-Path (Ensure-DataFolder) "profiles"
Ensure-ProfilesFolder | Out-Null
$profiles = @(Get-ChildItem -Path $profDir -Filter "*.json" -File | Sort-Object Name)
if ($profiles.Count -eq 0) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Load Profile" -Content "No profiles found. Save a profile first." -CloseButtonText "OK"
return
}
$list = New-ThemedListView
$list.MaxHeight = 300
$list.SelectionMode = [WinUIShell.Microsoft.UI.Xaml.Controls.ListViewSelectionMode]::Single
foreach ($pf in $profiles) {
$pName = [System.IO.Path]::GetFileNameWithoutExtension($pf.Name)
$data = Read-Json -Path $pf.FullName
$count = if ($null -ne $data) { $data.Count } else { 0 }
$row = New-ProfileListRow -Name $pName -Count $count
$list.Items.Add($row) | Out-Null
}
$result = Show-CustomDialog -XamlRoot $xamlRoot -Title "Load Profile" -Content $list -PrimaryButtonText "Load" -CloseButtonText "Cancel"
if ($result -ne "Primary") { return }
$sel = $list.SelectedItem
if ($null -eq $sel) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Load Profile" -Content "Select a profile to load." -CloseButtonText "OK"
return
}
$selName = $sel.Tag
Profile-LoadByName -Name $selName
}
function Profile-LoadByName {
param([string]$Name)
if ($null -eq $script:EditorWindow) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$profPath = Join-Path (Join-Path (Ensure-DataFolder) "profiles") "$Name.json"
if (-not (Test-Path $profPath)) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Load Profile" -Content "Profile '$Name' not found." -CloseButtonText "OK"
return
}
$confirm = Show-ConfirmDialog -XamlRoot $xamlRoot -Title "Load Profile?" -Message "Loading '$Name' will replace all current FFlags. Continue?"
if (-not $confirm) { return }
$data = Read-Json -Path $profPath
if ($null -eq $data) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Load Profile" -Content "Profile '$Name' is empty or corrupt." -CloseButtonText "OK"
return
}
$diff = New-FlagDiff -Current $script:Flags -Incoming $data -IsReplace
if ($diff.Additions.Count -gt 0 -or $diff.Removals.Count -gt 0 -or $diff.Changes.Count -gt 0) {
$applyDiff = Show-FlagDiffDialog -Diff $diff -Current $script:Flags -Incoming $data -DialogTitle "Load Profile: $Name"
if (-not $applyDiff) { return }
}
Push-UndoState -Action "Load Profile '$Name'" -Snapshot (Get-CurrentFlagSnapshot)
$script:Flags = @{}
foreach ($key in $data.Keys) {
$script:Flags[$key] = $data[$key]
}
Save-Flags
Editor-RefreshFlagList
Write-ConsoleLog -Message "Loaded profile '$Name' `($($data.Count) FFlags`)." -Level "INFO"
Show-TeachingTip -XamlRoot $xamlRoot -Title "Profile Loaded" -Message "'$Name' loaded with $($data.Count) FFlags."
}
function Profile-UpdateByName {
param([string]$Name)
if ($null -eq $script:EditorWindow) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$profPath = Join-Path (Join-Path (Ensure-DataFolder) "profiles") "$Name.json"
if (-not (Test-Path $profPath)) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Update Profile" -Content "Profile '$Name' not found." -CloseButtonText "OK"
return
}
$confirm = Show-ConfirmDialog -XamlRoot $xamlRoot -Title "Update Profile?" -Message "Update '$Name' with current FFlags ($($script:Flags.Count))?"
if (-not $confirm) { return }
$exportData = @{}
foreach ($key in $script:Flags.Keys) {
$exportData[$key] = $script:Flags[$key]
}
Write-Json -Path $profPath -Data $exportData
Write-ConsoleLog -Message "Profile '$Name' updated `($($exportData.Count) FFlags`)." -Level "INFO"
Show-TeachingTip -XamlRoot $xamlRoot -Title "Profile Updated" -Message "'$Name' updated with $($exportData.Count) FFlags."
}
function Profile-DeleteByName {
param([string]$Name)
if ($null -eq $script:EditorWindow) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$profPath = Join-Path (Join-Path (Ensure-DataFolder) "profiles") "$Name.json"
if (-not (Test-Path $profPath)) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Delete Profile" -Content "Profile '$Name' not found." -CloseButtonText "OK"
return
}
$confirm = Show-ConfirmDialog -XamlRoot $xamlRoot -Title "Delete Profile?" -Message "Permanently delete profile '$Name'?"
if (-not $confirm) { return }
Remove-Item -Path $profPath -Force
Write-ConsoleLog -Message "Profile '$Name' deleted." -Level "INFO"
Show-TeachingTip -XamlRoot $xamlRoot -Title "Profile Deleted" -Message "'$Name' has been deleted."
}
function Profile-Merge {
if ($null -eq $script:EditorWindow) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
$profDir = Join-Path (Ensure-DataFolder) "profiles"
Ensure-ProfilesFolder | Out-Null
$profiles = @(Get-ChildItem -Path $profDir -Filter "*.json" -File | Sort-Object Name)
if ($profiles.Count -eq 0) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Merge Profiles" -Content "No profiles found. Save a profile first." -CloseButtonText "OK"
return
}
if ($profiles.Count -lt 2) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Merge Profiles" -Content "At least 2 profiles are needed to merge." -CloseButtonText "OK"
return
}
$list = New-ThemedListView
$list.MaxHeight = 300
$list.SelectionMode = [WinUIShell.Microsoft.UI.Xaml.Controls.ListViewSelectionMode]::Multiple
foreach ($pf in $profiles) {
$pName = [System.IO.Path]::GetFileNameWithoutExtension($pf.Name)
$data = Read-Json -Path $pf.FullName
$count = if ($null -ne $data) { $data.Count } else { 0 }
$row = New-ProfileListRow -Name $pName -Count $count
$list.Items.Add($row) | Out-Null
}
$result = Show-CustomDialog -XamlRoot $xamlRoot -Title "Merge Profiles" -Content $list -PrimaryButtonText "Merge" -CloseButtonText "Cancel"
if ($result -ne "Primary") { return }
$selected = @($list.SelectedItems)
if ($selected.Count -lt 2) {
Show-CustomDialog -XamlRoot $xamlRoot -Title "Merge Profiles" -Content "Select at least 2 profiles to merge." -CloseButtonText "OK"
return
}
$merged = @{}
$conflicts = @{}
foreach ($key in $script:Flags.Keys) {
$merged[$key] = $script:Flags[$key]
}
foreach ($selItem in $selected) {
$pName = $selItem.Tag
$profPath = Join-Path $profDir "$pName.json"
$data = Read-Json -Path $profPath
if ($null -eq $data) { continue }
foreach ($key in $data.Keys) {
if ($merged.ContainsKey($key)) {
if ($merged[$key].ToString() -ne $data[$key].ToString()) {
if (-not $conflicts.ContainsKey($key)) {
$conflicts[$key] = @($merged[$key])
}
$conflicts[$key] = @($conflicts[$key]) + @($data[$key])
}
}
$merged[$key] = $data[$key]
}
}
if ($conflicts.Count -gt 0) {
$conflictPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$conflictPanel.Spacing = 8
$hdr = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$hdr.Text = "$($conflicts.Count) conflicting FFlag(s) detected. Using values from the last selected profile."
Set-SafeFontFamily -Target $hdr -Family $script:AppFontFamily
$hdr.FontSize = 13
$hdr.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$hdr.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$conflictPanel.Children.Add($hdr) | Out-Null
foreach ($cKey in $conflicts.Keys) {
$tb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$tb.Text = "$cKey = $($merged[$cKey])"
$tb.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Cascadia Code, Consolas, monospace")
$tb.FontSize = 12
$tb.Foreground = New-SolidBrush -Hex $script:ThemeColors.Warning
$tb.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$conflictPanel.Children.Add($tb) | Out-Null
}
$sv = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollViewer]::new()
$sv.Content = $conflictPanel
$sv.MaxHeight = 300
$sv.VerticalScrollBarVisibility = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollBarVisibility]::Auto
$cResult = Show-CustomDialog -XamlRoot $xamlRoot -Title "Merge Conflicts" -Content $sv -PrimaryButtonText "Continue" -CloseButtonText "Cancel"
if ($cResult -ne "Primary") {
return
}
}
$diff = New-FlagDiff -Current $script:Flags -Incoming $merged
if ($diff.Additions.Count -gt 0 -or $diff.Changes.Count -gt 0) {
$applyDiff = Show-FlagDiffDialog -Diff $diff -Current $script:Flags -Incoming $merged -DialogTitle "Merge Profiles: Preview"
if (-not $applyDiff) {
return
}
}
Push-UndoState -Action "Merge Profiles" -Snapshot (Get-CurrentFlagSnapshot)
foreach ($key in $merged.Keys) {
$script:Flags[$key] = $merged[$key]
}
Save-Flags
Editor-RefreshFlagList
$totalAdded = $merged.Count - $script:Flags.Count
Write-ConsoleLog -Message "Merged $($selected.Count) profile(s), $($merged.Count) total FFlags." -Level "INFO"
Show-TeachingTip -XamlRoot $xamlRoot -Title "Profiles Merged" -Message "$($selected.Count) profiles merged. $($merged.Count) FFlags total."
}
function New-ProfileListRow {
param([string]$Name, [int]$Count)
$grid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$grid.Tag = $Name
$col1 = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$col1.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$col2 = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$col2.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(0, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($col1) | Out-Null
$grid.ColumnDefinitions.Add($col2) | Out-Null
$nameBlock = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nameBlock.Text = $Name
Set-SafeFontFamily -Target $nameBlock -Family $script:AppFontFamily
$nameBlock.FontSize = 14
$nameBlock.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$nameBlock.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($nameBlock, 0)
$grid.Children.Add($nameBlock) | Out-Null
$countBlock = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$countBlock.Text = "$Count FFlags"
Set-SafeFontFamily -Target $countBlock -Family $script:AppFontFamily
$countBlock.FontSize = 12
$countBlock.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$countBlock.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$countBlock.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(8, 0, 0, 0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($countBlock, 1)
$grid.Children.Add($countBlock) | Out-Null
$padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(4, 6, 4, 6)
$grid.Padding = $padding
return $grid
}
function Editor-AdvancedSettings {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:Settings] entered' -Level 'INFO'
$__prepDlg = $null
$__prepDlgResult = @{ Result = $null; Done = $false }
try {
$__prepPagesIncomplete = $false
try {
if ($null -eq $script:SettingsPages) {
$__prepPagesIncomplete = $true
} elseif ($script:SettingsPages.Count -lt 6) {
$__prepPagesIncomplete = $true
}
} catch { $__prepPagesIncomplete = $true }
if ($__prepPagesIncomplete) {
Write-ConsoleLog -Message '[settings-prepare] user clicked Settings while prewarm active; showing progress dialog' -Level 'INFO'
try { $script:SettingsPrewarmTimer.Stop() } catch { }
$__prepXR = $null
try { $__prepXR = $script:EditorWindow.Content.XamlRoot } catch { $__prepXR = $null }
if ($null -ne $__prepXR) {
try {
$__prepProg = New-DumperProgressDialog -Title 'Preparing Settings...' -Message 'Warming Settings tabs for smooth switching. This takes a few seconds.' -XamlRoot $__prepXR
$__prepDlg = $__prepProg.Dialog
$script:SettingsPrepareDialog = $__prepDlg
try { Start-SettingsTabPrewarm } catch { }
Write-ConsoleLog -Message ('[editor-menu:Settings] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
try { $__prepDlg.ShowAsync().WaitForCompleted() | Out-Null } catch {
Write-ConsoleLog -Message ('[settings-prepare] dialog show failed: ' + $_.Exception.Message) -Level 'WARN'
}
try { $script:SettingsPrepareDialog = $null } catch { }
Write-ConsoleLog -Message '[settings-prepare] prewarm complete; opening Settings' -Level 'INFO'
} catch {
Write-ConsoleLog -Message ('[settings-prepare] progress dialog exception: ' + $_.Exception.Message) -Level 'WARN'
}
} else {
Write-ConsoleLog -Message '[settings-prepare] no Editor XamlRoot available; skipping progress dialog' -Level 'WARN'
}
}
Write-ConsoleLog -Message ('[editor-menu:Settings] before-window-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
Show-SettingsWindow
} catch {
try { if ($null -ne $__prepDlg) { $__prepDlg.Hide() } } catch { }
Write-ConsoleLog -Message ('Show-SettingsWindow failed: ' + $_.Exception.Message) -Level 'ERROR'
}
}
function Editor-CleanList {
$__menuDiagT0 = [datetime]::UtcNow
Write-ConsoleLog -Message '[editor-menu:CleanList] entered' -Level 'INFO'
if ($script:Flags -isnot [hashtable]) { $script:Flags = @{}; return }
if ($null -eq $script:EditorWindow -or $null -eq $script:EditorWindow.Content) { return }
if ($script:Flags.Count -eq 0) { return }
$xamlRoot = $script:EditorWindow.Content.XamlRoot
function New-CleanListToggleRow {
param([string] $Label, [object] $Toggle)
$grid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colText = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colText.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$grid.ColumnDefinitions.Add($colText) | Out-Null
$colSw = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colSw.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($colSw) | Out-Null
$lbl = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$lbl.Text = $Label
Set-SafeFontFamily -Target $lbl -Family $script:AppFontFamily
$lbl.FontSize = 14
$lbl.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$lbl.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$lbl.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$lbl.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 16, 0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($lbl, 0)
$grid.Children.Add($lbl) | Out-Null
$Toggle.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$Toggle.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
try { $Toggle.MinWidth = 0 } catch { }
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($Toggle, 1)
$grid.Children.Add($Toggle) | Out-Null
return $grid
}
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 12
$panel.MinWidth = 480
$cbEmpty = New-ThemedToggleSwitch -IsOn $true
$cbDupes = New-ThemedToggleSwitch -IsOn $true
$cbInvalid = New-ThemedToggleSwitch -IsOn $false
$panel.Children.Add((New-CleanListToggleRow -Label "Remove empty/null values" -Toggle $cbEmpty)) | Out-Null
$panel.Children.Add((New-CleanListToggleRow -Label "Remove duplicates by name" -Toggle $cbDupes)) | Out-Null
$panel.Children.Add((New-CleanListToggleRow -Label "Remove invalid FFlags (not in browser cache)" -Toggle $cbInvalid)) | Out-Null
$cacheHint = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$cacheHint.Text = "If empty, open the FFlag Browser once to populate the cache."
Set-SafeFontFamily -Target $cacheHint -Family $script:AppFontFamily
$cacheHint.FontSize = 11
$cacheHint.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$cacheHint.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$cacheHint.MaxWidth = 480
$cacheHint.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, -8, 0, 0)
$panel.Children.Add($cacheHint) | Out-Null
Write-ConsoleLog -Message ('[editor-menu:CleanList] build-before-show=' + [int]([datetime]::UtcNow - $__menuDiagT0).TotalMilliseconds + 'ms') -Level 'INFO'
$result = Show-CustomDialog -XamlRoot $xamlRoot -Title "Clean FFlag List" -Content $panel -PrimaryButtonText "Clean" -CloseButtonText "Cancel"
if ($result -ne "Primary") { return }
$preCleanSnapshot = Get-CurrentFlagSnapshot
$removed = 0
if ($cbEmpty.IsOn) {
$toRemove = @()
foreach ($key in $script:Flags.Keys) {
$val = $script:Flags[$key]
if ($null -eq $val -or [string]::IsNullOrWhiteSpace($val.ToString())) {
$toRemove += $key
}
}
foreach ($key in $toRemove) { $script:Flags.Remove($key) }
$removed += $toRemove.Count
}
if ($cbDupes.IsOn) {
$seen = @{}
$dupeGroups = @{}
$toRemove = @()
foreach ($key in $script:Flags.Keys) {
$lower = $key.ToLower()
if ($seen.ContainsKey($lower)) {
$toRemove += $key
if (-not $dupeGroups.ContainsKey($lower)) {
$dupeGroups[$lower] = @($seen[$lower], $script:Flags[$seen[$lower]])
}
$dupeGroups[$lower] += @($key, $script:Flags[$key])
} else {
$seen[$lower] = $key
}
}
$conflicts = @{}
foreach ($lower in $dupeGroups.Keys) {
$values = @()
for ($i = 1; $i -lt $dupeGroups[$lower].Count; $i += 2) {
$values += $dupeGroups[$lower][$i].ToString()
}
$uniqueValues = $values | Select-Object -Unique
if ($uniqueValues.Count -gt 1) { $conflicts[$lower] = $dupeGroups[$lower] }
}
if ($conflicts.Count -gt 0) {
$conflictPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$conflictPanel.Spacing = 8
$hdr = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$hdr.Text = "$($conflicts.Count) duplicate(s) have conflicting values. Choose which to keep:"
Set-SafeFontFamily -Target $hdr -Family $script:AppFontFamily
$hdr.FontSize = 13
$hdr.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$hdr.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$conflictPanel.Children.Add($hdr) | Out-Null
foreach ($lower in $conflicts.Keys) {
$group = $conflicts[$lower]
$tb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$entries = @()
for ($i = 0; $i -lt $group.Count; $i += 2) { $k = $group[$i]; $v = $group[$i+1]; $entries += "$k = $v" }
$joinSep = " | "
$tb.Text = ($entries -join $joinSep)
$tb.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Cascadia Code, Consolas, monospace")
$tb.FontSize = 12
$tb.Foreground = New-SolidBrush -Hex $script:ThemeColors.Warning
$tb.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$conflictPanel.Children.Add($tb) | Out-Null
}
$sv = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollViewer]::new()
$sv.Content = $conflictPanel
$sv.MaxHeight = 300
$cResult = Show-CustomDialog -XamlRoot $xamlRoot -Title "Duplicate Conflicts" -Content $sv -PrimaryButtonText "Keep Last" -SecondaryButtonText "Keep First" -CloseButtonText "Cancel"
if ($cResult -eq "None") { Write-ConsoleLog -Message "Clean List cancelled at duplicate conflict; restored snapshot." -Level "WARN"; $script:Flags = $preCleanSnapshot.Clone(); return }
if ($cResult -eq "Primary") {
$toRemove = @()
foreach ($lower in $dupeGroups.Keys) {
$group = $dupeGroups[$lower]
$keys = @()
for ($i = 0; $i -lt $group.Count; $i += 2) { $keys += $group[$i] }
for ($i = 0; $i -lt ($keys.Count - 1); $i++) { $toRemove += $keys[$i] }
}
}
}
foreach ($key in $toRemove) { $script:Flags.Remove($key) }
$removed += $toRemove.Count
}
if ($cbInvalid.IsOn -and $null -ne $script:FlagBrowserCache -and $script:FlagBrowserCache.Count -gt 0) {
$rawSet = @{}
if ($null -ne $script:BrowserRawNameMap -and $script:BrowserRawNameMap.Count -gt 0) {
foreach ($rk in $script:BrowserRawNameMap.Keys) { $rawSet[$rk] = $true }
} else {
foreach ($bKey in $script:FlagBrowserCache.Keys) {
$bEntry = $script:FlagBrowserCache[$bKey]
if ($null -ne $bEntry -and -not [string]::IsNullOrWhiteSpace($bEntry.RawName)) {
$rawSet[$bEntry.RawName.ToLower()] = $true
}
}
}
$toRemove = @()
foreach ($key in $script:Flags.Keys) {
if ($script:FlagBrowserCache.ContainsKey($key)) { continue }
$raw = if ($key -match '^(D?F|SF)(Flag|Int|String|Log)(.+)$') { $Matches[3] } else { $key }
if ($rawSet.ContainsKey($raw.ToLower())) { continue }
$toRemove += $key
}
foreach ($key in $toRemove) { $script:Flags.Remove($key) }
$removed += $toRemove.Count
} elseif ($cbInvalid.IsOn) {
Write-ConsoleLog -Message "Clean List: browser cache is empty, so invalid-flag removal was skipped (nothing removed). Open the FFlag Browser once to enable it." -Level "WARN"
}
if ($removed -gt 0) {
Push-UndoState -Action "Clean List" -Snapshot $preCleanSnapshot
try { Save-Flags } catch { Write-ConsoleLog -Message "Clean List: in-memory state updated but Save-Flags failed: $_" -Level "ERROR" }
Editor-RefreshFlagList
Write-ConsoleLog -Message "Cleaned: removed $removed FFlag(s)." -Level "INFO"
} else {
Write-ConsoleLog -Message "Clean List: no flags removed." -Level "INFO"
}
}
$script:LauncherWindow = $null
$script:LauncherSkipTray = $false
function New-LauncherMenuWindow {
$window = [WinUIShell.Microsoft.UI.Xaml.Window]::new()
$window.Title = $script:AppTitle
$window.ExtendsContentIntoTitleBar = $true
try {
$appWindow = $window.AppWindow
$appWindow.Resize(460, 325)
Center-Window -AppWindow $appWindow -Width 460 -Height 325
$iconFile = (Resolve-Path $script:IconPath).Path
$appWindow.SetIcon($iconFile)
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
try {
$presenter = $appWindow.Presenter
$presenter.PreferredMinimumWidth = 420
$presenter.PreferredMinimumHeight = 325
} catch {
Write-ConsoleLog -Message "OverlappedPresenter min size not available: $_" -Level "WARN"
}
$xAppFont = [System.Security.SecurityElement]::Escape([string]$script:AppFontFamily.Source)
$xPrimary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextPrimary)
$xSecondary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextSecondary)
$xDividers = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.Dividers)
$xStatus = [System.Security.SecurityElement]::Escape([string](Get-BootstrapperStatusText))
$launcherXaml = @"
<Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="LauncherRoot" RequestedTheme="Dark" Padding="20,2,20,12" Background="#D21C0808">
  <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
  <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="2*"/></Grid.ColumnDefinitions>
  <Grid x:Name="TitleRegion" Grid.Row="0" Grid.ColumnSpan="2" Padding="0,2,0,2" MinHeight="32" Background="Transparent"/>
  <StackPanel Grid.Row="1" Grid.Column="0" Orientation="Vertical" Spacing="2" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="0,15,10,0">
    <Border x:Name="AppIconHost" Width="80" Height="80" HorizontalAlignment="Center"/>
    <TextBlock Text="Allium" FontFamily="$xAppFont" FontSize="22" FontWeight="Bold" Foreground="$xPrimary" HorizontalAlignment="Center"/>
    <TextBlock Text="v1.0.0" FontFamily="$xAppFont" FontSize="12" Foreground="$xSecondary" HorizontalAlignment="Center" Margin="0,-3,0,0"/>
  </StackPanel>
  <StackPanel Grid.Row="1" Grid.Column="1" Orientation="Vertical" Spacing="8" HorizontalAlignment="Stretch" VerticalAlignment="Center" Margin="0,15,0,0">
    <Border x:Name="LaunchHost" HorizontalAlignment="Stretch"/>
    <Border x:Name="ConfigureHost" HorizontalAlignment="Stretch"/>
    <Border x:Name="BootstrapperHost" HorizontalAlignment="Stretch"/>
  </StackPanel>
  <Border Grid.Row="2" Grid.ColumnSpan="2" BorderBrush="$xDividers" BorderThickness="0,1,0,0" Padding="0,16,0,8" HorizontalAlignment="Stretch">
    <TextBlock x:Name="BootstrapperStatusText" Text="$xStatus" FontFamily="$xAppFont" FontSize="11" Foreground="$xSecondary" HorizontalAlignment="Center"/>
  </Border>
</Grid>
"@
$root = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($launcherXaml)
$titleRegion = $root.FindName('TitleRegion')
$appIconHost = $root.FindName('AppIconHost')
$launchHost = $root.FindName('LaunchHost')
$configureHost = $root.FindName('ConfigureHost')
$bootstrapperHost = $root.FindName('BootstrapperHost')
$bottomText = $root.FindName('BootstrapperStatusText')
$requiredLauncherParts = @{
TitleRegion = $titleRegion
AppIconHost = $appIconHost
LaunchHost = $launchHost
ConfigureHost = $configureHost
BootstrapperHost = $bootstrapperHost
BootstrapperStatusText = $bottomText
}
foreach ($partName in $requiredLauncherParts.Keys) {
if ($null -eq $requiredLauncherParts[$partName]) {
throw "P1274: XAML launcher part not found: $partName"
}
}
$window.SetTitleBar($titleRegion)
$appIcon = [WinUIShell.Microsoft.UI.Xaml.Controls.Image]::new()
$appIcon.Width = 80
$appIcon.Height = 80
$appIcon.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$iconLoaded = $false
$pngPath = $script:IconPath.Replace(".ico", ".png")
if (Test-Path $pngPath) {
try {
$absPath = (Resolve-Path $pngPath).Path
$fileUri = [WinUIShell.System.Uri]::new("file:///$($absPath.Replace('\','/'))")
$bmp = [WinUIShell.Microsoft.UI.Xaml.Media.Imaging.BitmapImage]::new()
$bmp.UriSource = $fileUri
$appIcon.Source = $bmp
$iconLoaded = $true
} catch { Write-ConsoleLog -Message "Failed to load PNG icon: $_" -Level "ERROR" }
}
if (-not $iconLoaded) {
try {
if (Test-Path $script:IconPath) {
$bmp = [WinUIShell.Microsoft.UI.Xaml.Media.Imaging.BitmapImage]::new()
$bmp.UriSource = [WinUIShell.System.Uri]::new($script:IconPath)
$appIcon.Source = $bmp
$iconLoaded = $true
}
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
}
if (-not $iconLoaded) {
$appIcon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$appIcon.Glyph = [char]0xE8F1
Set-SafeFontFamily -Target $appIcon -Family $script:IconFontFamily
$appIcon.FontSize = 64
$appIcon.Foreground = New-AccentBrush
$appIcon.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
}
$appIconHost.Child = $appIcon
$btnLaunch = New-ThemedButton -Content "Launch Roblox" -Glyph ([char]0xE768) -ToolbarStyle
$btnLaunch.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$btnLaunch.HorizontalContentAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$btnLaunch.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 10, 16, 10)
$btnLaunch.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnLaunch.AddClick({
try {
Invoke-LaunchRoblox
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
})
$launchHost.Child = $btnLaunch
$btnConfigure = New-ThemedButton -Content "Configure FFlags" -Glyph ([char]0xE713) -ToolbarStyle
$btnConfigure.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$btnConfigure.HorizontalContentAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$btnConfigure.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 10, 16, 10)
$btnConfigure.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$btnConfigure.AddClick({
try { Open-FFlagEditor } catch { Write-ConsoleLog -Message "Open-FFlagEditor error (non-fatal): $_" -Level "WARN" }
$script:LauncherSkipTray = $true
$launcherRef = $script:LauncherWindow
$closeDt = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$closeDt.Interval = New-UITimeSpan -Milliseconds 100
$closeDt.AddTick({
param($argumentList, $s, $e)
$s.Stop()
if ($null -ne $launcherRef) {
try { $launcherRef.Close() } catch {}
}
}.GetNewClosure())
$closeDt.Start()
})
$configureHost.Child = $btnConfigure
$bootSplitBtn = [WinUIShell.Microsoft.UI.Xaml.Controls.SplitButton]::new()
$bootSplitBtn.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$bootSplitBtn.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(32, 10, 0, 10)
$bootSplitBtn.CornerRadius = [WinUIShell.Microsoft.UI.Xaml.CornerRadius]::new(6)
$bootSplitBtn.Background = New-SolidBrush -Hex $script:ThemeColors.ButtonSurface
$bootSplitBtn.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
Set-SafeFontFamily -Target $bootSplitBtn -Family $script:AppFontFamily
$bootSplitBtn.AddClick({
param($argumentList, $s, $e)
try {
$boot = Get-SelectedBootstrapper
if ($null -ne $boot -and $boot.Found) {
Start-Process $boot.Path -ErrorAction Stop
Write-ConsoleLog -Message "Launched $($boot.Name)." -Level "INFO"
} else {
Write-ConsoleLog -Message "No bootstrapper selected or found." -Level "WARN"
}
} catch { Write-ConsoleLog -Message "Error launching bootstrapper: $_" -Level "ERROR" }
})
$bootFlyout = [WinUIShell.Microsoft.UI.Xaml.Controls.MenuFlyout]::new()
$bootSplitBtn.Flyout = $bootFlyout
Update-BootstrapperButton -Button $bootSplitBtn
$bootstrapperHost.Child = $bootSplitBtn
$script:LauncherBootstrapperButton = $bootSplitBtn
$script:LauncherBootstrapperFlyout = $bootFlyout
$script:LauncherBootstrapperStatusText = $bottomText
$window.Content = $root
Set-WindowTheme -Window $window
try {
$window.AppWindow.TitleBar.PreferredTheme = [WinUIShell.Microsoft.UI.Windowing.TitleBarTheme]::Dark
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
try {
$window.AppWindow.AddClosing({
param($argumentList, $s, $e)
Write-ConsoleLog -Message "Launcher AddClosing: toTray=$($script:Settings.minimizeToTray), trayIcon=$($null -ne $script:TrayNotifyIcon), skipTray=$($script:LauncherSkipTray)" -Level "INFO"
if ($script:Settings.minimizeToTray -and $null -ne $script:TrayNotifyIcon -and -not $script:LauncherSkipTray) {
$e.Cancel = $true
$window.AppWindow.Hide()
Show-TrayIcon
Write-ConsoleLog -Message "Minimized to system tray." -Level "INFO"
}
})
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$window.AddClosed({
$script:LauncherWindow = $null
})
$script:LauncherWindow = $window
return $window
}
function Get-BootstrapperStatusText {
$all = Get-AllBootstrappers
$found = $all | Where-Object { $_.Found }
if ($found.Count -eq 0) {
return "No bootstrappers detected"
}
$names = ($found | ForEach-Object { $_.Name }) -join ", "
return "Detected: $names"
}
function Update-BootstrapperButton {
param([object]$Button)
if ($null -eq $Button) { return }
$selected = Get-SelectedBootstrapper
$label = if ($null -ne $selected) { "Open $($selected.Name)" } else { "Open Bootstrapper" }
$stack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$stack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$stack.Spacing = 8
$stack.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$icon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$icon.Glyph = [char]0xE768
Set-SafeFontFamily -Target $icon -Family $script:IconFontFamily
$icon.FontSize = 14
$stack.Children.Add($icon) | Out-Null
$text = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$text.Text = $label
Set-SafeFontFamily -Target $text -Family $script:AppFontFamily
$text.FontSize = 14
$text.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$stack.Children.Add($text) | Out-Null
$Button.Content = $stack
}
function Refresh-BootstrapperFlyout {
if ($null -eq $script:LauncherBootstrapperFlyout -or $null -eq $script:LauncherWindow) { return }
try {
$script:LauncherBootstrapperFlyout.Items.Clear()
$xr = $script:LauncherWindow.Content.XamlRoot
if ($null -ne $xr) {
$items = Build-BootstrapperFlyoutItems -XamlRoot $xr
foreach ($fi in $items) { $script:LauncherBootstrapperFlyout.Items.Add($fi) | Out-Null }
}
} catch { }
}
function Build-BootstrapperFlyoutItems {
param([WinUIShell.Microsoft.UI.Xaml.XamlRoot]$XamlRoot)
$items = [System.Collections.Generic.List[object]]::new()
$all = Get-AllBootstrappers
$detected = $all | Where-Object { $_.Found -and $_.Priority -gt 0 }
$selected = Get-SelectedBootstrapper
$selectedName = if ($null -ne $selected) { $selected.Name } else { "" }
foreach ($b in $detected) {
$item = New-ToggleMenuFlyoutItem -Text $b.Name -IsChecked ($b.Name -eq $selectedName) -OnClick {
param($argumentList, $s, $e)
$bootName = $s.Text
$script:Settings.selectedBootstrapper = $bootName
Save-Settings
Update-BootstrapperButton -Button $script:LauncherBootstrapperButton
if ($null -ne $script:LauncherBootstrapperStatusText) {
$script:LauncherBootstrapperStatusText.Text = Get-BootstrapperStatusText
}
Refresh-BootstrapperFlyout
}
$items.Add($item) | Out-Null
}
foreach ($b in $script:CustomBootstrappers) {
$displayName = if ($b.Found) { $b.Name } else { "$($b.Name) (not found)" }
$item = New-ToggleMenuFlyoutItem -Text $displayName -IsChecked ($b.Name -eq $selectedName) -OnClick {
param($argumentList, $s, $e)
$bootName = $s.Text -replace ' \(not found\)$', ''
$script:Settings.selectedBootstrapper = $bootName
Save-Settings
Update-BootstrapperButton -Button $script:LauncherBootstrapperButton
if ($null -ne $script:LauncherBootstrapperStatusText) {
$script:LauncherBootstrapperStatusText.Text = Get-BootstrapperStatusText
}
Refresh-BootstrapperFlyout
}
if (-not $b.Found) {
$item.IsEnabled = $false
}
$items.Add($item) | Out-Null
}
$items.Add((New-MenuFlyoutSeparator)) | Out-Null
$addCustomItem = New-MenuFlyoutItem -Text "Add Custom..." -Glyph ([char]0xE710) -OnClick {
param($argumentList, $s, $e)
$launcherWin = $script:LauncherWindow
$settingsRef = $script:Settings
$bootBtn = $script:LauncherBootstrapperButton
$statusText = $script:LauncherBootstrapperStatusText
$themeSurface = $script:ThemeColors.Surface
$themeTextPrimary = $script:ThemeColors.TextPrimary
$themeTextSecondary = $script:ThemeColors.TextSecondary
$themeDividers = $script:ThemeColors.Dividers
$themeButtonSurface = $script:ThemeColors.ButtonSurface
$themeAccentColor = $script:AccentColor
$fontFamily = $script:AppFontFamily
$dt = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$dt.Interval = New-UITimeSpan -Milliseconds 150
$dt.AddTick({
param($argumentList, $ds, $de)
$ds.Stop()
try {
$xr = $launcherWin.Content.XamlRoot
if ($null -eq $xr) {
return
}
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$openDialog = [System.Windows.Forms.OpenFileDialog]::new()
$openDialog.Title = "Select Bootstrapper Executable"
$openDialog.Filter = "Executable files (*.exe)|*.exe|All files (*.*)|*.*"
$openDialog.FilterIndex = 1
$openDialog.Multiselect = $false
$dialogResult = Show-FileDialogWithOwner -Dialog $openDialog
if ($dialogResult -ne [System.Windows.Forms.DialogResult]::OK) {
return
}
$selectedPath = $openDialog.FileName
$defaultName = [System.IO.Path]::GetFileNameWithoutExtension($selectedPath)
$namePanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$namePanel.Spacing = 10
$fileLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$fileLabel.Text = "Selected file:"
$fileLabel.FontFamily = $fontFamily
$fileLabel.FontSize = 12
$fileLabel.Foreground = New-SolidBrush -Hex $themeTextSecondary
$namePanel.Children.Add($fileLabel) | Out-Null
$pathDisplay = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$pathDisplay.Text = $selectedPath
$pathDisplay.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new("Cascadia Code, Consolas, monospace")
$pathDisplay.FontSize = 11
$pathDisplay.Foreground = New-SolidBrush -Hex $themeTextPrimary
$pathDisplay.Opacity = 0.8
$pathDisplay.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$namePanel.Children.Add($pathDisplay) | Out-Null
$nameLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nameLabel.Text = "Display name:"
$nameLabel.FontFamily = $fontFamily
$nameLabel.FontSize = 14
$nameLabel.Foreground = New-SolidBrush -Hex $themeTextSecondary
$nameLabel.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 4, 0, 0)
$namePanel.Children.Add($nameLabel) | Out-Null
$nameInput = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBox]::new()
$nameInput.Text = $defaultName
$nameInput.PlaceholderText = "Enter display name"
$nameInput.FontFamily = $fontFamily
$nameInput.FontSize = 14
$nameInput.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$nameInput.Foreground = New-SolidBrush -Hex $themeTextPrimary
$nameInput.Background = New-SolidBrush -Hex $themeButtonSurface
try {
$bgBrush = New-SolidBrush -Hex $themeButtonSurface
$acBrush = New-SolidBrush -Hex $themeAccentColor
$nameInput.Resources["TextControlBackground"] = $bgBrush
$nameInput.Resources["TextControlBackgroundPointerOver"] = $bgBrush
$focusDarkBrush = New-SolidBrush -Hex "#381A26"
$nameInput.Resources["TextControlBackgroundFocused"] = $focusDarkBrush
$nameInput.Resources["TextControlBorderBrushFocused"] = New-SolidBrush -Hex $themeAccentColor
$nameInput.Resources["TextControlBorderThemeThicknessFocused"] = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0,0,0,2)
} catch { }
$namePanel.Children.Add($nameInput) | Out-Null
$nameDialog = [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialog]::new()
$nameDialog.XamlRoot = $xr
$nameDialog.Title = "Add Custom Bootstrapper"
$nameDialog.Content = $namePanel
$nameDialog.PrimaryButtonText = "Add"
$nameDialog.CloseButtonText = "Cancel"
$nameDialog.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$nameDialog.FontFamily = $fontFamily
$nameDialog.Foreground = New-SolidBrush -Hex $themeTextPrimary
$nameDialog.Background = New-SolidBrush -Hex $themeSurface
try {
$ac = New-Color -Hex $themeAccentColor
$rd = $nameDialog.Resources
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$rd[$key] = $ac
}
} catch { }
try { Set-AccentResourceOverrides -ResourceDictionary $nameDialog.Resources } catch { }
$nameDialogResult = $nameDialog.ShowAsync().WaitForCompleted()
if ("$nameDialogResult" -ne "Primary" -and $nameDialogResult -ne 1 -and $nameDialogResult -ne [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialogResult]::Primary) {
return
}
$enteredName = $nameInput.Text.Trim()
if ([string]::IsNullOrWhiteSpace($enteredName)) {
return
}
Add-CustomBootstrapper -Name $enteredName -Path $selectedPath
$settingsRef.selectedBootstrapper = $enteredName
Save-Settings
Update-BootstrapperButton -Button $bootBtn
if ($null -ne $statusText) {
$statusText.Text = Get-BootstrapperStatusText
}
Refresh-BootstrapperFlyout
} catch {
Write-ConsoleLog -Message "Error in Add Custom: $_" -Level "ERROR"
}
}.GetNewClosure())
$dt.Start()
}
$items.Add($addCustomItem) | Out-Null
if ($script:CustomBootstrappers.Count -gt 0) {
$items.Add((New-MenuFlyoutSeparator)) | Out-Null
foreach ($cb in $script:CustomBootstrappers) {
$removeItem = New-MenuFlyoutItem -Text "Remove $($cb.Name)" -OnClick {
param($argumentList, $s, $e)
$nameToRemove = $s.Text -replace '^Remove ', ''
$launcherWin = $script:LauncherWindow
$settingsRef = $script:Settings
$bootBtn = $script:LauncherBootstrapperButton
$statusText = $script:LauncherBootstrapperStatusText
$themeSurface = $script:ThemeColors.Surface
$themeTextPrimary = $script:ThemeColors.TextPrimary
$themeTextSecondary = $script:ThemeColors.TextSecondary
$themeDividers = $script:ThemeColors.Dividers
$themeButtonSurface = $script:ThemeColors.ButtonSurface
$themeAccentColor = $script:AccentColor
$fontFamily = $script:AppFontFamily
$dt = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$dt.Interval = New-UITimeSpan -Milliseconds 150
$dt.AddTick({
param($argumentList, $ds, $de)
$ds.Stop()
try {
$xr = $launcherWin.Content.XamlRoot
if ($null -eq $xr) {
return
}
$confirmPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$confirmPanel.Spacing = 12
$confirmMsg = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$confirmMsg.Text = "Remove '$nameToRemove' from custom bootstrappers?"
$confirmMsg.FontFamily = $fontFamily
$confirmMsg.FontSize = 14
$confirmMsg.Foreground = New-SolidBrush -Hex $themeTextSecondary
$confirmMsg.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$confirmPanel.Children.Add($confirmMsg) | Out-Null
$confirmDialog = [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialog]::new()
$confirmDialog.XamlRoot = $xr
$confirmDialog.Title = "Remove Bootstrapper"
$confirmDialog.Content = $confirmPanel
$confirmDialog.PrimaryButtonText = "Remove"
$confirmDialog.CloseButtonText = "Cancel"
$confirmDialog.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$confirmDialog.FontFamily = $fontFamily
$confirmDialog.Foreground = New-SolidBrush -Hex $themeTextPrimary
$confirmDialog.Background = New-SolidBrush -Hex $themeSurface
try {
$ac = New-Color -Hex $themeAccentColor
$rd = $confirmDialog.Resources
foreach ($key in @("SystemAccentColor","SystemAccentColorLight1","SystemAccentColorLight2","SystemAccentColorLight3","SystemAccentColorDark1","SystemAccentColorDark2","SystemAccentColorDark3")) {
$rd[$key] = $ac
}
} catch { }
try { Set-AccentResourceOverrides -ResourceDictionary $confirmDialog.Resources } catch { }
$confirmResult = $confirmDialog.ShowAsync().WaitForCompleted()
if ("$confirmResult" -ne "Primary" -and $confirmResult -ne 1 -and $confirmResult -ne [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialogResult]::Primary) {
return
}
Remove-CustomBootstrapper -Name $nameToRemove
if ($settingsRef.selectedBootstrapper -eq $nameToRemove) {
$settingsRef.selectedBootstrapper = ""
Save-Settings
}
Update-BootstrapperButton -Button $bootBtn
if ($null -ne $statusText) {
$statusText.Text = Get-BootstrapperStatusText
}
Refresh-BootstrapperFlyout
} catch {
Write-ConsoleLog -Message "Error in Remove: $_" -Level "ERROR"
}
}.GetNewClosure())
$dt.Start()
}
$items.Add($removeItem) | Out-Null
}
}
return $items
}
function Update-LauncherDisplay {
if ($null -eq $script:LauncherWindow) { return }
Update-BootstrapperButton -Button $script:LauncherBootstrapperButton
if ($null -ne $script:LauncherBootstrapperStatusText) {
$script:LauncherBootstrapperStatusText.Text = Get-BootstrapperStatusText
}
}
$script:LastContainerScanAddress = [IntPtr]::Zero
$global:AlliumAddressState = [pscustomobject]@{
HashmapBase = [IntPtr]::Zero
RawSingletonPtr = [IntPtr]::Zero
AcquiredAt = $null
SourceQuorum = @()
RobloxVersion = $null
ScanDurationMs = 0
PatternMatched = $null
LastVerifyOk = $true
FailureReason = $null
}
function Test-RobloxRunning {
$proc = Get-Process -Name 'RobloxPlayerBeta' -ErrorAction SilentlyContinue
return ($null -ne $proc)
}
function Get-AlliumAddressState {
[OutputType([pscustomobject])]
param()
return $global:AlliumAddressState
}
function Reset-AlliumAddressState {
[OutputType([void])]
param()
$global:AlliumAddressState.HashmapBase = [IntPtr]::Zero
$global:AlliumAddressState.RawSingletonPtr = [IntPtr]::Zero
$global:AlliumAddressState.AcquiredAt = $null
$global:AlliumAddressState.SourceQuorum = @()
$global:AlliumAddressState.RobloxVersion = $null
$global:AlliumAddressState.ScanDurationMs = 0
$global:AlliumAddressState.PatternMatched = $null
$global:AlliumAddressState.LastVerifyOk = $true
$global:AlliumAddressState.FailureReason = $null
}
function Test-AddressCandidate {
[OutputType([bool])]
param(
[Parameter(Mandatory)] $ProcessHandle,
[Parameter(Mandatory)] [IntPtr] $MapHeaderPtr
)
if ($MapHeaderPtr -eq [IntPtr]::Zero) { return $false }
try {
$bytes = [Allium.MemoryReader]::ReadBytes($ProcessHandle, $MapHeaderPtr, 56)
if ($null -eq $bytes -or $bytes.Length -lt 56) { return $false }
$list = [BitConverter]::ToUInt64($bytes, 0x10)
$mask = [BitConverter]::ToUInt64($bytes, 0x28)
if ($mask -eq 0) { return $false }
if ((($mask + 1) -band $mask) -ne 0) { return $false }
$listProbe = [Allium.MemoryReader]::ReadBytes($ProcessHandle, [IntPtr]$list, 16)
if ($null -eq $listProbe -or $listProbe.Length -lt 16) { return $false }
return $true
}
catch {
return $false
}
}
$global:AobPatternsFile = Join-Path $script:DataRoot 'patterns/aob-patterns.json'
$global:RvaHintsFile = Join-Path $script:DataRoot 'version-rva-hints.json'
$global:AddressCacheFile = Join-Path $script:DataRoot 'address-cache.json'
function Write-AtomicJson {
[OutputType([bool])]
param(
[Parameter(Mandatory)] [string] $Path,
[Parameter(Mandatory)] $Data,
[int] $Depth = 10
)
try {
$dir = Split-Path $Path -Parent
if ($dir -and (-not (Test-Path $dir))) {
New-Item -Path $dir -ItemType Directory -Force | Out-Null
}
$tmpPath = $Path + '.tmp'
$json = $Data | ConvertTo-Json -Depth $Depth
[System.IO.File]::WriteAllText($tmpPath, $json)
if (Test-Path $Path) {
$backupPath = $Path + '.bak'
[System.IO.File]::Replace($tmpPath, $Path, $backupPath, $true)
try { Remove-Item -LiteralPath $backupPath -Force -ErrorAction SilentlyContinue } catch { }
} else {
Move-Item -LiteralPath $tmpPath -Destination $Path -Force
}
return $true
}
catch {
Write-ConsoleLog -Message ("Write-AtomicJson failed for " + $Path + ": " + $_) -Level "ERROR"
try {
if (Test-Path ($Path + '.tmp')) {
Remove-Item -LiteralPath ($Path + '.tmp') -Force -ErrorAction SilentlyContinue
}
} catch { }
return $false
}
}
function Get-RobloxVersionFolder {
[OutputType([string])]
param()
try {
$roots = @(
(Join-Path $env:LOCALAPPDATA 'Roblox\Versions'),
(Join-Path $env:LOCALAPPDATA 'Bloxstrap\Versions'),
(Join-Path $env:LOCALAPPDATA 'Fishstrap\Versions'),
(Join-Path $env:LOCALAPPDATA 'Froststrap\Versions'),
(Join-Path $env:LOCALAPPDATA 'Voidstrap\Versions')
)
$best = $null
$bestTime = [DateTime]::MinValue
foreach ($root in $roots) {
if (-not (Test-Path $root)) { continue }
Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
if ($_.Name -match '^version-[0-9a-fA-F]+$') {
$exe = Join-Path $_.FullName 'RobloxPlayerBeta.exe'
if (Test-Path $exe) {
if ($_.LastWriteTimeUtc -gt $bestTime) {
$best = $_.Name
$bestTime = $_.LastWriteTimeUtc
}
}
}
}
}
return $best
}
catch {
return $null
}
}
function Read-AobPatterns {
[OutputType([object[]])]
param([string] $Path = $global:AobPatternsFile)
$obj = Read-Json -Path $Path
if ($null -eq $obj) { return @() }
if (-not $obj.ContainsKey('patterns')) { return @() }
$patterns = $obj['patterns']
if ($null -eq $patterns) { return @() }
$required = @('id', 'tier', 'pattern', 'disp_off', 'next_off')
$valid = New-Object System.Collections.Generic.List[object]
foreach ($p in $patterns) {
$allOk = $true
foreach ($f in $required) {
if (-not $p.ContainsKey($f)) { $allOk = $false; break }
}
if ($allOk) {
if (-not $p.ContainsKey('header_offset')) { $p['header_offset'] = 8 }
$valid.Add($p) | Out-Null
}
}
return @($valid.ToArray())
}
function Read-RvaHints {
[OutputType([hashtable])]
param([string] $Path = $global:RvaHintsFile)
$obj = Read-Json -Path $Path
if ($null -eq $obj) { return @{} }
if (-not $obj.ContainsKey('hints')) { return @{} }
if ($null -eq $obj['hints']) { return @{} }
return $obj['hints']
}
function Read-AddressCache {
[OutputType([hashtable])]
param([string] $Path = $global:AddressCacheFile)
$obj = Read-Json -Path $Path
if ($null -eq $obj) {
return @{ schema_version = 1; current_version = $null; entries = @{} }
}
if (-not $obj.ContainsKey('entries')) { $obj['entries'] = @{} }
if (-not $obj.ContainsKey('schema_version')) { $obj['schema_version'] = 1 }
return $obj
}
function Get-AddressCacheEntry {
param(
[Parameter(Mandatory)] [string] $Version,
[string] $Path = $global:AddressCacheFile
)
$cache = Read-AddressCache -Path $Path
if (-not $cache.ContainsKey('entries')) { return $null }
if (-not $cache['entries'].ContainsKey($Version)) { return $null }
return $cache['entries'][$Version]
}
function Save-AddressCacheEntry {
[OutputType([bool])]
param(
[Parameter(Mandatory)] [string] $Version,
[Parameter(Mandatory)] [hashtable] $Entry,
[string] $Path = $global:AddressCacheFile
)
$cache = Read-AddressCache -Path $Path
if (-not $cache.ContainsKey('entries')) { $cache['entries'] = @{} }
$cache['entries'][$Version] = $Entry
$cache['current_version'] = $Version
if (-not $cache.ContainsKey('schema_version')) { $cache['schema_version'] = 1 }
return (Write-AtomicJson -Path $Path -Data $cache)
}
function Resolve-SinglePattern {
[OutputType([IntPtr])]
param(
[Parameter(Mandatory)] $ProcessHandle,
[Parameter(Mandatory)] [IntPtr] $ModuleBase,
[Parameter(Mandatory)] [long] $ModuleSize,
[Parameter(Mandatory)] [hashtable] $PatternEntry
)
try {
$compiled = [Allium.PatternScanner]::Compile($PatternEntry.pattern)
$match = [Allium.PatternScanner]::Scan($ProcessHandle, $ModuleBase, $ModuleSize, $compiled)
if ($match -eq [IntPtr]::Zero) { return [IntPtr]::Zero }
$hdrOff = if ($PatternEntry.ContainsKey('header_offset')) { [int]$PatternEntry.header_offset } else { 8 }
$header = [Allium.RipRelativeDecoder]::Resolve(
$ProcessHandle,
$match,
[int]$PatternEntry.disp_off,
[int]$PatternEntry.next_off,
$hdrOff
)
if ($header -eq [IntPtr]::Zero) { return [IntPtr]::Zero }
if (-not (Test-AddressCandidate -ProcessHandle $ProcessHandle -MapHeaderPtr $header)) {
return [IntPtr]::Zero
}
return $header
}
catch {
return [IntPtr]::Zero
}
}
function Get-PatternQuorum {
[OutputType([pscustomobject])]
param(
[Parameter(Mandatory)] [hashtable[]] $ResolvedPatterns,
[int] $Threshold = 2
)
$byAddress = @{}
foreach ($r in $ResolvedPatterns) {
if ($r.Address -eq [IntPtr]::Zero) { continue }
$key = [string]$r.Address.ToInt64()
if (-not $byAddress.ContainsKey($key)) {
$byAddress[$key] = [pscustomobject]@{
Address = $r.Address
Weight = 0.0
Sources = New-Object System.Collections.Generic.List[string]
}
}
$weight = if ($r.Tier -eq 'trusted') { 1.0 } else { 0.5 }
$byAddress[$key].Weight += $weight
$byAddress[$key].Sources.Add($r.PatternId) | Out-Null
}
$sorted = $byAddress.Values | Sort-Object -Property Weight -Descending
if ($sorted.Count -eq 0) {
return [pscustomobject]@{
Address = [IntPtr]::Zero
Sources = @()
Weight = 0.0
MetQuorum = $false
}
}
$best = $sorted[0]
return [pscustomobject]@{
Address = $best.Address
Sources = @($best.Sources.ToArray())
Weight = $best.Weight
MetQuorum = ($best.Weight -ge $Threshold)
}
}
function Test-CacheEntryValid {
[OutputType([bool])]
param(
[Parameter(Mandatory)] $ProcessHandle,
[Parameter(Mandatory)] [hashtable] $CacheEntry,
[Parameter(Mandatory)] [string] $CurrentVersion
)
if ($null -eq $CacheEntry) { return $false }
if (-not $CacheEntry.ContainsKey('RobloxVersion')) { return $false }
if ($CacheEntry.RobloxVersion -ne $CurrentVersion) { return $false }
if (-not $CacheEntry.ContainsKey('HashmapBase')) { return $false }
try {
$ptrInt64 = [long]$CacheEntry.HashmapBase
$ptr = [IntPtr]$ptrInt64
if ($ptr -eq [IntPtr]::Zero) { return $false }
return (Test-AddressCandidate -ProcessHandle $ProcessHandle -MapHeaderPtr $ptr)
}
catch {
return $false
}
}
function Invoke-CacheInvalidation {
[OutputType([bool])]
param(
[Parameter(Mandatory)] [string] $Version,
[string] $Path = $global:AddressCacheFile
)
try {
$cache = Read-AddressCache -Path $Path
if (-not $cache.ContainsKey('entries')) { return $true }
if (-not $cache['entries'].ContainsKey($Version)) { return $true }
$cache['entries'].Remove($Version) | Out-Null
if ($cache.current_version -eq $Version) {
$cache.current_version = $null
}
return (Write-AtomicJson -Path $Path -Data $cache)
}
catch {
return $false
}
}
function Save-AlliumAddressStateToCache {
[OutputType([bool])]
param(
[Parameter(Mandatory)] [string] $Version,
[string] $Path = $global:AddressCacheFile
)
if ($null -eq $global:AlliumAddressState) { return $false }
if ($global:AlliumAddressState.HashmapBase -eq [IntPtr]::Zero) { return $false }
$entry = @{
RobloxVersion = $Version
HashmapBase = [string]$global:AlliumAddressState.HashmapBase.ToInt64()
RawSingletonPtr = [string]$global:AlliumAddressState.RawSingletonPtr.ToInt64()
AcquiredAt = if ($global:AlliumAddressState.AcquiredAt) {
$global:AlliumAddressState.AcquiredAt.ToString('o')
} else { $null }
SourceQuorum = @($global:AlliumAddressState.SourceQuorum)
ScanDurationMs = [long]$global:AlliumAddressState.ScanDurationMs
PatternMatched = [string]$global:AlliumAddressState.PatternMatched
LastVerifyOk = [bool]$global:AlliumAddressState.LastVerifyOk
}
return (Save-AddressCacheEntry -Version $Version -Entry $entry -Path $Path)
}
function Get-RvaHintCandidate {
[OutputType([pscustomobject])]
param(
[Parameter(Mandatory)] $ProcessHandle,
[Parameter(Mandatory)] [IntPtr] $ModuleBase,
[Parameter(Mandatory)] [string] $Version
)
$hints = Read-RvaHints
if ($null -eq $hints -or -not $hints.ContainsKey($Version)) {
return [pscustomobject]@{ Address = [IntPtr]::Zero; Source = $null; FailureReason = 'no-hint' }
}
$entry = $hints[$Version]
if (-not $entry.ContainsKey('fflag_singleton_rva')) {
return [pscustomobject]@{ Address = [IntPtr]::Zero; Source = $null; FailureReason = 'hint-missing-rva' }
}
try {
$rvaStr = [string]$entry.fflag_singleton_rva
if ($rvaStr.StartsWith('0x') -or $rvaStr.StartsWith('0X')) {
$rva = [Convert]::ToInt64($rvaStr.Substring(2), 16)
} else {
$rva = [Convert]::ToInt64($rvaStr, 16)
}
$slotAddr = [IntPtr]([long]$ModuleBase.ToInt64() + $rva)
$slotBytes = [Allium.MemoryReader]::ReadBytes($ProcessHandle, $slotAddr, 8)
if ($null -eq $slotBytes -or $slotBytes.Length -ne 8) {
return [pscustomobject]@{ Address = [IntPtr]::Zero; Source = $null; FailureReason = 'hint-deref-failed' }
}
$singleton = [BitConverter]::ToInt64($slotBytes, 0)
if ($singleton -eq 0) {
return [pscustomobject]@{ Address = [IntPtr]::Zero; Source = $null; FailureReason = 'hint-null-singleton' }
}
$hdrPtr = [IntPtr]([long]$singleton + 8)
if (-not (Test-AddressCandidate -ProcessHandle $ProcessHandle -MapHeaderPtr $hdrPtr)) {
return [pscustomobject]@{ Address = [IntPtr]::Zero; Source = $null; FailureReason = 'hint-verify-failed' }
}
$source = if ($entry.ContainsKey('source')) { [string]$entry.source } else { 'rva-hint' }
return [pscustomobject]@{
Address = $hdrPtr
RawSingleton = [IntPtr]([long]$singleton)
Source = $source
FailureReason = $null
}
}
catch {
return [pscustomobject]@{ Address = [IntPtr]::Zero; Source = $null; FailureReason = 'hint-exception' }
}
}
function Invoke-AddressAcquisitionMulti {
[OutputType([bool])]
param(
[Parameter(Mandatory)] $ProcessHandle,
[Parameter(Mandatory)] [IntPtr] $ModuleBase,
[Parameter(Mandatory)] [long] $ModuleSize,
[int] $QuorumThreshold = 2,
[switch] $SkipCache,
[switch] $ForceRescan
)
Reset-AlliumAddressState
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$currentVersion = Get-RobloxVersionFolder
if ([string]::IsNullOrWhiteSpace($currentVersion)) {
$currentVersion = 'unknown'
}
$global:AlliumAddressState.RobloxVersion = $currentVersion
if (-not $ForceRescan) {
$hint = Get-RvaHintCandidate -ProcessHandle $ProcessHandle -ModuleBase $ModuleBase -Version $currentVersion
if ($hint.Address -ne [IntPtr]::Zero) {
$sw.Stop()
$global:AlliumAddressState.HashmapBase = $hint.Address
$global:AlliumAddressState.RawSingletonPtr = $hint.RawSingleton
$global:AlliumAddressState.AcquiredAt = [DateTime]::UtcNow
$global:AlliumAddressState.SourceQuorum = @(('rva-hint:' + $hint.Source))
$global:AlliumAddressState.ScanDurationMs = $sw.ElapsedMilliseconds
$global:AlliumAddressState.PatternMatched = 'rva-hint'
$global:AlliumAddressState.LastVerifyOk = $true
$global:AlliumAddressState.FailureReason = $null
if ($currentVersion -ne 'unknown') {
Save-AlliumAddressStateToCache -Version $currentVersion | Out-Null
}
return $true
}
}
if (-not $SkipCache -and -not $ForceRescan) {
try {
$cached = Get-AddressCacheEntry -Version $currentVersion
if ($null -ne $cached) {
if (Test-CacheEntryValid -ProcessHandle $ProcessHandle -CacheEntry $cached -CurrentVersion $currentVersion) {
$hdrPtr = [IntPtr]([long]$cached.HashmapBase)
$rawPtr = if ($cached.ContainsKey('RawSingletonPtr')) {
[IntPtr]([long]$cached.RawSingletonPtr)
} else {
[IntPtr]([long]$cached.HashmapBase - 8)
}
$sw.Stop()
$global:AlliumAddressState.HashmapBase = $hdrPtr
$global:AlliumAddressState.RawSingletonPtr = $rawPtr
$global:AlliumAddressState.AcquiredAt = [DateTime]::UtcNow
$global:AlliumAddressState.SourceQuorum = @('cache')
$global:AlliumAddressState.RobloxVersion = $currentVersion
$global:AlliumAddressState.ScanDurationMs = $sw.ElapsedMilliseconds
$global:AlliumAddressState.PatternMatched = 'cache'
$global:AlliumAddressState.LastVerifyOk = $true
return $true
} else {
Invoke-CacheInvalidation -Version $currentVersion | Out-Null
}
}
}
catch {
}
}
$patterns = @(Read-AobPatterns)
if ($patterns.Count -eq 0) {
$sw.Stop()
$global:AlliumAddressState.ScanDurationMs = $sw.ElapsedMilliseconds
$global:AlliumAddressState.FailureReason = 'no-patterns'
return $false
}
$resolved = New-Object System.Collections.Generic.List[hashtable]
foreach ($p in $patterns) {
$addr = Resolve-SinglePattern -ProcessHandle $ProcessHandle -ModuleBase $ModuleBase -ModuleSize $ModuleSize -PatternEntry $p
$resolved.Add(@{
PatternId = [string]$p.id
Tier = [string]$p.tier
Address = $addr
}) | Out-Null
$addrHex = if ($addr -ne [IntPtr]::Zero) { '0x' + [int64]$addr.ToInt64().ToString('X') } else { 'ZERO' }
Write-ConsoleLog -Message ("  [dumper-diag] Pattern '$($p.id)' [$($p.tier)] resolved to: $addrHex") -Level 'INFO'
}
$quorum = Get-PatternQuorum -ResolvedPatterns @($resolved.ToArray()) -Threshold $QuorumThreshold
$sw.Stop()
if ($quorum.Address -eq [IntPtr]::Zero) {
$nonZero = @($resolved | Where-Object { $_.Address -ne [IntPtr]::Zero })
$uniqAddrs = @($nonZero | Group-Object -Property { [int64]$_.Address.ToInt64() })
Write-ConsoleLog -Message ("Acquisition quorum failed. Threshold=$QuorumThreshold, patterns tried=$($patterns.Count), non-zero resolutions=$($nonZero.Count), unique addresses=$($uniqAddrs.Count)") -Level 'WARN'
foreach ($grp in $uniqAddrs) {
$addrHex = '0x' + $grp.Name.ToString('X')
$sources = ($grp.Group | ForEach-Object { $_.PatternId }) -join ', '
Write-ConsoleLog -Message ("  Address $addrHex from patterns: $sources") -Level 'WARN'
}
$global:AlliumAddressState.ScanDurationMs = $sw.ElapsedMilliseconds
$global:AlliumAddressState.FailureReason = 'no-match'
return $false
}
$rawSingleton = [IntPtr]([long]$quorum.Address.ToInt64() - 8)
$global:AlliumAddressState.HashmapBase = $quorum.Address
$global:AlliumAddressState.RawSingletonPtr = $rawSingleton
$global:AlliumAddressState.AcquiredAt = [DateTime]::UtcNow
$global:AlliumAddressState.SourceQuorum = @($quorum.Sources)
$global:AlliumAddressState.RobloxVersion = $currentVersion
$global:AlliumAddressState.ScanDurationMs = $sw.ElapsedMilliseconds
$global:AlliumAddressState.PatternMatched = ($quorum.Sources -join ',')
$global:AlliumAddressState.LastVerifyOk = $true
if ($currentVersion -ne 'unknown') {
Save-AlliumAddressStateToCache -Version $currentVersion | Out-Null
}
return $true
}
$global:FFlagAnchorsFile = Join-Path $script:DataRoot 'anchors/fflag-name-anchors.json'
$global:FFlagOffsetsSourcesFile = Join-Path $script:DataRoot 'fflag-offsets-sources.json'
$global:FFlagOffsetsCacheDir = Join-Path $script:DataRoot 'per-flag-rvas'
function Read-FFlagOffsetsSources {
[OutputType([object[]])]
param([string] $Path = $global:FFlagOffsetsSourcesFile)
$obj = Read-Json -Path $Path
if ($null -eq $obj) { return @() }
if (-not $obj.ContainsKey('sources')) { return @() }
return @($obj['sources'])
}
function Get-FFlagOffsetsCachePath {
[OutputType([string])]
param([Parameter(Mandatory)] [string] $Version)
if (-not (Test-Path $global:FFlagOffsetsCacheDir)) {
New-Item -Path $global:FFlagOffsetsCacheDir -ItemType Directory -Force | Out-Null
}
return (Join-Path $global:FFlagOffsetsCacheDir ($Version + '.json'))
}
$global:FFlagOffsetsCacheSchemaVersion = 2
$global:FFlagOffsetsStructNames = @(
'FFlagList','ValueGetSet','FlagToValue',
'Pointer','ToFlag','ToValue',
'ClientVersion'
)
$global:FFlagOffsetsPrefixes = @(
'SFFlag','DFFlag','FFlag',
'SFInt','DFInt','FInt',
'SFString','DFString','FString',
'SFLog','DFLog','FLog'
)
function ConvertFrom-FFlagOffsetsBody {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [string] $Body
)
$result = @{}
if ([string]::IsNullOrWhiteSpace($Body)) { return $result }
$sectionBody = $Body
$sectionRegex = [regex]'namespace\s+FFlags\s*\{'
$sectionStart = $sectionRegex.Match($Body)
if ($sectionStart.Success) {
$searchStart = $sectionStart.Index + $sectionStart.Length
$depth = 1
$idx = $searchStart
while ($idx -lt $Body.Length -and $depth -gt 0) {
$ch = $Body[$idx]
if ($ch -eq '{') { $depth++ }
elseif ($ch -eq '}') { $depth-- }
$idx++
}
if ($depth -eq 0) {
$sectionBody = $Body.Substring($searchStart, $idx - $searchStart - 1)
}
}
$flagRegex = [regex]'(?:inline\s+)?(?:constexpr\s+)?uintptr_t\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(0x[0-9A-Fa-f]+)'
$struct = $global:FFlagOffsetsStructNames
foreach ($m in $flagRegex.Matches($sectionBody)) {
$name = $m.Groups[1].Value
$rva = $m.Groups[2].Value
if ($struct -contains $name) { continue }
$rvaLong = 0L
try {
$rvaLong = [Convert]::ToInt64($rva.Substring(2), 16)
} catch { continue }
if ($rvaLong -lt 0x10000) { continue }
if (-not $result.ContainsKey($name)) {
$result[$name] = $rva
}
}
return $result
}
function Get-FFlagOffsetsClientVersion {
[OutputType([string])]
param(
[Parameter(Mandatory)] [string] $Body
)
if ([string]::IsNullOrWhiteSpace($Body)) { return $null }
$rxTheo = [regex]'inline\s+std::string\s+ClientVersion\s*=\s*"([^"]+)"'
$m = $rxTheo.Match($Body)
if ($m.Success) { return $m.Groups[1].Value }
$rxHdr = [regex]'//\s*Roblox\s+[Vv]ersion\s*[:\-]?\s*(version-[0-9a-fA-F]+)'
$m = $rxHdr.Match($Body)
if ($m.Success) { return $m.Groups[1].Value }
return $null
}
function Invoke-FFlagOffsetsParallelFetch {
[OutputType([object[]])]
param(
[Parameter(Mandatory)] [object[]] $Sources,
[int] $TimeoutSec = 30,
[int] $ThrottleLimit = 3
)
if ($null -eq $Sources -or $Sources.Count -eq 0) { return @() }
$rawResults = $Sources | ForEach-Object -Parallel {
$src = $_
$timeout = $using:TimeoutSec
$result = @{
SourceId = if ($src.ContainsKey('id')) { [string]$src['id'] } else { 'unknown' }
UrlUsed = $null
UrlsTried = @()
Body = $null
LastError = $null
ElapsedMs = 0
HttpStatus = 0
}
if ($src.ContainsKey('enabled') -and ($src['enabled'] -eq $false)) {
$result.LastError = 'source disabled in config'
return $result
}
$urls = @()
if ($src.ContainsKey('urls') -and $null -ne $src['urls']) {
$urls = @($src['urls'])
} elseif ($src.ContainsKey('url')) {
$urls = @([string]$src['url'])
}
foreach ($u in $urls) {
$result.UrlsTried += $u
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
$resp = Invoke-WebRequest -Uri $u -TimeoutSec $timeout -UserAgent 'AlliumFFlagOffsets/1.1' -UseBasicParsing -ErrorAction Stop
$sw.Stop()
$result.ElapsedMs = [int]$sw.ElapsedMilliseconds
$result.HttpStatus = [int]$resp.StatusCode
$c = [string]$resp.Content
if (-not [string]::IsNullOrWhiteSpace($c)) {
$result.UrlUsed = $u
$result.Body = $c
return $result
}
$result.LastError = 'empty body'
}
catch {
$sw.Stop()
$result.ElapsedMs = [int]$sw.ElapsedMilliseconds
$result.LastError = $_.Exception.Message
}
}
return $result
} -ThrottleLimit $ThrottleLimit
$enriched = New-Object System.Collections.Generic.List[object]
foreach ($src in $Sources) {
$srcId = if ($src.ContainsKey('id')) { [string]$src['id'] } else { 'unknown' }
$raw = $rawResults | Where-Object { $_.SourceId -eq $srcId } | Select-Object -First 1
$report = @{
SourceId = $srcId
SourceName = if ($src.ContainsKey('name')) { [string]$src['name'] } else { $null }
Tier = if ($src.ContainsKey('tier')) { [string]$src['tier'] } else { 'community' }
Weight = if ($src.ContainsKey('weight')) { [double]$src['weight'] } else { 0.5 }
UrlUsed = if ($null -ne $raw) { $raw.UrlUsed } else { $null }
UrlsTried = if ($null -ne $raw) { $raw.UrlsTried } else { @() }
Success = $false
Flags = @{}
ClientVersion = $null
FetchedAt = [DateTime]::UtcNow.ToString('o')
LastError = if ($null -ne $raw) { $raw.LastError } else { 'no raw result' }
ContentLength = 0
ElapsedMs = if ($null -ne $raw) { $raw.ElapsedMs } else { 0 }
HttpStatus = if ($null -ne $raw) { $raw.HttpStatus } else { 0 }
}
if ($null -ne $raw -and $null -ne $raw.Body -and $raw.Body.Length -gt 0) {
$report.ContentLength = $raw.Body.Length
$report.Flags = ConvertFrom-FFlagOffsetsBody -Body $raw.Body
$report.ClientVersion = Get-FFlagOffsetsClientVersion -Body $raw.Body
$report.Success = ($report.Flags.Count -gt 0)
if (-not $report.Success -and $null -eq $report.LastError) {
$report.LastError = 'parser returned zero flags'
}
}
$enriched.Add([hashtable]$report) | Out-Null
}
return @($enriched.ToArray())
}
function Merge-FFlagOffsetsQuorum {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [object[]] $SourceReports,
[Parameter(Mandatory)] [AllowEmptyString()] [string] $ExpectedVersion
)
$out = @{
Flags = @{}
Provenance = @{}
ByFlagCount = 0
Disagreements = New-Object System.Collections.Generic.List[object]
}
$healthy = @($SourceReports | Where-Object {
$_.Success -and $_.Flags -and $_.Flags.Count -gt 0
})
if ($healthy.Count -eq 0) { return $out }
if (-not [string]::IsNullOrWhiteSpace($ExpectedVersion)) {
$fresh = @($healthy | Where-Object {
[string]::IsNullOrWhiteSpace($_.ClientVersion) -or $_.ClientVersion -eq $ExpectedVersion
})
if ($fresh.Count -gt 0) { $healthy = $fresh }
}
$allNames = New-Object System.Collections.Generic.HashSet[string]
foreach ($src in $healthy) {
foreach ($k in $src.Flags.Keys) { $allNames.Add($k) | Out-Null }
}
$out.ByFlagCount = $allNames.Count
foreach ($name in $allNames) {
$entries = New-Object System.Collections.Generic.List[object]
foreach ($src in $healthy) {
if ($src.Flags.ContainsKey($name)) {
$entries.Add(@{
SourceId = $src.SourceId
Tier = $src.Tier
Weight = $src.Weight
Rva = [string]$src.Flags[$name]
}) | Out-Null
}
}
if ($entries.Count -eq 0) { continue }
$groups = @{}
foreach ($e in $entries) {
$key = $e.Rva.ToLowerInvariant()
if (-not $groups.ContainsKey($key)) { $groups[$key] = New-Object System.Collections.Generic.List[object] }
$groups[$key].Add($e) | Out-Null
}
if ($groups.Count -eq 1) {
$rva = @($groups.Keys)[0]
$agreed = @($entries | ForEach-Object { $_.SourceId })
$out.Flags[$name] = $rva
$out.Provenance[$name] = @{
AgreedBy = $agreed
WinnerSource = $agreed[0]
Conflicts = @()
LowConfidence = ($entries.Count -eq 1)
}
continue
}
$best = $null
$bestWeight = -1.0
$bestMaxSingle = -1.0
foreach ($rva in $groups.Keys) {
$g = $groups[$rva]
$sum = 0.0
$maxSingle = 0.0
foreach ($e in $g) {
$sum += [double]$e.Weight
if ([double]$e.Weight -gt $maxSingle) { $maxSingle = [double]$e.Weight }
}
$take = $false
if ($sum -gt $bestWeight) { $take = $true }
elseif ($sum -eq $bestWeight -and $maxSingle -gt $bestMaxSingle) { $take = $true }
if ($take) {
$best = $rva
$bestWeight = $sum
$bestMaxSingle = $maxSingle
}
}
$winners = @($groups[$best] | ForEach-Object { $_.SourceId })
$conflictList = New-Object System.Collections.Generic.List[object]
foreach ($rva in $groups.Keys) {
if ($rva -eq $best) { continue }
$conflictList.Add(@{
Rva = $rva
Sources = @($groups[$rva] | ForEach-Object { $_.SourceId })
}) | Out-Null
}
$out.Flags[$name] = $best
$out.Provenance[$name] = @{
AgreedBy = $winners
WinnerSource = $winners[0]
Conflicts = @($conflictList.ToArray())
LowConfidence = $false
}
$out.Disagreements.Add(@{
Flag = $name
Winner = @{ Rva = $best; Sources = $winners }
Losers = @($conflictList.ToArray())
}) | Out-Null
}
return $out
}
function Save-FFlagOffsetsCache {
[OutputType([bool])]
param(
[Parameter(Mandatory)] [string] $Version,
[Parameter(Mandatory)] [hashtable] $MergeResult,
[Parameter(Mandatory)] [object[]] $SourceReports
)
$reportsForDisk = New-Object System.Collections.Generic.List[object]
foreach ($r in $SourceReports) {
$reportsForDisk.Add(@{
source_id = $r.SourceId
source_name = $r.SourceName
tier = $r.Tier
weight = $r.Weight
url_used = $r.UrlUsed
urls_tried = $r.UrlsTried
success = $r.Success
client_version = $r.ClientVersion
flag_count = if ($r.Success) { $r.Flags.Count } else { 0 }
content_length = $r.ContentLength
elapsed_ms = $r.ElapsedMs
http_status = if ($r.ContainsKey('HttpStatus')) { $r.HttpStatus } else { 0 }
last_error = $r.LastError
fetched_at = $r.FetchedAt
}) | Out-Null
}
$entry = @{
schema_version = $global:FFlagOffsetsCacheSchemaVersion
roblox_version = $Version
fetched_at = [DateTime]::UtcNow.ToString('o')
flag_count = $MergeResult.Flags.Count
flags = $MergeResult.Flags
provenance = $MergeResult.Provenance
sources = @($reportsForDisk.ToArray())
disagreements = @($MergeResult.Disagreements.ToArray())
}
$path = Get-FFlagOffsetsCachePath -Version $Version
return (Write-AtomicJson -Path $path -Data $entry -Depth 12)
}
function Read-FFlagOffsetsCache {
[OutputType([hashtable])]
param([Parameter(Mandatory)] [string] $Version)
$path = Get-FFlagOffsetsCachePath -Version $Version
if (-not (Test-Path $path)) { return $null }
$obj = Read-Json -Path $path
if ($null -eq $obj) { return $null }
if (-not $obj.ContainsKey('flags')) { return $null }
if ($obj.ContainsKey('roblox_version') -and $obj.roblox_version -ne $Version) {
return $null
}
$schema = if ($obj.ContainsKey('schema_version')) { [int]$obj.schema_version } else { 1 }
return @{
SchemaVersion = $schema
RobloxVersion = if ($obj.ContainsKey('roblox_version')) { [string]$obj.roblox_version } else { $Version }
SourceId = if ($obj.ContainsKey('source_id')) { [string]$obj.source_id } else { 'legacy' }
FetchedAt = if ($obj.ContainsKey('fetched_at')) { [string]$obj.fetched_at } else { $null }
Flags = $obj.flags
Provenance = if ($obj.ContainsKey('provenance')) { $obj.provenance } else { @{} }
Sources = if ($obj.ContainsKey('sources')) { @($obj.sources) } else { @() }
Disagreements = if ($obj.ContainsKey('disagreements')) { @($obj.disagreements) } else { @() }
NeedsUpgrade = ($schema -lt $global:FFlagOffsetsCacheSchemaVersion)
}
}
function Update-FFlagOffsetsCache {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [string] $Version,
[switch] $Force
)
if (-not $Force) {
$existing = Read-FFlagOffsetsCache -Version $Version
if ($null -ne $existing -and $existing.Flags.Count -gt 0 -and -not $existing.NeedsUpgrade) {
return $existing
}
}
$sources = @(Read-FFlagOffsetsSources)
if ($sources.Count -eq 0) {
Write-ConsoleLog -Message 'No FFlag offsets sources configured; cannot refresh cache.' -Level 'WARN'
return $null
}
Write-ConsoleLog -Message ('Fetching ' + $sources.Count + ' FFlag offset sources in parallel for ' + $Version) -Level 'INFO'
$reports = @(Invoke-FFlagOffsetsParallelFetch -Sources $sources -TimeoutSec 30 -ThrottleLimit 3)
$healthy = @($reports | Where-Object { $_.Success })
Write-ConsoleLog -Message ('Sources healthy: ' + $healthy.Count + '/' + $reports.Count) -Level 'INFO'
if ($healthy.Count -eq 0) {
$errs = @($reports | ForEach-Object { $_.SourceId + '=' + $_.LastError }) -join '; '
Write-ConsoleLog -Message ('All sources failed: ' + $errs) -Level 'ERROR'
return $null
}
$merge = Merge-FFlagOffsetsQuorum -SourceReports $reports -ExpectedVersion $Version
if ($merge.Flags.Count -eq 0) {
Write-ConsoleLog -Message 'Quorum merge produced zero flags.' -Level 'ERROR'
return $null
}
if ($merge.Disagreements.Count -gt 0) {
Write-ConsoleLog -Message ('Quorum disagreements: ' + $merge.Disagreements.Count + ' flag(s) had cross-source conflicts.') -Level 'WARN'
}
$ok = Save-FFlagOffsetsCache -Version $Version -MergeResult $merge -SourceReports $reports
if (-not $ok) {
Write-ConsoleLog -Message 'Cache write failed.' -Level 'ERROR'
return $null
}
Write-ConsoleLog -Message ('Cached ' + $merge.Flags.Count + ' flag offsets from ' + $healthy.Count + ' source(s).') -Level 'INFO'
return @{
SchemaVersion = $global:FFlagOffsetsCacheSchemaVersion
RobloxVersion = $Version
SourceId = 'quorum'
FetchedAt = [DateTime]::UtcNow.ToString('o')
Flags = $merge.Flags
Provenance = $merge.Provenance
Sources = $reports
Disagreements = @($merge.Disagreements.ToArray())
NeedsUpgrade = $false
}
}
function Get-FFlagTypeFromName {
[OutputType([string])]
param([Parameter(Mandatory)] [string] $Name)
if ($Name -match '^S?D?FFlag') { return 'bool' }
if ($Name -match '^S?D?FInt') { return 'int' }
if ($Name -match '^S?D?FString') { return 'string' }
if ($Name -match '^S?D?FLog') { return 'byte' }
return 'unknown'
}
try {
$__initVersion = Get-RobloxVersionFolder
if (-not [string]::IsNullOrWhiteSpace($__initVersion)) {
$__existingCache = Read-FFlagOffsetsCache -Version $__initVersion
if ($null -eq $__existingCache -or $__existingCache.Flags.Count -eq 0) {
Update-FFlagOffsetsCache -Version $__initVersion | Out-Null
}
}
} catch { }
$script:SettingsWindow = $null
$script:SettingsNavView = $null
$script:SettingsContentHost = $null
$script:SettingsCurrentPageKey = $null
$script:SettingsMemoryStatusRefs = $null
$script:SettingsContentGrid = $null
$script:SettingsPages = @{}
$script:SettingsTabDefinitions = @(
@{ Key = 'General'; Label = 'General'; Glyph = ([char]0xE713); Factory = 'New-SettingsGeneralPage' },
@{ Key = 'Watchdog'; Label = 'Watchdog'; Glyph = ([char]0xE7BA); Factory = 'New-SettingsWatchdogPage' },
@{ Key = 'Memory'; Label = 'Memory Mode'; Glyph = ([char]0xE950); Factory = 'New-SettingsMemoryModePage' },
@{ Key = 'Https'; Label = 'HTTPS Interception'; Glyph = ([char]0xE774); Factory = 'New-SettingsHttpsInterceptPage' },
@{ Key = 'Dumper'; Label = 'FFlag Dumper'; Glyph = ([char]0xEDA2); Factory = 'New-DumperTabPage' },
@{ Key = 'About'; Label = 'About'; Glyph = ([char]0xE946); Factory = 'New-SettingsAboutPage' }
)
$script:SettingsPrewarmOrder = @('General', 'Https', 'Memory', 'Watchdog', 'About', 'Dumper')
$script:SettingsPrewarmTimer = $null
$script:SettingsPrewarmSkip = $null
$script:SettingsPrewarmDone = $false
function Start-EditorPrewarm {
if ($script:EditorPrewarmDone) { return }
if ($null -ne $script:EditorPrewarmTimer) {
try {
if ($script:EditorPrewarmTimer.IsEnabled) { return }
} catch { }
}
Write-ConsoleLog -Message '[editor-prewarm] startup pre-warm dispatched (single tick at 300ms)' -Level 'INFO'
$script:EditorPrewarmTimer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$script:EditorPrewarmTimer.Interval = New-UITimeSpan -Milliseconds 300
$script:EditorPrewarmTimer.AddTick({
param($argumentList, $s, $e)
try { $s.Stop() } catch { }
if ($script:EditorPrewarmDone) { return }
try {
$t0 = [datetime]::UtcNow
if ($null -eq $script:EditorWindow) {
$script:EditorWindow = New-FFlagEditorWindow
}
try { Editor-PopulateToolbar } catch {
Write-ConsoleLog -Message ('[editor-prewarm] populate failed: ' + $_.Exception.Message) -Level 'WARN'
}
$elapsed = [int]([datetime]::UtcNow - $t0).TotalMilliseconds
Write-ConsoleLog -Message ('[editor-prewarm] editor window warmed in ' + $elapsed + 'ms') -Level 'INFO'
$script:EditorPrewarmDone = $true
} catch {
Write-ConsoleLog -Message ('[editor-prewarm] failed: ' + $_.Exception.Message) -Level 'WARN'
$script:EditorPrewarmDone = $true
}
})
$script:EditorPrewarmTimer.Start()
}
function Start-SettingsTabPrewarm {
if ($script:SettingsPrewarmDone) { return }
if ($null -ne $script:SettingsPrewarmTimer) {
try {
if ($script:SettingsPrewarmTimer.IsEnabled) { return }
} catch { }
}
if ($null -eq $script:SettingsPages) { $script:SettingsPages = @{} }
if ($null -eq $script:SettingsPrewarmSkip) { $script:SettingsPrewarmSkip = @{} }
Write-ConsoleLog -Message '[settings-prewarm] startup pre-warm dispatched (1ms cadence, warm-order optimized)' -Level 'INFO'
$script:SettingsPrewarmT0 = [datetime]::UtcNow
$script:SettingsPrewarmTimer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$script:SettingsPrewarmTimer.Interval = New-UITimeSpan -Milliseconds 1
$script:SettingsPrewarmTimer.AddTick({
param($argumentList, $s, $e)
if ($script:SettingsPrewarmDone) {
try { $s.Stop() } catch { }
return
}
try {
if ($null -eq $script:SettingsTabDefinitions) { $s.Stop(); return }
if ($null -eq $script:SettingsPages) { $script:SettingsPages = @{} }
if ($null -eq $script:SettingsPrewarmSkip) { $script:SettingsPrewarmSkip = @{} }
$__pwDebug = $false
try { $__pwDebug = [bool]$script:Settings['debugLogging'] } catch { $__pwDebug = $false }
$__pwIterKeys = $script:SettingsPrewarmOrder
if ($null -eq $__pwIterKeys -or $__pwIterKeys.Count -eq 0) {
$__pwIterKeys = $script:SettingsTabDefinitions | ForEach-Object { $_.Key }
}
try {
$__pwLastViewed = $null
if ($null -ne $script:Settings) {
try { $__pwLastViewed = [string]$script:Settings['settingsLastViewedTab'] } catch { $__pwLastViewed = $null }
}
if (-not [string]::IsNullOrWhiteSpace($__pwLastViewed) -and $__pwLastViewed -ne 'General' -and ($__pwIterKeys -contains $__pwLastViewed)) {
$__pwReordered = New-Object System.Collections.Generic.List[string]
$__pwReordered.Add('General') | Out-Null
$__pwReordered.Add($__pwLastViewed) | Out-Null
foreach ($__pwK in $__pwIterKeys) {
if ($__pwK -eq 'General' -or $__pwK -eq $__pwLastViewed) { continue }
$__pwReordered.Add($__pwK) | Out-Null
}
$__pwIterKeys = $__pwReordered.ToArray()
}
} catch { }
$nextKey = $null
$nextFactory = $null
foreach ($__pwKey in $__pwIterKeys) {
if ($script:SettingsPages.ContainsKey($__pwKey)) { continue }
if ($script:SettingsPrewarmSkip.ContainsKey($__pwKey)) { continue }
$__pwDef = $null
foreach ($def in $script:SettingsTabDefinitions) {
if ($def.Key -eq $__pwKey) { $__pwDef = $def; break }
}
if ($null -eq $__pwDef) { continue }
$nextKey = $__pwKey
$nextFactory = $__pwDef.Factory
break
}
if ($null -eq $nextKey) {
$script:SettingsPrewarmDone = $true
$s.Stop()
Write-ConsoleLog -Message '[settings-prewarm] all tabs warmed; timer stopped' -Level 'INFO'
try {
if ($null -ne $script:SettingsPrewarmT0) {
$__pwTotalMs = [int]([datetime]::UtcNow - $script:SettingsPrewarmT0).TotalMilliseconds
Write-ConsoleLog -Message ('[settings-prewarm] TOTAL prewarm wall-clock: ' + $__pwTotalMs + 'ms') -Level 'INFO'
}
} catch { }
try {
if ($null -ne $script:SettingsPrepareDialog) {
Write-ConsoleLog -Message '[settings-prewarm] hiding settings-prepare dialog (last-tick handoff)' -Level 'INFO'
try { $script:SettingsPrepareDialog.Hide() } catch {
Write-ConsoleLog -Message ('[settings-prewarm] dialog Hide() failed: ' + $_.Exception.Message) -Level 'WARN'
}
$script:SettingsPrepareDialog = $null
}
} catch { }
return
}
if ([string]::IsNullOrWhiteSpace($nextFactory)) {
$script:SettingsPrewarmSkip[$nextKey] = $true
return
}
$cmd = Get-Command -Name $nextFactory -ErrorAction SilentlyContinue
if ($null -eq $cmd) {
$script:SettingsPrewarmSkip[$nextKey] = $true
return
}
try {
$t0 = [datetime]::UtcNow
$page = & $cmd
$script:SettingsPages[$nextKey] = $page
try {
if ($null -ne $page -and $null -ne $page.Resources) {
Set-AccentResourceOverrides -ResourceDictionary $page.Resources
Write-ConsoleLog -Message ('[settings-prewarm] accent overrides applied to ' + $nextKey) -Level 'INFO'
}
} catch {
Write-ConsoleLog -Message ('[settings-prewarm] accent override for ' + $nextKey + ' failed: ' + $_.Exception.Message) -Level 'WARN'
}
$elapsed = [int]([datetime]::UtcNow - $t0).TotalMilliseconds
Write-ConsoleLog -Message ('[settings-prewarm] warmed ' + $nextKey + ' in ' + $elapsed + 'ms') -Level 'INFO'
} catch {
$script:SettingsPrewarmSkip[$nextKey] = $true
Write-ConsoleLog -Message ('[settings-prewarm] factory ' + $nextFactory + ' failed: ' + $_.Exception.Message) -Level 'WARN'
}
} catch {
try { $s.Stop() } catch { }
Write-ConsoleLog -Message ('[settings-prewarm] tick error: ' + $_.Exception.Message) -Level 'WARN'
}
})
$script:SettingsPrewarmTimer.Start()
}
function Activate-SettingsTab {
param(
[Parameter(Mandatory)] [string] $Key
)
$__atDebug = $false
try { $__atDebug = [bool]$script:Settings['debugLogging'] } catch { $__atDebug = $false }
if ([string]::IsNullOrWhiteSpace($Key)) { return }
if ($null -eq $script:SettingsPages) { $script:SettingsPages = @{} }
if ($null -eq $script:SettingsTabDefinitions) { return }
if ($null -eq $script:SettingsContentGrid) {
if ($__atDebug) { Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' SKIP: SettingsContentGrid is null') -Level 'WARN' }
return
}
$__wasCached = $script:SettingsPages.ContainsKey($Key)
if ($__atDebug) {
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' cached=' + $__wasCached) -Level 'INFO'
}
if (-not $__wasCached) {
$factoryName = $null
foreach ($def in $script:SettingsTabDefinitions) {
if ($def.Key -eq $Key) { $factoryName = $def.Factory; break }
}
if ([string]::IsNullOrWhiteSpace($factoryName)) { return }
$cmd = Get-Command -Name $factoryName -ErrorAction SilentlyContinue
if ($null -eq $cmd) { return }
try {
$page = & $cmd
$script:SettingsPages[$Key] = $page
try {
if ($null -ne $page -and $null -ne $page.Resources) {
Set-AccentResourceOverrides -ResourceDictionary $page.Resources
}
} catch { }
if ($__atDebug) { Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' factory ran; page-is-null=' + ($null -eq $page)) -Level 'INFO' }
} catch {
Write-ConsoleLog -Message ('Settings page factory ' + $factoryName + ' failed: ' + $_.Exception.Message) -Level 'ERROR'
return
}
}
$newPage = $script:SettingsPages[$Key]
if ($__atDebug) {
$__pageIsNull = ($null -eq $newPage)
$__pageType = 'unknown'
try { if (-not $__pageIsNull) { $__pageType = $newPage.GetType().Name } } catch { $__pageType = 'gettype-failed' }
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' newPage-null=' + $__pageIsNull + ' type=' + $__pageType) -Level 'INFO'
}
try {
if ($__atDebug) {
$__cntBefore = -1
try { $__cntBefore = [int]$script:SettingsContentGrid.Children.Count } catch { $__cntBefore = -1 }
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' grid.Children.Count BEFORE Clear=' + $__cntBefore) -Level 'INFO'
}
$script:SettingsContentGrid.Children.Clear()
if ($__atDebug) {
$__cntAfterClear = -1
try { $__cntAfterClear = [int]$script:SettingsContentGrid.Children.Count } catch { $__cntAfterClear = -1 }
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' grid.Children.Count AFTER Clear=' + $__cntAfterClear) -Level 'INFO'
}
$script:SettingsContentGrid.Children.Add($newPage) | Out-Null
$__addOk = $true
try { $__addOk = ([int]$script:SettingsContentGrid.Children.Count -gt 0) } catch { $__addOk = $true }
if ((-not $__addOk) -and $__wasCached) {
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' cached page silently failed to attach (stale WinUI Parent); rebuilding from factory') -Level 'WARN'
$__repairFactory = $null
foreach ($def in $script:SettingsTabDefinitions) {
if ($def.Key -eq $Key) { $__repairFactory = $def.Factory; break }
}
if (-not [string]::IsNullOrWhiteSpace($__repairFactory)) {
$__repairCmd = Get-Command -Name $__repairFactory -ErrorAction SilentlyContinue
if ($null -ne $__repairCmd) {
try {
try { $script:SettingsPages.Remove($Key) | Out-Null } catch { }
$__t0 = [datetime]::UtcNow
$newPage = & $__repairCmd
$script:SettingsPages[$Key] = $newPage
try {
if ($null -ne $newPage -and $null -ne $newPage.Resources) {
Set-AccentResourceOverrides -ResourceDictionary $newPage.Resources
}
} catch { }
$script:SettingsContentGrid.Children.Add($newPage) | Out-Null
try {
Start-Sleep -Milliseconds 30
$script:SettingsContentGrid.Children.Clear()
$script:SettingsContentGrid.Children.Add($newPage) | Out-Null
} catch { }
$__elapsed = [int]([datetime]::UtcNow - $__t0).TotalMilliseconds
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' repair complete + wiggle (' + $__elapsed + 'ms)') -Level 'INFO'
} catch {
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' repair FAILED: ' + $_.Exception.Message) -Level 'ERROR'
}
} else {
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' repair skipped: factory ' + $__repairFactory + ' not found') -Level 'ERROR'
}
}
}
if ($__atDebug) {
$__cntAfterAdd = -1
try { $__cntAfterAdd = [int]$script:SettingsContentGrid.Children.Count } catch { $__cntAfterAdd = -1 }
Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' grid.Children.Count AFTER Add=' + $__cntAfterAdd) -Level 'INFO'
}
$script:SettingsCurrentPageKey = $Key
try {
$null = $newPage.Focus([WinUIShell.Microsoft.UI.Xaml.FocusState]::Programmatic)
if ($__atDebug) { Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' focus OK') -Level 'INFO' }
} catch {
if ($__atDebug) { Write-ConsoleLog -Message ('[activate-tab] key=' + $Key + ' focus threw: ' + $_.Exception.Message) -Level 'WARN' }
}
} catch {
Write-ConsoleLog -Message ('Activate-SettingsTab swap failed: ' + $_.Exception.Message + ' (key=' + $Key + ' newPage-null=' + ($null -eq $newPage) + ')') -Level 'ERROR'
}
}
function Test-WinUIShellVersion {
[OutputType([bool])]
param()
try {
$mod = Get-Module -Name WinUIShell -ErrorAction SilentlyContinue
if ($null -eq $mod) {
$mod = Get-Module -Name WinUIShell -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
}
if ($null -eq $mod) {
Write-ConsoleLog -Message 'WinUIShell module not found. Settings window requires WinUIShell 0.12.0 or newer.' -Level 'WARN'
return $false
}
$required = [version]'0.12.0'
if ($mod.Version -lt $required) {
Write-ConsoleLog -Message ('WinUIShell version ' + $mod.Version + ' detected; 0.12.0 or newer is recommended for the Settings window.') -Level 'WARN'
}
return $true
}
catch {
return $true
}
}
function Get-AlliumSourceSha {
[OutputType([string])]
param()
try {
if ($null -ne $script:AlliumScriptPath -and (Test-Path $script:AlliumScriptPath)) {
return (Get-FileHash -Algorithm SHA256 -LiteralPath $script:AlliumScriptPath).Hash.ToLower()
}
$selfPath = $MyInvocation.ScriptName
if ([string]::IsNullOrWhiteSpace($selfPath) -and $null -ne $PSCommandPath) {
$selfPath = $PSCommandPath
}
if (-not [string]::IsNullOrWhiteSpace($selfPath) -and (Test-Path $selfPath)) {
return (Get-FileHash -Algorithm SHA256 -LiteralPath $selfPath).Hash.ToLower()
}
}
catch { }
return '(unavailable)'
}
function Get-AlliumSourceLineCount {
[OutputType([int])]
param()
try {
if ($null -ne $script:AlliumScriptPath -and (Test-Path $script:AlliumScriptPath)) {
$bytes = [System.IO.File]::ReadAllBytes($script:AlliumScriptPath)
$lf = 0
foreach ($b in $bytes) { if ($b -eq 10) { $lf++ } }
return ($lf + 1)
}
}
catch { }
return 0
}
function New-DiagnosticBundle {
[OutputType([string])]
param()
try {
$chosenDir = $null
try {
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$fbd = [System.Windows.Forms.FolderBrowserDialog]::new()
$fbd.Description = 'Choose a folder to save the Allium diagnostic bundle:'
$fbd.UseDescriptionForTitle = $true
$fbd.ShowNewFolderButton = $true
$fbd.AutoUpgradeEnabled = $true
if ((Show-FileDialogWithOwner -Dialog $fbd) -eq [System.Windows.Forms.DialogResult]::OK) {
$chosenDir = $fbd.SelectedPath
}
} catch {
Write-ConsoleLog -Message ('FolderBrowserDialog picker failed: ' + $_.Exception.Message) -Level 'WARN'
}
if ([string]::IsNullOrWhiteSpace($chosenDir)) {
Write-ConsoleLog -Message 'Diagnostic bundle export cancelled by user.' -Level 'INFO'
return $null
}
$stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$bundleDir = Join-Path $chosenDir ('AlliumDiagnostic_' + $stamp)
New-Item -Path $bundleDir -ItemType Directory -Force | Out-Null
$meta = @{
allium_sha = Get-AlliumSourceSha
allium_line_count = Get-AlliumSourceLineCount
allium_path = if ($null -ne $script:AlliumScriptPath) { [string]$script:AlliumScriptPath } else { '(unavailable)' }
powershell = $PSVersionTable.PSVersion.ToString()
ps_edition = $PSVersionTable.PSEdition
os = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
os_arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
captured_at = ([DateTime]::UtcNow.ToString('o'))
data_root = if ($null -ne $script:DataRoot) { [string]$script:DataRoot } else { '(unset)' }
}
$meta | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $bundleDir 'allium_diagnostic.json') -Encoding utf8
$dataDir = $script:DataRoot
if ($dataDir -and (Test-Path $dataDir)) {
$copyTargets = @(
@{ Src = (Join-Path $dataDir 'settings.json'); Dst = 'settings.json' },
@{ Src = (Join-Path $dataDir 'fflag-offsets-sources.json'); Dst = 'fflag-offsets-sources.json' },
@{ Src = (Join-Path $dataDir 'address-cache.json'); Dst = 'address-cache.json' }
)
foreach ($t in $copyTargets) {
if (Test-Path $t.Src) {
Copy-Item -LiteralPath $t.Src -Destination (Join-Path $bundleDir $t.Dst) -Force -ErrorAction SilentlyContinue
}
}
if ($null -ne $script:DebugLogFile -and (Test-Path $script:DebugLogFile)) {
Copy-Item -LiteralPath $script:DebugLogFile -Destination (Join-Path $bundleDir 'debug.log') -Force -ErrorAction SilentlyContinue
}
$rvasSrc = Join-Path $dataDir 'per-flag-rvas'
if (Test-Path $rvasSrc) {
Copy-Item -LiteralPath $rvasSrc -Destination (Join-Path $bundleDir 'per-flag-rvas') -Recurse -Force -ErrorAction SilentlyContinue
}
$logsSrc = Join-Path $dataDir 'logs'
if (Test-Path $logsSrc) {
Copy-Item -LiteralPath $logsSrc -Destination (Join-Path $bundleDir 'logs') -Recurse -Force -ErrorAction SilentlyContinue
}
}
return $bundleDir
}
catch {
Write-ConsoleLog -Message ('New-DiagnosticBundle failed: ' + $_.Exception.Message) -Level 'ERROR'
return $null
}
}
function Update-MemoryStatusCard {
param()
if ($null -eq $script:SettingsMemoryStatusRefs) { return }
$refs = $script:SettingsMemoryStatusRefs
if ($null -ne $refs.LastRefreshText) {
$refs.LastRefreshText.Text = (Get-Date -Format 'HH:mm:ss')
}
try {
$version = $null
if (Get-Command Get-RobloxVersionFolder -ErrorAction SilentlyContinue) {
$version = Get-RobloxVersionFolder
}
$entry = $null
if (-not [string]::IsNullOrWhiteSpace($version) -and (Get-Command Get-AddressCacheEntry -ErrorAction SilentlyContinue)) {
$entry = Get-AddressCacheEntry -Version $version
}
if ($null -ne $refs.VersionText) {
$refs.VersionText.Text = if ([string]::IsNullOrWhiteSpace($version)) { 'not detected' } else { $version }
}
if ($null -eq $entry) {
if ($null -ne $refs.SourceText) { $refs.SourceText.Text = '(no cache entry)' }
if ($null -ne $refs.HashmapText) { $refs.HashmapText.Text = '-' }
if ($null -ne $refs.LastAcqText) { $refs.LastAcqText.Text = '-' }
if ($null -ne $refs.ScanText) { $refs.ScanText.Text = '-' }
if ($null -ne $refs.FailureText) { $refs.FailureText.Text = '-' }
return
}
$sourceId = if ($entry.ContainsKey('source_id')) { [string]$entry['source_id'] } else { 'unknown' }
$hashmap = if ($entry.ContainsKey('hashmap_base')) { [string]$entry['hashmap_base'] } else { '-' }
$when = if ($entry.ContainsKey('acquired_at')) { [string]$entry['acquired_at'] } else { '-' }
$scanMs = if ($entry.ContainsKey('scan_duration_ms')) { [string]$entry['scan_duration_ms'] + ' ms' } else { '-' }
$failure = if ($entry.ContainsKey('failure_reason') -and -not [string]::IsNullOrWhiteSpace([string]$entry['failure_reason'])) { [string]$entry['failure_reason'] } else { '(none)' }
if ($null -ne $refs.SourceText) { $refs.SourceText.Text = $sourceId }
if ($null -ne $refs.HashmapText) { $refs.HashmapText.Text = $hashmap }
if ($null -ne $refs.LastAcqText) { $refs.LastAcqText.Text = $when }
if ($null -ne $refs.ScanText) { $refs.ScanText.Text = $scanMs }
if ($null -ne $refs.FailureText) { $refs.FailureText.Text = $failure }
}
catch {
Write-ConsoleLog -Message ('Update-MemoryStatusCard failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
function New-SettingsPanelHost {
$sv = [WinUIShell.Microsoft.UI.Xaml.Controls.ScrollViewer]::new()
$sv.HorizontalScrollMode = 'Disabled'
$sv.VerticalScrollMode = 'Auto'
$sv.HorizontalContentAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$sv.VerticalContentAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Stretch
$sv.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 0, 0)
$sv.Background = New-SolidBrush -Hex $script:ThemeColors.MiddleLayer
$cardHost = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$cardHost.Background = New-SolidBrush -Hex $script:ThemeColors.MiddleLayer
$cardHost.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(40, 28, 40, 28)
$cardHost.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.Spacing = 4
$panel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$cardHost.Child = $panel
$sv.Content = $cardHost
return @{ ScrollViewer = $sv; Panel = $panel }
}
function Register-SettingsToggle {
param(
[Parameter(Mandatory)] [string] $Key,
[Parameter(Mandatory)] $ToggleControl,
[scriptblock] $OnChange
)
$ToggleControl.Tag = $Key
if ($null -ne $OnChange) {
if ($null -eq $script:SettingsToggleCallbacks) { $script:SettingsToggleCallbacks = @{} }
$script:SettingsToggleCallbacks[$Key] = $OnChange
}
$ToggleControl.AddToggled({
param($argumentList, $s, $e)
try {
$key = [string]$s.Tag
if ([string]::IsNullOrWhiteSpace($key)) { return }
$script:Settings[$key] = [bool]$s.IsOn
Save-Settings
if ($null -ne $script:SettingsToggleCallbacks -and $script:SettingsToggleCallbacks.ContainsKey($key)) {
& $script:SettingsToggleCallbacks[$key] $s.IsOn
}
} catch {
Write-ConsoleLog -Message ('Settings toggle handler failed: ' + $_.Exception.Message) -Level 'ERROR'
}
})
}
function New-SettingsCardGroup {
param(
[string] $Header = '',
[string] $Description = '',
[object[]] $Rows = @(),
[switch] $IsFirstSection,
[switch] $InfoCard,
[object] $HeaderAction = $null,
[object] $PreCardElement = $null
)
$xHeader = [System.Security.SecurityElement]::Escape([string]$Header)
$xDescription = [System.Security.SecurityElement]::Escape([string]$Description)
$xPrimary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextPrimary)
$xSecondary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextSecondary)
$xCard = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.CardLayer)
$xDividers = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.Dividers)
$headerMargin = if ($IsFirstSection) { '0,0,0,6' } else { '0,32,0,6' }
$cardPadding = if ($InfoCard) { '16' } else { '0' }
$headerXaml = ''
if ($Header -and $Header.Trim()) {
if ($null -ne $HeaderAction) {
$headerXaml = "<Grid x:Name=`"CardHeaderGrid`" Margin=`"$headerMargin`"><Grid.ColumnDefinitions><ColumnDefinition Width=`"*`"/><ColumnDefinition Width=`"Auto`"/></Grid.ColumnDefinitions><TextBlock Grid.Column=`"0`" Text=`"$xHeader`" FontSize=`"18`" FontWeight=`"SemiBold`" Foreground=`"$xPrimary`" VerticalAlignment=`"Center`"/></Grid>"
} else {
$headerXaml = "<TextBlock Text=`"$xHeader`" FontSize=`"18`" FontWeight=`"SemiBold`" Foreground=`"$xPrimary`" Margin=`"$headerMargin`"/>"
}
}
$descriptionXaml = ''
if ($Description -and $Description.Trim()) {
$descriptionXaml = "<TextBlock Text=`"$xDescription`" FontSize=`"12`" Foreground=`"$xSecondary`" Margin=`"0,0,0,20`" TextWrapping=`"Wrap`"/>"
}
$preCardXaml = if ($null -ne $PreCardElement) { '<StackPanel x:Name="PreCardHost" Spacing="0"/>' } else { '' }
$cardGroupXaml = @"
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="CardGroupRoot" Spacing="0">
  $headerXaml
  $descriptionXaml
  $preCardXaml
  <Border Background="$xCard" BorderBrush="$xDividers" BorderThickness="1" CornerRadius="4" Padding="$cardPadding">
    <StackPanel x:Name="CardRowsHost" Spacing="0"/>
  </Border>
</StackPanel>
"@
$outer = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($cardGroupXaml)
$inner = $outer.FindName('CardRowsHost')
if ($null -eq $inner) { throw 'P1275: XAML card-group part not found: CardRowsHost' }
if ($Header -and $Header.Trim() -and $null -ne $HeaderAction) {
$headerGrid = $outer.FindName('CardHeaderGrid')
if ($null -eq $headerGrid) { throw 'P1275: XAML card-group part not found: CardHeaderGrid' }
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($HeaderAction, 1)
$headerGrid.Children.Add($HeaderAction) | Out-Null
}
if ($null -ne $PreCardElement) {
$preCardHost = $outer.FindName('PreCardHost')
if ($null -eq $preCardHost) { throw 'P1275: XAML card-group part not found: PreCardHost' }
$preCardHost.Children.Add($PreCardElement) | Out-Null
}
$rowCount = 0
if ($null -ne $Rows) { $rowCount = @($Rows).Count }
$index = 0
foreach ($row in $Rows) {
$inner.Children.Add($row) | Out-Null
$index++
if ($index -lt $rowCount) {
$divider = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$divider.Height = 1
$divider.Background = New-SolidBrush -Hex $script:ThemeColors.Dividers
$divider.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$inner.Children.Add($divider) | Out-Null
}
}
return $outer
}
function New-SettingsToggleCard {
param(
[Parameter(Mandatory)] [string] $Header,
[string] $Description = '',
[Nullable[char]] $Glyph = $null,
[Parameter(Mandatory)] [string] $SettingsKey,
[bool] $IsOn = $false,
[scriptblock] $OnChange,
[switch] $SetHelpText,
[switch] $IsDisabled
)
$row = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$row.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0))
$row.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(20, 14, 20, 14)
$grid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$hasGlyph = ($null -ne $Glyph)
if ($hasGlyph) {
$colIcon = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colIcon.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($colIcon) | Out-Null
}
$colText = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colText.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$grid.ColumnDefinitions.Add($colText) | Out-Null
$colToggle = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colToggle.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($colToggle) | Out-Null
$textColIndex = 0
if ($hasGlyph) { $textColIndex = 1 }
$toggleColIndex = $textColIndex + 1
if ($hasGlyph) {
$icon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$icon.Glyph = [string]$Glyph
Set-SafeFontFamily -Target $icon -Family $script:IconFontFamily
$icon.FontSize = 18
$icon.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$icon.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$icon.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 16, 0)
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($icon, 0)
$grid.Children.Add($icon) | Out-Null
}
$textStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$textStack.Spacing = 2
$textStack.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$hdr = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$hdr.Text = $Header
$hdr.FontSize = 14
$hdr.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$hdr.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$textStack.Children.Add($hdr) | Out-Null
if ($Description -and $Description.Trim()) {
$desc = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$desc.Text = $Description
$desc.FontSize = 12
$desc.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$desc.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$textStack.Children.Add($desc) | Out-Null
}
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($textStack, $textColIndex)
$grid.Children.Add($textStack) | Out-Null
$toggle = New-ThemedToggleSwitch -Header '' -IsOn $IsOn
try { $toggle.OnContent = 'On' } catch { Write-ConsoleLog -Message ('OnContent set failed: ' + $_.Exception.Message) -Level 'WARN' }
try { $toggle.OffContent = 'Off' } catch { Write-ConsoleLog -Message ('OffContent set failed: ' + $_.Exception.Message) -Level 'WARN' }
$toggle.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 0, 0, 0)
$toggle.MinWidth = 0
$toggle.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($toggle, $toggleColIndex)
$grid.Children.Add($toggle) | Out-Null
$row.Child = $grid
if ($SetHelpText -and $Description -and $Description.Trim()) {
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetHelpText($toggle, $Description)
} catch { Write-ConsoleLog -Message ('AutomationProperties SetHelpText failed: ' + $_.Exception.Message) -Level 'WARN' }
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetName($toggle, $Header)
} catch { Write-ConsoleLog -Message ('AutomationProperties SetName failed: ' + $_.Exception.Message) -Level 'WARN' }
}
if ($IsDisabled) {
$toggle.IsEnabled = $false
$toggle.Opacity = 0.5
return $row
}
if ($PSBoundParameters.ContainsKey('OnChange')) {
Register-SettingsToggle -Key $SettingsKey -ToggleControl $toggle -OnChange $OnChange
} else {
Register-SettingsToggle -Key $SettingsKey -ToggleControl $toggle
}
return $row
}
function New-SettingsInputCard {
param(
[Parameter(Mandatory)] [string] $Header,
[string] $Description = '',
[Nullable[char]] $Glyph = $null,
[Parameter(Mandatory)] [object] $InputControl,
[switch] $IsDisabled,
[switch] $SetHelpText,
[object] $InlineFooter = $null
)
$hasGlyph = ($null -ne $Glyph)
$textColIndex = if ($hasGlyph) { 1 } else { 0 }
$inputColIndex = $textColIndex + 1
$xHeader = [System.Security.SecurityElement]::Escape([string]$Header)
$xDescription = [System.Security.SecurityElement]::Escape([string]$Description)
$xPrimary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextPrimary)
$xSecondary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextSecondary)
$iconColumnXaml = ''
$iconXaml = ''
if ($hasGlyph) {
$glyphHex = ([int][char]$Glyph).ToString('X4')
$xIconFont = [System.Security.SecurityElement]::Escape([string]$script:IconFontFamily.Source)
$iconColumnXaml = '<ColumnDefinition Width="Auto"/>'
$iconXaml = "<FontIcon Grid.Column=`"0`" Glyph=`"&#x$glyphHex;`" FontFamily=`"$xIconFont`" FontSize=`"16`" Foreground=`"$xPrimary`" VerticalAlignment=`"Center`" Margin=`"0,0,16,0`"/>"
}
$descriptionXaml = ''
if ($Description -and $Description.Trim()) {
$descriptionXaml = "<TextBlock Text=`"$xDescription`" FontSize=`"12`" Foreground=`"$xSecondary`" TextWrapping=`"Wrap`"/>"
}
$inputCardXaml = @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Background="Transparent" Padding="20,14,20,14">
  <Grid x:Name="InputCardGrid">
    <Grid.ColumnDefinitions>$iconColumnXaml<ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
    $iconXaml
    <StackPanel x:Name="InputCardTextStack" Grid.Column="$textColIndex" Spacing="2" VerticalAlignment="Center">
      <TextBlock Text="$xHeader" FontSize="14" FontWeight="SemiBold" Foreground="$xPrimary"/>
      $descriptionXaml
    </StackPanel>
  </Grid>
</Border>
"@
$row = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($inputCardXaml)
$grid = $row.FindName('InputCardGrid')
$textStack = $row.FindName('InputCardTextStack')
if ($null -eq $grid) { throw 'P1276: XAML input-card part not found: InputCardGrid' }
if ($null -eq $textStack) { throw 'P1276: XAML input-card part not found: InputCardTextStack' }
if ($null -ne $InlineFooter) {
$textStack.Children.Add($InlineFooter) | Out-Null
}
try { $InputControl.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 0, 0, 0) } catch { }
try { $InputControl.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center } catch { }
if ($IsDisabled) {
try { $InputControl.IsEnabled = $false } catch { }
try { $InputControl.Opacity = 0.5 } catch { }
}
try {
if ($InputControl -is [WinUIShell.Microsoft.UI.Xaml.Controls.TextBox]) {
Set-ThemedTextBoxResources -Control $InputControl
try { Set-AccentResourceOverrides -ResourceDictionary $InputControl.Resources } catch { }
}
} catch { }
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($InputControl, $inputColIndex)
$grid.Children.Add($InputControl) | Out-Null
if ($SetHelpText -and $Description -and $Description.Trim()) {
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetHelpText($InputControl, $Description)
} catch { Write-ConsoleLog -Message ('AutomationProperties SetHelpText failed: ' + $_.Exception.Message) -Level 'WARN' }
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetName($InputControl, $Header)
} catch { Write-ConsoleLog -Message ('AutomationProperties SetName failed: ' + $_.Exception.Message) -Level 'WARN' }
}
return $row
}
function New-SettingsKeyValueRow {
param(
[Parameter(Mandatory)] [string] $Label,
[Parameter(Mandatory)] [string] $Value,
[switch] $Monospace
)
$grid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colLabel.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$grid.ColumnDefinitions.Add($colLabel) | Out-Null
$colValue = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colValue.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($colValue) | Out-Null
$labelTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$labelTb.Text = $Label
$labelTb.FontSize = 14
$labelTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$labelTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$labelTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($labelTb, 0)
$grid.Children.Add($labelTb) | Out-Null
$valueTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$valueTb.Text = $Value
$valueTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$valueTb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$valueTb.TextAlignment = [WinUIShell.Microsoft.UI.Xaml.TextAlignment]::Right
$valueTb.FontSize = 12
$valueTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Normal
$valueTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
if ($Monospace) {
try {
$valueTb.FontFamily = [WinUIShell.Microsoft.UI.Xaml.Media.FontFamily]::new('Cascadia Mono, Consolas, Courier New')
} catch { Write-ConsoleLog -Message ('Mono font set failed: ' + $_.Exception.Message) -Level 'WARN' }
}
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($valueTb, 1)
$grid.Children.Add($valueTb) | Out-Null
return $grid
}
function New-SettingsGeneralPage {
$panelHost = New-SettingsPanelHost
$panel = $panelHost.Panel
$onAutoDetectChange = {
param($isOn)
try {
if ($isOn) {
Detect-Bootstrappers
if ($null -ne $script:LauncherBootstrapperButton) {
Update-BootstrapperButton -Button $script:LauncherBootstrapperButton
}
if ($null -ne $script:LauncherBootstrapperStatusText) {
$script:LauncherBootstrapperStatusText.Text = Get-BootstrapperStatusText
}
Refresh-BootstrapperFlyout
Write-ConsoleLog -Message '[instant-apply] Bootstrapper rescan complete.' -Level 'INFO'
}
} catch {
Write-ConsoleLog -Message ('autoDetectBootstrappers instant-apply failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$autoDetectCard = New-SettingsToggleCard -Header 'Auto-detect bootstrappers on launch' -Description 'Scans for common bootstrappers at startup.' -SettingsKey 'autoDetectBootstrappers' -IsOn $script:Settings.autoDetectBootstrappers -OnChange $onAutoDetectChange -SetHelpText
$minimizeTrayCard = New-SettingsToggleCard -Header 'Minimize to system tray' -Description 'Hides to the notification area instead of closing.' -SettingsKey 'minimizeToTray' -IsOn $script:Settings.minimizeToTray -SetHelpText
$warnIfRunningCard = New-SettingsToggleCard -Header 'Warn if Roblox is already running' -Description 'Shows a confirmation popup when clicking Save and Launch if a Roblox process is already open.' -SettingsKey 'warnIfRobloxRunning' -IsOn $script:Settings.warnIfRobloxRunning -SetHelpText
$debugLoggingCard = New-SettingsToggleCard -Header 'Debug logging' -Description ' Writes verbose diagnostics to debug.log and the console.' -SettingsKey 'debugLogging' -IsOn $script:Settings.debugLogging -SetHelpText
$__alliumDesktopDir = ''
try { $__alliumDesktopDir = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory) } catch { }
$__alliumShortcutExists = $false
try {
if (-not [string]::IsNullOrWhiteSpace($__alliumDesktopDir)) {
$__alliumShortcutExists = Test-Path -LiteralPath ([System.IO.Path]::Combine($__alliumDesktopDir, 'Allium.lnk'))
}
} catch { }
$onDesktopShortcutChange = {
param($isOn)
try {
$desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)
if ([string]::IsNullOrWhiteSpace($desktop)) { throw 'Could not resolve the Desktop folder.' }
$lnk = [System.IO.Path]::Combine($desktop, 'Allium.lnk')
if ($isOn) {
$psExe = try { (Get-Process -Id $PID).Path } catch { $null }
if ([string]::IsNullOrWhiteSpace($psExe)) { $psExe = Join-Path $PSHOME 'powershell.exe' }
$scriptPath = [string]$script:AlliumScriptPath
$workDir = try { Split-Path -Parent $scriptPath } catch { '' }
$iconPath = [string]$script:IconPath
$shell = New-Object -ComObject WScript.Shell
$sc = $shell.CreateShortcut($lnk)
$sc.TargetPath = $psExe
$sc.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $scriptPath + '"'
$sc.WorkingDirectory = $workDir
if (Test-Path -LiteralPath $iconPath) { $sc.IconLocation = $iconPath + ',0' }
$sc.Description = 'Open Allium'
$sc.WindowStyle = 1
$sc.Save()
Write-ConsoleLog -Message '[desktop-shortcut] Desktop shortcut created.' -Level 'INFO'
} else {
if (Test-Path -LiteralPath $lnk) {
Remove-Item -LiteralPath $lnk -Force -ErrorAction Stop
Write-ConsoleLog -Message '[desktop-shortcut] Desktop shortcut removed.' -Level 'INFO'
} else {
Write-ConsoleLog -Message '[desktop-shortcut] No desktop shortcut to remove.' -Level 'INFO'
}
}
} catch {
Write-ConsoleLog -Message ('[desktop-shortcut] toggle action failed: ' + $_.Exception.Message) -Level 'ERROR'
}
}
$desktopShortcutCard = New-SettingsToggleCard -Header 'Desktop shortcut' -Description 'Adds or removes an Allium desktop shortcut.' -SettingsKey 'desktopShortcutEnabled' -IsOn $__alliumShortcutExists -OnChange $onDesktopShortcutChange -SetHelpText
$onMultiInstanceChange = {
param($isOn)
Set-RobloxMultiInstance -Enabled $isOn
}
$multiInstanceCard = New-SettingsToggleCard -Header 'Multi-instance Roblox' -Description 'Holds the Roblox lock so multiple clients can run. Requires launching extra clients from the Roblox website.' -SettingsKey 'robloxMultiInstance' -IsOn $script:Settings.robloxMultiInstance -OnChange $onMultiInstanceChange -SetHelpText
$behaviorGroup = New-SettingsCardGroup -Header 'Behavior' -Description 'Startup, tray, and diagnostic logging.' -Rows @(
$autoDetectCard,
$minimizeTrayCard,
$warnIfRunningCard,
$debugLoggingCard,
$desktopShortcutCard,
$multiInstanceCard
) -IsFirstSection
$panel.Children.Add($behaviorGroup) | Out-Null
$onConsoleLogChange = {
param($isOn)
try {
if ($null -ne $script:EditorConsolePanel) {
$script:EditorConsolePanel.Visibility = if ($isOn) { 'Visible' } else { 'Collapsed' }
}
} catch {
Write-ConsoleLog -Message ('consoleLogVisible instant-apply failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$consoleLogCard = New-SettingsToggleCard -Header 'Show console log panel' -Description 'Displays the in-window console for real-time logging.' -SettingsKey 'consoleLogVisible' -IsOn $script:Settings.consoleLogVisible -OnChange $onConsoleLogChange -SetHelpText
$onBrowserVisChange = {
param($isOn)
try {
if (Get-Command Editor-ToggleBrowser -ErrorAction SilentlyContinue) {
Editor-ToggleBrowser
}
} catch {
Write-ConsoleLog -Message ('fflagBrowserVisible instant-apply failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$browserVisCard = New-SettingsToggleCard -Header 'Show FFlag browser panel by default' -Description 'Opens the FFlag browser automatically alongside the editor.' -SettingsKey 'fflagBrowserVisible' -IsOn $script:Settings.fflagBrowserVisible -OnChange $onBrowserVisChange -SetHelpText
$onPrefixChange = {
param($isOn)
try {
if (Get-Command Editor-RefreshFlagList -ErrorAction SilentlyContinue) {
Editor-RefreshFlagList
}
} catch {
Write-ConsoleLog -Message ('showPrefixIndicators instant-apply failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$prefixIndicatorCard = New-SettingsToggleCard -Header 'Show FFlag type prefix indicators' -Description 'Displays colored badges next to each FFlag name.' -SettingsKey 'showPrefixIndicators' -IsOn $script:Settings.showPrefixIndicators -OnChange $onPrefixChange -SetHelpText
$panelsGroup = New-SettingsCardGroup -Header 'Panels' -Description 'Which extra panels/labels the editor opens by default.' -Rows @(
$consoleLogCard,
$browserVisCard,
$prefixIndicatorCard
)
$panel.Children.Add($panelsGroup) | Out-Null
try { Set-AccentResourceOverrides -ResourceDictionary $panelHost.ScrollViewer.Resources } catch { }
return $panelHost.ScrollViewer
}
function New-SettingsWatchdogPage {
$panelHost = New-SettingsPanelHost
$panel = $panelHost.Panel
$onWatchdogEnabledChange = {
param($isOn)
try {
if ($isOn) { Start-Watchdog } else { Stop-Watchdog }
} catch {
Write-ConsoleLog -Message ('watchdogEnabled instant-apply failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$watchdogEnabledCard = New-SettingsToggleCard -Header 'Watchdog' -Description 'Runs the Roblox monitor in the background.' -SettingsKey 'watchdogEnabled' -IsOn $script:Settings.watchdogEnabled -OnChange $onWatchdogEnabledChange -SetHelpText
$autoReapplyOnRestartCard = New-SettingsToggleCard -Header 'Re-apply FFlags on restart' -Description 'Automatically rewrites FFlags after Roblox launches.' -SettingsKey 'watchdogAutoReapplyOnRestart' -IsOn $script:Settings.watchdogAutoReapplyOnRestart -SetHelpText
$onMonitorFileChange = {
param($isOn)
try {
if ($script:WatchdogRunning) {
if ($isOn) { Watchdog-StartFileMonitor } else { Watchdog-StopFileMonitor }
}
} catch {
Write-ConsoleLog -Message ('watchdogMonitorFile instant-apply failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$monitorFileCard = New-SettingsToggleCard -Header 'Monitor override file' -Description 'Detects external edits to ClientAppSettings.json.' -SettingsKey 'watchdogMonitorFile' -IsOn $script:Settings.watchdogMonitorFile -OnChange $onMonitorFileChange -SetHelpText
$onMonitorVersionChange = {
param($isOn)
try {
if ($script:WatchdogRunning) {
if ($isOn) { Watchdog-StartVersionMonitor } else { Watchdog-StopVersionMonitor }
}
} catch {
Write-ConsoleLog -Message ('watchdogMonitorVersion instant-apply failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$monitorVersionCard = New-SettingsToggleCard -Header 'Monitor version folder' -Description 'Detects when Roblox updates.' -SettingsKey 'watchdogMonitorVersion' -IsOn $script:Settings.watchdogMonitorVersion -OnChange $onMonitorVersionChange -SetHelpText
$monitoringGroup = New-SettingsCardGroup -Header 'Monitoring' -Description 'Watchdog behavior and change-detection sources.' -Rows @(
$watchdogEnabledCard,
$autoReapplyOnRestartCard,
$monitorFileCard,
$monitorVersionCard
) -IsFirstSection
$panel.Children.Add($monitoringGroup) | Out-Null
$onAutoReapplyChange = {
param($isOn)
try {
if ($isOn) { Start-AutoReapplyTimer } else { Stop-AutoReapplyTimer }
} catch {
Write-ConsoleLog -Message ('Auto-reapply toggle side-effect failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
$autoReapplyToggleCard = New-SettingsToggleCard -Header 'Periodic auto-reapply' -Description 'Rewrites FFlags based on a fixed timer.' -SettingsKey 'autoReapplyEnabled' -IsOn $script:Settings.autoReapplyEnabled -OnChange $onAutoReapplyChange -SetHelpText
$intervalBox = New-ThemedTextBox -Placeholder ''
$intervalBox.Text = [string]$script:Settings.autoReapplyIntervalSeconds
$intervalBox.Width = 160
$intervalBox.Tag = 'autoReapplyIntervalSeconds'
$intervalValidationMsg = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$intervalValidationMsg.Text = 'Enter a number between 5 and 300.'
$intervalValidationMsg.FontSize = 11
$intervalValidationMsg.Foreground = New-SolidBrush -Hex $script:ThemeColors.Warning
$intervalValidationMsg.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 4, 0, 0)
$intervalValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$intervalValidationMsg.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$captureIntervalValidationMsg = $intervalValidationMsg
$captureIntervalBox = $intervalBox
$captureSettings = $script:Settings
$intervalBox.AddTextChanged({
param($argumentList, $s, $e)
try {
$raw = $s.Text
$parsed = 0
if ([int]::TryParse($raw, [ref]$parsed)) {
$clamped = $parsed
if ($clamped -lt 5) { $clamped = 5 }
if ($clamped -gt 300) { $clamped = 300 }
$captureSettings['autoReapplyIntervalSeconds'] = $clamped
Save-Settings
if ($clamped -ne $parsed -and $s.Text -ne [string]$clamped) {
$s.Text = [string]$clamped
}
if ($null -ne $captureIntervalValidationMsg) {
$captureIntervalValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
}
} elseif ($raw -and $raw.Trim()) {
if ($null -ne $captureIntervalValidationMsg) {
$captureIntervalValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
}
} catch {
Write-ConsoleLog -Message ('Interval TextBox handler failed: ' + $_.Exception.Message) -Level 'WARN'
}
}.GetNewClosure())
$intervalBox.AddLostFocus({
param($argumentList, $s, $e)
try {
$raw = $captureIntervalBox.Text
$parsed = 0
if ([int]::TryParse($raw, [ref]$parsed)) {
$clamped = $parsed
if ($clamped -lt 5) { $clamped = 5 }
if ($clamped -gt 300) { $clamped = 300 }
$captureSettings['autoReapplyIntervalSeconds'] = $clamped
Save-Settings
if ($captureIntervalBox.Text -ne [string]$clamped) {
$captureIntervalBox.Text = [string]$clamped
}
if ($null -ne $captureIntervalValidationMsg) {
$captureIntervalValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
}
} else {
$fallback = [string]$captureSettings['autoReapplyIntervalSeconds']
if ($captureIntervalBox.Text -ne $fallback) {
$captureIntervalBox.Text = $fallback
}
if ($null -ne $captureIntervalValidationMsg) {
$captureIntervalValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
}
}
} catch {
Write-ConsoleLog -Message ('Interval TextBox LostFocus failed: ' + $_.Exception.Message) -Level 'WARN'
}
}.GetNewClosure())
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetHelpText($intervalBox, 'Seconds between forced re-applications (5 - 300).')
} catch { Write-ConsoleLog -Message ('AutomationProperties SetHelpText failed: ' + $_.Exception.Message) -Level 'WARN' }
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetName($intervalBox, 'Interval')
} catch { Write-ConsoleLog -Message ('AutomationProperties SetName failed: ' + $_.Exception.Message) -Level 'WARN' }
$intervalInputStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$intervalInputStack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$intervalInputStack.Spacing = 8
$intervalInputStack.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$intervalInputStack.Children.Add($intervalBox) | Out-Null
$intervalUnitLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$intervalUnitLabel.Text = 'seconds'
$intervalUnitLabel.FontSize = 13
$intervalUnitLabel.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$intervalUnitLabel.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$intervalInputStack.Children.Add($intervalUnitLabel) | Out-Null
$intervalCard = New-SettingsInputCard -Header 'Auto-reapply interval' -Description 'How often to reapply (5–300s).' -InputControl $intervalInputStack -InlineFooter $intervalValidationMsg
$autoReapplyGroup = New-SettingsCardGroup -Header 'Auto-reapply' -Description 'Periodic FFlag re-application on a fixed interval.' -Rows @(
$autoReapplyToggleCard,
$intervalCard
)
$panel.Children.Add($autoReapplyGroup) | Out-Null
try { Set-AccentResourceOverrides -ResourceDictionary $panelHost.ScrollViewer.Resources } catch { }
return $panelHost.ScrollViewer
}
function New-SettingsMemoryModePage {
$panelHost = New-SettingsPanelHost
$panel = $panelHost.Panel
$memoryWriteModeCard = New-SettingsToggleCard -Header 'Memory write mode' -Description 'Writes FFlags directly to the Roblox process memory.' -SettingsKey 'memoryWriteMode' -IsOn $script:Settings.memoryWriteMode -SetHelpText
$directWriteGroup = New-SettingsCardGroup -Header 'Direct memory write' -Description 'Apply FFlags in real-time using Roblox offsets.' -Rows @(
$memoryWriteModeCard
) -IsFirstSection
$panel.Children.Add($directWriteGroup) | Out-Null
function New-MemStatRow {
param([string] $Label, [string] $Value)
$grid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colLabel.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$grid.ColumnDefinitions.Add($colLabel) | Out-Null
$colValue = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colValue.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($colValue) | Out-Null
$labelTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$labelTb.Text = $Label
$labelTb.FontSize = 14
$labelTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$labelTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$labelTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($labelTb, 0)
$grid.Children.Add($labelTb) | Out-Null
$valueTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$valueTb.Text = $Value
$valueTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$valueTb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$valueTb.TextAlignment = [WinUIShell.Microsoft.UI.Xaml.TextAlignment]::Right
$valueTb.FontSize = 12
$valueTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Normal
$valueTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($valueTb, 1)
$grid.Children.Add($valueTb) | Out-Null
return @{ Row = $grid; ValueBlock = $valueTb }
}
$verRes = New-MemStatRow -Label 'Roblox version' -Value '-'
$srcRes = New-MemStatRow -Label 'Address source' -Value '-'
$hashRes = New-MemStatRow -Label 'HashmapBase' -Value '-'
$acqRes = New-MemStatRow -Label 'Last acquired' -Value '-'
$scanRes = New-MemStatRow -Label 'Scan duration' -Value '-'
$failRes = New-MemStatRow -Label 'Failure' -Value '-'
$refreshRes = New-MemStatRow -Label 'Last refreshed' -Value 'never'
$refs = @{
VersionText = $verRes.ValueBlock
SourceText = $srcRes.ValueBlock
HashmapText = $hashRes.ValueBlock
LastAcqText = $acqRes.ValueBlock
ScanText = $scanRes.ValueBlock
FailureText = $failRes.ValueBlock
LastRefreshText = $refreshRes.ValueBlock
}
$statusStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$statusStack.Spacing = 8
$statusStack.Children.Add($verRes.Row) | Out-Null
$statusStack.Children.Add($srcRes.Row) | Out-Null
$statusStack.Children.Add($hashRes.Row) | Out-Null
$statusStack.Children.Add($acqRes.Row) | Out-Null
$statusStack.Children.Add($scanRes.Row) | Out-Null
$statusStack.Children.Add($failRes.Row) | Out-Null
$statusStack.Children.Add($refreshRes.Row) | Out-Null
$script:SettingsMemoryStatusRefs = $refs
$refreshBtn = New-ThemedButton -Content 'Refresh' -ToolbarStyle -FontSize 13
$refreshBtn.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$refreshBtn.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 0, -55)
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetName($refreshBtn, 'Refresh acquisition status')
} catch { Write-ConsoleLog -Message ('AutomationProperties SetName failed: ' + $_.Exception.Message) -Level 'WARN' }
try {
[WinUIShell.Microsoft.UI.Xaml.Automation.AutomationProperties]::SetHelpText($refreshBtn, 'Re-run address acquisition and refresh the status card.')
} catch { Write-ConsoleLog -Message ('AutomationProperties SetHelpText failed: ' + $_.Exception.Message) -Level 'WARN' }
$refreshBtn.AddClick({ Update-MemoryStatusCard })
$statusGroup = New-SettingsCardGroup -Header 'Address acquisition status' -Description 'Current HashmapBase pointer and its origin.' -Rows @($statusStack) -InfoCard -HeaderAction $refreshBtn
$panel.Children.Add($statusGroup) | Out-Null
Update-MemoryStatusCard
$manualStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$manualStack.Spacing = 12
$manualIntro = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$manualIntro.Text = 'Enter a HashmapBase pointer in hex (for example 0x7ffabc123000) to override auto-acquisition.'
$manualIntro.FontSize = 12
$manualIntro.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$manualIntro.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$manualStack.Children.Add($manualIntro) | Out-Null
$manualRow = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$manualColBox = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$manualColBox.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$manualRow.ColumnDefinitions.Add($manualColBox) | Out-Null
$manualColBtn = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$manualColBtn.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$manualRow.ColumnDefinitions.Add($manualColBtn) | Out-Null
$addrBox = New-ThemedTextBox -Placeholder '0x7ffabc123000'
$addrBox.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($addrBox, 0)
$manualRow.Children.Add($addrBox) | Out-Null
$validateBtn = New-ThemedButton -Content 'Validate' -ToolbarStyle
$validateBtn.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(12, 0, 0, 0)
$validateBtn.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($validateBtn, 1)
$manualRow.Children.Add($validateBtn) | Out-Null
$manualStack.Children.Add($manualRow) | Out-Null
$validationMessage = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$validationMessage.Text = ''
$validationMessage.FontSize = 12
$validationMessage.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$validationMessage.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$manualStack.Children.Add($validationMessage) | Out-Null
$captureAddrBox = $addrBox
$captureValidationMsg = $validationMessage
$warningHex = $script:ThemeColors.Warning
$errorHex = $script:ThemeColors.Error
$successHex = $script:ThemeColors.Success
$validateBtn.AddClick({
try {
$raw = $captureAddrBox.Text
if (-not ($raw -and $raw.Trim())) {
$captureValidationMsg.Text = 'Enter an address first.'
$captureValidationMsg.Foreground = New-SolidBrush -Hex $warningHex
$captureValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
return
}
$hex = $raw.Trim()
if ($hex.StartsWith('0x') -or $hex.StartsWith('0X')) { $hex = $hex.Substring(2) }
$parsed = 0L
if ([long]::TryParse($hex, [System.Globalization.NumberStyles]::HexNumber, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$parsed) -and $parsed -gt 0) {
$captureValidationMsg.Text = 'Address parses OK: 0x' + $parsed.ToString('X')
$captureValidationMsg.Foreground = New-SolidBrush -Hex $successHex
} else {
$captureValidationMsg.Text = 'Not a valid hex address.'
$captureValidationMsg.Foreground = New-SolidBrush -Hex $errorHex
}
$captureValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
} catch {
$captureValidationMsg.Text = 'Error: ' + $_.Exception.Message
$captureValidationMsg.Foreground = New-SolidBrush -Hex $errorHex
$captureValidationMsg.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
}.GetNewClosure())
$manualAddressGroup = New-SettingsCardGroup -Header 'Manual address entry' -Description 'Override auto-acquisition with a hex pointer.' -Rows @($manualStack) -InfoCard
$panel.Children.Add($manualAddressGroup) | Out-Null
try { Set-AccentResourceOverrides -ResourceDictionary $panelHost.ScrollViewer.Resources } catch { }
return $panelHost.ScrollViewer
}
function New-SettingsHttpsInterceptPage {
$panelHost = New-SettingsPanelHost
$panel = $panelHost.Panel
function New-HttpsStatRow {
param([string] $Label, [string] $Value)
$grid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colLabel.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$grid.ColumnDefinitions.Add($colLabel) | Out-Null
$colValue = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colValue.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($colValue) | Out-Null
$labelTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$labelTb.Text = $Label
$labelTb.FontSize = 14
$labelTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$labelTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$labelTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($labelTb, 0)
$grid.Children.Add($labelTb) | Out-Null
$valueTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$valueTb.Text = $Value
$valueTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$valueTb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$valueTb.TextAlignment = [WinUIShell.Microsoft.UI.Xaml.TextAlignment]::Right
$valueTb.FontSize = 12
$valueTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Normal
$valueTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($valueTb, 1)
$grid.Children.Add($valueTb) | Out-Null
return @{ Row = $grid; ValueBlock = $valueTb }
}
$enableToggleCard = New-SettingsToggleCard -Header 'HTTPS interception' -Description 'Toggle to merge FFlags overrides.' -SettingsKey 'httpInterceptEnabled' -IsOn $script:Settings.httpInterceptEnabled -SetHelpText -OnChange {
try {
if ($script:Settings.httpInterceptEnabled) {
$__ok = Start-HttpIntercept
if (-not $__ok) {
Write-ConsoleLog -Message '[https-page] Failed to start proxy.' -Level 'WARN'
}
} else {
Stop-HttpIntercept
}
} catch {
Write-ConsoleLog -Message ('[https-page] Toggle action error: ' + $_.Exception.Message) -Level 'WARN'
}
}
$mainControlsGroup = New-SettingsCardGroup -Header 'HTTPS Interception' -Description 'Route Roblox HTTPS traffic through a local proxy to apply FFlags.' -Rows @(
$enableToggleCard
) -IsFirstSection
$panel.Children.Add($mainControlsGroup) | Out-Null
if ($script:Settings.httpInterceptCaInstalled) {
$__caStatusVal = 'Installed'
$__caThumbVal = [string]$script:Settings.httpInterceptCaThumbprint
if ([string]::IsNullOrWhiteSpace($__caThumbVal)) { $__caThumbVal = '—' }
$__caGenVal = [string]$script:Settings.httpInterceptCaGeneratedUtc
if ([string]::IsNullOrWhiteSpace($__caGenVal)) { $__caGenVal = '—' }
} else {
$__caStatusVal = 'Not installed'
$__caThumbVal = '—'
$__caGenVal = '—'
}
$caStatusRes = New-HttpsStatRow -Label 'Status' -Value $__caStatusVal
$caThumbRes = New-HttpsStatRow -Label 'Thumbprint' -Value $__caThumbVal
$caGenRes = New-HttpsStatRow -Label 'Generated' -Value $__caGenVal
$script:HttpsPageCaStatusValue = $caStatusRes.ValueBlock
$script:HttpsPageCaThumbValue = $caThumbRes.ValueBlock
$script:HttpsPageCaGenValue = $caGenRes.ValueBlock
$caDetailText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$caDetailText.Text = ''
$caDetailText.FontSize = 12
$caDetailText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$caDetailText.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$caDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$script:HttpsPageCaDetailText = $caDetailText
$caRowsStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$caRowsStack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Vertical
$caRowsStack.Spacing = 8
$caRowsStack.Children.Add($caStatusRes.Row) | Out-Null
$caRowsStack.Children.Add($caThumbRes.Row) | Out-Null
$caRowsStack.Children.Add($caGenRes.Row) | Out-Null
$caRowsStack.Children.Add($caDetailText) | Out-Null
$installBtn = New-ThemedButton -Content 'Install' -ToolbarStyle -FontSize 13
$script:HttpsPageInstallBtn = $installBtn
$uninstallBtn = New-ThemedButton -Content 'Uninstall' -ToolbarStyle -FontSize 13
$script:HttpsPageUninstallBtn = $uninstallBtn
if ($script:Settings.httpInterceptCaInstalled) {
$installBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$uninstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
} else {
$installBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
$uninstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
}
$installBtn.AddClick({
param($argumentList, $s, $e)
try {
$script:HttpsPageInstallBtn.IsEnabled = $false
$script:HttpsPageUninstallBtn.IsEnabled = $false
if ($null -ne $script:HttpsPageCaStatusValue) { $script:HttpsPageCaStatusValue.Text = 'Installing…' }
$__tim = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$__tim.Interval = New-UITimeSpan -Milliseconds 50
$__tim.AddTick({
param($argumentList, $ts, $te)
$ts.Stop()
try {
$__result = Install-AlliumProxyCA
if ($null -ne $__result -and $__result.Success) {
if ($null -ne $script:HttpsPageCaStatusValue) { $script:HttpsPageCaStatusValue.Text = 'Installed' }
if ($null -ne $script:HttpsPageCaThumbValue) {
$__t = [string]$script:Settings.httpInterceptCaThumbprint
if ([string]::IsNullOrWhiteSpace($__t)) { $__t = '—' }
$script:HttpsPageCaThumbValue.Text = $__t
}
if ($null -ne $script:HttpsPageCaGenValue) {
$__g = [string]$script:Settings.httpInterceptCaGeneratedUtc
if ([string]::IsNullOrWhiteSpace($__g)) { $__g = '—' }
$script:HttpsPageCaGenValue.Text = $__g
}
$script:HttpsPageInstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$script:HttpsPageUninstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ('CA installed: ' + $__result.Installed + ' new, ' + $__result.Skipped + ' present, ' + $__result.Failed + ' failed of ' + $__result.Discovered + ' discovered.')
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
} else {
$__err = 'unknown error'
if ($null -ne $__result -and $null -ne $__result.Error) { $__err = $__result.Error }
if ($null -ne $script:HttpsPageCaStatusValue) { $script:HttpsPageCaStatusValue.Text = 'Not installed' }
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ('CA install failed: ' + $__err)
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
}
} catch {
if ($null -ne $script:HttpsPageCaStatusValue) { $script:HttpsPageCaStatusValue.Text = 'Not installed' }
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ('CA install error: ' + $_.Exception.Message)
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
}
$script:HttpsPageInstallBtn.IsEnabled = $true
$script:HttpsPageUninstallBtn.IsEnabled = $true
})
$__tim.Start()
} catch {
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ('CA install dispatch error: ' + $_.Exception.Message)
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
$script:HttpsPageInstallBtn.IsEnabled = $true
$script:HttpsPageUninstallBtn.IsEnabled = $true
}
})
$uninstallBtn.AddClick({
param($argumentList, $s, $e)
try {
$script:HttpsPageInstallBtn.IsEnabled = $false
$script:HttpsPageUninstallBtn.IsEnabled = $false
if ($null -ne $script:HttpsPageCaStatusValue) { $script:HttpsPageCaStatusValue.Text = 'Uninstalling…' }
$__tim = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$__tim.Interval = New-UITimeSpan -Milliseconds 50
$__tim.AddTick({
param($argumentList, $ts, $te)
$ts.Stop()
try {
$__result = Uninstall-AlliumProxyCA
if ($null -ne $__result -and $__result.Success) {
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ('CA uninstalled. Stripped: ' + $__result.Stripped + ', Restored: ' + $__result.Restored + ', Failed: ' + $__result.Failed)
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
} else {
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = 'CA uninstall completed with errors. See console log.'
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
}
if ($null -ne $script:HttpsPageCaStatusValue) { $script:HttpsPageCaStatusValue.Text = 'Not installed' }
if ($null -ne $script:HttpsPageCaThumbValue) { $script:HttpsPageCaThumbValue.Text = '—' }
if ($null -ne $script:HttpsPageCaGenValue) { $script:HttpsPageCaGenValue.Text = '—' }
$script:HttpsPageUninstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
$script:HttpsPageInstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
} catch {
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ('CA uninstall error: ' + $_.Exception.Message)
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
}
$script:HttpsPageInstallBtn.IsEnabled = $true
$script:HttpsPageUninstallBtn.IsEnabled = $true
})
$__tim.Start()
} catch {
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ('CA uninstall dispatch error: ' + $_.Exception.Message)
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible
}
$script:HttpsPageInstallBtn.IsEnabled = $true
$script:HttpsPageUninstallBtn.IsEnabled = $true
}
})
$caBtnStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$caBtnStack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Horizontal
$caBtnStack.Spacing = 8
$caBtnStack.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Top
$caBtnStack.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$caBtnStack.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 0, -60)
$caBtnStack.Children.Add($installBtn) | Out-Null
$caBtnStack.Children.Add($uninstallBtn) | Out-Null
$caHeaderDesc = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$caHeaderDesc.Text = 'Locally-trusted CA used to decrypt client-settings.'
$caHeaderDesc.FontSize = 12
$caHeaderDesc.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$caHeaderDesc.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$caHeaderDesc.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Top
$caHeaderDesc.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 16, 0)
$caHeaderGrid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$caHdrColText = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$caHdrColText.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$caHeaderGrid.ColumnDefinitions.Add($caHdrColText) | Out-Null
$caHdrColBtn = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$caHdrColBtn.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$caHeaderGrid.ColumnDefinitions.Add($caHdrColBtn) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($caHeaderDesc, 0)
$caHeaderGrid.Children.Add($caHeaderDesc) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($caBtnStack, 1)
$caHeaderGrid.Children.Add($caBtnStack) | Out-Null
$caHeaderGrid.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 0, 20)
$caGroup = New-SettingsCardGroup -Header 'Root certificate' -Rows @($caRowsStack) -InfoCard -PreCardElement $caHeaderGrid
$panel.Children.Add($caGroup) | Out-Null
if ($null -ne $script:HttpsInterceptorInstance -and $script:HttpsInterceptorInstance.IsRunning) {
$__stState = ('Running on 127.0.0.1:' + $script:HttpsInterceptorInstance.Port)
} else {
$__stState = 'Stopped'
}
if ($null -ne $script:HttpsInterceptorInstance) {
$__stOver = [string]$script:HttpsInterceptorInstance.FlagOverrideCount
$__stReq = [string]$script:HttpsInterceptorInstance.RecordCount
} else {
$__stOver = '(proxy not running)'
$__stReq = '0'
}
$stStateRes = New-HttpsStatRow -Label 'State' -Value $__stState
$stOverRes = New-HttpsStatRow -Label 'Flag overrides active' -Value $__stOver
$stReqRes = New-HttpsStatRow -Label 'Requests intercepted (session)' -Value $__stReq
$script:HttpsPageStatusStateText = $stStateRes.ValueBlock
$script:HttpsPageStatusOverridesText = $stOverRes.ValueBlock
$script:HttpsPageStatusRequestsText = $stReqRes.ValueBlock
$statusStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$statusStack.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Vertical
$statusStack.Spacing = 8
$statusStack.Children.Add($stStateRes.Row) | Out-Null
$statusStack.Children.Add($stOverRes.Row) | Out-Null
$statusStack.Children.Add($stReqRes.Row) | Out-Null
$statusGroup = New-SettingsCardGroup -Header 'Proxy status' -Description 'Current proxy and interception state.' -Rows @($statusStack) -InfoCard
$panel.Children.Add($statusGroup) | Out-Null
$diagToggleCard = New-SettingsToggleCard -Header 'Live traffic log' -Description 'Logs each intercepted request to the console log.' -SettingsKey 'httpInterceptDiagnosticsLive' -IsOn $script:Settings.httpInterceptDiagnosticsLive -SetHelpText -OnChange {
try {
if ($script:Settings.httpInterceptDiagnosticsLive -and $null -ne $script:HttpsInterceptorInstance) {
$__recs = @($script:HttpsInterceptorInstance.GetRecentRequests())
$__hw = 0L
if ($__recs.Count -gt 0) {
$__last = $__recs[$__recs.Count - 1]
if ($null -ne $__last) { $__hw = $__last.UtcTimestamp.Ticks }
}
$script:HttpsPageLogHighWater = $__hw
}
} catch {
Write-ConsoleLog -Message ('[https-page] diag toggle onchange: ' + $_.Exception.Message) -Level 'WARN'
}
}
$diagGroup = New-SettingsCardGroup -Header 'Diagnostics' -Description 'Optional logging for troubleshooting interception.' -Rows @(
$diagToggleCard
)
$panel.Children.Add($diagGroup) | Out-Null
$resetBtn = New-ThemedButton -Content 'Reset all HTTPS state' -ToolbarStyle
$script:HttpsPageResetBtn = $resetBtn
if ($null -eq $script:HttpsResetDiagSequence) { $script:HttpsResetDiagSequence = 0 }
if ($null -eq $script:HttpsResetDiagTicks) { $script:HttpsResetDiagTicks = @{} }
if ($null -eq $script:HttpsResetCompletedIds) { $script:HttpsResetCompletedIds = @{} }
$resetBtn.AddClick({
param($argumentList, $s, $e)
$script:HttpsResetDiagSequence++
$__resetDiagId = [int]$script:HttpsResetDiagSequence
$script:HttpsResetDiagActiveId = $__resetDiagId
$script:HttpsResetDiagTicks[$__resetDiagId] = 0
Write-ConsoleLog -Message ('[https-reset:' + $__resetDiagId + '] click entered') -Level 'INFO'
try {
$__confirmPanel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$__confirmPanel.Orientation = [WinUIShell.Microsoft.UI.Xaml.Controls.Orientation]::Vertical
$__confirmPanel.Spacing = 8
$__confirmMsg = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$__confirmMsg.Text = 'This will stop the proxy, uninstall the Allium root CA from every discovered Roblox installation, and remove the ALLIUM HOSTS block from your Windows hosts file. Continue?'
$__confirmMsg.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$__confirmMsg.FontSize = 13
$__confirmMsg.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$__confirmPanel.Children.Add($__confirmMsg) | Out-Null
$__result = Show-CustomDialog -XamlRoot $s.XamlRoot -Title 'Reset all HTTPS state?' -Content $__confirmPanel -PrimaryButtonText 'Reset' -CloseButtonText 'Cancel'
if ($__result -ne 'Primary') {
Write-ConsoleLog -Message '[https-page] Reset cancelled.' -Level 'INFO'
return
}
$script:HttpsPageResetBtn.IsEnabled = $false
Write-ConsoleLog -Message ('[https-reset:' + $__resetDiagId + '] confirmed; timer starting') -Level 'INFO'
Write-ConsoleLog -Message '[https-page] Resetting HTTPS state...' -Level 'INFO'
$__tim = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$__tim.Interval = New-UITimeSpan -Milliseconds 50
$__tim.AddTick({
param($argumentList, $ts, $te)
$ts.Stop()
$__tickDiagId = [int]$script:HttpsResetDiagActiveId
if (-not $script:HttpsResetDiagTicks.ContainsKey($__tickDiagId)) { $script:HttpsResetDiagTicks[$__tickDiagId] = 0 }
$script:HttpsResetDiagTicks[$__tickDiagId] = [int]$script:HttpsResetDiagTicks[$__tickDiagId] + 1
$__tickDiagCount = [int]$script:HttpsResetDiagTicks[$__tickDiagId]
Write-ConsoleLog -Message ('[https-reset:' + $__tickDiagId + '] tick #' + $__tickDiagCount) -Level 'INFO'
if ($script:HttpsResetCompletedIds.ContainsKey($__tickDiagId)) {
Write-ConsoleLog -Message ('[https-reset:' + $__tickDiagId + '] tick #' + $__tickDiagCount + ' suppressed by one-shot gate') -Level 'INFO'
return
}
$script:HttpsResetCompletedIds[$__tickDiagId] = $true
$__parts = @()
try {
Stop-HttpIntercept
$__parts += 'proxy stopped'
} catch {
$__parts += ('stop-error: ' + $_.Exception.Message)
}
try {
$__uninst = Uninstall-AlliumProxyCA
if ($null -ne $__uninst) {
$__parts += ('CA uninst: stripped=' + $__uninst.Stripped + ' restored=' + $__uninst.Restored + ' failed=' + $__uninst.Failed)
}
} catch {
$__parts += ('ca-error: ' + $_.Exception.Message)
}
try {
if (Test-Path $script:HttpsHostsPath -PathType Leaf) {
$__existing = [System.IO.File]::ReadAllText($script:HttpsHostsPath)
if ($__existing.Contains('# ==== BEGIN ALLIUM HOSTS')) {
$__pattern = '(?s)\r?\n?# ==== BEGIN ALLIUM HOSTS ====.*?# ==== END ALLIUM HOSTS ====\r?\n?'
$__stripped = [regex]::Replace($__existing, $__pattern, '')
[System.IO.File]::WriteAllText($script:HttpsHostsPath, $__stripped)
$__parts += 'hosts sentinel stripped'
} else {
$__parts += 'hosts already clean'
}
}
} catch {
$__parts += ('hosts-error: ' + $_.Exception.Message)
}
$script:Settings.httpInterceptEnabled = $false
Save-Settings
Write-ConsoleLog -Message ('[https-reset:' + $__tickDiagId + '] completion reached from tick #' + $__tickDiagCount) -Level 'INFO'
Write-ConsoleLog -Message ('[https-page] Reset complete: ' + ($__parts -join ', ')) -Level 'INFO'
if ($null -ne $script:HttpsPageCaStatusValue) { $script:HttpsPageCaStatusValue.Text = 'Not installed' }
if ($null -ne $script:HttpsPageCaThumbValue) { $script:HttpsPageCaThumbValue.Text = '—' }
if ($null -ne $script:HttpsPageCaGenValue) { $script:HttpsPageCaGenValue.Text = '—' }
if ($null -ne $script:HttpsPageCaDetailText) {
$script:HttpsPageCaDetailText.Text = ''
$script:HttpsPageCaDetailText.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed
}
if ($null -ne $script:HttpsPageInstallBtn) { $script:HttpsPageInstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Visible }
if ($null -ne $script:HttpsPageUninstallBtn) { $script:HttpsPageUninstallBtn.Visibility = [WinUIShell.Microsoft.UI.Xaml.Visibility]::Collapsed }
if ($null -ne $script:HttpsPageStatusStateText) { $script:HttpsPageStatusStateText.Text = 'Stopped' }
if ($null -ne $script:HttpsPageStatusOverridesText) { $script:HttpsPageStatusOverridesText.Text = '(proxy not running)' }
if ($null -ne $script:HttpsPageStatusRequestsText) { $script:HttpsPageStatusRequestsText.Text = '0' }
$script:HttpsPageResetBtn.IsEnabled = $true
})
$__tim.Start()
} catch {
Write-ConsoleLog -Message ('[https-page] Reset dispatch error: ' + $_.Exception.Message) -Level 'WARN'
$script:HttpsPageResetBtn.IsEnabled = $true
}
})
$resetCard = New-SettingsInputCard -Header 'Reset all HTTPS state' -Description 'Stops the proxy, removes the CA, and clears hosts entries.' -InputControl $resetBtn
$resetGroup = New-SettingsCardGroup -Header 'Troubleshooting' -Description 'Recover from a broken interception state.' -Rows @($resetCard)
$panel.Children.Add($resetGroup) | Out-Null
if ($null -ne $script:HttpsPageRefreshTimer) {
try { $script:HttpsPageRefreshTimer.Stop() } catch {}
}
if ($null -eq $script:HttpsPageRefreshTickCounter) {
$script:HttpsPageRefreshTickCounter = 0
}
if ($null -eq $script:HttpsPageLogHighWater) {
$script:HttpsPageLogHighWater = 0L
}
$script:HttpsPageRefreshTimer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$script:HttpsPageRefreshTimer.Interval = New-UITimeSpan -Milliseconds 2000
$script:HttpsPageRefreshTimer.AddTick({
param($argumentList, $s, $e)
$script:HttpsPageRefreshTickCounter++
try {
if (($script:HttpsPageRefreshTickCounter % 30) -eq 1) {
$__hasInst = ($null -ne $script:HttpsInterceptorInstance)
$__isRun = $false
if ($__hasInst) { try { $__isRun = [bool]$script:HttpsInterceptorInstance.IsRunning } catch {} }
Write-ConsoleLog -Message ('[https-page] refresh tick #' + $script:HttpsPageRefreshTickCounter + ' hasInst=' + $__hasInst + ' isRun=' + $__isRun) -Level 'INFO'
}
if ($null -ne $script:HttpsInterceptorInstance -and $script:HttpsInterceptorInstance.IsRunning) {
if ($null -ne $script:HttpsPageStatusStateText) {
$script:HttpsPageStatusStateText.Text = ('Running on 127.0.0.1:' + $script:HttpsInterceptorInstance.Port)
}
if ($null -ne $script:HttpsPageStatusOverridesText) {
$script:HttpsPageStatusOverridesText.Text = [string]$script:HttpsInterceptorInstance.FlagOverrideCount
}
if ($null -ne $script:HttpsPageStatusRequestsText) {
$script:HttpsPageStatusRequestsText.Text = [string]$script:HttpsInterceptorInstance.RecordCount
}
} else {
if ($null -ne $script:HttpsPageStatusStateText) {
$script:HttpsPageStatusStateText.Text = 'Stopped'
}
if ($null -ne $script:HttpsPageStatusOverridesText) {
$script:HttpsPageStatusOverridesText.Text = '(proxy not running)'
}
if ($null -ne $script:HttpsPageStatusRequestsText) {
$script:HttpsPageStatusRequestsText.Text = '0'
}
}
if ($script:Settings.httpInterceptDiagnosticsLive -and $null -ne $script:HttpsInterceptorInstance) {
$__records = @($script:HttpsInterceptorInstance.GetRecentRequests())
if ($__records.Count -gt 0) {
$__hw = 0L
if ($null -ne $script:HttpsPageLogHighWater) { $__hw = [long]$script:HttpsPageLogHighWater }
$__newHw = $__hw
foreach ($__rec in $__records) {
if ($null -eq $__rec) { continue }
$__ticks = $__rec.UtcTimestamp.Ticks
if ($__ticks -le $__hw) { continue }
if ($__ticks -gt $__newHw) { $__newHw = $__ticks }
$__ts = $__rec.UtcTimestamp.ToLocalTime().ToString('HH:mm:ss')
$__flags = ''
if ($__rec.Modified) { $__flags += ' MOD' }
if (-not [string]::IsNullOrEmpty([string]$__rec.Note)) { $__flags += ' (' + $__rec.Note + ')' }
$__line = ($__ts + '  ' + $__rec.Method.PadRight(6) + ' ' + $__rec.Host + $__rec.PathAndQuery + '  [' + $__rec.UpstreamStatus + '] ' + $__rec.UpstreamBytes + 'B' + $__flags)
Write-ConsoleLog -Message ('[https-intercept] ' + $__line) -Level 'INFO'
}
$script:HttpsPageLogHighWater = $__newHw
}
}
} catch {
try {
Write-ConsoleLog -Message ('[https-page] refresh tick #' + $script:HttpsPageRefreshTickCounter + ' EXCEPTION: ' + $_.Exception.Message) -Level 'WARN'
} catch {}
}
})
$script:HttpsPageRefreshTimer.Start()
Write-ConsoleLog -Message '[https-page] refresh timer started (2s cadence)' -Level 'INFO'
try { Set-AccentResourceOverrides -ResourceDictionary $panelHost.ScrollViewer.Resources } catch { }
return $panelHost.ScrollViewer
}
function New-SettingsAboutPage {
$panelHost = New-SettingsPanelHost
$panel = $panelHost.Panel
$sha = Get-AlliumSourceSha
$lineCount = Get-AlliumSourceLineCount
$psVer = $PSVersionTable.PSVersion.ToString()
$xVersion = [System.Security.SecurityElement]::Escape([string]$script:AppVersion)
$xSha = [System.Security.SecurityElement]::Escape([string]$sha)
$xLoc = [System.Security.SecurityElement]::Escape([string]$lineCount)
$xPs = [System.Security.SecurityElement]::Escape([string]$psVer)
$xPrimary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextPrimary)
$xSecondary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextSecondary)
$buildInfoXaml = @"
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Spacing="8">
  <Grid ColumnSpacing="20"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="Version" FontSize="14" FontWeight="SemiBold" Foreground="$xPrimary" VerticalAlignment="Center"/><TextBlock Grid.Column="1" Text="$xVersion" FontSize="12" FontWeight="Normal" Foreground="$xSecondary" HorizontalAlignment="Right" TextAlignment="Right" VerticalAlignment="Center"/></Grid>
  <Grid ColumnSpacing="20"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="Source SHA-256" FontSize="14" FontWeight="SemiBold" Foreground="$xPrimary" VerticalAlignment="Center"/><TextBlock Grid.Column="1" Text="$xSha" FontSize="12" FontWeight="Normal" FontFamily="Cascadia Mono, Consolas, Courier New" Foreground="$xSecondary" HorizontalAlignment="Right" TextAlignment="Right" VerticalAlignment="Center"/></Grid>
  <Grid ColumnSpacing="20"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="Lines of code" FontSize="14" FontWeight="SemiBold" Foreground="$xPrimary" VerticalAlignment="Center"/><TextBlock Grid.Column="1" Text="$xLoc" FontSize="12" FontWeight="Normal" Foreground="$xSecondary" HorizontalAlignment="Right" TextAlignment="Right" VerticalAlignment="Center"/></Grid>
  <Grid ColumnSpacing="20"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="PowerShell" FontSize="14" FontWeight="SemiBold" Foreground="$xPrimary" VerticalAlignment="Center"/><TextBlock Grid.Column="1" Text="$xPs" FontSize="12" FontWeight="Normal" Foreground="$xSecondary" HorizontalAlignment="Right" TextAlignment="Right" VerticalAlignment="Center"/></Grid>
  <Grid ColumnSpacing="20"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions><TextBlock Text="License" FontSize="14" FontWeight="SemiBold" Foreground="$xPrimary" VerticalAlignment="Center"/><TextBlock Grid.Column="1" Text="MIT" FontSize="12" FontWeight="Normal" Foreground="$xSecondary" HorizontalAlignment="Right" TextAlignment="Right" VerticalAlignment="Center"/></Grid>
</StackPanel>
"@
$buildInfoStack = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($buildInfoXaml)
$buildInfoGroup = New-SettingsCardGroup -Header 'Build info' -Description 'Version fingerprint and runtime environment.' -Rows @($buildInfoStack) -IsFirstSection -InfoCard
$panel.Children.Add($buildInfoGroup) | Out-Null
$credits = @(
@{ Name = 'mdgrs-mei'; Contribution = 'WinUIShell'; Url = 'https://github.com/mdgrs-mei/WinUIShell' },
@{ Name = '4anti'; Contribution = 'Roblox-Fastflag-Manager'; Url = 'https://github.com/4anti/Roblox-Fastflag-Manager' },
@{ Name = 'Fleasion'; Contribution = 'HTTPS Interception base'; Url = 'https://github.com/fleasion/fleasion' },
@{ Name = 'Froststrap'; Contribution = 'Editor and UI Inspiration'; Url = 'https://github.com/Froststrap/Froststrap' },
@{ Name = 'souloveryall'; Contribution = 'FFlag Offsets and FFlags database';Url = 'https://github.com/souloveryall/offsets.hpp/blob/main/Offsets.hpp' },
@{ Name = 'theo'; Contribution = 'FFlag Offsets'; Url = 'https://offsets.imtheo.lol/fflags.hpp' },
@{ Name = 'MaximumADHD'; Contribution = 'Roblox-FFlag-Tracker'; Url = 'https://github.com/MaximumADHD/Roblox-FFlag-Tracker' }
)
$xPrimary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextPrimary)
$xSecondary = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.TextSecondary)
$xButton = [System.Security.SecurityElement]::Escape([string]$script:ThemeColors.ButtonSurface)
$xIconFont = [System.Security.SecurityElement]::Escape([string]$script:IconFontFamily.Source)
$creditsXaml = [System.Text.StringBuilder]::new(4096)
[void]$creditsXaml.Append('<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Spacing="12">')
for ($creditIndex = 0; $creditIndex -lt $credits.Count; $creditIndex++) {
$credit = $credits[$creditIndex]
$xName = [System.Security.SecurityElement]::Escape([string]$credit.Name)
$xContribution = [System.Security.SecurityElement]::Escape([string]$credit.Contribution)
[void]$creditsXaml.Append('<Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>')
[void]$creditsXaml.Append("<FontIcon Grid.Column=`"0`" Glyph=`"&#xE1CB;`" FontFamily=`"$xIconFont`" FontSize=`"18`" Foreground=`"$xSecondary`" VerticalAlignment=`"Center`" Margin=`"0,0,16,0`"/>")
[void]$creditsXaml.Append("<StackPanel Grid.Column=`"1`" Spacing=`"2`"><TextBlock Text=`"$xName`" FontSize=`"14`" FontWeight=`"SemiBold`" Foreground=`"$xPrimary`"/><TextBlock Text=`"$xContribution`" FontSize=`"12`" Foreground=`"$xSecondary`" TextWrapping=`"Wrap`"/></StackPanel>")
if ($credit.Url -and ([string]$credit.Url).Trim()) {
$xAutomationName = [System.Security.SecurityElement]::Escape('Open link for ' + [string]$credit.Name)
$xHelp = [System.Security.SecurityElement]::Escape('Placeholder link for ' + [string]$credit.Name)
[void]$creditsXaml.Append("<Button x:Name=`"CreditLink$creditIndex`" Grid.Column=`"2`" Background=`"$xButton`" Foreground=`"$xPrimary`" Padding=`"8,4,8,4`" CornerRadius=`"4`" VerticalAlignment=`"Center`" Margin=`"12,0,0,0`" AutomationProperties.Name=`"$xAutomationName`" AutomationProperties.HelpText=`"$xHelp`"><FontIcon Glyph=`"&#xE8A7;`" FontFamily=`"$xIconFont`" FontSize=`"14`" Foreground=`"$xSecondary`"/></Button>")
}
[void]$creditsXaml.Append('</Grid>')
}
[void]$creditsXaml.Append('</StackPanel>')
$creditsStack = [WinUIShell.Microsoft.UI.Xaml.Markup.XamlReader]::Load($creditsXaml.ToString())
for ($creditIndex = 0; $creditIndex -lt $credits.Count; $creditIndex++) {
$credit = $credits[$creditIndex]
if ($credit.Url -and ([string]$credit.Url).Trim()) {
$linkBtn = $creditsStack.FindName("CreditLink$creditIndex")
if ($null -eq $linkBtn) { throw "P1273: XAML credit link not found: CreditLink$creditIndex" }
$captureCreditUrl = [string]$credit.Url
$linkBtn.AddClick({
try {
Start-Process $captureCreditUrl -ErrorAction Stop
} catch {
Write-ConsoleLog -Message ('Failed to open credit URL: ' + $_.Exception.Message) -Level 'WARN'
}
}.GetNewClosure())
}
}
$creditsGroup = New-SettingsCardGroup -Header 'Credits' -Description 'Individuals and projects Allium builds on.' -Rows @($creditsStack) -InfoCard
$panel.Children.Add($creditsGroup) | Out-Null
$logPath = if ($null -ne $script:DebugLogFile) { [string]$script:DebugLogFile } else { '(unset)' }
$openLogBtn = New-ThemedButton -Content 'Open Log' -ToolbarStyle
$captureLogPath = $logPath
$openLogBtn.AddClick({
try {
if (Test-Path $captureLogPath) {
Start-Process -FilePath $captureLogPath -ErrorAction Stop
} else {
Show-EditorNotification -Title 'Log' -Message 'Log file does not exist yet.'
}
} catch {
Show-EditorNotification -Title 'Log' -Message ('Failed to open log: ' + $_.Exception.Message)
}
}.GetNewClosure())
$logCard = New-SettingsInputCard -Header 'Log file' -Description $logPath -InputControl $openLogBtn
$exportLabel = 'Export'
$exportBtn = New-ThemedButton -Content $exportLabel -ToolbarStyle
$exportBtn.AddClick({
try {
$zip = New-DiagnosticBundle
if ($null -ne $zip) {
Show-EditorNotification -Title 'Diagnostic bundle' -Message ('Exported to ' + $zip)
} else {
Show-EditorNotification -Title 'Diagnostic bundle' -Message 'Export failed. Check the debug log for details.'
}
} catch {
Show-EditorNotification -Title 'Diagnostic bundle' -Message ('Export error: ' + $_.Exception.Message)
}
})
$bundleCard = New-SettingsInputCard -Header 'Diagnostic bundle' -Description 'Bundles logs, config, and cache into a folder you choose.' -InputControl $exportBtn
$diagnosticsGroup = New-SettingsCardGroup -Header 'Diagnostics' -Description 'Log file access and diagnostic export.' -Rows @($logCard, $bundleCard)
$panel.Children.Add($diagnosticsGroup) | Out-Null
try { Set-AccentResourceOverrides -ResourceDictionary $panelHost.ScrollViewer.Resources } catch { }
return $panelHost.ScrollViewer
}
function New-DumperTabPage {
$panelHost = New-SettingsPanelHost
$panel = $panelHost.Panel
if ($null -eq $script:Settings) { $script:Settings = @{} }
if (-not $script:Settings.ContainsKey('dumperDiagnosticsMode')) {
$script:Settings['dumperDiagnosticsMode'] = $false
}
function New-DumperStatRow {
param([string] $Label, [string] $Value)
$grid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colLabel.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$grid.ColumnDefinitions.Add($colLabel) | Out-Null
$colValue = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colValue.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$grid.ColumnDefinitions.Add($colValue) | Out-Null
$labelTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$labelTb.Text = $Label
$labelTb.FontSize = 14
$labelTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$labelTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$labelTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($labelTb, 0)
$grid.Children.Add($labelTb) | Out-Null
$valueTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$valueTb.Text = $Value
$valueTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$valueTb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$valueTb.TextAlignment = [WinUIShell.Microsoft.UI.Xaml.TextAlignment]::Right
$valueTb.FontSize = 12
$valueTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Normal
$valueTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($valueTb, 1)
$grid.Children.Add($valueTb) | Out-Null
return @{ Row = $grid; ValueBlock = $valueTb }
}
$diagRow = New-SettingsToggleCard -Header 'Diagnostics mode' -Description 'Show detailed run information and the five most recent results for each strategy.' -SettingsKey 'dumperDiagnosticsMode' -IsOn ([bool]$script:Settings['dumperDiagnosticsMode'])
$dumpButton = New-ThemedButton -Content 'Dump now' -ToolbarStyle
$dumpButton.AddClick({
param($argumentList, $s, $e)
try {
$xr = $null
try { $xr = $s.XamlRoot } catch { }
if ($null -eq $xr) {
try { $xr = $script:SettingsWindow.Content.XamlRoot } catch { }
}
Invoke-AlliumDumperAsync -Title 'Running FFlag dump' -Message 'Extracting flags from the running Roblox client. This usually takes 15-25 seconds.' -XamlRoot $xr -Work { Get-AlliumFFlagDump -Strategy 'Auto' } -OnComplete {
param($result)
try {
if ($null -ne $script:RefreshDumperDiagnostics) {
& $script:RefreshDumperDiagnostics
}
} catch { }
if ($null -eq $result) {
Write-ConsoleLog -Message 'Dump returned null result' -Level 'WARN'
return
}
if ($result -is [hashtable] -and $result.ContainsKey('Total')) {
Write-ConsoleLog -Message ('Async dump complete: ' + $result.Total + ' flags in ' + $result.DurationMs + ' ms') -Level 'INFO'
if ($null -ne $script:DumperQuorumRefs) {
try {
$script:DumperQuorumRefs.TotalRow.Text = [string]$result.Total
$script:DumperQuorumRefs.AgreeRow.Text = [string]$result.Agree
$script:DumperQuorumRefs.DisagreeRow.Text = [string]$result.Disagree
$containerScan = if ($result.ContainsKey('ContainerScanOnly')) { [string]$result.ContainerScanOnly } else { '-' }
$stat = if ($result.ContainsKey('StaticOnly')) { [string]$result.StaticOnly } else { '-' }
$sov = if ($result.ContainsKey('SouloveryallOnly')) { [string]$result.SouloveryallOnly } else { '-' }
$fvm = if ($result.ContainsKey('FvmOnly')) { [string]$result.FvmOnly } else { '-' }
$script:DumperQuorumRefs.ContainerScanOnlyRow.Text = $containerScan
$script:DumperQuorumRefs.StaticOnlyRow.Text = $stat
$script:DumperQuorumRefs.SovOnlyRow.Text = $sov
$script:DumperQuorumRefs.FvmOnlyRow.Text = $fvm
} catch {
Write-ConsoleLog -Message ('Quorum refs update failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
if ($null -ne $script:RefreshDumperHistory) {
try { & $script:RefreshDumperHistory } catch {
Write-ConsoleLog -Message ('Dump history refresh failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
} elseif ($result -is [hashtable] -and $result.ContainsKey('Error')) {
Write-ConsoleLog -Message ('Async dump failed: ' + $result.Error) -Level 'ERROR'
} else {
Write-ConsoleLog -Message ('Async dump returned unexpected shape: ' + ($result | Out-String).Trim()) -Level 'WARN'
}
}
} catch {
Write-ConsoleLog -Message ('FFlag Dumper invoke failed: ' + $_.Exception.Message) -Level 'ERROR'
}
})
$dumpCard = New-SettingsInputCard -Header 'Run dump' -Description 'Extract every FFlag registered in the running Roblox process via the default quorum.' -InputControl $dumpButton
$openFolderButton = New-ThemedButton -Content 'Open' -ToolbarStyle
$capturedDumpsDir = [string]$global:DumpsDir
$openFolderButton.AddClick({
try {
if (-not (Test-Path $capturedDumpsDir)) {
Initialize-AlliumDumperDataDirs
}
Start-Process -FilePath $capturedDumpsDir -ErrorAction Stop
} catch {
Write-ConsoleLog -Message ('Open dump folder failed: ' + $_.Exception.Message) -Level 'WARN'
}
}.GetNewClosure())
$folderCard = New-SettingsInputCard -Header 'Dump folder' -Description ([string]$global:DumpsDir) -InputControl $openFolderButton
$modeGroup = New-SettingsCardGroup -Header 'FFlag Dumper' -Description 'Extract every FFlag registered in the running Roblox client.' -Rows @($diagRow, $dumpCard, $folderCard) -IsFirstSection
$countRes = New-DumperStatRow -Label 'Flags dumped' -Value '(no dump yet)'
$durationRes = New-DumperStatRow -Label 'Duration' -Value '(no dump yet)'
$timestampRes = New-DumperStatRow -Label 'Timestamp' -Value '(no dump yet)'
$agreementRes = New-DumperStatRow -Label 'Strategy agreement' -Value '(no dump yet)'
$script:DumperStatusRefs = @{
CountRow = $countRes.ValueBlock
DurationRow = $durationRes.ValueBlock
TimestampRow = $timestampRes.ValueBlock
AgreementRow = $agreementRes.ValueBlock
}
$statsStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$statsStack.Spacing = 8
$statsStack.Children.Add($countRes.Row) | Out-Null
$statsStack.Children.Add($durationRes.Row) | Out-Null
$statsStack.Children.Add($timestampRes.Row) | Out-Null
$statsStack.Children.Add($agreementRes.Row) | Out-Null
$statsGroup = New-SettingsCardGroup -Header 'Last dump' -Description 'Statistics from the most recent successful dump session.' -Rows @($statsStack) -InfoCard
$cacheAge = Get-AlliumFVariablesCacheAge
if ($cacheAge.IsPresent -and $null -ne $cacheAge.Age) {
$cacheAgeText = Format-AlliumTimespanShort -Span $cacheAge.Age
} elseif ($cacheAge.IsPresent) {
$cacheAgeText = '(unknown)'
} else {
$cacheAgeText = '(no cache yet)'
}
$cacheAgeRes = New-DumperStatRow -Label 'FVariables cache age' -Value $cacheAgeText
$cacheAgeBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$cacheAgeBorder.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(20, 14, 20, 14)
$cacheAgeBorder.Child = $cacheAgeRes.Row
$script:DumperCacheAgeRefs = @{ AgeBlock = $cacheAgeRes.ValueBlock }
$refreshButton = New-ThemedButton -Content 'Refresh now' -ToolbarStyle
$refreshButton.AddClick({
param($argumentList, $s, $e)
try {
$xr = $null
try { $xr = $s.XamlRoot } catch { }
if ($null -eq $xr) {
try { $xr = $script:SettingsWindow.Content.XamlRoot } catch { }
}
Invoke-AlliumDumperAsync -Title 'Refreshing FVariables cache' -Message 'Fetching the latest flag prefix map from MaximumADHD and souloveryall.' -XamlRoot $xr -Work { Get-AlliumFVariables -ForceRefresh | Out-Null; return @{ Success = $true } } -OnComplete {
param($result)
if ($null -ne $result -and $result -is [hashtable] -and $result.ContainsKey('Error')) {
Write-ConsoleLog -Message ('FVariables refresh failed: ' + $result.Error) -Level 'ERROR'
}
try {
$fresh = Get-AlliumFVariablesCacheAge
$newText = if ($fresh.IsPresent -and $null -ne $fresh.Age) {
Format-AlliumTimespanShort -Span $fresh.Age
} elseif ($fresh.IsPresent) { '(unknown)' } else { '(no cache yet)' }
if ($null -ne $script:DumperCacheAgeRefs) {
$script:DumperCacheAgeRefs.AgeBlock.Text = $newText
}
Write-ConsoleLog -Message ('FVariables cache refreshed; age now ' + $newText + ' (' + $fresh.FlagCount + ' entries)') -Level 'INFO'
} catch {
Write-ConsoleLog -Message ('Cache age refresh failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
} catch {
Write-ConsoleLog -Message ('FVariables refresh invoke failed: ' + $_.Exception.Message) -Level 'ERROR'
}
})
$refreshCard = New-SettingsInputCard -Header 'Refresh cache' -Description 'Force a fresh fetch of the FVariables cache from all sources.' -InputControl $refreshButton
$sourcesGroup = New-SettingsCardGroup -Header 'Sources' -Description 'External FFlag databases used to resolve names and verify offsets.' -Rows @($cacheAgeBorder, $refreshCard)
$lastSummary = $script:LastDumpSummary
$qTotalVal = if ($null -ne $lastSummary) { [string]$lastSummary.Total } else { '(no dump yet)' }
$qAgreeVal = if ($null -ne $lastSummary) { [string]$lastSummary.Agree } else { '(no dump yet)' }
$qDisagreeVal = if ($null -ne $lastSummary) { [string]$lastSummary.Disagree } else { '(no dump yet)' }
$qContainerScanVal = if ($null -eq $lastSummary) { '(no dump yet)' } elseif ($lastSummary.ContainsKey('ContainerScanOnly')) { [string]$lastSummary.ContainerScanOnly } else { '-' }
$qStaticVal = if ($null -eq $lastSummary) { '(no dump yet)' } elseif ($lastSummary.ContainsKey('StaticOnly')) { [string]$lastSummary.StaticOnly } else { '-' }
$qSovVal = if ($null -eq $lastSummary) { '(no dump yet)' } elseif ($lastSummary.ContainsKey('SouloveryallOnly')) { [string]$lastSummary.SouloveryallOnly } else { '-' }
$qTotalRes = New-DumperStatRow -Label 'Total flags' -Value $qTotalVal
$qAgreeRes = New-DumperStatRow -Label 'Multi-source agreement' -Value $qAgreeVal
$qDisagreeRes = New-DumperStatRow -Label 'Multi-source divergence' -Value $qDisagreeVal
$qContainerScanRes = New-DumperStatRow -Label 'ContainerScan only' -Value $qContainerScanVal
$qStaticRes = New-DumperStatRow -Label 'Static only' -Value $qStaticVal
$qSovRes = New-DumperStatRow -Label 'Souloveryall only' -Value $qSovVal
$qFvmVal = if ($null -eq $lastSummary) { '(no dump yet)' } elseif ($lastSummary.ContainsKey('FvmOnly')) { [string]$lastSummary.FvmOnly } else { '-' }
$qFvmRes = New-DumperStatRow -Label 'FlagValueMap only' -Value $qFvmVal
$script:DumperQuorumRefs = @{
TotalRow = $qTotalRes.ValueBlock
AgreeRow = $qAgreeRes.ValueBlock
DisagreeRow = $qDisagreeRes.ValueBlock
ContainerScanOnlyRow = $qContainerScanRes.ValueBlock
StaticOnlyRow = $qStaticRes.ValueBlock
SovOnlyRow = $qSovRes.ValueBlock
FvmOnlyRow = $qFvmRes.ValueBlock
}
$quorumStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$quorumStack.Spacing = 8
$quorumStack.Children.Add($qTotalRes.Row) | Out-Null
$quorumStack.Children.Add($qAgreeRes.Row) | Out-Null
$quorumStack.Children.Add($qDisagreeRes.Row) | Out-Null
$quorumStack.Children.Add($qContainerScanRes.Row) | Out-Null
$quorumStack.Children.Add($qStaticRes.Row) | Out-Null
$quorumStack.Children.Add($qSovRes.Row) | Out-Null
$quorumStack.Children.Add($qFvmRes.Row) | Out-Null
$quorumGroup = New-SettingsCardGroup -Header 'Quorum breakdown' -Description 'Per-strategy contribution summary from the most recent dump.' -Rows @($quorumStack) -InfoCard
$diagStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$diagStack.Spacing = 10
$script:DumperStrategyDiagRefs = @{ Stack = $diagStack }
$script:RefreshDumperDiagnostics = {
try {
$stackRef = $script:DumperStrategyDiagRefs.Stack
if ($null -eq $stackRef) { return }
$stackRef.Children.Clear()
$reg = Get-AlliumDumperStrategyRegistry
if ($null -eq $reg -or $null -eq $reg.Order -or $reg.Order.Count -eq 0) {
$noneTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$noneTb.Text = '(no strategies registered)'
$noneTb.FontSize = 12
$noneTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$stackRef.Children.Add($noneTb) | Out-Null
return
}
$diagOn = [bool]$script:Settings['dumperDiagnosticsMode']
foreach ($sname in $reg.Order) {
$strategy = $reg.Registry[$sname]
if ($null -eq $strategy) { continue }
$telem = $strategy.GetTelemetry()
$rowStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$rowStack.Spacing = 4
$safetyTag = if ($telem.IsHyperionSafe) { ' [Hyperion-safe]' } else { '' }
if ($null -eq $telem.LastRunTime) {
$status = '(no run yet)'
} elseif ([string]::IsNullOrWhiteSpace($telem.LastError)) {
$lastTs = Format-AlliumTimespanShort -Span ((Get-Date) - [datetime]$telem.LastRunTime)
$status = ($telem.LastFlagCount.ToString() + ' flags, ' + $telem.LastElapsedMs.ToString() + ' ms, ' + $lastTs + ' ago')
} else {
$status = ('FAILED: ' + $telem.LastError)
}
$primaryGrid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colLabel = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colLabel.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$primaryGrid.ColumnDefinitions.Add($colLabel) | Out-Null
$colValue = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colValue.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$primaryGrid.ColumnDefinitions.Add($colValue) | Out-Null
$labelTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$labelTb.Text = ($telem.Name + $safetyTag)
$labelTb.FontSize = 14
$labelTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$labelTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$labelTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($labelTb, 0)
$primaryGrid.Children.Add($labelTb) | Out-Null
$valueTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$valueTb.Text = $status
$valueTb.FontSize = 12
$valueTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::Normal
$valueTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$valueTb.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$valueTb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Right
$valueTb.TextAlignment = [WinUIShell.Microsoft.UI.Xaml.TextAlignment]::Right
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($valueTb, 1)
$primaryGrid.Children.Add($valueTb) | Out-Null
$rowStack.Children.Add($primaryGrid) | Out-Null
if ($diagOn -and $strategy.History.Count -gt 0) {
$historyStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$historyStack.Spacing = 2
$historyStack.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 0, 0, 0)
for ($k = $strategy.History.Count - 1; $k -ge 0; $k--) {
$entry = $strategy.History[$k]
$ageStr = if ($null -ne $entry.RunTime) {
Format-AlliumTimespanShort -Span ((Get-Date) - [datetime]$entry.RunTime)
} else { '?' }
$idx = $strategy.History.Count - $k
$line = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
if ([string]::IsNullOrWhiteSpace($entry.Error)) {
$line.Text = ('  #' + $idx.ToString() + ': ' + $entry.FlagCount.ToString() + ' flags, ' + $entry.ElapsedMs.ToString() + ' ms, ' + $ageStr + ' ago')
} else {
$line.Text = ('  #' + $idx.ToString() + ': FAILED (' + $entry.Error + '), ' + $ageStr + ' ago')
}
$line.FontSize = 11
$line.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$historyStack.Children.Add($line) | Out-Null
}
$rowStack.Children.Add($historyStack) | Out-Null
}
$stackRef.Children.Add($rowStack) | Out-Null
}
} catch {
Write-ConsoleLog -Message ('Strategy diagnostics refresh failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
try { & $script:RefreshDumperDiagnostics } catch {
Write-ConsoleLog -Message ('Initial strategy diagnostics render failed: ' + $_.Exception.Message) -Level 'WARN'
}
$diagGroup = New-SettingsCardGroup -Header 'Strategy diagnostics' -Description 'View live run details and the five most recent results for each strategy.' -Rows @($diagStack) -InfoCard
$historyStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$historyStack.Spacing = 0
$capturedHistoryStack = $historyStack
$capturedDumpsDirForHistory = [string]$global:DumpsDir
$script:DumperHistoryRefs = @{ Stack = $capturedHistoryStack }
$script:RefreshDumperHistory = {
try {
$stackRef = $script:DumperHistoryRefs.Stack
if ($null -eq $stackRef) { return }
$stackRef.Children.Clear()
$dumpsDir = [string]$global:DumpsDir
if (-not (Test-Path $dumpsDir)) {
$emptyTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$emptyTb.Text = '(no dumps yet)'
$emptyTb.FontSize = 13
$emptyTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$emptyBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$emptyBorder.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(20, 14, 20, 14)
$emptyBorder.Child = $emptyTb
$stackRef.Children.Add($emptyBorder) | Out-Null
return
}
$files = Get-ChildItem -Path $dumpsDir -Filter 'dump-*.json' -File -ErrorAction SilentlyContinue |
Sort-Object -Property LastWriteTime -Descending |
Select-Object -First 20
if ($null -eq $files -or @($files).Count -eq 0) {
$emptyTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$emptyTb.Text = '(no dumps yet)'
$emptyTb.FontSize = 13
$emptyTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$emptyBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$emptyBorder.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(20, 14, 20, 14)
$emptyBorder.Child = $emptyTb
$stackRef.Children.Add($emptyBorder) | Out-Null
return
}
$isFirst = $true
foreach ($f in $files) {
if (-not $isFirst) {
$divider = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$divider.Height = 1
$divider.Background = New-SolidBrush -Hex $script:ThemeColors.Dividers
$divider.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Stretch
$stackRef.Children.Add($divider) | Out-Null
}
$isFirst = $false
$rowBorder = [WinUIShell.Microsoft.UI.Xaml.Controls.Border]::new()
$rowBorder.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(20, 12, 20, 12)
$rowGrid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$colTxt = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colTxt.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$rowGrid.ColumnDefinitions.Add($colTxt) | Out-Null
$colBtn = [WinUIShell.Microsoft.UI.Xaml.Controls.ColumnDefinition]::new()
$colBtn.Width = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowGrid.ColumnDefinitions.Add($colBtn) | Out-Null
$textStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$textStack.Spacing = 2
$textStack.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$nameTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$nameTb.Text = $f.Name
$nameTb.FontFamily = $script:AppFontFamily
$nameTb.FontSize = 13
$nameTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$nameTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$nameTb.TextTrimming = [WinUIShell.Microsoft.UI.Xaml.TextTrimming]::CharacterEllipsis
$textStack.Children.Add($nameTb) | Out-Null
$timeTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$timeTb.Text = $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
$timeTb.FontFamily = $script:AppFontFamily
$timeTb.FontSize = 12
$timeTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$textStack.Children.Add($timeTb) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($textStack, 0)
$rowGrid.Children.Add($textStack) | Out-Null
$revealBtn = New-ThemedButton -Content 'Reveal' -ToolbarStyle
$revealBtn.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(16, 0, 0, 0)
$revealBtn.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$capturedPath = [string]$f.FullName
$revealBtn.AddClick({
try {
Start-Process -FilePath 'explorer.exe' -ArgumentList ('/select,"' + $capturedPath + '"') -ErrorAction Stop
} catch {
Write-ConsoleLog -Message ('Reveal in Explorer failed: ' + $_.Exception.Message) -Level 'WARN'
}
}.GetNewClosure())
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetColumn($revealBtn, 1)
$rowGrid.Children.Add($revealBtn) | Out-Null
$rowBorder.Child = $rowGrid
$stackRef.Children.Add($rowBorder) | Out-Null
}
} catch {
Write-ConsoleLog -Message ('Dump history refresh error: ' + $_.Exception.Message) -Level 'WARN'
}
}
try { & $script:RefreshDumperHistory } catch {
Write-ConsoleLog -Message ('Initial dump history render failed: ' + $_.Exception.Message) -Level 'WARN'
}
$historyRefreshButton = New-ThemedButton -Content 'Refresh list' -ToolbarStyle
$historyRefreshButton.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$historyRefreshButton.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 0, -50)
$historyRefreshButton.AddClick({
try {
if ($null -ne $script:RefreshDumperHistory) {
& $script:RefreshDumperHistory
}
} catch {
Write-ConsoleLog -Message ('Dump history manual refresh failed: ' + $_.Exception.Message) -Level 'WARN'
}
})
$historyGroup = New-SettingsCardGroup -Header 'Dump history' -Description 'Most recent dump files. Shows up to 20 entries.' -Rows @($historyStack) -HeaderAction $historyRefreshButton
$panel.Children.Add($modeGroup) | Out-Null
$panel.Children.Add($statsGroup) | Out-Null
$panel.Children.Add($sourcesGroup) | Out-Null
$panel.Children.Add($quorumGroup) | Out-Null
$panel.Children.Add($diagGroup) | Out-Null
$panel.Children.Add($historyGroup) | Out-Null
try { Set-AccentResourceOverrides -ResourceDictionary $panelHost.ScrollViewer.Resources } catch { }
return $panelHost.ScrollViewer
}
function Complete-DumperHeavyGroups {
param(
[Parameter(Mandatory)] $Page
)
return
}
function Show-SettingsWindow {
$__swT0 = [datetime]::UtcNow
Test-WinUIShellVersion | Out-Null
if ($null -ne $script:SettingsWindow) {
try {
$script:SettingsWindow.Activate()
$__swElapsed = [int]([datetime]::UtcNow - $__swT0).TotalMilliseconds
Write-ConsoleLog -Message ('[settings-window] reactivate (fast path) completed in ' + $__swElapsed + 'ms') -Level 'INFO'
return
} catch { $script:SettingsWindow = $null }
}
if ($null -eq $script:SettingsPages) { $script:SettingsPages = @{} }
$script:SettingsMemoryStatusRefs = $null
$script:SettingsCurrentPageKey = $null
if ($null -eq $script:SettingsToggleCallbacks) { $script:SettingsToggleCallbacks = @{} }
$win = [WinUIShell.Microsoft.UI.Xaml.Window]::new()
Write-ConsoleLog -Message ('[settings-phase] window-created=' + [int]([datetime]::UtcNow - $__swT0).TotalMilliseconds + 'ms') -Level 'INFO'
$win.Title = "$($script:AppTitle) - Settings"
$win.ExtendsContentIntoTitleBar = $true
try {
$win.AppWindow.Resize(960, 680)
Center-Window -AppWindow $win.AppWindow -Width 960 -Height 680
$iconFile = (Resolve-Path $script:IconPath).Path
$win.AppWindow.SetIcon($iconFile)
} catch { Write-ConsoleLog -Message ('Settings window init error: ' + $_.Exception.Message) -Level 'WARN' }
try {
$presenter = $win.AppWindow.Presenter
$presenter.PreferredMinimumWidth = 840
$presenter.PreferredMinimumHeight = 600
} catch {
Write-ConsoleLog -Message ('OverlappedPresenter min size not available: ' + $_.Exception.Message) -Level 'WARN'
}
$titleRegion = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$titleRegion.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(24, 16, 0, 12)
$titleRegion.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(0, 0, 0, 0)
)
$titleStack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$titleStack.Spacing = 2
$titleText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$titleText.Text = 'Allium Settings'
Set-SafeFontFamily -Target $titleText -Family $script:AppFontFamily
$titleText.FontSize = 20
$titleText.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$titleText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$subtitleText = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$subtitleText.Text = 'Configure Allium behavior, watchdog, memory mode, and more.'
Set-SafeFontFamily -Target $subtitleText -Family $script:AppFontFamily
$subtitleText.FontSize = 14
$subtitleText.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$titleStack.Children.Add($titleText) | Out-Null
$titleStack.Children.Add($subtitleText) | Out-Null
$titleRegion.Children.Add($titleStack) | Out-Null
$win.SetTitleBar($titleRegion)
$root = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$root.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$root.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(210, 0x1c, 0x08, 0x08)
)
$root.RowSpacing = 0
try {
Set-AccentResourceOverrides -ResourceDictionary $root.Resources
} catch { Write-ConsoleLog -Message ('Root accent overrides failed: ' + $_.Exception.Message) -Level 'WARN' }
$rowTitleBar = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowTitleBar.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Auto)
$rowSpacer = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowSpacer.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(0, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Pixel)
$rowNav = [WinUIShell.Microsoft.UI.Xaml.Controls.RowDefinition]::new()
$rowNav.Height = [WinUIShell.Microsoft.UI.Xaml.GridLength]::new(1, [WinUIShell.Microsoft.UI.Xaml.GridUnitType]::Star)
$root.RowDefinitions.Add($rowTitleBar) | Out-Null
$root.RowDefinitions.Add($rowSpacer) | Out-Null
$root.RowDefinitions.Add($rowNav) | Out-Null
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($titleRegion, 0)
$root.Children.Add($titleRegion) | Out-Null
$navView = [WinUIShell.Microsoft.UI.Xaml.Controls.NavigationView]::new()
$navView.PaneDisplayMode = 'Left'
$navView.PaneTitle = ''
$navView.IsBackButtonVisible = 'Collapsed'
$navView.IsSettingsVisible = $false
try { $navView.OpenPaneLength = 232 } catch { }
try { $navView.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 0, 0) } catch { }
try {
Set-AccentResourceOverrides -ResourceDictionary $navView.Resources
} catch { Write-ConsoleLog -Message ('NavView accent overrides failed: ' + $_.Exception.Message) -Level 'WARN' }
$contentGrid = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$contentGrid.Padding = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 0, 30, 30)
$contentGrid.Background = New-SolidBrush -Hex $script:ThemeColors.SidebarTint
try {
Set-AccentResourceOverrides -ResourceDictionary $contentGrid.Resources
} catch { Write-ConsoleLog -Message ('ContentGrid accent overrides failed: ' + $_.Exception.Message) -Level 'WARN' }
$navView.Content = $contentGrid
$script:SettingsContentGrid = $contentGrid
[WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::SetRow($navView, 2)
$root.Children.Add($navView) | Out-Null
$navItems = @()
foreach ($tab in $script:SettingsTabDefinitions) {
$item = [WinUIShell.Microsoft.UI.Xaml.Controls.NavigationViewItem]::new()
$item.Content = $tab.Label
try {
$icon = [WinUIShell.Microsoft.UI.Xaml.Controls.FontIcon]::new()
$icon.Glyph = [string]$tab.Glyph
Set-SafeFontFamily -Target $icon -Family $script:IconFontFamily
$icon.FontSize = 16
$icon.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
if ($tab.Key -eq 'About') {
$icon.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 2, 0, 0)
} else {
$icon.Margin = [WinUIShell.Microsoft.UI.Xaml.Thickness]::new(0, 1, 0, 0)
}
$item.Icon = $icon
} catch { }
$item.Tag = $tab.Key
$navView.MenuItems.Add($item) | Out-Null
$navItems += $item
}
$navView.AddSelectionChanged({
param($argumentList, $s, $e)
try {
$selected = $s.SelectedItem
if ($null -eq $selected) { return }
$key = [string]$selected.Tag
if ([string]::IsNullOrWhiteSpace($key)) { return }
$needsFactory = $false
try { $needsFactory = -not $script:SettingsPages.ContainsKey($key) } catch { $needsFactory = $true }
$timerRunning = $false
if (($null -ne $script:SettingsPrewarmTimer) -and (-not $script:SettingsPrewarmDone)) {
try { $timerRunning = [bool]$script:SettingsPrewarmTimer.IsEnabled } catch { $timerRunning = $false }
}
if ($needsFactory -and $timerRunning) {
try { $script:SettingsPrewarmTimer.Stop() } catch { }
}
Activate-SettingsTab -Key $key
if ($needsFactory -and $timerRunning -and (-not $script:SettingsPrewarmDone)) {
try { Start-SettingsTabPrewarm } catch { }
}
} catch {
Write-ConsoleLog -Message ('NavigationView SelectionChanged failed: ' + $_.Exception.Message) -Level 'WARN'
}
})
try { $navView.SelectedItem = $navItems[0] } catch { }
$win.AddClosed({
try {
if ($null -ne $script:SettingsPages -and $script:SettingsPages.Count -gt 0) {
$__invalidatedCount = $script:SettingsPages.Count
Write-ConsoleLog -Message ('[settings-close] invalidating ALL cached pages (' + $__invalidatedCount + ') to force fresh template resolution on reopen') -Level 'INFO'
try { $script:SettingsPages.Clear() } catch { }
}
} catch { }
try {
if (-not [string]::IsNullOrWhiteSpace($script:SettingsCurrentPageKey)) {
if ($null -eq $script:Settings) { $script:Settings = @{} }
$script:Settings['settingsLastViewedTab'] = [string]$script:SettingsCurrentPageKey
try { Save-Settings } catch { }
Write-ConsoleLog -Message ('[settings-close] persisted last-viewed tab: ' + $script:SettingsCurrentPageKey) -Level 'INFO'
}
} catch { }
try {
if ($null -ne $script:SettingsContentGrid) {
$script:SettingsContentGrid.Children.Clear()
}
} catch { }
try {
$script:SettingsPrewarmDone = $false
} catch {
Write-ConsoleLog -Message ('[settings-close] flag reset failed: ' + $_.Exception.Message) -Level 'WARN'
}
try {
if ($null -ne $script:HttpsPageRefreshTimer) {
try { $script:HttpsPageRefreshTimer.Stop() } catch { }
$script:HttpsPageRefreshTimer = $null
}
} catch { }
$script:HttpsPageRefreshTickCounter = 0
$script:HttpsPageStatusStateText = $null
$script:HttpsPageStatusOverridesText = $null
$script:HttpsPageStatusRequestsText = $null
$script:HttpsPageDiagViewerRows = $null
$script:HttpsPageDiagViewerEmpty = $null
$script:SettingsWindow = $null
$script:SettingsNavView = $null
$script:SettingsContentHost = $null
$script:SettingsCurrentPageKey = $null
$script:SettingsMemoryStatusRefs = $null
$script:SettingsContentGrid = $null
})
$win.Content = $root
Write-ConsoleLog -Message ('[settings-phase] visual-tree-ready=' + [int]([datetime]::UtcNow - $__swT0).TotalMilliseconds + 'ms') -Level 'INFO'
$__settingsThemeT0 = [datetime]::UtcNow
try { Set-WindowTheme -Window $win } catch { Write-ConsoleLog -Message ('Set-WindowTheme failed: ' + $_.Exception.Message) -Level 'WARN' }
Write-ConsoleLog -Message ('[settings-theme-phase] set-window-theme-ms=' + [int]([datetime]::UtcNow - $__settingsThemeT0).TotalMilliseconds) -Level 'INFO'
try {
$win.AppWindow.TitleBar.PreferredTheme = [WinUIShell.Microsoft.UI.Windowing.TitleBarTheme]::Dark
} catch { Write-ConsoleLog -Message ('PreferredTheme=Dark failed: ' + $_.Exception.Message) -Level 'WARN' }
$script:P12306AccentFixApplied = $true
$script:SettingsWindow = $win
$script:SettingsNavView = $navView
$script:SettingsContentHost = $contentGrid
$__brushRefreshCount = 0
$__settingsPageLoopT0 = [datetime]::UtcNow
try {
if ($null -ne $script:SettingsPages -and $script:SettingsPages.Count -gt 0) {
foreach ($__pageKey in @($script:SettingsPages.Keys)) {
$__pageAccentT0 = [datetime]::UtcNow
$__cachedPage = $script:SettingsPages[$__pageKey]
if ($null -eq $__cachedPage) { continue }
try {
if ($null -ne $__cachedPage.Resources) {
Set-AccentResourceOverrides -ResourceDictionary $__cachedPage.Resources
$__brushRefreshCount++
Write-ConsoleLog -Message ('[settings-accent-page] key=' + $__pageKey + ' ms=' + [int]([datetime]::UtcNow - $__pageAccentT0).TotalMilliseconds) -Level 'INFO'
}
} catch { }
}
}
} catch { }
Write-ConsoleLog -Message ('[settings-theme-phase] page-loop-ms=' + [int]([datetime]::UtcNow - $__settingsPageLoopT0).TotalMilliseconds) -Level 'INFO'
Write-ConsoleLog -Message ('[settings-window] refreshed accent brushes on ' + $__brushRefreshCount + ' cached page(s)') -Level 'INFO'
Write-ConsoleLog -Message ('[settings-phase] accent-refresh-done=' + [int]([datetime]::UtcNow - $__swT0).TotalMilliseconds + 'ms') -Level 'INFO'
$__swElapsed = [int]([datetime]::UtcNow - $__swT0).TotalMilliseconds
Write-ConsoleLog -Message ('[settings-window] open completed in ' + $__swElapsed + 'ms') -Level 'INFO'
$win.Activate()
Write-ConsoleLog -Message ('[settings-phase] activate-returned=' + [int]([datetime]::UtcNow - $__swT0).TotalMilliseconds + 'ms') -Level 'INFO'
}
$global:DumpsDir = Join-Path $script:DataRoot 'dumps'
$global:GenealogyDir = Join-Path $global:DumpsDir 'genealogy'
$global:FVariablesCache = Join-Path $script:DataRoot 'fvariables-cache.json'
$script:LastDumpSummary = $null
$script:LastFVariablesFetchVersion = $null
class DumperStrategy {
[string] $Name
[string] $Description
[bool] $IsHyperionSafe
[bool] $RequiresProcessAttach
[bool] $IsOfflineCapable
[scriptblock] $Invoker
[int] $LastElapsedMs
[int] $LastFlagCount
[string] $LastError
[Nullable[datetime]] $LastRunTime
[System.Collections.ArrayList] $History
[int] $MaxHistory
DumperStrategy() {
$this.History = New-Object System.Collections.ArrayList
$this.MaxHistory = 5
$this.LastElapsedMs = 0
$this.LastFlagCount = 0
$this.LastError = ''
$this.LastRunTime = $null
}
[void] RecordRun([int] $elapsedMs, [int] $flagCount, [string] $errorText) {
$this.LastElapsedMs = $elapsedMs
$this.LastFlagCount = $flagCount
$this.LastError = $errorText
$this.LastRunTime = Get-Date
$entry = @{
ElapsedMs = $elapsedMs
FlagCount = $flagCount
Error = $errorText
RunTime = $this.LastRunTime
}
[void] $this.History.Add($entry)
while ($this.History.Count -gt $this.MaxHistory) {
$this.History.RemoveAt(0)
}
}
[hashtable] GetTelemetry() {
return @{
Name = $this.Name
Description = $this.Description
IsHyperionSafe = $this.IsHyperionSafe
RequiresProcessAttach = $this.RequiresProcessAttach
IsOfflineCapable = $this.IsOfflineCapable
LastElapsedMs = $this.LastElapsedMs
LastFlagCount = $this.LastFlagCount
LastError = $this.LastError
LastRunTime = $this.LastRunTime
HistoryCount = $this.History.Count
}
}
}
$script:DumperStrategyRegistry = $null
$script:DumperStrategyOrder = @()
function Register-AlliumDumperStrategy {
[OutputType([void])]
param(
[Parameter(Mandatory)] [string] $Name,
[Parameter(Mandatory)] [string] $Description,
[Parameter(Mandatory)] [scriptblock] $Invoker,
[bool] $IsHyperionSafe = $false,
[bool] $RequiresProcessAttach = $true,
[bool] $IsOfflineCapable = $false
)
if ($null -eq $script:DumperStrategyRegistry) {
$script:DumperStrategyRegistry = @{}
$script:DumperStrategyOrder = @()
}
$strategy = [DumperStrategy]::new()
$strategy.Name = $Name
$strategy.Description = $Description
$strategy.Invoker = $Invoker
$strategy.IsHyperionSafe = $IsHyperionSafe
$strategy.RequiresProcessAttach = $RequiresProcessAttach
$strategy.IsOfflineCapable = $IsOfflineCapable
$script:DumperStrategyRegistry[$Name] = $strategy
if ($script:DumperStrategyOrder -notcontains $Name) {
$script:DumperStrategyOrder += $Name
}
}
function Initialize-AlliumDumperStrategies {
[OutputType([void])]
param([switch] $Force)
if ($null -ne $script:DumperStrategyRegistry -and -not $Force) { return }
$script:DumperStrategyRegistry = @{}
$script:DumperStrategyOrder = @()
Register-AlliumDumperStrategy -Name 'static-live' -Description 'Codegen-agnostic live-process static extractor (Block J StaticFlagExtractor). LEA-pair scan of .text at 13-byte spacing.' -Invoker { param($Target, $FVarLookup) Invoke-AlliumStaticDump -Target $Target -FVarLookup $FVarLookup } -IsHyperionSafe $false -RequiresProcessAttach $true -IsOfflineCapable $false
Register-AlliumDumperStrategy -Name 'container-scan' -Description 'Memory signature scan of the FFlag container (Block J ContainerScanner). Hyperion-immune on current builds. Primary strategy.' -Invoker { param($Target, $FVarLookup) Invoke-AlliumContainerScanDump -Target $Target -FVarLookup $FVarLookup } -IsHyperionSafe $true -RequiresProcessAttach $true -IsOfflineCapable $false
Register-AlliumDumperStrategy -Name 'souloveryall' -Description 'Souloveryall + Theo + MaximumADHD offset cache tier chain. Last-resort fallback when live strategies fail.' -Invoker { param($Target, $FVarLookup) Invoke-AlliumSouloveryallDump -Target $Target -FVarLookup $FVarLookup } -IsHyperionSafe $true -RequiresProcessAttach $false -IsOfflineCapable $true
Register-AlliumDumperStrategy -Name 'bucket-walk' -Description 'bucket-walking FFlag hashmap traversal via Block D HashmapWalker.DumpAllBuckets. Fails on Hyperion-guarded builds.' -Invoker { param($Target, $FVarLookup) Invoke-AlliumHashmapDump -Target $Target } -IsHyperionSafe $false -RequiresProcessAttach $true -IsOfflineCapable $false
Register-AlliumDumperStrategy -Name 'flag-value-map' -Description 'GetSet-indirection FFlag map walker. Enumerates every entry with typed name/rva/value via linked list walk from the sentinel 0x3F800000 anchor. Hyperion-safe live-memory strategy; also produces default-value snapshots. Primary source in the quorum merge.' -Invoker { param($Target, $FVarLookup) Invoke-AlliumFlagValueMapDump -Target $Target -FVarLookup $FVarLookup } -IsHyperionSafe $true -RequiresProcessAttach $true -IsOfflineCapable $false
}
function Get-AlliumDumperStrategyRegistry {
[OutputType([hashtable])]
param()
Initialize-AlliumDumperStrategies
return @{
Registry = $script:DumperStrategyRegistry
Order = $script:DumperStrategyOrder
}
}
function Invoke-AlliumDumperStrategyByName {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [string] $Name,
[Parameter(Mandatory)] [hashtable] $Target,
[hashtable] $FVarLookup = @{}
)
Initialize-AlliumDumperStrategies
if (-not $script:DumperStrategyRegistry.ContainsKey($Name)) {
throw ('Unknown dumper strategy: ' + $Name)
}
$strategy = $script:DumperStrategyRegistry[$Name]
$sw = New-Object System.Diagnostics.Stopwatch
$sw.Start()
$result = $null
$errorText = ''
try {
$result = & $strategy.Invoker $Target $FVarLookup
} catch {
$errorText = $_.Exception.Message
$result = @{ Strategy = $Name; Flags = @{}; DurationMs = 0; Error = $errorText }
}
$sw.Stop()
$elapsedMs = [int] $sw.ElapsedMilliseconds
$flagCount = 0
if ($null -ne $result -and $result.ContainsKey('Flags') -and $null -ne $result.Flags) {
$flagCount = $result.Flags.Count
}
if ([string]::IsNullOrWhiteSpace($errorText) -and $null -ne $result -and $result.ContainsKey('Error')) {
$errorText = [string]$result.Error
}
$strategy.RecordRun($elapsedMs, $flagCount, $errorText)
try {
if ($null -ne $script:RefreshDumperDiagnostics) {
& $script:RefreshDumperDiagnostics
}
} catch { }
return $result
}
function Initialize-AlliumDumperDataDirs {
if (-not (Test-Path $global:DumpsDir)) {
New-Item -Path $global:DumpsDir -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $global:GenealogyDir)) {
New-Item -Path $global:GenealogyDir -ItemType Directory -Force | Out-Null
}
}
function Test-AlliumFVariablesStale {
[OutputType([bool])]
param()
if (-not (Test-Path $global:FVariablesCache)) { return $true }
try {
$cached = Read-Json -Path $global:FVariablesCache
if ($null -eq $cached -or -not $cached.ContainsKey('version')) { return $true }
$current = Get-RobloxVersionFolder
if ([string]::IsNullOrWhiteSpace($current)) { return $false }
return ($cached['version'] -ne $current)
} catch {
return $true
}
}
function Format-AlliumTimespanShort {
param([TimeSpan] $Span)
if ($null -eq $Span) { return '?' }
$t = [TimeSpan]$Span
if ($t.TotalDays -ge 1) { return ('{0}d {1}h' -f [int]$t.TotalDays, $t.Hours) }
if ($t.TotalHours -ge 1) { return ('{0}h {1}m' -f [int]$t.TotalHours, $t.Minutes) }
if ($t.TotalMinutes -ge 1) { return ('{0}m' -f [int]$t.TotalMinutes) }
return ('{0}s' -f [int]$t.TotalSeconds)
}
function Get-AlliumFVariablesCacheAge {
[OutputType([hashtable])]
param()
if (-not (Test-Path $global:FVariablesCache)) {
return @{ IsPresent = $false; Age = $null; Fetched = $null; Version = $null; FlagCount = 0 }
}
try {
$cached = Read-Json -Path $global:FVariablesCache
if ($null -eq $cached) {
return @{ IsPresent = $true; Age = $null; Fetched = $null; Version = $null; FlagCount = 0 }
}
$fetched = $null
if ($cached.ContainsKey('fetched_at')) {
try {
$dto = [DateTimeOffset]::Parse([string]$cached['fetched_at'], [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal)
$fetched = $dto.UtcDateTime
} catch { }
}
$age = $null
if ($null -ne $fetched) {
$nowUtc = [DateTime]::UtcNow
$age = $nowUtc - $fetched
if ($age.TotalSeconds -lt 0) { $age = [TimeSpan]::Zero }
}
$version = if ($cached.ContainsKey('version')) { [string]$cached['version'] } else { $null }
$flagCount = 0
if ($cached.ContainsKey('flags')) {
try { $flagCount = ([hashtable]$cached['flags']).Count } catch { }
}
return @{ IsPresent = $true; Age = $age; Fetched = $fetched; Version = $version; FlagCount = $flagCount }
} catch {
return @{ IsPresent = $true; Age = $null; Fetched = $null; Version = $null; FlagCount = 0 }
}
}
function New-DumperProgressDialog {
param(
[Parameter(Mandatory)] [string] $Title,
[Parameter(Mandatory)] [string] $Message,
[Parameter(Mandatory)] $XamlRoot
)
$stack = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$stack.Spacing = 16
$stack.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$stack.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$ring = [WinUIShell.Microsoft.UI.Xaml.Controls.ProgressRing]::new()
$ring.IsActive = $true
$ring.Width = 48
$ring.Height = 48
$ring.Foreground = New-AccentBrush
$ring.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$stack.Children.Add($ring) | Out-Null
$msgTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$msgTb.Text = $Message
$msgTb.FontSize = 13
$msgTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextSecondary
$msgTb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$msgTb.TextAlignment = [WinUIShell.Microsoft.UI.Xaml.TextAlignment]::Center
$msgTb.TextWrapping = [WinUIShell.Microsoft.UI.Xaml.TextWrapping]::Wrap
$msgTb.MaxWidth = 320
$stack.Children.Add($msgTb) | Out-Null
$dlg = [WinUIShell.Microsoft.UI.Xaml.Controls.ContentDialog]::new()
$dlg.XamlRoot = $XamlRoot
$titleTb = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$titleTb.Text = $Title
Set-SafeFontFamily -Target $titleTb -Family $script:AppFontFamily
$titleTb.FontSize = 20
$titleTb.FontWeight = [WinUIShell.Microsoft.UI.Text.FontWeights]::SemiBold
$titleTb.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$titleTb.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$titleTb.MinWidth = 400
$titleTb.TextAlignment = [WinUIShell.Microsoft.UI.Xaml.TextAlignment]::Center
$dlg.Title = $titleTb
$dlg.Content = $stack
try { $dlg.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark } catch { }
try { $dlg.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary } catch { }
try { $dlg.Background = New-SolidBrush -Hex $script:ThemeColors.Surface } catch { }
try {
$rd = $dlg.Resources
$rd["ContentDialogBackground"] = New-SolidBrush -Hex $script:ThemeColors.Surface
$rd["ContentDialogForeground"] = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$rd["ContentDialogBorderBrush"] = New-SolidBrush -Hex $script:ThemeColors.Dividers
$rd["ContentDialogTopOverlay"] = New-SolidBrush -Hex $script:ThemeColors.Surface
} catch { }
try { Set-AccentResourceOverrides -ResourceDictionary $dlg.Resources } catch { }
return @{ Dialog = $dlg; MessageBlock = $msgTb }
}
function Invoke-AlliumDumperAsync {
param(
[Parameter(Mandatory)] [string] $Title,
[Parameter(Mandatory)] [string] $Message,
[Parameter(Mandatory)] [scriptblock] $Work,
[Parameter(Mandatory)] [scriptblock] $OnComplete,
[Parameter(Mandatory)] $XamlRoot
)
$prog = New-DumperProgressDialog -Title $Title -Message $Message -XamlRoot $XamlRoot
$dlg = $prog.Dialog
$shared = @{ Result = $null; Ran = $false; Error = $null }
$localDlg = $dlg
$localWork = $Work
$localShared = $shared
$workTimer = [WinUIShell.Microsoft.UI.Xaml.DispatcherTimer]::new()
$workTimer.Interval = New-UITimeSpan -Milliseconds 100
$workTimer.AddTick({
param($argumentList, $s, $e)
$s.Stop()
try {
$localShared.Result = & $localWork
} catch {
$localShared.Error = $_.Exception.Message
$localShared.Result = @{ Success = $false; Error = $localShared.Error }
try { Write-ConsoleLog -Message ('Dumper work failed: ' + $localShared.Error) -Level 'ERROR' } catch { }
}
$localShared.Ran = $true
try { $localDlg.Hide() } catch { }
}.GetNewClosure())
$workTimer.Start()
try {
$dlg.ShowAsync().WaitForCompleted() | Out-Null
} catch {
Write-ConsoleLog -Message ('Progress dialog show failed: ' + $_.Exception.Message) -Level 'WARN'
return
}
if ($shared.Ran) {
try {
& $OnComplete $shared.Result
} catch {
Write-ConsoleLog -Message ('Dumper OnComplete failed: ' + $_.Exception.Message) -Level 'ERROR'
}
} else {
Write-ConsoleLog -Message 'Dumper work never executed (timer did not tick before dialog closed)' -Level 'WARN'
}
}
function Get-AlliumFVariables {
[OutputType([hashtable])]
param([switch] $ForceRefresh)
Initialize-AlliumDumperDataDirs
$useCached = (-not $ForceRefresh) -and (-not (Test-AlliumFVariablesStale))
if ($useCached) {
try {
$cached = Read-Json -Path $global:FVariablesCache
if ($null -ne $cached -and $cached.ContainsKey('flags')) { return $cached['flags'] }
} catch { }
}
$fvarLookup = @{}
$ua = 'AlliumFFlagDumper/0.9.3'
$prefixRegex = '^((DF|F|SF)(Flag|Int|String|Log))(.+)$'
$sourcesUsed = @()
try {
$url = 'https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/FVariables.txt'
$resp = Invoke-WebRequest -Uri $url -TimeoutSec 30 -UserAgent $ua -UseBasicParsing -ErrorAction Stop
$body = $resp.Content
if ($body.Length -gt 0 -and $body[0] -eq [char]0xFEFF) { $body = $body.Substring(1) }
$trimmed = $body.TrimStart()
$firstChar = if ($trimmed.Length -gt 0) { $trimmed[0] } else { '' }
if ($firstChar -ne '[') {
if ([bool]$script:Settings['dumperDiagnosticsMode']) {
$snip = if ($body.Length -gt 200) { $body.Substring(0, 200) } else { $body }
Write-ConsoleLog -Message ('MaximumADHD FVariables body snippet: ' + $snip) -Level 'WARN'
}
throw ("unexpected response shape (first char: '" + $firstChar + "')")
}
$lines = $resp.Content -split "`n"
$addedFromMax = 0
foreach ($line in $lines) {
if ($line -match '^\[(C\+\+|Lua)\]\s+((DF|F|SF)(Flag|Int|String|Log))(.+)$') {
$label = $Matches[1]
$prefixed = $Matches[2] + $Matches[5].Trim()
$rawName = $Matches[5].Trim()
if (-not $fvarLookup.ContainsKey($rawName)) {
$fvarLookup[$rawName] = @{ Prefixed = $prefixed; Label = $label }
$addedFromMax++
}
}
}
$sourcesUsed += "MaximumADHD: +$addedFromMax"
} catch {
Write-ConsoleLog -Message ('MaximumADHD FVariables fetch failed: ' + $_.Exception.Message) -Level 'WARN'
}
try {
$url = 'https://raw.githubusercontent.com/souloveryall/AllFFlagsPrefixes/main/AllFFlagsPrefixes'
$resp = Invoke-WebRequest -Uri $url -TimeoutSec 30 -UserAgent $ua -UseBasicParsing -ErrorAction Stop
$body = $resp.Content
if ($body.Length -gt 0 -and $body[0] -eq [char]0xFEFF) { $body = $body.Substring(1) }
$trimmed = $body.TrimStart()
$firstChar = if ($trimmed.Length -gt 0) { $trimmed[0] } else { '' }
if ($firstChar -ne '{' -and $firstChar -ne '[') {
if ([bool]$script:Settings['dumperDiagnosticsMode']) {
$snip = if ($body.Length -gt 200) { $body.Substring(0, 200) } else { $body }
Write-ConsoleLog -Message ('souloveryall/AllFFlagsPrefixes body snippet: ' + $snip) -Level 'WARN'
}
throw ("unexpected response shape (first char: '" + $firstChar + "')")
}
$json = $resp.Content | ConvertFrom-Json -AsHashtable
$addedFromSov = 0
foreach ($prefixedName in $json.Keys) {
if ($null -eq $prefixedName -or $prefixedName.Length -eq 0) { continue }
if ($prefixedName -match $prefixRegex) {
$rawName = $Matches[4]
if (-not $fvarLookup.ContainsKey($rawName)) {
$fvarLookup[$rawName] = @{ Prefixed = $prefixedName; Label = 'C++' }
$addedFromSov++
}
}
}
$sourcesUsed += "souloveryall-AllFFlagsPrefixes: +$addedFromSov"
} catch {
Write-ConsoleLog -Message ('souloveryall/AllFFlagsPrefixes fetch failed: ' + $_.Exception.Message) -Level 'WARN'
}
try {
$url = 'https://raw.githubusercontent.com/souloveryall/flaglist/main/flaglist.json'
$resp = Invoke-WebRequest -Uri $url -TimeoutSec 30 -UserAgent $ua -UseBasicParsing -ErrorAction Stop
$body = $resp.Content
if ($body.Length -gt 0 -and $body[0] -eq [char]0xFEFF) { $body = $body.Substring(1) }
$trimmed = $body.TrimStart()
$firstChar = if ($trimmed.Length -gt 0) { $trimmed[0] } else { '' }
if ($firstChar -ne '{' -and $firstChar -ne '[') {
if ([bool]$script:Settings['dumperDiagnosticsMode']) {
$snip = if ($body.Length -gt 200) { $body.Substring(0, 200) } else { $body }
Write-ConsoleLog -Message ('souloveryall/flaglist body snippet: ' + $snip) -Level 'WARN'
}
throw ("unexpected response shape (first char: '" + $firstChar + "')")
}
$json = $resp.Content | ConvertFrom-Json -AsHashtable
$addedFromFl = 0
$iterable = if ($json -is [array]) { $json } elseif ($json -is [hashtable]) { $json.Keys } else { @() }
foreach ($prefixedName in $iterable) {
if ($null -eq $prefixedName -or $prefixedName.Length -eq 0) { continue }
if ($prefixedName -match $prefixRegex) {
$rawName = $Matches[4]
if (-not $fvarLookup.ContainsKey($rawName)) {
$fvarLookup[$rawName] = @{ Prefixed = $prefixedName; Label = 'C++' }
$addedFromFl++
}
}
}
$sourcesUsed += "souloveryall-flaglist: +$addedFromFl"
} catch {
Write-ConsoleLog -Message ('souloveryall/flaglist fetch failed: ' + $_.Exception.Message) -Level 'WARN'
}
if ($fvarLookup.Count -gt 0) {
try {
$version = Get-RobloxVersionFolder
$utcNow = (Get-Date).ToUniversalTime().ToString('o')
$payload = @{ version = $version; fetched_at = $utcNow; flags = $fvarLookup }
Write-Json -Path $global:FVariablesCache -Data $payload | Out-Null
Write-ConsoleLog -Message ("FVariables cache refreshed: " + $fvarLookup.Count + " total entries (" + ($sourcesUsed -join '; ') + ")") -Level 'INFO'
} catch {
Write-ConsoleLog -Message ('FVariables cache write failed: ' + $_.Exception.Message) -Level 'WARN'
}
} else {
Write-ConsoleLog -Message 'All FVariables sources failed to return data; falling back to cached copy if available' -Level 'WARN'
try {
$cached = Read-Json -Path $global:FVariablesCache
if ($null -ne $cached -and $cached.ContainsKey('flags')) { return $cached['flags'] }
} catch { }
}
return $fvarLookup
}
function Get-AlliumFFlagDumpTarget {
[OutputType([hashtable])]
param()
$pids = [Allium.ProcessAttach]::FindProcessesByName('RobloxPlayerBeta.exe')
if ($null -eq $pids -or $pids.Length -eq 0) {
return @{ Success = $false; Error = 'Roblox not running'; Pid = 0 }
}
$targetPid = [uint32]$pids[0]
$handle = [Allium.ProcessAttach]::OpenForReadWrite($targetPid)
if ($null -eq $handle -or $handle.IsInvalid) {
return @{ Success = $false; Error = 'OpenForReadWrite failed'; Pid = $targetPid }
}
$modInfo = [Allium.ProcessAttach]::GetPrimaryModuleBase($handle)
$modBase = $modInfo.Item1
$modSize = $modInfo.Item2
if ($modBase -eq [IntPtr]::Zero -or $modSize -eq 0) {
[Allium.ProcessAttach]::Close($handle)
return @{ Success = $false; Error = 'GetPrimaryModuleBase failed'; Pid = $targetPid }
}
$exePath = Get-RobloxPlayerPath
$version = Get-RobloxVersionFolder
return @{
Success = $true
Pid = $targetPid
Handle = $handle
ModBase = $modBase
ModSize = $modSize
ExePath = $exePath
Version = $version
}
}
function Invoke-AlliumHashmapDump {
[OutputType([hashtable])]
param([Parameter(Mandatory)] [hashtable] $Target)
$result = @{ Strategy = 'bucket-walk'; Flags = @{}; DurationMs = 0; Error = $null }
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
$addrState = Get-AlliumAddressState
if ($null -eq $addrState -or $addrState.HashmapBase -eq [IntPtr]::Zero) {
Write-ConsoleLog -Message 'Hashmap base not cached; triggering multi-source address acquisition...' -Level 'INFO'
try {
$ok = Invoke-AddressAcquisitionMulti -ProcessHandle $Target.Handle -ModuleBase $Target.ModBase -ModuleSize $Target.ModSize
if ($ok) {
$addrState = Get-AlliumAddressState
}
} catch {
Write-ConsoleLog -Message ('Auto-acquisition failed: ' + $_.Exception.Message) -Level 'WARN'
}
if ($null -eq $addrState -or $addrState.HashmapBase -eq [IntPtr]::Zero) {
$result.Error = 'Hashmap base could not be acquired. Try opening Memory Mode Settings and enabling memory write first.'
return $result
}
}
$mapPtr = $addrState.HashmapBase
$mapPtr = [IntPtr]$addrState['hashmap_base_intptr']
$offsets = [Allium.AlliumOffsetsModule]::Current
$entries = [Allium.HashmapWalker]::DumpAllBuckets($Target.Handle, $mapPtr, $offsets)
foreach ($e in $entries) {
if ($null -eq $e -or [string]::IsNullOrEmpty($e.Name)) { continue }
$result.Flags[$e.Name] = @{
Name = $e.Name
EntryPtr = ([int64]$e.EntryPtr).ToString('X')
ValuePtr = ([int64]$e.ValuePtr).ToString('X')
Rva = ([int64]$e.ValuePtr - [int64]$Target.ModBase).ToString('X')
Source = 'bucket-walk'
}
}
} catch {
$result.Error = 'Hashmap dump exception: ' + $_.Exception.Message
}
$sw.Stop()
$result.DurationMs = [int]$sw.ElapsedMilliseconds
return $result
}
function Invoke-AlliumStaticDump {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [hashtable] $Target,
[hashtable] $FVarLookup = @{}
)
$result = @{ Strategy = 'static-live'; Flags = @{}; DurationMs = 0; Error = $null }
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
$sections = [Allium.PeSectionEnumerator]::Enumerate($Target.Handle, $Target.ModBase)
$text = [Allium.PeSectionEnumerator]::FindByName($sections, '.text')
$rdata = [Allium.PeSectionEnumerator]::FindByName($sections, '.rdata')
if ($null -eq $text -or $null -eq $rdata) {
$result.Error = 'Required PE section (.text or .rdata) not found'
return $result
}
$allowed = New-Object 'System.Collections.Generic.HashSet[string]'
if ($null -ne $FVarLookup -and $FVarLookup.Count -gt 0) {
foreach ($rawName in $FVarLookup.Keys) {
[void]$allowed.Add([string]$rawName)
}
}
Write-ConsoleLog -Message ("  [static-live] Scanning .text (" + $text.VirtualSize + " bytes) with " + $allowed.Count + " allowed names") -Level 'INFO'
$sfeResult = [Allium.StaticFlagExtractor]::Extract($Target.Handle, $text.VirtualAddress, $text.VirtualSize, $rdata.VirtualAddress, $rdata.VirtualSize, $allowed, 128)
Write-ConsoleLog -Message ("  [static-live] .text  read: bytesReadable=" + $sfeResult.TextBytesReadable + " bytesSkipped=" + $sfeResult.TextBytesSkipped + " regionsSkipped=" + $sfeResult.TextRegionsSkipped) -Level 'INFO'
Write-ConsoleLog -Message ("  [static-live] .rdata read: bytesReadable=" + $sfeResult.RdataBytesReadable + " bytesSkipped=" + $sfeResult.RdataBytesSkipped + " regionsSkipped=" + $sfeResult.RdataRegionsSkipped) -Level 'INFO'
Write-ConsoleLog -Message ("  [static-live] Diagnostics: leaRdxHits=" + $sfeResult.LeaRdxHits + " nameHits=" + $sfeResult.NameStringHits + " allowHits=" + $sfeResult.AllowlistHits + " paired=" + $sfeResult.PairedWithValueLea) -Level 'INFO'
$extracted = $sfeResult.Flags
foreach ($f in $extracted) {
if ($null -eq $f -or [string]::IsNullOrEmpty($f.Name)) { continue }
$rva = ([int64]$f.ValueAddr - [int64]$Target.ModBase).ToString('X')
$label = 'C++'
$prefixedName = $f.Name
$rawUnprefixed = $f.Name
if ($FVarLookup.ContainsKey($f.Name)) {
$meta = $FVarLookup[$f.Name]
$prefixedName = [string]$meta.Prefixed
$label = [string]$meta.Label
$rawUnprefixed = $f.Name
}
$result.Flags[$prefixedName] = @{
Name = $prefixedName
RawName = $rawUnprefixed
Rva = $rva
ValueAddr = ([int64]$f.ValueAddr).ToString('X')
NameAddr = ([int64]$f.NameAddr).ToString('X')
LeaRdxAddr = ([int64]$f.LeaRdxAddr).ToString('X')
Source = 'static-live'
Label = $label
}
}
Write-ConsoleLog -Message ("  [static-live] Extracted " + $result.Flags.Count + " flags") -Level 'INFO'
} catch {
$result.Error = 'Static-live extraction exception: ' + $_.Exception.Message
}
$sw.Stop()
$result.DurationMs = [int]$sw.ElapsedMilliseconds
return $result
}
function Invoke-AlliumContainerScanDump {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [hashtable] $Target,
[hashtable] $FVarLookup = @{}
)
$result = @{ Strategy = 'container-scan'; Flags = @{}; DurationMs = 0; Error = $null }
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
$bytesScanned = [long]0
$regionsScanned = [int]0
$regionsSkipped = [int]0
$containerAddr = [Allium.ContainerScanner]::FindContainer(
$Target.Handle, $Target.ModBase, $Target.ModSize,
[ref]$bytesScanned, [ref]$regionsScanned, [ref]$regionsSkipped)
Write-ConsoleLog -Message ("  [container-scan] Scan: bytesScanned=" + $bytesScanned + " regionsScanned=" + $regionsScanned + " regionsSkipped=" + $regionsSkipped) -Level 'INFO'
if ($containerAddr -eq [IntPtr]::Zero) {
$result.Error = 'FFlagList container not found in module memory'
return $result
}
Write-ConsoleLog -Message ("  [container-scan] Container found at 0x" + ([int64]$containerAddr).ToString('X')) -Level 'INFO'
$script:LastContainerScanAddress = $containerAddr
$scanResult = [Allium.ContainerScanner]::DumpContainer(
$Target.Handle, $containerAddr, $Target.ModBase, $Target.ModSize)
if ($null -ne $scanResult.Error) {
$result.Error = 'Container walk failed: ' + $scanResult.Error
return $result
}
Write-ConsoleLog -Message ("  [container-scan] Container reports " + $scanResult.ElementCount + " elements") -Level 'INFO'
foreach ($f in $scanResult.Flags) {
if ($null -eq $f -or [string]::IsNullOrEmpty($f.Name)) { continue }
$rvaStr = ('{0:X}' -f $f.Rva)
$label = 'C++'
$prefixedName = $f.Name
$rawUnprefixed = $f.Name
if ($f.Name -match '^((SF|DF|F)(Flag|Int|String|Log))(.+)$') {
$prefixedName = $f.Name
$rawUnprefixed = $Matches[4]
if ($FVarLookup.ContainsKey($rawUnprefixed)) {
$label = [string]$FVarLookup[$rawUnprefixed].Label
}
} elseif ($FVarLookup.ContainsKey($f.Name)) {
$meta = $FVarLookup[$f.Name]
$prefixedName = [string]$meta.Prefixed
$rawUnprefixed = $f.Name
$label = [string]$meta.Label
}
$result.Flags[$prefixedName] = @{
Name = $prefixedName
RawName = $rawUnprefixed
Rva = $rvaStr
Source = 'container-scan'
Label = $label
}
}
Write-ConsoleLog -Message ("  [container-scan] Extracted " + $result.Flags.Count + " flags") -Level 'INFO'
} catch {
$result.Error = 'ContainerScan dump exception: ' + $_.Exception.Message
}
$sw.Stop()
$result.DurationMs = [int]$sw.ElapsedMilliseconds
return $result
}
function Invoke-AlliumFlagValueMapDump {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [hashtable] $Target,
[hashtable] $FVarLookup = @{},
[long] $ScanStart = 0x1000000,
[long] $ScanEnd = 0x40000000,
[int] $ChunkSize = 0x1000,
[int] $MaxCandidates = 32,
[int] $MaxNodes = 60000,
[int] $MaxStringLen = 512,
[IntPtr] $KnownContainer = [IntPtr]::Zero
)
$result = @{
Strategy = 'flag-value-map'
Flags = @{}
DurationMs = 0
Error = $null
MapAddress = ''
MapEntryCount = 0
TypeDistribution = @{}
}
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
$baseL = [long]$Target.ModBase
$modSize = if ($null -ne $Target.ModSize) { [long]$Target.ModSize } else { [long]0x10000000 }
$handle = $Target.Handle
$fvarSet = New-Object System.Collections.Generic.HashSet[string]
foreach ($k in $FVarLookup.Keys) { [void]$fvarSet.Add([string]$k) }
$modSize = if ($null -ne $Target.ModSize) { [long]$Target.ModSize } else { [long]0x10000000 }
$effectiveKnown = $KnownContainer
if ($effectiveKnown -eq [IntPtr]::Zero -and $null -ne $script:LastContainerScanAddress) {
$effectiveKnown = [IntPtr]$script:LastContainerScanAddress
}
$scanRes = $null
$usedFastPath = $false
if ($effectiveKnown -ne [IntPtr]::Zero) {
$knownAddrL = [long]$effectiveKnown
if ($knownAddrL -ge 0x10000 -and $knownAddrL -lt 0x7FFFFFFFFFFF) {
try {
$vBytes = [Allium.MemoryReader]::ReadBytes($Target.Handle, $effectiveKnown, 8)
if ($vBytes.Length -ge 8) {
$val = [System.BitConverter]::ToUInt64($vBytes, 0)
if ($val -eq 0x3F800000) {
Write-ConsoleLog -Message ('  [flag-value-map] ContainerScan-container fast-path: reusing 0x' + $knownAddrL.ToString('X') + ' (skipping candidate discovery)') -Level 'INFO'
$scanRes = [Allium.FlagValueMapScanner]::WalkKnownMap($Target.Handle, $Target.ModBase,
[long]$modSize, [long]$knownAddrL, [int]$MaxNodes, [int]$MaxStringLen)
$usedFastPath = $true
}
}
} catch {
Write-ConsoleLog -Message ('  [flag-value-map] fast-path validation exception (falling back): ' + $_.Exception.Message) -Level 'WARN'
$scanRes = $null
}
}
}
if (-not $usedFastPath -or $null -eq $scanRes) {
$scanRes = [Allium.FlagValueMapScanner]::Scan($Target.Handle, $Target.ModBase,
[long]$ScanStart, [long]$ScanEnd, [int]$ChunkSize, [int]$MaxCandidates,
[int]$MaxNodes, [int]$MaxStringLen, [long]$modSize, $fvarSet)
}
if ($null -eq $scanRes) { $result.Error = 'C# scanner returned null'; return $result }
if (-not [string]::IsNullOrEmpty($scanRes.Error)) { $result.Error = $scanRes.Error; return $result }
$result.MapAddress = '0x' + $scanRes.MapAddress.ToString('X')
$result.MapEntryCount = $scanRes.WalkCount
$result.TypeDistribution = @{
Int = $scanRes.IntCount; Flag = $scanRes.FlagCount; String = $scanRes.StringCount
Log = $scanRes.LogCount; FlagAlt = $scanRes.FlagAltCount; Unknown = $scanRes.UnknownCount
}
Write-ConsoleLog -Message ('  [flag-value-map] Map found at ' + $result.MapAddress + ' (fvar-match score=' + $scanRes.FvarMatchScore + ')') -Level 'INFO'
Write-ConsoleLog -Message ('  [flag-value-map] Container walked: ' + $scanRes.WalkCount + ' nodes (Block K native scanner)') -Level 'INFO'
$prefixRegex = '^((SF|DF|F)(Flag|Int|String|Log))(.+)$'
foreach ($entry in $scanRes.Flags) {
$decName = $entry.Name
$prefixedName = $decName
$rawUnprefixed = $decName
$label = 'C++'
if ($decName -match $prefixRegex) {
$prefixedName = $decName
$rawUnprefixed = $Matches[4]
if ($FVarLookup.ContainsKey($rawUnprefixed)) {
$label = [string]$FVarLookup[$rawUnprefixed].Label
}
} elseif ($FVarLookup.ContainsKey($decName)) {
$meta = $FVarLookup[$decName]
$prefixedName = [string]$meta.Prefixed
$rawUnprefixed = $decName
$label = [string]$meta.Label
}
$result.Flags[$prefixedName] = @{
Name = $prefixedName
RawName = $rawUnprefixed
Rva = $entry.RvaHex
Source = 'flag-value-map'
Label = $label
Type = $entry.Type
Value = $entry.Value
}
}
Write-ConsoleLog -Message ('  [flag-value-map] Extracted ' + $result.Flags.Count + ' flags') -Level 'INFO'
$script:LastFvmDump = $result
} catch {
$result.Error = 'flag-value-map dump exception: ' + $_.Exception.Message
}
$sw.Stop()
$result.DurationMs = [int]$sw.ElapsedMilliseconds
return $result
}
function Get-AlliumFlagValue {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [string] $Name,
[switch] $Refresh
)
$fvm = $null
if (-not $Refresh.IsPresent -and $null -ne $script:LastFvmDump -and $script:LastFvmDump.Flags -is [hashtable] -and $script:LastFvmDump.Flags.Count -gt 0) {
$fvm = $script:LastFvmDump
} else {
$target = Get-AlliumFFlagDumpTarget
if (-not $target.Success) {
return @{ Found = $false; Error = 'Target attach failed: ' + $target.Error }
}
try {
$fvarLookup = Get-AlliumFVariables
$fvm = Invoke-AlliumFlagValueMapDump -Target $target -FVarLookup $fvarLookup
} finally {
try { [Allium.ProcessAttach]::Close($target.Handle) } catch { }
}
}
if ($null -eq $fvm -or $null -eq $fvm.Flags -or $fvm.Flags.Count -eq 0) {
return @{ Found = $false; Error = 'flag-value-map dump returned no flags'; DumpError = ($fvm.Error) }
}
if ($fvm.Flags.ContainsKey($Name)) {
$e = $fvm.Flags[$Name]
return @{ Found = $true; Name = $e.Name; RawName = $e.RawName; Type = $e.Type; Rva = $e.Rva; Value = $e.Value; Label = $e.Label }
}
foreach ($k in $fvm.Flags.Keys) {
if ($fvm.Flags[$k].RawName -eq $Name) {
$e = $fvm.Flags[$k]
return @{ Found = $true; Name = $e.Name; RawName = $e.RawName; Type = $e.Type; Rva = $e.Rva; Value = $e.Value; Label = $e.Label }
}
}
return @{ Found = $false; Error = ('Flag not found: ' + $Name) }
}
function Initialize-AlliumFvmFromExternalOffsets {
[OutputType([hashtable])]
param([switch] $ForceRefresh)
$result = @{ Success = $false; EntryCount = 0; Version = ''; VersionMismatch = $false; Error = $null }
try {
$currentVersion = Get-RobloxVersionFolder
if ([string]::IsNullOrWhiteSpace($currentVersion)) {
$result.Error = 'Roblox version could not be determined; external offsets require a version to look up.'
return $result
}
$extCache = Update-FFlagOffsetsCache -Version $currentVersion -Force:$ForceRefresh
if ($null -eq $extCache -or $null -eq $extCache.Flags -or $extCache.Flags.Count -eq 0) {
$result.Error = 'External offsets cache empty or fetch failed for ' + $currentVersion
return $result
}
$cachedVersion = if ($extCache.ContainsKey('RobloxVersion')) { [string]$extCache.RobloxVersion } else { '' }
$result.Version = $cachedVersion
if (-not [string]::IsNullOrWhiteSpace($cachedVersion) -and $cachedVersion -ne $currentVersion) {
$result.VersionMismatch = $true
}
$fvarLookup = @{}
try { $fvarLookup = Get-AlliumFVariables } catch { $fvarLookup = @{} }
$fvmFlags = @{}
foreach ($rawKey in @($extCache.Flags.Keys)) {
$rvaRaw = [string]$extCache.Flags[$rawKey]
if ([string]::IsNullOrWhiteSpace($rvaRaw)) { continue }
$rvaHex = $rvaRaw -replace '^0x', ''
try { $rvaHex = ('{0:X}' -f [Convert]::ToInt64($rvaHex, 16)) } catch { continue }
$displayName = if ($null -ne $fvarLookup -and $fvarLookup.ContainsKey($rawKey)) {
$meta = $fvarLookup[$rawKey]
if ($null -ne $meta -and $null -ne $meta.Prefixed) { [string]$meta.Prefixed } else { $rawKey }
} else { $rawKey }
$typeVal = 'Unknown'
if ($displayName -match '^(DF|F|SF)Flag') { $typeVal = 'Flag' }
elseif ($displayName -match '^(DF|F)Int') { $typeVal = 'Int' }
elseif ($displayName -match '^(DF|F)String') { $typeVal = 'String' }
elseif ($displayName -match '^(DF|F)Log') { $typeVal = 'Log' }
$fvmFlags[$displayName] = @{
Name = $displayName
RawName = $rawKey
Rva = $rvaHex
Source = 'external-offsets'
Label = 'C++'
Type = $typeVal
Value = ''
}
}
$script:LastFvmDump = @{
Strategy = 'external-offsets'
Flags = $fvmFlags
MapAddress = 'N/A (external)'
MapEntryCount = $fvmFlags.Count
TypeDistribution = @{}
IsFromExternal = $true
ExternalVersion = $cachedVersion
VersionMismatch = $result.VersionMismatch
Error = $null
DurationMs = 0
}
$result.Success = $true
$result.EntryCount = $fvmFlags.Count
} catch {
$result.Error = 'External offsets prime failed: ' + $_.Exception.Message
}
return $result
}
function Set-AlliumFlagValue {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [string] $Name,
[Parameter(Mandatory)] $Value,
[switch] $Force,
[switch] $Refresh,
[switch] $Quiet
)
$memWriteOn = $false
try {
if ($null -ne $script:Settings -and $script:Settings.ContainsKey('memoryWriteMode')) {
$memWriteOn = [bool]$script:Settings['memoryWriteMode']
}
} catch { }
if (-not $memWriteOn) {
return @{
Success = $true
Name = $Name
Type = 'MemoryDisabled'
Rva = 'memory-write-off'
Error = $null
}
}
if ($Refresh.IsPresent) {
$lookup = Get-AlliumFlagValue -Name $Name -Refresh
} else {
$lookup = Get-AlliumFlagValue -Name $Name
}
if ($null -eq $lookup -or -not $lookup.Found) {
$lookupErr = if ($null -eq $lookup) { 'null result' } else { $lookup.Error }
return @{
Success = $false
Name = $Name
Type = 'NotFound'
Rva = 'not-found'
Error = 'Flag lookup failed: ' + $lookupErr
}
}
$type = $lookup.Type
$rvaHex = $lookup.Rva
$oldValue = $lookup.Value
if ($type -eq 'String') {
return @{
Success = $false
Name = $lookup.Name
Type = $type
OldValue = $oldValue
Error = 'String-typed flags are not writable via Set-AlliumFlagValue (requires SSO threshold handling). Modify ClientAppSettings.json instead.'
}
}
if ($type -eq 'Unknown' -or $type -eq 'NoGetSet') {
return @{
Success = $false
Name = $lookup.Name
Type = $type
OldValue = $oldValue
Error = 'Unknown vtable type; cannot dispatch typed write.'
}
}
if ([string]::IsNullOrEmpty($rvaHex) -or $rvaHex -eq 'inline-sso' -or $rvaHex -like 'unknown*' -or $rvaHex -like 'out-of-*') {
return @{
Success = $false
Name = $lookup.Name
Type = $type
OldValue = $oldValue
Rva = $rvaHex
Error = 'Storage RVA is not a valid module-relative offset.'
}
}
$target = Get-AlliumFFlagDumpTarget
if (-not $target.Success) {
return @{ Success = $false; Error = 'Attach failed: ' + $target.Error }
}
try {
$rvaL = [System.Convert]::ToInt64($rvaHex, 16)
$storageAddr = [IntPtr]([long]$target.ModBase + $rvaL)
$intVal = 0
$intConvertOk = $true
if ($type -eq 'Int' -or $type -eq 'Log') {
try { $intVal = [int]$Value }
catch { $intConvertOk = $false }
if (-not $intConvertOk) {
return @{
Success = $false
Name = $lookup.Name
Type = 'TypeMismatch'
Rva = 'type-mismatch'
OldValue = $oldValue
Error = 'Type mismatch: cannot convert value ' + '"' + [string]$Value + '"' + ' to Int32 for a ' + $type + '-typed flag.'
}
}
}
$wr = $null
switch ($type) {
'Int' { $wr = [Allium.TypedWriters]::WriteInt($target.Handle, $storageAddr, $intVal) }
'Log' { $wr = [Allium.TypedWriters]::WriteInt($target.Handle, $storageAddr, $intVal) }
'Flag' {
$b = $false
if ($Value -is [bool]) { $b = [bool]$Value }
elseif ($Value -is [string] -and ($Value -eq 'True' -or $Value -eq 'true' -or $Value -eq '1')) { $b = $true }
elseif ($Value -is [int] -and $Value -ne 0) { $b = $true }
$wr = [Allium.TypedWriters]::WriteBool($target.Handle, $storageAddr, $b)
}
'FlagAlt' {
$b = $false
if ($Value -is [bool]) { $b = [bool]$Value }
elseif ($Value -is [string] -and ($Value -eq 'True' -or $Value -eq 'true' -or $Value -eq '1')) { $b = $true }
elseif ($Value -is [int] -and $Value -ne 0) { $b = $true }
$wr = [Allium.TypedWriters]::WriteBool($target.Handle, $storageAddr, $b)
}
default {
return @{ Success = $false; Error = 'Unhandled type in write dispatch: ' + $type }
}
}
if ($null -eq $wr -or -not $wr.Success) {
$errMsg = if ($null -eq $wr) { 'writer returned null' } else { $wr.Error }
return @{
Success = $false
Name = $lookup.Name
Type = $type
Rva = $rvaHex
OldValue = $oldValue
Error = 'Write failed: ' + $errMsg
}
}
$verifyMatch = $false
$newReadValue = ''
$vb = [Allium.MemoryReader]::ReadBytes($target.Handle, $storageAddr, 4)
if ($vb.Length -ge 4) {
if ($type -eq 'Int' -or $type -eq 'Log') {
$rv = [System.BitConverter]::ToInt32($vb, 0)
$newReadValue = [string]$rv
$verifyMatch = ($rv -eq [int]$Value)
} else {
$rb = $vb[0]
$newReadValue = if ($rb -eq 0) { 'False' } elseif ($rb -eq 1) { 'True' } else { 'byte=' + $rb }
$expected = 0
if ($Value -is [bool]) { $expected = if ($Value) { 1 } else { 0 } }
elseif ($Value -is [string] -and ($Value -eq 'True' -or $Value -eq 'true' -or $Value -eq '1')) { $expected = 1 }
elseif ($Value -is [int] -and $Value -ne 0) { $expected = 1 }
$verifyMatch = ($rb -eq $expected)
}
}
if ($null -ne $script:LastFvmDump -and $script:LastFvmDump.Flags -is [hashtable]) {
if ($script:LastFvmDump.Flags.ContainsKey($lookup.Name)) {
$script:LastFvmDump.Flags[$lookup.Name].Value = $newReadValue
}
}
$effectNote = if ($lookup.Name -match '^(D[FS])') {
'Dynamic flag: change auto-refreshes within ~5 minutes.'
} elseif ($lookup.Name -match '^SF') {
'Synchronized flag: server-controlled; client write may be overwritten.'
} else {
'Static flag: change takes effect on next scene load (teleport/rejoin), not mid-session.'
}
if (-not $Quiet.IsPresent) {
try { Write-ConsoleLog -Message ('Set-AlliumFlagValue: ' + $lookup.Name + ' = ' + $newReadValue + ' (' + $effectNote + ')') -Level 'INFO' } catch { }
}
return @{
Success = $true
Name = $lookup.Name
RawName = $lookup.RawName
Type = $type
Rva = $rvaHex
OldValue = $oldValue
NewValue = $newReadValue
BytesWritten = $wr.BytesWritten
VerifyMatch = $verifyMatch
EffectivenessNote = $effectNote
}
} finally {
try { [Allium.ProcessAttach]::Close($target.Handle) } catch { }
}
}
function Set-AlliumFlagValueBatch {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [hashtable] $Flags,
[switch] $Verify
)
$results = @{}
if ($Flags.Count -eq 0) { return $results }
try {
$memWriteOn = $false
try {
if ($null -ne $script:Settings -and $script:Settings.ContainsKey('memoryWriteMode')) {
$memWriteOn = [bool]$script:Settings['memoryWriteMode']
}
} catch { }
if (-not $memWriteOn) {
foreach ($name in @($Flags.Keys)) {
$results[$name] = @{
Success = $true; Name = $name
Type = 'MemoryDisabled'; Rva = 'memory-write-off'
Error = $null
}
}
return $results
}
try {
if ($null -eq $script:LastFvmDump -or -not ($script:LastFvmDump.Flags -is [hashtable]) -or $script:LastFvmDump.Flags.Count -eq 0) {
$firstName = @($Flags.Keys)[0]
$null = Get-AlliumFlagValue -Name $firstName -Refresh
}
} catch {
Write-ConsoleLog -Message ('[batch-v3] cache-fill phase threw: ' + $_.Exception.Message) -Level 'WARN'
}
if ($null -eq $script:LastFvmDump -or -not ($script:LastFvmDump.Flags -is [hashtable])) {
foreach ($name in @($Flags.Keys)) {
$results[$name] = @{
Success = $false; Name = $name; Type = 'NotFound'; Rva = 'not-found'
Error = 'Flag lookup failed: fvm cache unavailable'
}
}
return $results
}
$fvmFlags = $script:LastFvmDump.Flags
$rawIndex = @{}
try {
foreach ($k in @($fvmFlags.Keys)) {
if ($null -eq $k) { continue }
$entry = $fvmFlags[$k]
if ($null -eq $entry) { continue }
$rn = $null
try { $rn = $entry.RawName } catch { $rn = $null }
if ($null -ne $rn) {
$rawIndex[$rn] = $k
}
}
} catch {
Write-ConsoleLog -Message ('[batch-v3] reverse-index phase threw: ' + $_.Exception.Message) -Level 'WARN'
$rawIndex = @{}
}
$target = $null
try { $target = Get-AlliumFFlagDumpTarget } catch {
Write-ConsoleLog -Message ('[batch-v3] attach phase threw: ' + $_.Exception.Message) -Level 'WARN'
}
if ($null -eq $target -or -not $target.Success) {
$attachErr = if ($null -eq $target) { 'attach returned null' } else { 'Attach failed: ' + $target.Error }
foreach ($name in @($Flags.Keys)) {
$results[$name] = @{ Success = $false; Name = $name; Error = $attachErr }
}
return $results
}
try {
foreach ($name in @($Flags.Keys)) {
$val = $Flags[$name]
$lookup = $null
try {
if ($fvmFlags.ContainsKey($name)) {
$lookup = $fvmFlags[$name]
} elseif ($rawIndex.ContainsKey($name)) {
$lookup = $fvmFlags[$rawIndex[$name]]
}
} catch { $lookup = $null }
if ($null -eq $lookup) {
$results[$name] = @{
Success = $false; Name = $name
Type = 'NotFound'; Rva = 'not-found'
Error = 'Flag lookup failed: Flag not found: ' + $name
}
continue
}
$type = $null; $rvaHex = $null; $oldValue = $null
$canonicalName = $name; $rawName = $null
try { $type = $lookup.Type } catch { }
try { $rvaHex = $lookup.Rva } catch { }
try { $oldValue = $lookup.Value } catch { }
try { if ($null -ne $lookup.Name) { $canonicalName = $lookup.Name } } catch { }
try { $rawName = $lookup.RawName } catch { }
if ($type -eq 'String') {
$results[$name] = @{
Success = $false; Name = $canonicalName; Type = $type
OldValue = $oldValue
Error = 'String-typed flags are not writable via batch.'
}
continue
}
if ($type -eq 'Unknown' -or $type -eq 'NoGetSet') {
$results[$name] = @{
Success = $false; Name = $canonicalName; Type = $type
OldValue = $oldValue
Error = 'Unknown vtable type; cannot dispatch typed write.'
}
continue
}
if ([string]::IsNullOrEmpty($rvaHex) -or $rvaHex -eq 'inline-sso' -or $rvaHex -like 'unknown*' -or $rvaHex -like 'out-of-*') {
$results[$name] = @{
Success = $false; Name = $canonicalName; Type = $type
OldValue = $oldValue; Rva = $rvaHex
Error = 'Storage RVA is not a valid module-relative offset.'
}
continue
}
try {
$rvaL = [System.Convert]::ToInt64($rvaHex, 16)
$storageAddr = [IntPtr]([long]$target.ModBase + $rvaL)
$intVal = 0
$intConvertOk = $true
if ($type -eq 'Int' -or $type -eq 'Log') {
try { $intVal = [int]$val } catch { $intConvertOk = $false }
if (-not $intConvertOk) {
$results[$name] = @{
Success = $false; Name = $canonicalName
Type = 'TypeMismatch'; Rva = 'type-mismatch'
OldValue = $oldValue
Error = 'Type mismatch: cannot convert value to Int32.'
}
continue
}
}
$wr = $null
switch ($type) {
'Int' { $wr = [Allium.TypedWriters]::WriteInt($target.Handle, $storageAddr, $intVal) }
'Log' { $wr = [Allium.TypedWriters]::WriteInt($target.Handle, $storageAddr, $intVal) }
'Flag' {
$b = $false
if ($val -is [bool]) { $b = [bool]$val }
elseif ($val -is [string] -and ($val -eq 'True' -or $val -eq 'true' -or $val -eq '1')) { $b = $true }
elseif ($val -is [int] -and $val -ne 0) { $b = $true }
$wr = [Allium.TypedWriters]::WriteBool($target.Handle, $storageAddr, $b)
}
'FlagAlt' {
$b = $false
if ($val -is [bool]) { $b = [bool]$val }
elseif ($val -is [string] -and ($val -eq 'True' -or $val -eq 'true' -or $val -eq '1')) { $b = $true }
elseif ($val -is [int] -and $val -ne 0) { $b = $true }
$wr = [Allium.TypedWriters]::WriteBool($target.Handle, $storageAddr, $b)
}
default {
$results[$name] = @{ Success = $false; Name = $canonicalName; Error = 'Unhandled type: ' + $type }
continue
}
}
if ($null -eq $wr -or -not $wr.Success) {
$errMsg = if ($null -eq $wr) { 'writer returned null' } else { $wr.Error }
$results[$name] = @{
Success = $false; Name = $canonicalName; Type = $type
Rva = $rvaHex; OldValue = $oldValue
Error = 'Write failed: ' + $errMsg
}
continue
}
$verifyMatch = $true
$newReadValue = ''
if ($Verify.IsPresent) {
$verifyMatch = $false
$vb = [Allium.MemoryReader]::ReadBytes($target.Handle, $storageAddr, 4)
if ($vb.Length -ge 4) {
if ($type -eq 'Int' -or $type -eq 'Log') {
$rv = [System.BitConverter]::ToInt32($vb, 0)
$newReadValue = [string]$rv
$verifyMatch = ($rv -eq [int]$val)
} else {
$rb = $vb[0]
$newReadValue = if ($rb -eq 0) { 'False' } elseif ($rb -eq 1) { 'True' } else { 'byte=' + $rb }
$expected = 0
if ($val -is [bool]) { $expected = if ($val) { 1 } else { 0 } }
elseif ($val -is [string] -and ($val -eq 'True' -or $val -eq 'true' -or $val -eq '1')) { $expected = 1 }
elseif ($val -is [int] -and $val -ne 0) { $expected = 1 }
$verifyMatch = ($rb -eq $expected)
}
}
try {
if ($fvmFlags.ContainsKey($canonicalName)) {
$fvmFlags[$canonicalName].Value = $newReadValue
}
} catch { }
}
$results[$name] = @{
Success = $true; Name = $canonicalName; RawName = $rawName
Type = $type; Rva = $rvaHex
OldValue = $oldValue; NewValue = $newReadValue
BytesWritten = $wr.BytesWritten
VerifyMatch = $verifyMatch
}
} catch {
$results[$name] = @{
Success = $false; Name = $name
Error = 'Batch write exception: ' + $_.Exception.Message
}
}
}
} finally {
try { [Allium.ProcessAttach]::Close($target.Handle) } catch { }
}
return $results
} catch {
$exMsg = $_.Exception.Message
$exType = $_.Exception.GetType().FullName
$stackTrace = ''
try { $stackTrace = $_.ScriptStackTrace } catch { }
try {
Write-ConsoleLog -Message ('[batch-v3] TOP-LEVEL UNCAUGHT: ' + $exType + ': ' + $exMsg) -Level 'ERROR'
if (-not [string]::IsNullOrEmpty($stackTrace)) {
Write-ConsoleLog -Message ('[batch-v3] stack: ' + $stackTrace) -Level 'ERROR'
}
} catch { }
foreach ($name in @($Flags.Keys)) {
if (-not $results.ContainsKey($name)) {
$results[$name] = @{
Success = $false; Name = $name
Error = 'Batch primitive crashed: ' + $exMsg
}
}
}
return $results
}
}
function Invoke-WatchdogAutoApplyMemory {
[OutputType([hashtable])]
param()
$stats = @{ Applied = 0; Missing = 0; Failed = 0; Skipped = 0; Error = $null }
try {
if (-not ($script:Flags -is [hashtable]) -or $script:Flags.Count -eq 0) { return $stats }
$rob = $false
try { $rob = Test-RobloxRunning } catch { $rob = $false }
if (-not $rob) { $stats.Skipped = $script:Flags.Count; return $stats }
$__wdResults = @{}
try { $__wdResults = Set-AlliumFlagValueBatch -Flags $script:Flags } catch { $__wdResults = @{} }
foreach ($name in @($script:Flags.Keys)) {
$wr = $null
if ($__wdResults.ContainsKey($name)) {
$wr = $__wdResults[$name]
} else {
$val = $script:Flags[$name]
try { $wr = Set-AlliumFlagValue -Name $name -Value $val -Force -Quiet }
catch { $wr = $null }
}
if ($null -eq $wr) { $stats.Failed++ }
elseif ($wr.Success) { $stats.Applied++ }
elseif ($null -ne $wr.Type -and $wr.Type -eq 'String') { $stats.Applied++ }
elseif ($null -ne $wr.Type -and $wr.Type -eq 'NotFound') { $stats.Missing++ }
elseif ($null -ne $wr.Rva -and ($wr.Rva -eq 'inline-sso' -or $wr.Rva -like 'unknown*' -or $wr.Rva -like 'out-of-*')) { $stats.Applied++ }
else { $stats.Failed++ }
}
} catch {
$stats.Error = $_.Exception.Message
}
return $stats
}
function Merge-AlliumDumpQuorum {
[OutputType([hashtable])]
param(
[hashtable] $Dynamic = @{},
[hashtable] $Static = @{},
[hashtable] $ContainerScan = @{},
[hashtable] $Souloveryall = @{},
[hashtable] $FlagValueMap = @{}
)
$merged = @{}
$agree = 0
$disagree = 0
$dynOnly = 0
$stcOnly = 0
$containerScanOnly = 0
$sovOnly = 0
$fvmOnly = 0
$allNames = New-Object System.Collections.Generic.HashSet[string]
foreach ($n in $FlagValueMap.Keys) { [void]$allNames.Add($n) }
foreach ($n in $Dynamic.Keys) { [void]$allNames.Add($n) }
foreach ($n in $ContainerScan.Keys) { [void]$allNames.Add($n) }
foreach ($n in $Static.Keys) { [void]$allNames.Add($n) }
foreach ($n in $Souloveryall.Keys) { [void]$allNames.Add($n) }
foreach ($name in $allNames) {
$inFvm = $FlagValueMap.ContainsKey($name)
$inDyn = $Dynamic.ContainsKey($name)
$inContainerScan = $ContainerScan.ContainsKey($name)
$inStc = $Static.ContainsKey($name)
$inSov = $Souloveryall.ContainsKey($name)
$sources = @()
$confidence = 'low'
$rva = ''
$chosenSource = $null
if ($inFvm) {
$rva = $FlagValueMap[$name].Rva
$sources += 'flag-value-map'
$chosenSource = $FlagValueMap[$name]
}
if ($inContainerScan) {
$sources += 'container-scan'
if ($null -eq $chosenSource) { $rva = $ContainerScan[$name].Rva; $chosenSource = $ContainerScan[$name] }
elseif ($rva -eq $ContainerScan[$name].Rva) { $agree++ }
else { $disagree++ }
}
if ($inStc) {
$sources += 'static-live'
if ($null -eq $chosenSource) { $rva = $Static[$name].Rva; $chosenSource = $Static[$name] }
elseif ($rva -eq $Static[$name].Rva) { $agree++ }
else { $disagree++ }
}
if ($inDyn) {
$sources += 'bucket-walk'
if ($null -eq $chosenSource) { $rva = $Dynamic[$name].Rva; $chosenSource = $Dynamic[$name] }
elseif ($rva -eq $Dynamic[$name].Rva) { $agree++ }
else { $disagree++ }
}
if ($inSov) {
$sources += 'souloveryall'
if ($null -eq $chosenSource) { $rva = $Souloveryall[$name].Rva; $chosenSource = $Souloveryall[$name] }
}
$memoryCount = 0
if ($inFvm) { $memoryCount++ }
if ($inDyn) { $memoryCount++ }
if ($inContainerScan) { $memoryCount++ }
if ($inStc) { $memoryCount++ }
if ($memoryCount -ge 2) { $confidence = 'high' }
elseif ($memoryCount -eq 1) { $confidence = 'medium' }
else { $confidence = 'low' }
if ($inFvm -and -not $inContainerScan -and -not $inDyn -and -not $inStc -and -not $inSov) { $fvmOnly++ }
elseif ($inDyn -and -not $inFvm -and -not $inContainerScan -and -not $inStc -and -not $inSov) { $dynOnly++ }
elseif ($inContainerScan -and -not $inFvm -and -not $inDyn -and -not $inStc -and -not $inSov) { $containerScanOnly++ }
elseif ($inStc -and -not $inFvm -and -not $inContainerScan -and -not $inDyn -and -not $inSov) { $stcOnly++ }
elseif ($inSov -and -not $inFvm -and -not $inContainerScan -and -not $inDyn -and -not $inStc) { $sovOnly++ }
$entry = @{
Name = $name
Rva = $rva
Sources = $sources
Confidence = $confidence
}
if ($null -ne $chosenSource) {
if ($chosenSource.ContainsKey('Type')) { $entry['Type'] = $chosenSource['Type'] }
if ($chosenSource.ContainsKey('Label')) { $entry['Label'] = $chosenSource['Label'] }
if ($chosenSource.ContainsKey('Source')) { $entry['Source'] = $chosenSource['Source'] }
if ($chosenSource.ContainsKey('RawName')) { $entry['RawName'] = $chosenSource['RawName'] }
if ($chosenSource.ContainsKey('Value')) { $entry['Value'] = $chosenSource['Value'] }
if ($chosenSource.ContainsKey('ValueAddr')) { $entry['ValueAddr'] = $chosenSource['ValueAddr'] }
if ($chosenSource.ContainsKey('NameAddr')) { $entry['NameAddr'] = $chosenSource['NameAddr'] }
if ($chosenSource.ContainsKey('LeaRdxAddr')) { $entry['LeaRdxAddr'] = $chosenSource['LeaRdxAddr'] }
if ($chosenSource.ContainsKey('ValueLeaReg')){ $entry['ValueLeaReg']= $chosenSource['ValueLeaReg'] }
}
$merged[$name] = $entry
}
return @{
Flags = $merged
Agree = $agree
Disagree = $disagree
DynOnly = $dynOnly
ContainerScanOnly = $containerScanOnly
StaticOnly = $stcOnly
SouloveryallOnly = $sovOnly
FvmOnly = $fvmOnly
Total = $merged.Count
}
}
function Save-AlliumFFlagDump {
[OutputType([string])]
param(
[Parameter(Mandatory)] [hashtable] $Summary,
[string] $OutputDir = $null
)
Initialize-AlliumDumperDataDirs
if ([string]::IsNullOrWhiteSpace($OutputDir)) { $OutputDir = $global:DumpsDir }
$ts = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss')
$ver = if ($Summary.ContainsKey('Version')) { [string]$Summary['Version'] } else { 'unknown' }
$fname = "dump-" + $ver + "-" + $ts + ".json"
$fpath = Join-Path $OutputDir $fname
Write-Json -Path $fpath -Data $Summary | Out-Null
Write-ConsoleLog -Message ("Dump saved: " + $fpath) -Level 'INFO'
return $fpath
}
function Invoke-AlliumSouloveryallDump {
[OutputType([hashtable])]
param(
[Parameter(Mandatory)] [hashtable] $Target,
[hashtable] $FVarLookup = @{},
[switch] $ForceRefresh
)
$result = @{ Strategy = 'souloveryall'; Flags = @{}; DurationMs = 0; Error = $null }
$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
$version = if ($null -ne $Target -and $Target.ContainsKey('Version') -and -not [string]::IsNullOrWhiteSpace([string]$Target['Version'])) {
[string]$Target['Version']
} else {
Get-RobloxVersionFolder
}
if ([string]::IsNullOrWhiteSpace($version)) {
$result.Error = 'Roblox version could not be determined'
return $result
}
$cache = Update-FFlagOffsetsCache -Version $version -Force:$ForceRefresh
if ($null -eq $cache -or $null -eq $cache.Flags -or $cache.Flags.Count -eq 0) {
$result.Error = 'Souloveryall cache empty or unavailable for ' + $version
return $result
}
$rawToPrefixed = @{}
if ($null -ne $FVarLookup -and $FVarLookup.Count -gt 0) {
foreach ($rawName in $FVarLookup.Keys) {
$meta = $FVarLookup[$rawName]
if ($null -ne $meta -and $null -ne $meta.Prefixed) {
$rawToPrefixed[$rawName] = [string]$meta.Prefixed
}
}
}
foreach ($name in $cache.Flags.Keys) {
if ([string]::IsNullOrEmpty($name)) { continue }
$rvaVal = $cache.Flags[$name]
$rvaStr = if ($null -eq $rvaVal) { '' } else { [string]$rvaVal }
$displayName = $name
$rawUnprefixed = $name
if ($name -match '^((SF|DF|F)(Flag|Int|String|Log))(.+)$') {
$displayName = $name
$rawUnprefixed = $Matches[4]
} elseif ($rawToPrefixed.ContainsKey($name)) {
$displayName = $rawToPrefixed[$name]
$rawUnprefixed = $name
}
$type = Get-FFlagTypeFromName -Name $displayName
$result.Flags[$displayName] = @{
Name = $displayName
RawName = $rawUnprefixed
Rva = $rvaStr
Type = $type
Source = 'souloveryall'
}
}
Write-ConsoleLog -Message ("  [souloveryall-fallback] Retrieved " + $result.Flags.Count + " flags from cache (" + $rawToPrefixed.Count + " prefixed from FVariables)") -Level 'INFO'
} catch {
$result.Error = 'Souloveryall dump exception: ' + $_.Exception.Message
}
$sw.Stop()
$result.DurationMs = [int]$sw.ElapsedMilliseconds
return $result
}
function Update-AlliumFFlagGenealogy {
param([Parameter(Mandatory)] [hashtable] $Summary)
Initialize-AlliumDumperDataDirs
$ver = if ($Summary.ContainsKey('Version')) { [string]$Summary['Version'] } else { 'unknown' }
$gpath = Join-Path $global:GenealogyDir ($ver + '.json')
$existing = @{}
if (Test-Path $gpath) {
try { $existing = Read-Json -Path $gpath } catch { $existing = @{} }
if ($null -eq $existing) { $existing = @{} }
}
if (-not $existing.ContainsKey('history')) { $existing['history'] = @() }
$entry = @{
timestamp = [DateTime]::UtcNow.ToString('o')
total_flags = $Summary['Total']
agree = $Summary['Agree']
disagree = $Summary['Disagree']
dyn_only = $Summary['DynOnly']
static_only = $Summary['StaticOnly']
strategies = $Summary['Strategies']
}
$existing['history'] += $entry
$existing['version'] = $ver
$existing['last_updated'] = $entry.timestamp
Write-Json -Path $gpath -Data $existing | Out-Null
}
function Test-AlliumFFlagDump {
[OutputType([hashtable])]
param([Parameter(Mandatory)] [hashtable] $Summary)
$knownGood = @(
'FFlagDebugDisplayFPS',
'FFlagDebugSkyGray',
'DFIntDebugDynamicRenderKiloPixels',
'DFFlagDebugPauseVoxelizer',
'DFIntTextureCompositorActiveJobs',
'FFlagDebugDisableTelemetryV2Event',
'FFlagDebugDisableTelemetryV2Stat',
'DFIntTaskSchedulerTargetFps',
'DFFlagDebugRenderForceTechnologyVoxel',
'FStringDebugLuaLogLevel',
'FIntGameGridFlexFeedItemTileNumPerFeed',
'DFFlagDisableDPIScale',
'FIntRuntimeMaxNumOfThreads',
'DFIntMinimalSimRadiusBuffer',
'FFlagDebugGraphicsPreferD3D11'
)
$flags = $Summary['Flags']
$found = 0
$missing = @()
foreach ($kg in $knownGood) {
if ($flags.ContainsKey($kg)) { $found++ } else { $missing += $kg }
}
return @{
Total = $knownGood.Count
Found = $found
Missing = $missing
Pass = ($found -eq $knownGood.Count)
}
}
function Get-AlliumFvmPrefixType {
param([string]$Name)
if ([string]::IsNullOrEmpty($Name)) { return $null }
if ($Name -match '^(DF|SF|F)Flag') { return 'Flag' }
if ($Name -match '^(DF|F)Int') { return 'Int' }
if ($Name -match '^(DF|F)String') { return 'String' }
if ($Name -match '^(DF|F)Log') { return 'Log' }
return $null
}
function Repair-AlliumFvmTypeMap {
param([hashtable]$Dump)
if ($null -eq $Dump -or -not ($Dump.Flags -is [hashtable]) -or $Dump.Flags.Count -eq 0) { return 0 }
$flags = $Dump.Flags
$votes = @{}
foreach ($k in @($flags.Keys)) {
$meta = $flags[$k]
if ([string]$meta.Value -match '^VT:([0-9A-Fa-f]+)$') {
$vt = $Matches[1]
$t = Get-AlliumFvmPrefixType -Name ([string]$meta.Name)
if ($null -ne $t) {
if (-not $votes.ContainsKey($vt)) { $votes[$vt] = @{} }
if (-not $votes[$vt].ContainsKey($t)) { $votes[$vt][$t] = 0 }
$votes[$vt][$t]++
}
}
}
$clusterType = @{}
foreach ($vt in @($votes.Keys)) {
$best = $null; $bestN = -1
foreach ($t in @($votes[$vt].Keys)) {
if ($votes[$vt][$t] -gt $bestN) { $bestN = $votes[$vt][$t]; $best = $t }
}
if ($null -ne $best) { $clusterType[$vt] = $best }
}
$fixed = 0
foreach ($k in @($flags.Keys)) {
$meta = $flags[$k]
if ([string]$meta.Value -match '^VT:([0-9A-Fa-f]+)$') {
$vt = $Matches[1]
$pfx = Get-AlliumFvmPrefixType -Name ([string]$meta.Name)
if ($null -ne $pfx) {
$newType = $pfx
} elseif ($clusterType.ContainsKey($vt)) {
$newType = $clusterType[$vt]
} else {
$newType = 'Unknown'
}
$meta.Type = $newType
$meta.Value = ''
$fixed++
}
}
if ($fixed -gt 0) {
Write-ConsoleLog -Message ('  [flag-value-map] R30 type repair: ' + $clusterType.Count + ' vtable cluster(s) calibrated, ' + $fixed + ' flag(s) typed') -Level 'INFO'
}
return $fixed
}
function Get-AlliumFFlagDump {
[OutputType([hashtable])]
param(
[ValidateSet('Dynamic', 'Static', 'Auto')] [string] $Strategy = 'Auto',
[switch] $NoSave
)
$overallSw = [System.Diagnostics.Stopwatch]::StartNew()
Write-ConsoleLog -Message ("FFlag Dumper started: strategy=" + $Strategy) -Level 'INFO'
$target = Get-AlliumFFlagDumpTarget
if (-not $target.Success) {
Write-ConsoleLog -Message ("FFlag Dumper cannot attach: " + $target.Error) -Level 'ERROR'
return @{ Success = $false; Error = $target.Error }
}
try {
$fvarLookup = Get-AlliumFVariables
$dynResult = @{ Flags = @{}; DurationMs = 0 }
$stcResult = @{ Flags = @{}; DurationMs = 0 }
$containerScanResult = @{ Flags = @{}; DurationMs = 0 }
$sovResult = @{ Flags = @{}; DurationMs = 0 }
$fvmResult = @{ Flags = @{}; DurationMs = 0 }
$strategiesUsed = @()
if ($Strategy -in @('Static','Auto')) {
$stcResult = Invoke-AlliumDumperStrategyByName -Name 'static-live' -Target $target -FVarLookup $fvarLookup
$strategiesUsed += 'static-live'
if ($null -ne $stcResult.Error) {
Write-ConsoleLog -Message ("Static-live warning: " + $stcResult.Error) -Level 'WARN'
}
}
if ($Strategy -in @('ContainerScan','Auto')) {
$containerScanResult = Invoke-AlliumDumperStrategyByName -Name 'container-scan' -Target $target -FVarLookup $fvarLookup
$strategiesUsed += 'container-scan'
if ($null -ne $containerScanResult.Error) {
Write-ConsoleLog -Message ("Container Scan warning: " + $containerScanResult.Error) -Level 'WARN'
}
}
if ($Strategy -eq 'Dynamic') {
$dynResult = Invoke-AlliumDumperStrategyByName -Name 'bucket-walk' -Target $target -FVarLookup $fvarLookup
$strategiesUsed += 'bucket-walk'
if ($null -ne $dynResult.Error) {
Write-ConsoleLog -Message ("Dynamic-hashmap warning: " + $dynResult.Error) -Level 'WARN'
}
}
if ($Strategy -in @('Souloveryall','Auto')) {
$sovResult = Invoke-AlliumDumperStrategyByName -Name 'souloveryall' -Target $target -FVarLookup $fvarLookup
$strategiesUsed += 'souloveryall'
if ($null -ne $sovResult.Error) {
Write-ConsoleLog -Message ("Souloveryall warning: " + $sovResult.Error) -Level 'WARN'
}
}
if ($Strategy -in @('FlagValueMap','Auto')) {
$fvmResult = Invoke-AlliumDumperStrategyByName -Name 'flag-value-map' -Target $target -FVarLookup $fvarLookup
$strategiesUsed += 'flag-value-map'
if ($null -ne $fvmResult.Error) {
Write-ConsoleLog -Message ("flag-value-map warning: " + $fvmResult.Error) -Level 'WARN'
}
}
try {
[void](Repair-AlliumFvmTypeMap -Dump $fvmResult)
if ($null -ne $script:LastFvmDump) { [void](Repair-AlliumFvmTypeMap -Dump $script:LastFvmDump) }
if ($fvmResult.Flags -is [hashtable] -and $fvmResult.Flags.Count -gt 0) {
$__pt = @{ Flag = 0; Int = 0; String = 0; Log = 0; Unknown = 0; Other = 0 }
foreach ($__fk in $fvmResult.Flags.Keys) {
$__ft = [string]$fvmResult.Flags[$__fk].Type
if ($__pt.ContainsKey($__ft)) { $__pt[$__ft]++ } else { $__pt.Other++ }
}
Write-ConsoleLog -Message ('  [flag-value-map] Post-repair types: Flag=' + $__pt.Flag + ', Int=' + $__pt.Int + ', String=' + $__pt.String + ', Log=' + $__pt.Log + ', Unknown=' + $__pt.Unknown + ', Other=' + $__pt.Other) -Level 'INFO'
}
} catch {
Write-ConsoleLog -Message ('R30 type repair failed (non-fatal): ' + $_.Exception.Message) -Level 'WARN'
}
$primaryStrategy = if ($fvmResult.Flags.Count -gt 0) { 'flag-value-map' }
elseif ($containerScanResult.Flags.Count -gt 0) { 'container-scan' }
elseif ($stcResult.Flags.Count -gt 0) { 'static-live' }
elseif ($dynResult.Flags.Count -gt 0) { 'bucket-walk' }
elseif ($sovResult.Flags.Count -gt 0) { 'souloveryall' }
else { 'none' }
Write-ConsoleLog -Message ("Primary strategy: " + $primaryStrategy + " (fvm=" + $fvmResult.Flags.Count + " container-scan=" + $containerScanResult.Flags.Count + " static=" + $stcResult.Flags.Count + " dyn=" + $dynResult.Flags.Count + " sov=" + $sovResult.Flags.Count + ")") -Level 'INFO'
$quorum = Merge-AlliumDumpQuorum -Dynamic $dynResult.Flags -Static $stcResult.Flags -ContainerScan $containerScanResult.Flags -Souloveryall $sovResult.Flags -FlagValueMap $fvmResult.Flags
try {
if ($null -ne $script:RefreshDumperDiagnostics) {
& $script:RefreshDumperDiagnostics
}
} catch { }
$overallSw.Stop()
$summary = @{
Success = $true
Version = $target.Version
Pid = $target.Pid
ModBase = ([int64]$target.ModBase).ToString('X')
ModSize = $target.ModSize
Strategies = $strategiesUsed
Total = $quorum.Total
Agree = $quorum.Agree
Disagree = $quorum.Disagree
DynOnly = $quorum.DynOnly
ContainerScanOnly = $quorum.ContainerScanOnly
StaticOnly = $quorum.StaticOnly
SouloveryallOnly = $quorum.SouloveryallOnly
DurationMs = [int]$overallSw.ElapsedMilliseconds
DynDurationMs = $dynResult.DurationMs
StaticDurationMs = $stcResult.DurationMs
Timestamp = [DateTime]::UtcNow.ToString('o')
Flags = $quorum.Flags
}
if ($quorum.Disagree -gt 0) {
Write-ConsoleLog -Message ("Quorum divergence: " + $quorum.Disagree + " flag(s) with mismatched RVAs across >=2 memory sources. This may indicate Roblox client drift.") -Level 'WARN'
}
Update-AlliumFFlagGenealogy -Summary $summary
if (-not $NoSave) {
$path = Save-AlliumFFlagDump -Summary $summary
$summary['DumpPath'] = $path
}
$script:LastDumpSummary = $summary
if ($null -ne $script:DumperStatusRefs) {
try {
$script:DumperStatusRefs.CountRow.Text = ($quorum.Total.ToString() + ' flags')
$script:DumperStatusRefs.DurationRow.Text = ($summary.DurationMs.ToString() + ' ms')
$script:DumperStatusRefs.TimestampRow.Text = $summary.Timestamp
$agreeText = if ($quorum.Total -gt 0) { ('{0:P1}' -f ($quorum.Agree / [double]$quorum.Total)) } else { 'n/a' }
$script:DumperStatusRefs.AgreementRow.Text = $agreeText
} catch { }
}
Write-ConsoleLog -Message ("FFlag Dumper complete: " + $quorum.Total + " flags in " + $summary.DurationMs + " ms") -Level 'INFO'
return $summary
} finally {
try { [Allium.ProcessAttach]::Close($target.Handle) } catch { }
}
}
function Start-HttpIntercept {
if (-not $script:Settings.httpInterceptEnabled) {
Write-ConsoleLog -Message 'Start-HttpIntercept called but httpInterceptEnabled is $false; ignoring.' -Level 'INFO'
return $false
}
if ($null -ne $script:HttpsInterceptorInstance) {
Write-ConsoleLog -Message 'HTTPS interceptor already running.' -Level 'INFO'
return $true
}
if (-not (Test-Path $script:HttpsInterceptCaPfxFile -PathType Leaf)) {
Write-ConsoleLog -Message 'HTTPS CA PFX missing; running Install-AlliumProxyCA first.' -Level 'WARN'
$__caResult = Install-AlliumProxyCA
if ($null -eq $__caResult -or -not $__caResult.Success) {
Write-ConsoleLog -Message 'HTTPS CA install failed; aborting proxy start.' -Level 'ERROR'
return $false
}
}
try {
$__caPfx = [Allium.HttpsCaGenerator]::LoadPfx($script:HttpsInterceptCaPfxFile)
[Allium.HttpsLeafCertFactory]::SetRootCa($__caPfx)
} catch {
Write-ConsoleLog -Message ('HTTPS CA load failed: ' + $_.Exception.Message) -Level 'ERROR'
return $false
}
try {
$script:HttpsInterceptorInstance = [Allium.HttpsInterceptor]::new()
try { $script:HttpsInterceptorInstance.BandwidthSaverEnabled = [bool]$script:BandwidthSaverMode } catch {}
if ($null -ne $script:Flags -and $script:Flags.Count -gt 0) {
Update-InterceptorOverrides
}
$__port = 443
$script:HttpsInterceptorInstance.Start($__port)
} catch {
Write-ConsoleLog -Message ('HTTPS interceptor start failed: ' + $_.Exception.Message) -Level 'ERROR'
try { if ($null -ne $script:HttpsInterceptorInstance) { $script:HttpsInterceptorInstance.Dispose() } } catch {}
$script:HttpsInterceptorInstance = $null
return $false
}
if (-not (Install-AlliumHosts)) {
Write-ConsoleLog -Message 'Hosts install failed; tearing down proxy.' -Level 'ERROR'
try { $script:HttpsInterceptorInstance.Stop() } catch {}
try { $script:HttpsInterceptorInstance.Dispose() } catch {}
$script:HttpsInterceptorInstance = $null
return $false
}
try { Register-AlliumHostsWatchdog } catch {
Write-ConsoleLog -Message ('Hosts watchdog register failed (non-fatal): ' + $_.Exception.Message) -Level 'WARN'
}
Write-ConsoleLog -Message ('HTTPS Interception started on port ' + $__port + ' (' + $script:HttpsInterceptorInstance.FlagOverrideCount + ' override(s) active)') -Level 'INFO'
return $true
}
function Stop-HttpIntercept {
try { Unregister-AlliumHostsWatchdog } catch {
Write-ConsoleLog -Message ('Watchdog unregister failed (non-fatal): ' + $_.Exception.Message) -Level 'WARN'
}
try { Uninstall-AlliumHosts | Out-Null } catch {
Write-ConsoleLog -Message ('Hosts uninstall failed (non-fatal): ' + $_.Exception.Message) -Level 'WARN'
}
if ($null -ne $script:HttpsInterceptorInstance) {
try { $script:HttpsInterceptorInstance.Stop() } catch {}
try { $script:HttpsInterceptorInstance.Dispose() } catch {}
$script:HttpsInterceptorInstance = $null
Write-ConsoleLog -Message 'HTTPS Interception stopped.' -Level 'INFO'
}
}
function Show-SplashWindow {
$win = [WinUIShell.Microsoft.UI.Xaml.Window]::new()
$win.Title = 'Launching Allium...'
$win.ExtendsContentIntoTitleBar = $true
try {
$win.AppWindow.Resize(300, 120)
Center-Window -AppWindow $win.AppWindow -Width 300 -Height 120
$iconFile = (Resolve-Path $script:IconPath).Path
$win.AppWindow.SetIcon($iconFile)
} catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$root = [WinUIShell.Microsoft.UI.Xaml.Controls.Grid]::new()
$root.RequestedTheme = [WinUIShell.Microsoft.UI.Xaml.ElementTheme]::Dark
$root.Background = [WinUIShell.Microsoft.UI.Xaml.Media.SolidColorBrush]::new(
[WinUIShell.Windows.UI.Color]::FromArgb(210, 0x1c, 0x08, 0x08)
)
$panel = [WinUIShell.Microsoft.UI.Xaml.Controls.StackPanel]::new()
$panel.VerticalAlignment = [WinUIShell.Microsoft.UI.Xaml.VerticalAlignment]::Center
$panel.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$panel.Spacing = 8
$txt = [WinUIShell.Microsoft.UI.Xaml.Controls.TextBlock]::new()
$txt.Text = "Loading Allium..."
Set-SafeFontFamily -Target $txt -Family $script:AppFontFamily
$txt.FontSize = 14
$txt.Foreground = New-SolidBrush -Hex $script:ThemeColors.TextPrimary
$txt.HorizontalAlignment = [WinUIShell.Microsoft.UI.Xaml.HorizontalAlignment]::Center
$pb = New-ThemedProgressBar -Indeterminate
$pb.Width = 180
$panel.Children.Add($txt) | Out-Null
$panel.Children.Add($pb) | Out-Null
$root.Children.Add($panel) | Out-Null
$win.Content = $root
$win.Activate()
return $win
}
Load-Settings
try {
Import-AlliumDependencies | Out-Null
} catch {
Write-ConsoleLog -Message ('Boot-time Import-AlliumDependencies failed: ' + $_.Exception.Message) -Level 'WARN'
}
if ($script:Settings.httpInterceptEnabled) {
try {
$__caRepair = Install-AlliumProxyCA
if ($null -ne $__caRepair -and $__caRepair.Installed -gt 0) {
Write-ConsoleLog -Message ('HTTPS CA auto-repair installed into ' + $__caRepair.Installed + ' new location(s)') -Level 'INFO'
}
} catch {
Write-ConsoleLog -Message ('HTTPS CA auto-repair failed: ' + $_.Exception.Message) -Level 'WARN'
}
}
Ensure-Icons
$splash = Show-SplashWindow
$script:AccentColor = $script:FallbackAccentColor
$script:AccentVariants = Get-AccentColorVariants -HexColor $script:AccentColor
$script:Use24HourTime = Get-SystemTimeFormat
Load-Flags
if ($script:Settings.httpInterceptEnabled) {
try { Start-HttpIntercept | Out-Null } catch { Write-ConsoleLog -Message ('Boot-time Start-HttpIntercept failed: ' + $_.Exception.Message) -Level 'ERROR' }
}
$launcher = New-LauncherMenuWindow
try { Start-SettingsTabPrewarm } catch { Write-ConsoleLog -Message ('Start-SettingsTabPrewarm dispatch failed: ' + $_.Exception.Message) -Level 'WARN' }
try { Start-EditorPrewarm } catch { Write-ConsoleLog -Message ('Start-EditorPrewarm dispatch failed: ' + $_.Exception.Message) -Level 'WARN' }
$__splashT0 = [datetime]::UtcNow
$__splashDeadline = $__splashT0.AddMilliseconds(6500)
while ((-not ($script:SettingsPrewarmDone -and $script:EditorPrewarmDone)) -and ([datetime]::UtcNow -lt $__splashDeadline)) {
Start-Sleep -Milliseconds 100
}
$__splashElapsed = [int]([datetime]::UtcNow - $__splashT0).TotalMilliseconds
$__splashPrewarmState = if ($script:SettingsPrewarmDone -and $script:EditorPrewarmDone) { 'complete' } elseif ($script:SettingsPrewarmDone) { 'editor-still-running' } elseif ($script:EditorPrewarmDone) { 'settings-still-running' } else { 'both-still-running' }
Write-ConsoleLog -Message ('[settings-prewarm] splash held ' + $__splashElapsed + 'ms; state=' + $__splashPrewarmState) -Level 'INFO'
try { $splash.Close() } catch { Write-ConsoleLog -Message "Error: $_" -Level "ERROR" }
$launcher.Activate()
Detect-Bootstrappers
Update-BootstrapperButton -Button $script:LauncherBootstrapperButton
if ($null -ne $script:LauncherBootstrapperStatusText) {
$script:LauncherBootstrapperStatusText.Text = Get-BootstrapperStatusText
}
Update-LauncherDisplay
Refresh-BootstrapperFlyout
if ($script:Settings.minimizeToTray) { Initialize-SystemTray }
if ($script:Settings.fflagBrowserVisible) { try { if (-not [string]::IsNullOrEmpty((Get-Command Editor-ToggleBrowser -ErrorAction SilentlyContinue))) { Editor-ToggleBrowser } } catch { Write-ConsoleLog -Message ("Failed to auto-open FFlag Browser: " + $_.Exception.Message) -Level "WARN" } }
if ($script:Settings.watchdogEnabled) { Start-Watchdog }
if ($script:Settings.autoReapplyEnabled) { Start-AutoReapplyTimer }
if ($script:Settings.robloxMultiInstance) { Set-RobloxMultiInstance -Enabled $true }
try {
$launcher.WaitForClosed()
while ($null -ne $script:EditorWindow -or $null -ne $script:BrowserWindow) {
$waitTarget = $null
if ($null -ne $script:EditorWindow) {
$waitTarget = $script:EditorWindow
} elseif ($null -ne $script:BrowserWindow) {
$waitTarget = $script:BrowserWindow
}
if ($null -ne $waitTarget) {
try { $waitTarget.WaitForClosed() } catch { break }
} else {
break
}
}
} finally {
try { Stop-HttpIntercept } catch { Write-ConsoleLog -Message ('Shutdown Stop-HttpIntercept failed: ' + $_.Exception.Message) -Level 'WARN' }
Stop-Watchdog; Stop-AutoReapplyTimer; Remove-SystemTray
}
