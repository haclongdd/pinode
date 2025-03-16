# Tu dong kiem tra va khoi dong lai script voi quyen Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Dang khoi dong lai script voi quyen Administrator..." -ForegroundColor Yellow
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

# Ham hien thi menu chinh voi tieu de va cac tuy chon
function Show-Menu {
    param ([string]$Title = "Menu Auto Setup")
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor Cyan
    Write-Host "1. Tai Pi Node / Pi Network"
    Write-Host "2. Kich hoat Windows Features"
    Write-Host "3. Kich hoat WSL va VM"
    Write-Host "4. Tai va cai dat WSL2 Kernel"
    Write-Host "5. Cap nhat WSL2"
    Write-Host "6. Cai dat Docker Desktop"
    Write-Host "7. Mo Firewall - Inbound/Outbound Rule"
    Write-Host "8. Chuyen mang sang Private"
    Write-Host "9. Cap nhat Windows"
    Write-Host "10. Tinh chinh Windows"
    Write-Host "11. Don dep he thong Windows va o C"
    Write-Host "0. Thoat"
    Write-Host "=========================================" -ForegroundColor Cyan

    # Chuoi khong dau, tach xuong dong bang nhieu lenh Write-Host
    Write-Host "TOOL DUOC TAO BOI @LONGKA25A FB: https://www.facebook.com/long.ka.79/" -ForegroundColor Yellow
    Write-Host "ANH/CHI/EM CAN HO TRO NODE - TU VAN MAY OI LAI MINH NHE -" -ForegroundColor Yellow
    Write-Host "DOI KHI E QUA TAI TROI CMT HOAC IB THI ALO 0878566247 CHO LE NHE MN." -ForegroundColor Yellow
    Write-Host "RIENG MAY AE CHAY NODE AO HAY BUG GI THI KHOI PM DO TON TIME CUA NHAU" -ForegroundColor Yellow
    Write-Host "THANKS MN DA DOC" -ForegroundColor Yellow
}

# Ham tai va cai dat Pi Network
function Install-PiNetwork {
    $piInstaller = "$env:TEMP\Pi_Network_Setup.exe"
    $url = "https://downloads.minepi.com/Pi%20Network%20Setup%200.5.0.exe"
    
    Write-Host "`n[PiNetwork] Dang tai xuong tu: $url" -ForegroundColor Green
    $webClient = New-Object System.Net.WebClient
    try {
        $webClient.DownloadFile($url, $piInstaller)
        Write-Host "[PiNetwork] Tai xuong hoan tat: $piInstaller" -ForegroundColor Green
        Write-Host "[PiNetwork] Bat dau cai dat..."
        Start-Process -FilePath $piInstaller -Wait
        Write-Host "[PiNetwork] Cai dat hoan tat!" -ForegroundColor Green
    }
    catch {
        Write-Host "[PiNetwork] Loi khi tai xuong hoac cai dat: $($_)" -ForegroundColor Red
    }
}

# Ham kich hoat cac Windows Features can thiet
function Enable-WindowsFeatures {
    Write-Host "`n[WindowsFeatures] Dang kich hoat cac tinh nang Windows..."
    $features = @(
        "NetFx3",
        "NetFx4.8",
        "Microsoft-Hyper-V-All",
        "VirtualMachinePlatform",
        "Microsoft-Windows-Subsystem-Linux"
    )
    
    foreach ($feature in $features) {
        try {
            Write-Host "[WindowsFeatures] Kich hoat $feature..."
            Start-Process powershell -ArgumentList "-Command dism.exe /online /enable-feature /featurename:$feature /all /norestart" -Verb RunAs -Wait
            Write-Host "[WindowsFeatures] $feature da duoc kich hoat." -ForegroundColor Green
        }
        catch {
            Write-Host "[WindowsFeatures] Loi khi kich hoat ${feature}: $($_)" -ForegroundColor Red
        }
    }
    Write-Host "[WindowsFeatures] Xong kich hoat. Neu can, vui long khoi dong lai he thong." -ForegroundColor Cyan
}

# Ham kich hoat WSL va VM
function Activate-WSLAndVM {
    Write-Host "`n[WSL & VM] Dang kich hoat WSL va Virtual Machine Platform..."
    try {
        Write-Host "[WSL & VM] Kich hoat Windows Subsystem for Linux..."
        Start-Process powershell -ArgumentList "-Command dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart" -Verb RunAs -Wait
        Write-Host "[WSL & VM] WSL da duoc kich hoat." -ForegroundColor Green
    }
    catch {
        Write-Host "[WSL & VM] Loi khi kich hoat WSL: $($_)" -ForegroundColor Red
    }
    
    try {
        Write-Host "[WSL & VM] Kich hoat Virtual Machine Platform..."
        Start-Process powershell -ArgumentList "-Command dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart" -Verb RunAs -Wait
        Write-Host "[WSL & VM] Virtual Machine Platform da duoc kich hoat." -ForegroundColor Green
    }
    catch {
        Write-Host "[WSL & VM] Loi khi kich hoat Virtual Machine Platform: $($_)" -ForegroundColor Red
    }
    
    # Tai va cai dat kernel WSL2
    $kernelURL = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $kernelInstaller = "$env:TEMP\wsl2kernel.msi"
    
    Write-Host "[WSL & VM] Dang tai ve goi kernel WSL2 tu: $kernelURL" -ForegroundColor Green
    try {
        Start-BitsTransfer -Source $kernelURL -Destination $kernelInstaller -DisplayName "Downloading WSL2 Kernel Update"
        Write-Host "[WSL & VM] Tai ve goi kernel hoan tat: $kernelInstaller" -ForegroundColor Green
    }
    catch {
        Write-Host "[WSL & VM] Loi khi tai ve goi kernel: $($_)" -ForegroundColor Red
        return
    }
    
    Write-Host "[WSL & VM] Bat dau cai dat goi kernel WSL2..." -ForegroundColor Green
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$kernelInstaller`" /quiet /norestart" -Wait
        Write-Host "[WSL & VM] Cai dat kernel WSL2 hoan tat!" -ForegroundColor Green
    }
    catch {
        Write-Host "[WSL & VM] Loi khi cai dat kernel: $($_)" -ForegroundColor Red
    }
}

# Ham tai va cai dat WSL2 Kernel (neu can rieng)
function Install-WSL2Kernel {
    Write-Host "`n[WSL2Kernel] Dang tai va cai dat WSL2 Kernel..."
    $kernelInstaller = "$env:TEMP\wsl2kernel.msi"
    $kernelURL = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $webClient = New-Object System.Net.WebClient
    try {
        Write-Host "[WSL2Kernel] Tai xuong tu: $kernelURL" -ForegroundColor Green
        $webClient.DownloadFile($kernelURL, $kernelInstaller)
        Write-Host "[WSL2Kernel] Tai xuong hoan tat: $kernelInstaller" -ForegroundColor Green
        Write-Host "[WSL2Kernel] Bat dau cai dat WSL2 Kernel..." -ForegroundColor Green
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$kernelInstaller`" /quiet /norestart" -Wait
        Write-Host "[WSL2Kernel] Cai dat WSL2 Kernel hoan tat!" -ForegroundColor Green
    }
    catch {
        Write-Host "[WSL2Kernel] Loi khi tai xuong hoac cai dat: $($_)" -ForegroundColor Red
    }
}

# Ham cap nhat WSL2
function Update-WSL2 {
    Write-Host "`n[WSL2] Dang cap nhat WSL2..." -ForegroundColor Green
    try {
        wsl --update
        Write-Host "[WSL2] Cap nhat WSL2 thanh cong!" -ForegroundColor Green
    }
    catch {
        Write-Host "[WSL2] Loi khi cap nhat WSL2: $($_)" -ForegroundColor Red
    }
}

# Ham cai dat Docker Desktop
function Install-Docker {
    Write-Host "`n[Docker] Dang tai va cai dat Docker Desktop..."
    $dockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
    $dockerURL = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    $webClient = New-Object System.Net.WebClient
    try {
        Write-Host "[Docker] Tai xuong tu: $dockerURL" -ForegroundColor Green
        $webClient.DownloadFile($dockerURL, $dockerInstaller)
        Write-Host "[Docker] Tai xuong hoan tat: $dockerInstaller" -ForegroundColor Green
        Write-Host "[Docker] Bat dau cai dat Docker Desktop..." -ForegroundColor Green
        Start-Process -FilePath $dockerInstaller -Wait
        Write-Host "[Docker] Cai dat Docker Desktop hoan tat!" -ForegroundColor Green
    }
    catch {
        Write-Host "[Docker] Loi khi tai xuong hoac cai dat: $($_)" -ForegroundColor Red
    }
}

# Ham cau hinh Firewall (Inbound Rule) mo cong 31400-31409
# Ham cau hinh Firewall (Inbound va Outbound Rule) mo cong 31400-31409
function Configure-Firewall {
    Write-Host "`n[Firewall] Dang cau hinh Firewall (Inbound & Outbound Rule) mo cong 31400-31409..."
    try {
        # Inbound Rule
        Write-Host "[Firewall] Cau hinh Inbound Rule..." -ForegroundColor Yellow
        New-NetFirewallRule -DisplayName "Allow MyApp Inbound" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 31400-31409 -Profile Any
        Write-Host "[Firewall] Cau hinh Inbound Rule hoan tat!" -ForegroundColor Green
        
        # Outbound Rule
        Write-Host "[Firewall] Cau hinh Outbound Rule..." -ForegroundColor Yellow
        New-NetFirewallRule -DisplayName "Allow MyApp Outbound" -Direction Outbound -Action Allow -Protocol TCP -LocalPort 31400-31409 -Profile Any
        Write-Host "[Firewall] Cau hinh Outbound Rule hoan tat!" -ForegroundColor Green
        
        Write-Host "[Firewall] Cau hinh Firewall hoan tat cho ca Inbound va Outbound!" -ForegroundColor Green
    }
    catch {
        Write-Host "[Firewall] Loi khi cau hinh Firewall: $($_)" -ForegroundColor Red
    }
}
# Ham chuyen doi cau hinh mang sang Private
function Set-PrivateNetwork {
    Write-Host "`n[Network] Dang chuyen doi cau hinh mang sang Private..."
    try {
        $networks = Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq "Public" }
        foreach ($net in $networks) {
            Set-NetConnectionProfile -InterfaceAlias $net.InterfaceAlias -NetworkCategory Private
            Write-Host "[Network] Da chuyen $($net.InterfaceAlias) sang Private." -ForegroundColor Green
        }
        if ($networks.Count -eq 0) {
            Write-Host "[Network] Khong co ket noi Public nao can chuyen." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[Network] Loi khi chuyen doi cau hinh mang: $($_)" -ForegroundColor Red
    }
}

# Ham bat Windows Update va cau hinh tu dong cap nhat
function Enable-WindowsUpdate {
    Write-Host "`n[WindowsUpdate] Dang bat Windows Update va cau hinh tu dong cap nhat..."
    try {
        Set-Service -Name wuauserv -StartupType Automatic
        Start-Service -Name wuauserv
        Write-Host "[WindowsUpdate] Windows Update da duoc bat va cau hinh tu dong cap nhat." -ForegroundColor Green
    }
    catch {
        Write-Host "[WindowsUpdate] Loi khi cau hinh Windows Update: $($_)" -ForegroundColor Red
    }
}

# Ham chuyen sang High Performance, turn off hard disk after = never
function Set-HighPerformance {
    Write-Host "`n[PowerOption] Dang chuyen sang High Performance (turn off hard disk after = never)..."
    try {
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        Write-Host "[PowerOption] Da chuyen sang High Performance." -ForegroundColor Green
        
        powercfg -x -disk-timeout-ac 0
        powercfg -x -disk-timeout-dc 0
        Write-Host "[PowerOption] Turn off hard disk after = never (AC/DC)!" -ForegroundColor Green
    }
    catch {
        Write-Host "[PowerOption] Loi khi chuyen sang High Performance: $($_)" -ForegroundColor Red
    }
}

# Ham don dep he thong Windows va o C
function Clean-System {
    Write-Host "`n[CleanSystem] Dang don dep he thong Windows va o C..."
    try {
        Write-Host "[CleanSystem] Dang xoa file tam trong %TEMP%..."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "[CleanSystem] Dang xoa Recycle Bin..."
        Clear-RecycleBin -Force -Confirm:$false
        
        Write-Host "[CleanSystem] Dang chay DISM StartComponentCleanup..."
        Start-Process powershell -ArgumentList "-Command DISM.exe /Online /Cleanup-Image /StartComponentCleanup /NoRestart" -Verb RunAs -Wait
        
        Write-Host "[CleanSystem] Don dep hoan tat!" -ForegroundColor Green
    }
    catch {
        Write-Host "[CleanSystem] Loi khi don dep: $($_)" -ForegroundColor Red
    }
}

# Vong lap chinh
while ($true) {
    Show-Menu
    $choice = Read-Host "`nChon mot tuy chon"
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
        "0" {
            Write-Host "`nThoat chuong trinh. Hen gap lai!" -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "`nLua chon khong hop le. Vui long thu lai!" -ForegroundColor Red
        }
    }
    Write-Host "`nNhan Enter de tiep tuc..."
    [void](Read-Host)
}
