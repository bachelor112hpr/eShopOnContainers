Param(
    [parameter(Mandatory=$false)][string]$global:rg
)

function clusterName {
    $name = Read-Host -prompt "Type in the cluster name"

    $clusterExists = az aks show -g "eShopRG" -n $name --query "name" -o tsv 2> $null

    if ($name -eq $clusterExists) {
        Write-Host "A cluster with that name already exists." -ForegroundColor Red
        return clusterName
    }else {
        Write-Host "Cluster name is available" -ForegroundColor Yellow
        return $name
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
        $global:rg = $rgToUse
        Write-Host "Resource group $rg selected."
    }
}


if ([string]::IsNullOrWhiteSpace($rg)) {
    selectRg
}

$clusterName = clusterName

$promptAutoscaling = Read-Host "Enable cluster autoscaler? y or n (Enter for no)"
Switch($promptAutoscaling) {
    Y {$enableAutoscaling = $true}
    N {$enableAutoscaling = $false}
    Default {$enableAutoscaling = $false}
}

if($enableAutoscaling) {
    $minNodes = Read-Host -prompt "Select a minimum number of nodes"
    $maxNodes = Read-Host -prompt "Select a maximum number of nodes"

    Write-Host "Creating clutser with autoscaler. Min: $minNodes Max: $maxNodes. This may take a while..." -ForegroundColor Yellow
    Write-Host "Using resource group: $rg"
    Write-Host "Maxnodes: $maxNodes"
    Write-Host "Minnodes: $minNodes"
    az aks create --resource-group $rg --name $clusterName --node-count $minNodes --enable-cluster-autoscaler --min-count $minNodes --max-count $maxNodes --enable-addons monitoring,http_application_routing --generate-ssh-keys
    Write-Host "Cluster created." -ForegroundColor Green
    Start-Sleep 5
}else {
    $nodes = Read-Host -prompt "Select number of nodes in the cluster"

    Write-Host "Creating cluster with $nodes nodes. This may take a while..." -ForegroundColor Yellow
    az aks create --resource-group $rg --name $clusterName --node-count $nodes --enable-addons monitoring,http_application_routing --generate-ssh-keys
    Write-Host "Cluster created." -ForegroundColor Green
    Start-Sleep 5
}