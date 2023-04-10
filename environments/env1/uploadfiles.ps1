Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/SMF_DMAPreReqAssessCombo_V5.8.ps1' -OutFile .\SMF_DMAPreReqAssessCombo_V5.8.ps1
Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/DMA-INPUT-FILE.xlsx' -OutFile .\DMA-INPUT-FILE.xlsx
Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/Terminate.ps1' -OutFile .\Terminate.ps1
Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/Network_Validation.ps1' -OutFile .\Network_Validation.ps1
Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/Network_Validation.xlsx' -OutFile .\Network_Validation.xlsx
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
Install-Module -Name Az.Accounts -Force
Install-Module Az.Resources -Force
Install-Module Az.Storage -Force
winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
Restart-Computer
