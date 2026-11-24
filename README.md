Write-Host "===== WINDOWS DEBLOAT =====" -ForegroundColor Cyan

# Cortana
Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Remove-AppxPackage -ErrorAction SilentlyContinue

# Xbox
Get-AppxPackage -AllUsers Microsoft.XboxApp | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers Microsoft.XboxGamingOverlay | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers Microsoft.Xbox.TCUI | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers Microsoft.XboxGameCallableUI | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers Microsoft.GamingApp | Remove-AppxPackage -ErrorAction SilentlyContinue

# Clipchamp
Get-AppxPackage -AllUsers Clipchamp.Clipchamp | Remove-AppxPackage -ErrorAction SilentlyContinue

# Mapas
Get-AppxPackage -AllUsers Microsoft.WindowsMaps | Remove-AppxPackage -ErrorAction SilentlyContinue

# Solitario y juegos Microsoft
Get-AppxPackage -AllUsers Microsoft.MicrosoftSolitaireCollection | Remove-AppxPackage -ErrorAction SilentlyContinue

# Mixed Reality
Get-AppxPackage -AllUsers Microsoft.MixedReality.Portal | Remove-AppxPackage -ErrorAction SilentlyContinue

# Comunicaciones
Get-AppxPackage -AllUsers Microsoft.People | Remove-AppxPackage -ErrorAction SilentlyContinue

# Feedback Hub
Get-AppxPackage -AllUsers Microsoft.WindowsFeedbackHub | Remove-AppxPackage -ErrorAction SilentlyContinue

# Tu Teléfono / Phone Link
Get-AppxPackage -AllUsers Microsoft.YourPhone | Remove-AppxPackage -ErrorAction SilentlyContinue

# Servicios pesados para HDD
$services = @(
"SysMain",
"WSearch",
"DiagTrack",
"MapsBroker",
"Fax",
"RetailDemo",
"dmwappushservice"
)

foreach ($svc in $services) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# Desactivar Widgets
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f

# Desactivar Game Bar
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 0 /f

# Desactivar Apps en segundo plano
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f

# Alto rendimiento
powercfg /setactive SCHEME_MIN

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "LIMPIEZA COMPLETADA" -ForegroundColor Green
Write-Host "REINICIA EL EQUIPO" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Pause
