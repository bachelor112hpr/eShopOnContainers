Param(
    [parameter(Mandatory=$false)][String]$rg,
    [parameter(Mandatory=$false)][String]$vmName,
    [parameter(Mandatory=$false)][String]$userName
)

$ipAddress = az vm show -d -g $rg -n $vmName --query publicIps -o tsv

$sshName = $userName+'@'+$ipAddress

Write-Host "Passing config script for the agents to virtual machine..." -ForegroundColor Yellow

scp $pwd\LinuxAgentHost.sh $sshName":/home/$userName/."

Write-Host "Please login to the virtual machine..." -ForegroundColor Yellow

ssh $sshName