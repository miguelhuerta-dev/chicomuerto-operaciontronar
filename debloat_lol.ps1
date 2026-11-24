# =====================================================================
#  Debloat ligero para laptop lenta + League of Legends
#  Seguro con Vanguard: NO toca Windows Update, Defender, firma de
#  drivers, Secure Boot ni archivos de Riot.
#  Ejecutar como Administrador.
# =====================================================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Abre PowerShell como ADMINISTRADOR y vuelve a correr el script." -ForegroundColor Red
    pause; exit
}

Write-Host "`n[1/8] Creando punto de restauracion..." -ForegroundColor Cyan
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Antes de debloat LoL" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
    Write-Host "  OK" -ForegroundColor Green
} catch { Write-Host "  No se pudo crear (puede que ya exista uno de hoy). Continuando..." -ForegroundColor Yellow }

# ---------------------------------------------------------------------
Write-Host "`n[2/8] Quitando apps basura preinstaladas..." -ForegroundColor Cyan
$apps = @(
    "Microsoft.BingNews","Microsoft.BingWeather","Microsoft.GetHelp","Microsoft.Getstarted",
    "Microsoft.MicrosoftOfficeHub","Microsoft.MicrosoftSolitaireCollection","Microsoft.People",
    "Microsoft.SkypeApp","Microsoft.WindowsFeedbackHub","Microsoft.WindowsMaps",
    "Microsoft.ZuneMusic","Microsoft.ZuneVideo","Microsoft.MixedReality.Portal",
    "Microsoft.Microsoft3DViewer","Microsoft.Print3D","Microsoft.Office.OneNote",
    "Microsoft.YourPhone","Microsoft.WindowsAlarms","Microsoft.549981C3F5F10",
    "*CandyCrush*","*Spotify*","*Disney*","*TikTok*","*Facebook*","*Instagram*",
    "*Netflix*","*king.com*","*HPJumpStart*","*HPPrivacySettings*","*HPSupportAssistant*",
    "*AD2F1837.HPWelcome*","*McAfee*"
)
foreach ($a in $apps) {
    Get-AppxPackage -Name $a -AllUsers -ErrorAction SilentlyContinue |
        Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}
Write-Host "  OK" -ForegroundColor Green

# ---------------------------------------------------------------------
Write-Host "`n[3/8] Desactivando servicios que comen disco y RAM..." -ForegroundColor Cyan
# DiagTrack = telemetria | WSearch = indexado (mata el HDD) | SysMain = precarga (100% disco en HDD)
# dmwappushservice = telemetria | MapsBroker = mapas | Fax | RetailDemo
$servicios = @("DiagTrack","dmwappushservice","WSearch","SysMain","MapsBroker","Fax","RetailDemo","WerSvc")
foreach ($s in $servicios) {
    $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
    if ($svc) {
        Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
        Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  $s desactivado"
    }
}

# ---------------------------------------------------------------------
Write-Host "`n[4/8] Apagando apps en segundo plano y Game DVR..." -ForegroundColor Cyan
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord
New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord
# Telemetria al minimo
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord
# Sin sugerencias/anuncios en Inicio
$cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
foreach ($n in "SilentInstalledAppsEnabled","SystemPaneSuggestionsEnabled","SubscribedContent-338388Enabled","SubscribedContent-338389Enabled","SoftLandingEnabled") {
    Set-ItemProperty -Path $cdm -Name $n -Value 0 -Type DWord -ErrorAction SilentlyContinue
}
# Edge no precarga al iniciar
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "StartupBoostEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "BackgroundModeEnabled" -Value 0 -Type DWord
Write-Host "  OK" -ForegroundColor Green

# ---------------------------------------------------------------------
Write-Host "`n[5/8] Efectos visuales en modo rendimiento..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0"
Write-Host "  OK" -ForegroundColor Green

# ---------------------------------------------------------------------
Write-Host "`n[6/8] Plan de energia: Alto rendimiento..." -ForegroundColor Cyan
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -h off   # quita hibernacion (libera GBs en disco)
Write-Host "  OK" -ForegroundColor Green

# ---------------------------------------------------------------------
Write-Host "`n[7/8] Limpiando temporales..." -ForegroundColor Cyan
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  OK" -ForegroundColor Green

# ---------------------------------------------------------------------
Write-Host "`n[8/8] Optimizando el disco duro (desfragmentar, tarda un rato)..." -ForegroundColor Cyan
Write-Host "  Puedes cerrar con Ctrl+C si no quieres esperar; todo lo demas ya quedo." -ForegroundColor Yellow
Optimize-Volume -DriveLetter C -Defrag -Verbose

Write-Host "`n=====================================================" -ForegroundColor Green
Write-Host " LISTO. Reinicia la laptop para que todo aplique." -ForegroundColor Green
Write-Host " Si algo sale mal: Panel de control > Recuperacion >" -ForegroundColor Green
Write-Host " Restaurar sistema > 'Antes de debloat LoL'" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
pause
