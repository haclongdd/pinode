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

# (Thêm lại các hàm khác như Install-PiNetwork, Enable-WindowsFeatures, v.v. nếu cần, hoặc giữ nguyên từ script trước)

# Ham tai file tu Dropbox va cai dat
function Install-FromGoogleDrive {
    Write-Host "`n[GDrive] Dang xu ly tai va cai dat..." -ForegroundColor Cyan
    $downloadUrl = "https://www.dropbox.com/scl/fi/4vagxcpvqce2lozpx2j99/Pi.Network.Setup.0.5.1.exe?rlkey=1qchyoq3yimjqt4ra4wdl9i70&st=jzro54c4&dl=1"  # URL tải trực tiếp từ Dropbox
    $installerPath = "$env:TEMP\Pi.Network.Setup.0.5.1.exe"  # Tên file khớp với file từ Dropbox
    
    try {
        # Kiem tra va xoa file cu neu ton tai
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

        # Kiem tra file sau khi tai
        if (-not (Test-Path $installerPath)) {
            Write-Host "│ └─[Error] Tai xuong that bai! File khong ton tai: $installerPath" -ForegroundColor Red
            Write-Host "   └─[Suggestion] Vui long kiem tra lai URL hoac tai thu cong tu: $downloadUrl" -ForegroundColor Yellow
            return
        }
        if ((Get-Item $installerPath).Length -eq 0) {
            Write-Host "│ └─[Error] File tai xuong bi rong hoac bi hu hong!" -ForegroundColor Red
            Remove-Item -Path $installerPath -Force
            Write-Host "   └─[Suggestion] Vui long kiem tra lai URL hoac tai thu cong tu: $downloadUrl" -ForegroundColor Yellow
            return
        }

        Write-Host "│ └─Tai xuong hoan tat: $installerPath" -ForegroundColor Green
        
        Write-Host "├─[Install] Dang cai dat..." -ForegroundColor Yellow
        for ($i = 0; $i -le 100; $i += 10) {
            Write-Progress -Activity "[GDrive] Dang cai dat..." `
                          -Status "$i% Complete" `
                          -PercentComplete $i
            Start-Sleep -Milliseconds 300
        }
        Start-Process -FilePath $installerPath -Wait
        Write-Progress -Activity "[GDrive] Dang cai dat..." -Completed
        Write-Host "└─[Success] Cai dat hoan tat!" -ForegroundColor Green
    }
    catch {
        Write-Host "└─[Error] Loi khi tai hoac cai dat: $($_)" -ForegroundColor Red
        if (Test-Path $installerPath) {
            Write-Host "   └─[Info] File co the bi hu hong. Xoa file." -ForegroundColor Yellow
            Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
        }
        Write-Host "   └─[Suggestion] Vui long kiem tra lai URL hoac tai thu cong tu: $downloadUrl" -ForegroundColor Yellow
        Write-Progress -Activity "[GDrive] Dang tai xuong..." -Completed
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
