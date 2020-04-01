$rebootReq = $false

#Install azCLI if not installed
	if (-not (Get-Command az -ErrorAction Ignore)) {
        Write-Host "AzureCLI not installed. Installing now..." -ForegroundColor Green
        Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
        $rebootReq = $true
        Write-Host "AzureCLI is installed." -ForegroundColor Green
    }else {
        Write-Host "AzureCLI is already installed." -ForegroundColor Green
    }

#Install NuGet if not installed
    Write-Host "NuGet is not installed. Installing now..." -ForegroundColor Green
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

#Install kubectl if not installed
	if (-not (Get-Command kubectl -ErrorAction Ignore)) {
        Write-Host "Kubectl is not installed. Installing now..." -ForegroundColor Yellow
        Install-Script -Name install-kubectl -Scope CurrentUser -Force

	    Write-Host 'Set rights to run script...'
	    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
  
	    Write-Host 'Running script install-kubectl.ps1...'

	    install-kubectl.ps1 -DownloadLocation C:\kubectl

	    Write-Host 'Adding $pathToKubectl to Envirement-variable...' -ForegroundColor Green
	    $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
	    $newpath = $oldpath+";C:\kubectl"
	    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
        Write-Host 'Envirement-variable PATH now includes C:\kubectl' -ForegroundColor Green
        $rebootReq = $true
        Write-Host "Kubectl is now installed." -ForegroundColor Green
    }else {
        Write-Host "Kubectl is already installed." -ForegroundColor Green
    }

    if($rebootReq){
        Write-Host 'Systemrestart required. Rebooting now...' -ForegroundColor Yellow
        Start-Sleep 30
        Restart-Computer
    }
