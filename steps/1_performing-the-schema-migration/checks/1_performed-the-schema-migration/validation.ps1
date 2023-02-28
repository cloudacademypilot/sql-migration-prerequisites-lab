param(
    [string]
    $Resourcegroupname
)

if ((Get-Module -ListAvailable Az.DataMigration) -eq $null)
	{
       Install-Module -Name Az.DataMigration -RequiredVersion 0.7.4 -Force
    }

$dmsinstance = Get-AzResource -ResourceGroupName $Resourcegroupname -ResourceType Microsoft.DataMigration/services;
$dmsname = $dmsinstance.Name;

$schemamigrationactivity = Get-AzDataMigrationTask -TaskName Schemaonlymigrationactivity -ServiceName $dmsname -ResourceGroupName $Resourcegroupname -ProjectName SqlToSqlDbMigrationProject -Expand;
$resultfromigration = $schemamigrationactivity.ProjectTask.Properties.State;

if ($resultfromigration -eq "Succeeded") { 
    Write-Host "schema only migration activity completed" }
else { Write-Host "Please complete schema only migration activity" }
