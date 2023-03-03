param(
    [string]
    $Resourcegroupname
)

if ((Get-Module -ListAvailable Az.DataMigration) -eq $null)
	{
       Install-Module -Name Az.DataMigration -RequiredVersion 0.7.4 -Force
    }

$dmsinstance = Get-AzDataMigrationSqlServiceMigration -ResourceGroupName $Resourcegroupname -SqlMigrationServiceName "onlinedms";
$resultonline = $dmsinstance.MigrationStatus;

if ($resultonline -eq "Succeeded") { 
    Write-Host "online migration activity completed" }
else { Write-Host "Please complete online migration activity" }

$dmsinstance = Get-AzDataMigrationSqlServiceMigration -ResourceGroupName $Resourcegroupname -SqlMigrationServiceName "offlinedms";
$resultoffline = $dmsinstance.MigrationStatus;

if ($resultoffline -eq "Succeeded") { 
    Write-Host "offline migration activity completed" }
else { Write-Host "Please complete offline migration activity" }



