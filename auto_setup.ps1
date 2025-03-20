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
    Write-Host "  1. Kich hoat Windows" -ForegroundColor Green
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
    Write-Host " 13. Tai Pi Node / Pi Network" -ForegroundColor Green
    Write-Host "  0. Thoat" -ForegroundColor Red
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ [INFO] TOOL DUOC TAO BOI @LONGKA25A    ║" -ForegroundColor Yellow
    Write-Host "║ [INFO] FB: https://www.facebook.com/long.ka.79/ ║" -ForegroundColor Yellow
    Write-Host "║ [SUPPORT] CAN HO TRO NODE - TU VAN MAY OI LAI MINH ║" -ForegroundColor Magenta
    Write-Host "║ [CONTACT] ALO 0878566247 NEU CAN GAP   ║" -ForegroundColor Magenta
    Write-Host "║ [NOTE] KHONG HO TRO NODE AO/BUG        ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
}

# Ham kich hoat Windows bang HWID
function Activate-Windows {
    Write-Host "`n[Windows Activation] Dang kich hoat Windows..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/4] Dang kiem tra phien ban Windows..." -ForegroundColor Yellow
        $osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
        if ($osVersion -like "*Windows 10*") {
            if ($osVersion -like "*Pro*") {
                Write-Host "├─[Step 2/4] Windows 10 Pro detected. Installing key..." -ForegroundColor Yellow
                Start-Process -FilePath "cscript" -ArgumentList "//nologo slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX" -Wait
            } elseif ($osVersion -like "*Home*") {
                Write-Host "├─[Step 2/4] Windows 10 Home detected. Installing key..." -ForegroundColor Yellow
                Start-Process -FilePath "cscript" -ArgumentList "//nologo slmgr.vbs /ipk TX9XD-98N7V-6WMQ6-BX7FG-H8Q99" -Wait
            }
        } elseif ($osVersion -like "*Windows 11*") {
            if ($osVersion -like "*Pro*") {
                Write-Host "├─[Step 2/4] Windows 11 Pro detected. Installing key..." -ForegroundColor Yellow
                Start-Process -FilePath "cscript" -ArgumentList "//nologo slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX" -Wait
            } elseif ($osVersion -like "*Home*") {
                Write-Host "├─[Step 2/4] Windows 11 Home detected. Installing key..." -ForegroundColor Yellow
                Start-Process -FilePath "cscript" -ArgumentList "//nologo slmgr.vbs /ipk YTMG3-N6DKC-DKB77-7M9GH-8HVX7" -Wait
            }
        } else {
            Write-Host "└─[Error] Khong the xac dinh phien ban Windows!" -ForegroundColor Red
            return
        }

        Write-Host "├─[Step 3/4] Thiet lap KMS server..." -ForegroundColor Yellow
        Start-Process -FilePath "cscript" -ArgumentList "//nologo slmgr.vbs /skms kms8.msguides.com" -Wait
        Write-Host "├─[Step 4/4] Dang kich hoat..." -ForegroundColor Yellow
        Start-Process -FilePath "cscript" -ArgumentList "//nologo slmgr.vbs /ato" -Wait
        Write-Host "└─[Success] Kich hoat Windows thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "└─[Error] Loi khi kich hoat Windows: $($_)" -ForegroundColor Red
    }
}

# Ham tai Pi Node / Pi Network tu Dropbox
function Install-PiNetwork {
    Write-Host "`n[PiNode] Dang xu ly tai va cai dat Pi Network..." -ForegroundColor Cyan
    $downloadUrl = "https://www.dropbox.com/scl/fi/4vagxcpvqce2lozpx2j99/Pi.Network.Setup.0.5.1.exe?rlkey=1qchyoq3yimjqt4ra4wdl9i70&st=jzro54c4&dl=1"
    $installerPath = "$env:TEMP\Pi.Network.Setup.0.5.1.exe"
    
    try {
        if (Test-Path $installerPath) {
            Write-Host "├─[Cleanup] Xoa file cu: $installerPath" -ForegroundColor Yellow
            Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
        }

        $totalBytes = -1
        try {
            $webRequest = [System.Net.HttpWebRequest]::Create($downloadUrl)
            $webResponse = $webRequest.GetResponse()
            $totalBytes = $webResponse.ContentLength
            $webResponse.Close()
        } catch {
            Write-Host "│ └─[Warning] Khong the lay kich thuoc file: $($_)" -ForegroundColor Yellow
        }

        if ($totalBytes -eq -1) {
            Write-Host "├─[Download] Dang tai file tu Dropbox (Khong the lay kich thuoc file)..." -ForegroundColor Yellow
        } else {
            Write-Host "├─[Download] Dang tai file tu Dropbox (Tong kich thuoc: $([math]::Round($totalBytes / 1MB, 2)) MB)..." -ForegroundColor Yellow
        }

        $job = Start-Job -ScriptBlock {
            param($url, $path)
            Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
        } -ArgumentList $downloadUrl, $installerPath

        while ($job.State -eq "Running") {
            if (Test-Path $installerPath) {
                $bytesRead = (Get-Item $installerPath).Length
                if ($totalBytes -gt 0) {
                    $percent = [math]::Round(($bytesRead / $totalBytes) * 100, 2)
                    $mbRead = [math]::Round($bytesRead / 1MB, 2)
                    $mbTotal = [math]::Round($totalBytes / 1MB, 2)
                    Write-Host "`r├─[Download] Dang tai... ($mbRead MB / $mbTotal MB - $percent%)" -ForegroundColor Yellow -NoNewline
                }
            }
            Start-Sleep -Milliseconds 500
        }

        $job | Receive-Job -Wait -AutoRemoveJob
        Write-Host "`n│ └─Tai xuong hoan tat: $installerPath" -ForegroundColor Green

        if (-not (Test-Path $installerPath) -or (Get-Item $installerPath).Length -eq 0) {
            Write-Host "│ └─[Error] Tai xuong that bai hoac file bi hu hong!" -ForegroundColor Red
            Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
            Write-Host "   └─[Suggestion] Vui long kiem tra lai URL: $downloadUrl" -ForegroundColor Yellow
            return
        }
        
        Write-Host "├─[Install] Dang cai dat Pi Network..." -ForegroundColor Yellow -NoNewline
        $process = Start-Process -FilePath $installerPath -PassThru
        while (-not $process.HasExited) {
            Write-Host "." -ForegroundColor Yellow -NoNewline
            Start-Sleep -Milliseconds 500
        }
        Write-Host "`n└─[Success] Cai dat Pi Network hoan tat!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi tai hoac cai dat: $($_)" -ForegroundColor Red
        Write-Host "   └─[Suggestion] Vui long kiem tra lai URL: $downloadUrl" -ForegroundColor Yellow
    }
}

# Ham cai dat Docker Desktop
function Install-Docker {
    Write-Host "`n[Docker] Dang xu ly tai va cai dat Docker Desktop..." -ForegroundColor Cyan
    $downloadUrl = "https://www.dropbox.com/scl/fi/1ry90prm5sgm5qtn06bdr/Docker-Desktop-Installer.exe?rlkey=my8y7b6f7lb1ehsgvz1nqcrur&st=pz9bsw92&dl=1"
    $installerPath = "$env:TEMP\DockerDesktopInstaller.exe"
    $maxRetries = 3
    $retryCount = 0
    $success = $false
    
    while (-not $success -and $retryCount -lt $maxRetries) {
        try {
            if (Test-Path $installerPath) {
                Write-Host "├─[Cleanup] Xoa file cu: $installerPath" -ForegroundColor Yellow
                Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
            }

            $totalBytes = -1
            try {
                $webRequest = [System.Net.HttpWebRequest]::Create($downloadUrl)
                $webResponse = $webRequest.GetResponse()
                $totalBytes = $webResponse.ContentLength
                $webResponse.Close()
            } catch {
                Write-Host "│ └─[Warning] Khong the lay kich thuoc file: $($_)" -ForegroundColor Yellow
            }

            if ($totalBytes -eq -1) {
                Write-Host "├─[Download] Dang tai file tu Dropbox (Lan thu $($retryCount + 1)) (Khong the lay kich thuoc file)..." -ForegroundColor Yellow
            } else {
                Write-Host "├─[Download] Dang tai file tu Dropbox (Lan thu $($retryCount + 1)) (Tong kich thuoc: $([math]::Round($totalBytes / 1MB, 2)) MB)..." -ForegroundColor Yellow
            }

            $job = Start-Job -ScriptBlock {
                param($url, $path)
                Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
            } -ArgumentList $downloadUrl, $installerPath

            while ($job.State -eq "Running") {
                if (Test-Path $installerPath) {
                    $bytesRead = (Get-Item $installerPath).Length
                    if ($totalBytes -gt 0) {
                        $percent = [math]::Round(($bytesRead / $totalBytes) * 100, 2)
                        $mbRead = [math]::Round($bytesRead / 1MB, 2)
                        $mbTotal = [math]::Round($totalBytes / 1MB, 2)
                        Write-Host "`r├─[Download] Dang tai... ($mbRead MB / $mbTotal MB - $percent%)" -ForegroundColor Yellow -NoNewline
                    }
                }
                Start-Sleep -Milliseconds 500
            }

            $job | Receive-Job -Wait -AutoRemoveJob
            Write-Host "`n│ └─Tai xuong hoan tat: $installerPath" -ForegroundColor Green

            if (-not (Test-Path $installerPath) -or (Get-Item $installerPath).Length -lt 100000) {
                Write-Host "│ └─[Error] Tai xuong that bai hoac file bi hu hong!" -ForegroundColor Red
                Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
                $retryCount++
                continue
            }

            $success = $true
        } catch {
            Write-Host "`n│ └─[Error] Loi khi tai file: $($_)" -ForegroundColor Red
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "├─[Retry] Thu lai lan thu $($retryCount + 1)..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
            }
        }
    }

    if (-not $success) {
        Write-Host "└─[Error] Khong the tai file sau $maxRetries lan thu! Vui long kiem tra lai URL: $downloadUrl" -ForegroundColor Red
        return
    }

    try {
        Write-Host "├─[Install] Dang cai dat Docker Desktop..." -ForegroundColor Yellow -NoNewline
        $process = Start-Process -FilePath $installerPath -ArgumentList "install", "--quiet" -PassThru -NoNewWindow
        while (-not $process.HasExited) {
            Write-Host "." -ForegroundColor Yellow -NoNewline
            Start-Sleep -Milliseconds 500
        }
        Write-Host "`n└─[Success] Cai dat Docker Desktop hoan tat!" -ForegroundColor Green

        $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        if (Test-Path $dockerPath) {
            Write-Host "├─[Verify] Docker Desktop da duoc cai dat thanh cong tai: $dockerPath" -ForegroundColor Green
        } else {
            Write-Host "└─[Warning] Khong tim thay Docker Desktop. Co the cai dat khong thanh cong!" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "`n└─[Error] Loi khi cai dat: $($_)" -ForegroundColor Red
        Write-Host "   └─[Suggestion] Vui long kiem tra file tai ve tai: $installerPath" -ForegroundColor Yellow
    }
}

# Ham kich hoat Windows Features
function Enable-WindowsFeatures {
    Write-Host "`n[Features] Dang kich hoat cac tinh nang Windows..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/3] Kich hoat Hyper-V..." -ForegroundColor Yellow -NoNewline
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -All -NoRestart | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "├─[Step 2/3] Kich hoat Virtual Machine Platform..." -ForegroundColor Yellow -NoNewline
        Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "├─[Step 3/3] Kich hoat WSL..." -ForegroundColor Yellow -NoNewline
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "└─[Success] Kich hoat cac tinh nang Windows thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi kich hoat: $($_)" -ForegroundColor Red
    }
}

# Ham kich hoat WSL va VM
function Activate-WSLAndVM {
    Write-Host "`n[WSL+VM] Dang kich hoat WSL va Virtual Machine..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/2] Kich hoat Virtual Machine Platform..." -ForegroundColor Yellow -NoNewline
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "├─[Step 2/2] Kich hoat WSL..." -ForegroundColor Yellow -NoNewline
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "└─[Success] Kich hoat WSL va Virtual Machine thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi kich hoat: $($_)" -ForegroundColor Red
    }
}

# Ham tai va cai dat WSL2 Kernel
function Install-WSL2Kernel {
    Write-Host "`n[WSL2] Dang tai va cai dat WSL2 Kernel..." -ForegroundColor Cyan
    $url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $outPath = "$env:TEMP\wsl_update_x64.msi"
    
    try {
        if (Test-Path $outPath) {
            Write-Host "├─[Cleanup] Xoa file cu: $outPath" -ForegroundColor Yellow
            Remove-Item -Path $outPath -Force -ErrorAction SilentlyContinue
        }

        $totalBytes = -1
        try {
            $webRequest = [System.Net.HttpWebRequest]::Create($url)
            $webResponse = $webRequest.GetResponse()
            $totalBytes = $webResponse.ContentLength
            $webResponse.Close()
        } catch {
            Write-Host "│ └─[Warning] Khong the lay kich thuoc file: $($_)" -ForegroundColor Yellow
        }

        if ($totalBytes -eq -1) {
            Write-Host "├─[Download] Dang tai file WSL2 Kernel (Khong the lay kich thuoc file)..." -ForegroundColor Yellow
        } else {
            Write-Host "├─[Download] Dang tai file WSL2 Kernel (Tong kich thuoc: $([math]::Round($totalBytes / 1MB, 2)) MB)..." -ForegroundColor Yellow
        }

        $job = Start-Job -ScriptBlock {
            param($url, $path)
            Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
        } -ArgumentList $url, $outPath

        while ($job.State -eq "Running") {
            if (Test-Path $outPath) {
                $bytesRead = (Get-Item $outPath).Length
                if ($totalBytes -gt 0) {
                    $percent = [math]::Round(($bytesRead / $totalBytes) * 100, 2)
                    $mbRead = [math]::Round($bytesRead / 1MB, 2)
                    $mbTotal = [math]::Round($totalBytes / 1MB, 2)
                    Write-Host "`r├─[Download] Dang tai... ($mbRead MB / $mbTotal MB - $percent%)" -ForegroundColor Yellow -NoNewline
                }
            }
            Start-Sleep -Milliseconds 500
        }

        $job | Receive-Job -Wait -AutoRemoveJob
        Write-Host "`n│ └─Tai xuong hoan tat: $outPath" -ForegroundColor Green

        if (-not (Test-Path $outPath) -or (Get-Item $outPath).Length -eq 0) {
            Write-Host "│ └─[Error] Tai xuong that bai hoac file bi hu hong!" -ForegroundColor Red
            Remove-Item -Path $outPath -Force -ErrorAction SilentlyContinue
            Write-Host "   └─[Suggestion] Vui long kiem tra lai URL: $url" -ForegroundColor Yellow
            return
        }
        
        Write-Host "├─[Install] Dang cai dat WSL2 Kernel..." -ForegroundColor Yellow -NoNewline
        $process = Start-Process -FilePath $outPath -ArgumentList "/quiet" -PassThru
        while (-not $process.HasExited) {
            Write-Host "." -ForegroundColor Yellow -NoNewline
            Start-Sleep -Milliseconds 500
        }
        Write-Host "`n└─[Success] Cai dat WSL2 Kernel hoan tat!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi tai hoac cai dat: $($_)" -ForegroundColor Red
        Write-Host "   └─[Suggestion] Vui long kiem tra lai URL: $url" -ForegroundColor Yellow
    }
}

# Ham cap nhat WSL2
function Update-WSL2 {
    Write-Host "`n[WSL2] Dang cap nhat WSL2..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/1] Dang cap nhat WSL2..." -ForegroundColor Yellow -NoNewline
        $process = Start-Process -FilePath "wsl" -ArgumentList "--update" -PassThru -NoNewWindow
        while (-not $process.HasExited) {
            Write-Host "." -ForegroundColor Yellow -NoNewline
            Start-Sleep -Milliseconds 500
        }
        Write-Host "`n└─[Success] Cap nhat WSL2 thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi cap nhat: $($_)" -ForegroundColor Red
    }
}

# Ham mo Firewall
function Configure-Firewall {
    Write-Host "`n[Firewall] Dang mo Inbound/Outbound..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/3] Bat Firewall..." -ForegroundColor Yellow -NoNewline
        netsh advfirewall set allprofiles state on | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "├─[Step 2/3] Mo Inbound..." -ForegroundColor Yellow -NoNewline
        New-NetFirewallRule -DisplayName "Allow All Inbound" -Direction Inbound -Action Allow | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "├─[Step 3/3] Mo Outbound..." -ForegroundColor Yellow -NoNewline
        New-NetFirewallRule -DisplayName "Allow All Outbound" -Direction Outbound -Action Allow | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "└─[Success] Da cau hinh Firewall thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi cau hinh Firewall: $($_)" -ForegroundColor Red
    }
}

# Ham chuyen mang sang Private
function Set-PrivateNetwork {
    Write-Host "`n[Network] Dang chuyen mang sang Private..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/1] Chuyen mang sang Private..." -ForegroundColor Yellow -NoNewline
        Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "└─[Success] Chuyen mang sang Private thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi chuyen mang: $($_)" -ForegroundColor Red
    }
}

# Ham cap nhat Windows
function Enable-WindowsUpdate {
    Write-Host "`n[Update] Dang cap nhat Windows..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/3] Cai dat module PSWindowsUpdate..." -ForegroundColor Yellow -NoNewline
        Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "├─[Step 2/3] Kiem tra cac ban cap nhat..." -ForegroundColor Yellow -NoNewline
        $process = Start-Process -FilePath "powershell" -ArgumentList "-Command Get-WindowsUpdate -AcceptAll -Install" -PassThru -NoNewWindow
        while (-not $process.HasExited) {
            Write-Host "." -ForegroundColor Yellow -NoNewline
            Start-Sleep -Milliseconds 500
        }
        Write-Host "`n├─[Step 3/3] Cai dat cac ban cap nhat... [Done]" -ForegroundColor Green
        Write-Host "└─[Success] Cap nhat Windows thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi cap nhat Windows: $($_)" -ForegroundColor Red
    }
}

# Ham tinh chinh Windows
function Set-HighPerformance {
    Write-Host "`n[Performance] Dang tinh chinh Windows..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/1] Chuyen sang che do High Performance..." -ForegroundColor Yellow -NoNewline
        powercfg -setactive SCHEME_MIN | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "└─[Success] Da toi uu hoa hieu suat Windows!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi tinh chinh: $($_)" -ForegroundColor Red
    }
}

# Ham don dep he thong
function Clean-System {
    Write-Host "`n[Cleanup] Dang don dep he thong..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/1] Chay cong cu don dep..." -ForegroundColor Yellow -NoNewline
        $process = Start-Process -FilePath "cleanmgr" -ArgumentList "/sagerun:1" -PassThru
        while (-not $process.HasExited) {
            Write-Host "." -ForegroundColor Yellow -NoNewline
            Start-Sleep -Milliseconds 500
        }
        Write-Host "`n└─[Success] Don dep he thong thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi don dep: $($_)" -ForegroundColor Red
    }
}

# Ham dong bo thoi gian
function Sync-Time {
    Write-Host "`n[Time] Dang dong bo thoi gian (UTC+7)..." -ForegroundColor Cyan
    try {
        Write-Host "├─[Step 1/2] Thiet lap mui gio SE Asia Standard Time..." -ForegroundColor Yellow -NoNewline
        Set-TimeZone -Id "SE Asia Standard Time" | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "├─[Step 2/2] Dong bo thoi gian voi server..." -ForegroundColor Yellow -NoNewline
        w32tm /resync | Out-Null
        Write-Host " [Done]" -ForegroundColor Green
        Write-Host "└─[Success] Dong bo thoi gian thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "`n└─[Error] Loi khi dong bo thoi gian: $($_)" -ForegroundColor Red
    }
}

# Vong lap chinh
while ($true) {
    Show-Menu
    Write-Host "`n[INPUT] Nhap lua chon: " -ForegroundColor Cyan -NoNewline
    $choice = Read-Host
    switch ($choice) {
        "1" { Activate-Windows }
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
        "13" { Install-PiNetwork }
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
