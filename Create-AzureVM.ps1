$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

. "$env:dp0\Functions.ps1"

Connect-AzureRmAccount

Create-VM -vmSuffix "DCO01" -vmSize "Standard_D1_v2" -stName "cabimedstandard"


############################ OLD ##########################################

Create-VM -vmSuffix "DC1" -vmSize "Standard_D1_v2" -stName "azurermstandard" -subnetName "subnet-DC"
Create-VM -vmSuffix "RDP1" -vmSize "Standard_DS11_v2" -stName "azurermpremium" -subnetName "subnet-CLNT"
Create-VM -vmSuffix "RDP2" -vmSize "Standard_DS11_v2" -stName "azurermpremium" -subnetName "subnet-CLNT" -skus "2016-Datacenter" 
Create-VM -vmSuffix "SQL1" -vmSize "Standard_DS2_v2" -stName "azurermstandard" -subnetName "subnet-SQL"
Create-VM -vmSuffix "SQL2" -vmSize "Standard_DS2_v2" -stName "azurermstandard" -subnetName "subnet-SQL"
Create-VM -vmSuffix "SP1" -vmSize "Standard_DS2_v2" -stName "azurermstandard" -subnetName "subnet-SP" 
Create-VM -vmSuffix "SP2" -vmSize "Standard_DS2_v2" -stName "azurermstandard" -subnetName "subnet-SP" 
Create-VM -vmSuffix "MEDI" -vmSize "Standard_DS11_v2" -stName "azurermstandard" -subnetName "subnet-CLNT"
Create-VM -vmSuffix "SRV16NA" -vmSize "Standard_DS11_v2" -stName "azurermstandard" -subnetName "subnet-CLNT" -skus "2016-Nano-Server-Technical-Preview"
Create-VM -vmSuffix "SRV16TP" -vmSize "Standard_DS11_v2" -stName "azurermstandard" -subnetName "subnet-CLNT" -skus "Windows-Server-Technical-Preview"
Create-VM -vmSuffix "SQLSP1" -vmSize "Standard_DS11_v2" -stName "azurermstandard" -subnetName "subnet-SP" 
Create-VM -vmSuffix "DMZ01" -vmSize "Standard_D11_v2" -stName "azurermstandard" -subnetName "subnet-SP" 
Create-VM -vmSuffix "ADFS1" -vmSize "Standard_D1_v2" -stName "azurermstandard" -subnetName "subnet-DC"

Create-Vm -vmSuffix "CLNT1" -vmSize "Standard_DS2_v2" -stName "azurermstandard1" -subnetName "subnet-CLNT"

#### STORAGE
Create-Storage -rgName "AZURERM" -storageName "azurermstandard1" -skuName "Standard_LRS"
Create-Storage -rgName "AZURERM" -storageName "azurermpremium1" -skuName "Standard_LRS"

#### Create-VmFromExistingDisk
Create-VmFromExistingDisk -vmSuffix "DC1" -vmSize "Standard_D1_v2" -stName "azurermstandard" -subnetName "subnet-DC"
Create-VmFromExistingDisk -vmSuffix "RDP2" -vmSize "Standard_DS11_v2" -stName "azurermpremium" -subnetName "subnet-CLNT" 



