Param(
    [parameter(Mandatory=$false)][String]$global:rg
)

Write-Host 'Create Azure Container Registry (ACR):' -ForegroundColor Green


function regName {
    $global:RegName = Read-Host -prompt 'Name for your Container Registry (Enter for myACR)'
    if ([string]::IsNullOrWhiteSpace($RegName)){
        $global:RegName = 'myACR'
    }

    if($(az acr check-name -n $RegName --query nameAvailable) -eq $false){
        Write-Host 'Navnet finnes fra før' -ForegroundColor Red
        regName
    }
}

function selectRg {
    az group list --query '[].{Name:name, Location:location}' --output table

    $rgToUse = Read-Host -prompt "Select resource group from above"

    $rgExists = az group exists --name $rgToUse

    if ($rgExists -eq $false) {
        Write-Host "Resource group does not exist" -ForegroundColor Red
        selectRg
    }else {
        $global:rg=$rgToUse
        Write-Host "Resource group selected."
    }
}

function sku {
    $global:sku = Read-Host -prompt 'Choose SKU-type (Basic/Standard/Premium Enter for Basic)'
        if ([string]::IsNullOrWhiteSpace($sku)){
            $global:sku = 'Basic'
        }
        if ($sku -ne 'Basic' -and $sku -ne 'Standard' -and $sku -ne 'Premium') {
            Write-Host $sku 'is not a choose' -ForegroundColor red
            sku
        }
}

#Run the functions above
regName


if ([string]::IsNullOrWhiteSpace($rg)){
    selectRg
}

sku

$adminEnabled = Read-Host 'Do you want to enable admin user? y/n (Enter for Yes)'
Switch ($adminEnabled) {
    Y {$adminUser=$true}
    N {$adminUser=$false}
    Default {$adminUser=$true}
}

az acr create -g $rg -n $RegName --sku $sku --admin-enabled $adminUser

Write-Host 'ACR' $RegName 'has been created in Resource Group' $rg -ForegroundColor Green
