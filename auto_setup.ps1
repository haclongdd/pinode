# Tu dong kiem tra va khoi dong lai script voi quyen Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[ADMIN] Dang khoi dong lai script voi quyen Administrator..." -ForegroundColor Yellow
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

# Kiem tra mat khau truoc khi chay script
$password = Read-Host "Nhap mat khau" -AsSecureString
$passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
if ($passwordText -ne "6868") {
    Write-Host "Sai mat khau! Thoat chuong trinh." -ForegroundColor Red
    exit
}

Write-Host "Mat khau dung. Dang chay script..." -ForegroundColor Green

# Ham hien thi menu chinh voi giao dien cai tien
function Show-Menu {
    param ([string]$Title = "Menu Auto Setup")
    Clear-Host
    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan; Write-Host "        $Title        ".PadRight(34) -ForegroundColor White -BackgroundColor DarkCyan -NoNewline; Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "  1. Tai Pi Node / Pi Network" -ForegroundColor Green
    Write-Host "  2. Kich hoat Windows Features" -ForegroundColor Green
    Write-Host "  3. Kich hoat WSL va VM" -ForegroundColor Green
    Write-Host "  4. Tai va cai dat WSL2 Kernel" -ForegroundColor Green
    Write-Host "  5. Cap nhat WSL2" -ForegroundColor Green
    Write-Host "  6. Cai dat Docker Desktop" -ForegroundColor Green
    Write-Host "  7. Mo Firewall - Inbound/Outbound" -ForegroundColor Green
    Write-Host "  8. Chuyen mang sang Private" -ForegroundColor Green
    Write-Host "  9. Cap nhat Windows" -ForegroundColor Green
    Write-Host " 10. Tinh chinh Windows" -ForegroundColor Green
    Write-Host " 11. Don dep he thong Windows va o C" -ForegroundColor Green
    Write-Host " 12. Dong bo thoi gian (UTC+7 Bangkok, Hanoi)" -ForegroundColor Green
    Write-Host " 13. Tai file tu Dropbox va cai dat" -ForegroundColor Green
    Write-Host "  0. Thoat" -ForegroundColor Red
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ [INFO] TOOL DUOC TAO BOI @LONGKA25A    ║" -ForegroundColor Yellow
    Write-Host "║ [INFO] FB: https://www.facebook.com/long.ka.79/ ║" -ForegroundColor Yellow
    Write-Host "║ [SUPPORT] CAN HO TRO NODE - TU VAN MAY OI LAI MINH ║" -ForegroundColor Magenta
    Write-Host "║ [CONTACT] ALO 0878566247 NEU CAN GAP   ║" -ForegroundColor Magenta
    Write-Host "║ [NOTE] KHONG HO TRO NODE AO/BUG        ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
}

# Ham tai Pi Node / Pi Network (giả lập)
function Install-PiNetwork {
    Write-Host "[PiNode] Dang tai va cai dat Pi Network..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    Write-Host "[PiNode] Hoan tat!" -ForegroundColor Green
}

# Ham kich hoat Windows Features
function Enable-WindowsFeatures {
    Write-Host "[Features] Dang kich hoat cac tinh nang Windows..." -ForegroundColor Cyan
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart
        Write-Host "[Features] Kich hoat thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "[Features] Loi: $_" -ForegroundColor Red
    }
}

# Ham kich hoat WSL va VM
function Activate-WSLAndVM {
    Write-Host "[WSL+VM] Dang kich hoat WSL va Virtual Machine..." -ForegroundColor Cyan
    try {
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        Write-Host "[WSL+VM] Kich hoat thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "[WSL+VM] Loi: $_" -ForegroundColor Red
    }
}

# Ham tai va cai dat WSL2 Kernel
function Install-WSL2Kernel {
    Write-Host "[WSL2] Dang tai va cai dat WSL2 Kernel..." -ForegroundColor Cyan
    $url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $outPath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri $url -OutFile $outPath
    Start-Process -FilePath $outPath -ArgumentList "/quiet" -Wait
    Write-Host "[WSL2] Cai dat thanh cong!" -ForegroundColor Green
}

# Ham cap nhat WSL2
function Update-WSL2 {
    Write-Host "[WSL2] Dang cap nhat WSL2..." -ForegroundColor Cyan
    wsl --update
    Write-Host "[WSL2] Cap nhat thanh cong!" -ForegroundColor Green
}

# Ham cai dat Docker Desktop
function Install-Docker {
    Write-Host "[Docker] Dang cai dat Docker Desktop..." -ForegroundColor Cyan
    $url = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    $outPath = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri $url -OutFile $outPath
    Start-Process -FilePath $outPath -ArgumentList "install --quiet" -Wait
    Write-Host "[Docker] Cai dat thanh cong!" -ForegroundColor Green
}

# Ham mo Firewall
function Configure-Firewall {
    Write-Host "[Firewall] Dang mo Inbound/Outbound..." -ForegroundColor Cyan
    netsh advfirewall set allprofiles state on
    New-NetFirewallRule -DisplayName "Allow All Inbound" -Direction Inbound -Action Allow
    New-NetFirewallRule -DisplayName "Allow All Outbound" -Direction Outbound -Action Allow
    Write-Host "[Firewall] Da cau hinh thanh cong!" -ForegroundColor Green
}

# Ham chuyen mang sang Private
function Set-PrivateNetwork {
    Write-Host "[Network] Dang chuyen mang sang Private..." -ForegroundColor Cyan
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
    Write-Host "[Network] Chuyen thanh cong!" -ForegroundColor Green
}

# Ham cap nhat Windows
function Enable-WindowsUpdate {
    Write-Host "[Update] Dang cap nhat Windows..." -ForegroundColor Cyan
    Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
    Get-WindowsUpdate -AcceptAll -Install
    Write-Host "[Update] Cap nhat thanh cong!" -ForegroundColor Green
}

# Ham tinh chinh Windows
function Set-HighPerformance {
    Write-Host "[Performance] Dang tinh chinh Windows..." -ForegroundColor Cyan
    powercfg -setactive SCHEME_MIN
    Write-Host "[Performance] Da toi uu hoa!" -ForegroundColor Green
}

# Ham don dep he thong
function Clean-System {
    Write-Host "[Cleanup] Dang don dep he thong..." -ForegroundColor Cyan
    cleanmgr /sagerun:1
    Write-Host "[Cleanup] Don dep thanh cong!" -ForegroundColor Green
}

# Ham dong bo thoi gian
function Sync-Time {
    Write-Host "[Time] Dang dong bo thoi gian (UTC+7)..." -ForegroundColor Cyan
    Set-TimeZone -Id "SE Asia Standard Time"
    w32tm /resync
    Write-Host "[Time] Dong bo thanh cong!" -ForegroundColor Green
}

# Ham tai file tu Dropbox va cai dat
function Install-FromGoogleDrive {
    Write-Host "`n[GDrive] Dang xu ly tai va cai dat..." -ForegroundColor Cyan
    $downloadUrl = "https://www.dropbox.com/scl/fi/4vagxcpvqce2lozpx2j99/Pi.Network.Setup.0.5.1.exe?rlkey=1qchyoq3yimjqt4ra4wdl9i70&st=jzro54c4&dl=1"
    $installerPath = "$env:TEMP\Pi.Network.Setup.0.5.1.exe"
    
    try {
        if (Test-Path $installerPath) {
            Write-Host "├─[Cleanup] Xoa file cu: $installerPath" -ForegroundColor Yellow
            Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
        }

        $webClient = New-Object System.Net.WebClient
        Register-ObjectEvent $webClient DownloadProgressChanged -SourceIdentifier "GDriveDownload" -Action {
            Write-Progress -Activity "[GDrive] Dang tai xuong..." `
                          -Status "$($EventArgs.ProgressPercentage)% Complete" `
                          -PercentComplete $EventArgs.ProgressPercentage
        } | Out-Null
        
        Write-Host "├─[Download] Dang tai file tu Dropbox..." -ForegroundColor Yellow
        $webClient.DownloadFile($downloadUrl, $installerPath)
        Unregister-Event -SourceIdentifier "GDriveDownload"
        Write-Progress -Activity "[GDrive] Dang tai xuong..." -Completed

        if (-not (Test-Path $installerPath) -or (Get-Item $installerPath).Length -eq 0) {
            Write-Host "│ └─[Error] Tai xuong that bai hoac file bi hu hong!" -ForegroundColor Red
            Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
            return
        }

        Write-Host "│ └─Tai xuong hoan tat: $installerPath" -ForegroundColor Green
        
        Write-Host "├─[Install] Dang cai dat..." -ForegroundColor Yellow
        Start-Process -FilePath $installerPath -Wait
        Write-Host "└─[Success] Cai dat hoan tat!" -ForegroundColor Green
    } catch {
        Write-Host "└─[Error] Loi khi tai hoac cai dat: $($_)" -ForegroundColor Red
    }
}

# Vong lap chinh
while ($true) {
    Show-Menu
    Write-Host "`n[INPUT] Nhap lua chon: " -ForegroundColor Cyan -NoNewline
    $choice = Read-Host
    switch ($choice) {
        "1" { Install-PiNetwork }
        "2" { Enable-WindowsFeatures }
        "3" { Activate-WSLAndVM }
        "4" { Install-WSL2Kernel }
        "5" { Update-WSL2 }
        "6" { Install-Docker }
        "7" { Configure-Firewall }
        "8" { Set-PrivateNetwork }
        "9" { Enable-WindowsUpdate }
        "10" { Set-HighPerformance }
        "11" { Clean-System }
        "12" { Sync-Time }
        "13" { Install-FromGoogleDrive }
        "0" {
            Write-Host "`n[EXIT] Thoat chuong trinh!" -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "`n[ERROR] Lua chon khong hop le!" -ForegroundColor Red
        }
    }
    Write-Host "`n[CONTINUE] Nhan Enter de tiep tuc..." -ForegroundColor Cyan
    [void](Read-Host)
}
