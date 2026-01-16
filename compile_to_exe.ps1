$cscPath = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $cscPath)) {
    $cscPath = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}

$iconPath = "hytale.ico"

& $cscPath /target:winexe /win32icon:$iconPath /out:HytaleLauncher.exe launcher.cs

Write-Host "EXE creado: HytaleLauncher.exe"
