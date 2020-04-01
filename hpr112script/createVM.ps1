Param(
    [parameter(Mandatory=$false)][String]$resourceG
)

$global:rg = $resourceG

Install-Module -Name Az.Network -RequiredVersion 2.4.0
Install-Module -Name Az.Compute -RequiredVersion 3.6.0
Install-Module -Name Az -AllowClobber
Connect-AzAccount

Write-Host '
##################################
# Create Linux VM to host agents # 
##################################'-ForegroundColor Green


#Select Resource Group
function selectRg {
    $rgList = az group list --query '[].{Name:name, Location:location}' --output table
    Write-Host $rgList

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


#Network configuration
function netConfig {

    $subnetName = $rg+'Subnet'+$vmName
    $vnetName = $rg+'VNET'+$vmName
    $pipName = $vmName+$(Get-Random)
    $sshRuleName = $vmName+'nsgSHHRule'
    $webRuleName = $vmName+'wwwRule'
    $nsgName = $vmName+'SG'
    $nicName = $vmName+'Nic'

   # Create a subnet configuration
    $subnetConfig = New-AzVirtualNetworkSubnetConfig `
      -Name $subnetName `
      -AddressPrefix 192.168.1.0/24

    # Create a virtual network
    $vnet = New-AzVirtualNetwork `
      -ResourceGroupName $rg `
      -Location $location `
      -Name $vnetName `
      -AddressPrefix 192.168.0.0/16 `
      -Subnet $subnetConfig

   # Create a public IP address and specify a DNS name
    $pip = New-AzPublicIpAddress `
      -ResourceGroupName $rg `
      -Location $location `
      -AllocationMethod Static `
      -IdleTimeoutInMinutes 4 `
      -Name $pipName
    
   # Create an inbound network security group rule for port 22
    $nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
      -Name $sshRuleName `
      -Protocol "Tcp" `
      -Direction "Inbound" `
      -Priority 1000 `
      -SourceAddressPrefix * `
      -SourcePortRange * `
      -DestinationAddressPrefix * `
      -DestinationPortRange 22 `
      -Access "Allow"

   # Create an inbound network security group rule for port 80
    $nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
      -Name $webRuleName `
      -Protocol "Tcp" `
      -Direction "Inbound" `
      -Priority 1001 `
      -SourceAddressPrefix * `
      -SourcePortRange * `
      -DestinationAddressPrefix * `
      -DestinationPortRange 80 `
      -Access "Allow"
    
   #Create a network security group
    $nsg = New-AzNetworkSecurityGroup `
      -ResourceGroupName $rg `
      -Location $location `
      -Name $nsgName `
      -SecurityRules $nsgRuleSSH,$nsgRuleWeb

   #Create a virtual network card and associate with public IP address and NSG
    $global:nic = New-AzNetworkInterface `
      -Name $nicName `
      -ResourceGroupName $rg `
      -Location $location `
      -SubnetId $vnet.Subnets[0].Id `
      -PublicIpAddressId $pip.Id `
      -NetworkSecurityGroupId $nsg.Id
}

#Disk configuration
function diskConfig {
    $global:diskName = $vmName+'DataDisk'

    $diskConfig = New-AzDiskConfig `
    -Location $location `
    -CreateOption Empty `
    -DiskSizeGB 64

    $global:dataDisk = New-AzDisk `
    -ResourceGroupName $rg `
    -DiskName $diskName `
    -Disk $diskConfig
}

#Credential object
function cred {
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $global:cred = New-Object System.Management.Automation.PSCredential ($userName, $securePassword)
}

#VM configuration
function vmConfig {
    $vmConfig = New-AzVMConfig  `
    -VMName $vmName `
    -VMSize "Standard_B2ms" | `
    Set-AzVMOperatingSystem `
    -Linux `
    -ComputerName $vmName `
    -Credential $cred | `
    Set-AzVMSourceImage `
    -PublisherName "Canonical" `
    -Offer "UbuntuServer" `
    -Skus "18.04-LTS" `
    -Version "latest" | `
    Add-AzVMNetworkInterface `
    -Id $nic.Id | `
    Add-AzVMDataDisk `
    -Name $diskName `
    -CreateOption Attach `
    -ManagedDiskId $dataDisk.Id `
    -Lun 1

    return $vmConfig
}


Write-Host 'Information about your VM:' -ForegroundColor Green
$vmName = Read-Host -prompt 'Name your VM'
$userName = Read-Host -prompt 'Username for Linux login'
$password = Read-Host -prompt 'Password'
$location = Read-Host -prompt 'Select location'

if ([string]::IsNullOrWhiteSpace($rg)) {
    selectRg
}

netConfig
Write-Host "Network configured" -ForegroundColor Green

diskConfig
Write-Host "Disks configured" -ForegronudColor Green

cred
Write-Host "Credentials configured" -ForegroundColor Green

$vmConf = vmConfig

Write-Host "Creating virtual machine..." -ForegroundColor Yellow
New-AzVM -ResourceGroupName $rg -VM $vmConf -Location $location
Write-Host "Virtual machine created. Login." -ForegroundColor Green

Invoke-Expression -Command ".\vmLogin.ps1 -rg $resourceGroup -vmName $vmName -userName $userName"