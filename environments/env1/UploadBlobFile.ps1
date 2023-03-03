param(
    [string]
    $Resourcegroupname,
    
    [string]
    $uri
)

if ((Get-Module -ListAvailable Az.Accounts) -eq $null)
	{
       Install-Module -Name Az.Accounts -Force
    }

$bacpacFileName = "AdventureWorksLT2019.bak";
$storageaccount = Get-AzStorageAccount -ResourceGroupName $Resourcegroupname;
$storageaccountkey = Get-AzStorageAccountKey -ResourceGroupName $Resourcegroupname -Name $storageaccount.StorageAccountName[1];

$ctx = New-AzStorageContext -StorageAccountName $storageaccount.StorageAccountName[1] -StorageAccountKey $storageaccountkey.Value[0]

Invoke-WebRequest -Uri $uri -OutFile $bacpacFileName 
Set-AzStorageBlobContent -File $bacpacFileName -Container "backup" -Blob 'AdventureWorksLT2019' -Context $ctx
