param(
    [string]
    $userName,
	
	[string]
	$password
)

if ((Get-Command Install-PackageProvider -ErrorAction Ignore) -eq $null)
{
	# Load the latest SQL PowerShell Provider
	(Get-Module -ListAvailable SQLPS `
		| Sort-Object -Descending -Property Version)[0] `
		| Import-Module;
}
else
{
	# Conflicts with SqlServer module
	Remove-Module -Name SQLPS -ErrorAction Ignore;

	if ((Get-Module -ListAvailable SqlServer) -eq $null)
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; 
		Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null;
		Install-Module -Name SqlServer -Force -AllowClobber | Out-Null;
	}

	# Load the latest SQL PowerShell Provider
	Import-Module -Name SqlServer;
}

$fileList = Invoke-Sqlcmd `
                    -QueryTimeout 0 `
                    -ServerInstance . `
                    -UserName $username `
                    -Password $password `
                    -Query "restore filelistonly from disk='$($pwd)\AdventureWorksLT2019.bak'";

# Create move records for each file in the backup
$relocateFiles = @();
$relocateFilesForoffline = @();

foreach ($nextBackupFile in $fileList)
{
    # Move the file to the default data directory of the default instance
    $nextBackupFileName = Split-Path -Path ($nextBackupFile.PhysicalName) -Leaf;
    $relocateFiles += New-Object `
        Microsoft.SqlServer.Management.Smo.RelocateFile( `
            $nextBackupFile.LogicalName,
            "$env:temp\$($nextBackupFileName)");
}

foreach ($nextBackupFile in $fileList)
{
    # Move the file to the default data directory of the default instance
    $nextBackupFileName = Split-Path -Path ($nextBackupFile.PhysicalName) -Leaf;
    $relocateFilesForoffline += New-Object `
        Microsoft.SqlServer.Management.Smo.RelocateFile( `
            $nextBackupFile.LogicalName,
            "F:\Data\$($nextBackupFileName)");
}

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
Restore-SqlDatabase `
	-ReplaceDatabase `
	-ServerInstance . `
	-Database "SampleDatabase1" `
	-BackupFile "$pwd\AdventureWorksLT2019.bak" `
	-RelocateFile $relocateFiles `
	-Credential $credentials; 
Restore-SqlDatabase `
	-ReplaceDatabase `
	-ServerInstance . `
	-Database "SampleDatabase2" `
	-BackupFile "$pwd\AdventureWorksLT2019.bak" `
	-RelocateFile $relocateFilesForoffline `
	-Credential $credentials;
	
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
Restart-Computer
