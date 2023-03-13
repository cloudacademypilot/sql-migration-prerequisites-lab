Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/Network_Validation.ps1' -OutFile .\Network_Validation.ps1
Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/Network_Validation.xlsx' -OutFile .\Network_Validation.xlsx
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
Install-Module -Name Az.Accounts -Force
Install-Module Az.Resources -Force
Install-Module Az.Storage -Force
Restart-Computer
