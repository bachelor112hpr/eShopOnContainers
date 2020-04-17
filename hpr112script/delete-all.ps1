Param(
    [parameter(Mandatory=$false)][string]$rg,
    [parameter(Mandatory=$false)][string]$name,
    [parameter(Mandatory=$false)][string]$namespace="default"
)

$specifyCluster=$false

# Makes sure that both cluster name and resource group are filled out
if(-not [string]::IsNullOrEmpty($rg) -or -not [string]::IsNullOrEmpty($name)) {
    $specifyCluster=$true
    if([string]::IsNullOrEmpty($rg) -or [string]::IsNullOrEmpty($name)) {
        Write-Host "Error: must use -rg and -name when specifying cluster" -ForegroundColor Red
        exit 1
    }
}

# Get credentials from cluster if specified
if($specifyCluster) {
    az aks Get-Credentials -n $name -g $rg

    # If error in command Get-Credentials
    if (!$?) {
        Write-Host "Error: wrong cluster name or resource group" -ForeGoundColor Red
        exit 1
    }
}


Write-Host "Deleting all in cluster $name in resource group $rg"

# Things to be deleted from the cluster
$contents = ("deployments", "pods", "secrets", "replicasets", "configmaps", "ingresses", "services", "hpa")

foreach ($content in $contents) {
    kubectl delete --all $content --namespace=$namespace
    Write-Host "All $content deleted from namespace $namespace" -ForegroundColor Green
}
