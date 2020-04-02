.\Connect-to-Azure.ps1

$location = Read-Host -prompt "Please select a location: (ex. eastus)"

$ReadhostRG = Read-Host "Create new resource group? y or n (Enter for no)"
Switch ($ReadhostRG) {
    Y {$newRg=$true}
    N {$newRg=$false}
    Default {$newRg=$false}
}

function selectRg {
    az group list --query '[].{Name:name, Location:location}' --output table

    $rgToUse = Read-Host -prompt "Select resource group from above"

    $rgExists = az group exists --name $rgToUse

    if ($rgExists -eq $false) {
        Write-Host "Resource group does not exist" -ForegroundColor Red
        selectRg
    }else {
        $global:resourceGroup = $rgToUse
        Write-Host "Resource group $resourceGroup selected."
    }
}

function createRg {
    $rgName = Read-Host -prompt "Resource group name"

    $rgAlreadyExists = az group exists --name $rgName

    if($rgAlreadyExists -eq $true) {
        Write-Host "Resource group with name $rgName already exists" -ForegroundColor Red
        createRg
    }else {
        Write-Host "Creating resource group $rgName" -ForegroundColor Yellow
        az group create --location $location --name $rgName | Out-Null
        Write-Host "Resource group $rgName created" -ForegroundColor Green
        $global:resourceGroup = $rgName
    }
}

if($newRg) {
    createRg
}else {
    selectRg
}

Write-Host "Chosen resource group:" -ForegroundColor Yellow
Write-Host $resourceGroup -ForegroundColor Green


$ReadHostcontreg = Read-Host -prompt 'Would you like to create a Container Registry? y/n (Enter for yes)'
Switch ($ReadHostcontReg) {
    Y {$contReg=$true}
    N {$contReg=$false}
    Default {$contReg=$true}
}

if($contReg){
   Invoke-Expression -Command ".\create-ACR.ps1 -resourceG $resourceGroup" 
}

$ReadHostAKS = Read-Host -prompt 'Would you like to create a cluster? y/n (Enter for yes)'
Switch ($ReadHostAKS) {
    Y {$AKS=$true}
    N {$AKS=$false}
    Default {$AKS=$true}
}

if($AKS){
   Invoke-Expression -Command ".\createAks.ps1 -resourceG $resourceGroup"
}

$ReadHostVM = Read-Host -prompt 'Would you like to create a VM for hosting agents? y/n (Enter for yes)'
Switch ($ReadHostAKS) {
    Y {$VM=$true}
    N {$VM=$false}
    Default {$VM=$true}
}

if($VM){
   Invoke-Expression -Command ".\createVM.ps1 -resourceG $resourceGroup"
}
