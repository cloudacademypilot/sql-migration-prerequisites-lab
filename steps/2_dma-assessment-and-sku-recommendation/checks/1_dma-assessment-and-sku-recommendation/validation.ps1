param(
    [string]
    $Resourcegroupname
)

$StorageAccountNames = Get-AzStorageAccount -ResourceGroupName $Resourcegroupname
$StorageAccountName = $StorageAccountNames[0].StorageAccountName

$key = (Get-AzStorageAccountKey -Resourcegroupname $Resourcegroupname -Name $StorageAccountName)[0].Value
$context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key

$Files = Get-AzStorageBlob -Container 'backup' -Context $context

if($Files){
    Write-Host "DMA Assessment step is completed"
}
else{
    Write-Host "DMA Assessment step is not completed"
}
