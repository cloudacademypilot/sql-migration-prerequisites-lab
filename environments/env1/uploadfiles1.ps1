winrm quickconfig -Force
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
Restart-Computer
