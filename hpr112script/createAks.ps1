Param(
    [parameter(Mandatory=$false)][String]$resourceG
)

$global:rg = $resourceG

Write-Host "Creating Azure Kubernetes Service" -ForegroundColor Yellow

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
    az aks create --resource-group $rg --name $clusterName --node-count $minNodes --enable-cluster-autoscaler --min-count $minNodes --max-count $maxNodes --enable-addons monitoring,http_application_routing --generate-ssh-keys
    Write-Host "Cluster created." -ForegroundColor Green
}else {
    $nodes = Read-Host -prompt "Select number of nodes in the cluster"
    Write-Host "Creating cluster with $nodes nodes. This may take a while..." -ForegroundColor Yellow

    $sp = az ad sp create-for-rbac --skip-assignment --query '[appId, password]'
    $spId = $sp[1].Trim(",", " ")
    $spSecret = $sp[2].Trim(" ")

    Write-Host "SP created:"
    Write-Host "ID: "+$spId
    Write-Host "Secret: "+$spSecret

    Start-Sleep 10

    az aks create --resource-group $rg --name $clusterName --node-count $nodes --enable-addons monitoring,http_application_routing --generate-ssh-keys --service-principal $spId --client-secret $spSecret
    Write-Host "Cluster created." -ForegroundColor Green
}

Start-Sleep 5
