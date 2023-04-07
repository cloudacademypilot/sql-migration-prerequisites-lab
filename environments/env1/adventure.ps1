Invoke-WebRequest 'https://raw.githubusercontent.com/CSLabsInternal/sql-migration-prerequisites-lab/main/environments/env1/adventure.zip' -OutFile .\adventure.zip
Move-Item -Path C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.15\Downloads\0\adventure.zip -Destination C:\adventure.zip
