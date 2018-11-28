###############################################################
#                                                             #
# Create Virtual Machine from existing dist (ResourceManager) #
#                                                             #
###############################################################
function Create-VmFromExistingDisk(
		[string]$vmSuffix,  
		[string]$nicPrefix = "NET",
		[string]$ipPrefix = "IP",
		[string]$stName,  		   
		[string]$locName = "westeurope", 
		[string]$rgName = "AZURERM", 		   
		[string]$vmSize,
		[string]$subnetName,
		[string]$vNETName = "VNET-AZURERM",
        [string]$ipAddress
) 
{	
	#generate names for components
	$vmName = $rgName + "-" + $vmSuffix
	Write-Host "Virtual Machine : $vmName"
	$nicName = $nicPrefix + "-" + $vmSuffix
	Write-Host "Network Interface: $nicName"
	$ipName = $ipPrefix + "-" + $vmSuffix
	Write-Host "Public IP Address: $ipName"
	
	#create IP Address
	$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Static 
	Write-Host "Public IP Address created."
	
	#create network interface
	$vnet = Get-AzureRmVirtualNetwork -Name $vNETName -ResourceGroupName $rgName
	$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
	$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $subnet.Id -PublicIpAddressId $pip.Id -PrivateIpAddress $ipAddress
	Write-Host "Network Interface created."
	
	#create VM
	$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
	Write-Host "Start creating vm $vmName as $vmSize"
	$compName = $vmName
	
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
	Write-Host "Network Interface added"

	#create os disk
	$osDiskName = $vmname+'_osDisk'
	$osDiskCaching = 'ReadWrite'
	$osDiskVhdUri = "https://$stName.blob.core.windows.net/vhds/"+$vmname+"_os.vhd"
    $vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $osDiskVhdUri -name $osDiskName -CreateOption attach -Windows -Caching $osDiskCaching
	Write-Host "Disk created."
	
	New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm -Verbose -Debug
	Write-Host "Virtual Machine created."
}

###############################################################
#                                                             #
# Create Virtual Machine (ResourceManager) #
#                                                             #
###############################################################
function Create-VM(
        [string]$vmSuffix, 
        [string]$vmPrefix = "AZR", 
		[string]$nicPrefix = "NET",
		[string]$ipPrefix = "IP",
		[string]$stName,  		   
		[string]$locName = "westeurope", 
		[string]$rgName = "CABIMED", 		   
		[string]$vmSize,
		[string]$subnetName = "default",
		[string]$vNETName = "Cabimed-vnet",
        [string]$ipAddress,
        [string]$skus = "2016-Datacenter"
)
{
	$cred = Get-Credential -Message "Type the name and password of the local administrator account."
	
	#generate names for components
	$vmName = $vmPrefix + "-" + $vmSuffix
	Write-Host "Virtual Machine : $vmName"
	$nicName = $nicPrefix + "-" + $vmSuffix
	Write-Host "Network Interface: $nicName"
	$ipName = $ipPrefix + "-" + $vmSuffix
	Write-Host "Public IP Address: $ipName"
	
	#create IP Address
	$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Static 
	Write-Host "Public IP Address created."
	
	#create network interface
	$vnet = Get-AzureRmVirtualNetwork -Name $vNETName -ResourceGroupName $rgName
	$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
	$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $subnet.Id -PublicIpAddressId $pip.Id -PrivateIpAddress $ipAddress
	Write-Host "Network Interface created."
	
	#create VM
	$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
	Write-Host "Start creating vm $vmName as $vmSize"
	$compName = $vmName
	$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $compName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

    ##################################  GET SKUS #################################################################################
    #PS C:\Windows\System32\WindowsPowerShell\v1.0> Get-AzureRmVMImageSku -Location westeurope -PublisherName MicrosoftWindowsServer -Offer WindowsServer | Select Skus
	#Skus
	#----
	#2008-R2-SP1
	#2008-R2-SP1-BYOL
	#2012-Datacenter
	#2012-Datacenter-BYOL
	#2012-R2-Datacenter
	#2012-R2-Datacenter-BYOL
	#2016-Datacenter
	#2016-Datacenter-Server-Core
	#2016-Datacenter-with-Containers
	#2016-Nano-Server
	#2016-Nano-Server-Technical-Preview
	#2016-Technical-Preview-with-Containers
	#Windows-Server-Technical-Preview
    ##############################################################################################################################

	$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus $skus -Version "latest"

	$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
	Write-Host "Network Interface added"
	
	#create os disk
	$osDiskName = $vmname+'_osDisk'
	$osDiskCaching = 'ReadWrite'
	$osDiskVhdUri = "https://$stName.blob.core.windows.net/vhds/"+$vmname+"_os.vhd"
	$vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $osDiskVhdUri -name $osDiskName -CreateOption fromImage -Caching $osDiskCaching 
	Write-Host "Disk created."
	
	New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm
	Write-Host "Virtual Machine created."
}

###############################################################
#                                                             #
# Rename VHD												  #
#                                                             #
###############################################################
function Rename-Vhd (
		   [string]$subscriptionName = "BizSpark",  
		   [string]$storageAccountName, 
		   [string]$storageAccountKey,  		   
		   [string]$srcContainerName = "vhds", 
		   [string]$dstContainerName = "vhds", 		   
		   [string]$srcBlob,
		   [string]$dstBlob 
	) 
{	
	Login-AzureRMAccount 
	Select-AzureRmSubscription -SubscriptionName $subscriptionName 
	 
	$Context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey  
	Start-AzureStorageBlobCopy -SrcContainer $srcContainerName -DestContainer $dstContainerName -SrcBlob $srcBlob -DestBlob $dstBlob -Context $Context -DestContext $Context 
	Remove-AzureStorageBlob -Container $srcContainerName -Context $Context -Blob $srcBlob 
}

###############################################################
#                                                             #
# Add DNS Server											  #
# https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-static-private-ip-arm-ps/
###############################################################
function Add-DNSServer(
    [string]$nicName,
    [string]$rgName,
    [string]$ipAddress
)
{
    $nic=Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName
    $nic.DnsSettings[0].DnsServers = $ipAddress
    Set-AzureRmNetworkInterface -NetworkInterface $nic
}

###############################################################
#                                                             #
# Create storage											  #
# 															  #
###############################################################
function Create-Storage(
	[string]$rgName,
	[string]$storageName,
	[string]$location = "West Europe",
	[string]$skuName
) 
{
    Login-AzureRmAccount

	$StorageAccount = @{
		ResourceGroupName = $rgName;
		Name = $storageName;
		SkuName = $skuName;
		Location = $location;
    }
	New-AzureRmStorageAccount @StorageAccount;
	
	### Obtain the Storage Account authentication keys using Azure Resource Manager (ARM)
	$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rgName -Name $storageName;

	### Use the Azure.Storage module to create a Storage Authentication Context
	$StorageContext = New-AzureStorageContext -StorageAccountName $storageName -StorageAccountKey $Keys[0].Value;
	
	### Create a Blob Container in the Storage Account
	New-AzureStorageContainer -Context $StorageContext -Name 'vhds';
}

