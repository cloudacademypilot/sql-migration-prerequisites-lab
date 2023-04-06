function exitCode{
    Write-Host "-Ending Execution"
    exit
}

function createFolder([string]$newFolder) {
    if(Test-Path $newFolder)
    {
        Write-Host "-Folder'$newFolder' Exist..."
    }
    else
    {
        New-Item $newFolder -ItemType Directory
        Write-Host "-$newFolder folder created..."
    }
}

function Test-PrivateIP {
    
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [string]
        $IP
    )
    process {

        if ($IP -Match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)') {
            return "PRIVATE"
        }
        else {
           return "PUBLIC"
        }
    }    
}



$folder = $PSScriptRoot
createFolder $folder\Downloads\
createFolder $folder\Output\

#Check for ImportExcel module
Write-Host "Checking for ImportExcel Module"
if((Get-Module -ListAvailable).Name -notcontains "ImportExcel")
{
    Write-Host "Excel PS module not found."
    Write-Host "Downloading ImportExcel PS Module..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #Adding exception block for invoke web request
            try { $response =Invoke-WebRequest -Uri "https://github.com/dfinke/ImportExcel/archive/refs/tags/v7.8.0.zip" -OutFile "$folder\Downloads\ImportExcel.zip"} 
            catch {

               Write-Host "======================================================================================="  
               Write-Host "Error while downloading Importexcel package , Please make sure computer is connected to internet "  -ForegroundColor Red  
               Write-Host "======================================================================================="  
               Write-Host "Please see the error below & execution has been stopped          " 
            throw  $_.Exception.Response.StatusCode.Value__
            }
    
    Write-Host "Downloaded."
    Expand-Archive "$folder\Downloads\ImportExcel.zip" "$folder\Downloads\"
    move "$folder\Downloads\ImportExcel-7.8.0" "C:\Program Files\WindowsPowerShell\Modules\ImportExcel"
    Import-Module ImportExcel
}

#Checking for Az module
Write-Host "Checking for Az Module"

if((Get-Module -ListAvailable).Name -notcontains "Az"){
Write-Host "Az Module already installed"
}
else{
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force    
}
Import-Module Az       
  
   
# Read the input config Excel and validate
$inputfile = $PSScriptRoot+"\Network_Validation.xlsx"
Write-Host "Input file is $inputfile." -ForegroundColor Green
Write-Host "===================================================================="  


if (-not(Test-Path -Path $inputfile -PathType Leaf)) {
     try {    
         Write-Host "======================================================================================="  
         Write-Host "Unable to read the input file [$inputfile]. Check file & its permission...  "  -ForegroundColor Red  
         Write-Host "======================================================================================="  
         Write-Host "Please see the error below & Azure_IP_Allocation has been stopped          "  
         throw $_.Exception.Message                      
     }
     catch {
         throw $_.Exception.Message
     }
 }

$validInputs = 1..7
    $User_Exit_Response = "F"

do {
    Write-Host "=======================================================================================" 
    Write-Host "Please enter enter the Action names to be esecuted - " -ForegroundColor Green
    Write-Host "===================================================================="
    Write-Host "1. Validate the ip address is in private range or not"
    Write-Host "2. Windows Firewall for Inbound & Outbound rules"
    Write-Host "3. Test Connection w.r.t Hostname & Port"
    Write-Host "4. Check Network Diagnostic Status w.r.t Source Ip and Destination Ip"
    Write-Host "5. Infra Validation w.r.t Resource Group Name and VM Name"
    Write-Host "6. Check Disk Space"
    Write-Host "7. Exit"
    
    [int]$response_Execute_Operation = read-host "Please provide your inputs"
    if(-not $validInputs.Contains($response_Execute_Operation)){write-host "Please select the choice between 1 - 4"}
    
 
  if ($response_Execute_Operation -eq 1) {
   try {
         $ConfigList = Import-Excel -Path $inputfile -WorksheetName Nslookup    
         }
  catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named Nslookup  "  -ForegroundColor Red  
         Write-Host "=================================================================================="  
         Write-Host "Please see the error below process has been stopped          "  
         throw $_.Exception.Message
         }

  $ColumnList=$ConfigList | Get-Member -MemberType NoteProperty | %{"$($_.Name)"}
     if (($ColumnList.Contains("Hostname"))){

        Write-Host "Excel validation is done successfully for action 1" 
        }
     else {Write-Host "There are missmatches in the Excel column . Kindly check and retrigger the automation "  -ForegroundColor Red 
           exitCode}

    $Output_ValidateIP =@()

    foreach ($Iplookup in $ConfigList){

    $Hostname = $Iplookup.'Hostname'
    if ([string]::IsNullOrWhitespace($Hostname)){
     
    Continue

    }

    $Ip_Address = [system.net.dns]::GetHostByName($Hostname).AddressList.IpAddressToString

    $Ip_Validation= Test-PrivateIP $Ip_Address

    $Output_ValidateIP += New-Object psobject -Property @{HostName=$Hostname;IP_Address=$Ip_Address;IP_STATUS =$Ip_Validation}

    #$Ip_Validation
    
    }

    Write-Host "======================================================================================="  
         Write-Host "Below are the Final Outputs for - Validate the ip address is in private range or not"  -ForegroundColor Green  
         Write-Host "======================================================================================="  
         Write-Host ($Output_ValidateIP | select HostName,IP_Address,IP_STATUS| Format-Table | Out-String)

         $Output_ValidateIP |  select HostName,IP_Address,IP_STATUS | Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Ip_Address_Validation"


  }
  

  if ($response_Execute_Operation -eq 2) {
   try {
         $Windows_firewall_Config_List = Import-Excel -Path $inputfile -WorksheetName Windows_firewall    
         }
  catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named Windows_firewall  "  -ForegroundColor Red  
         Write-Host "=================================================================================="  
         Write-Host "Please see the error below process has been stopped          "  
         throw $_.Exception.Message
         }

  $ColumnList_Windows_firewall=$Windows_firewall_Config_List | Get-Member -MemberType NoteProperty | %{"$($_.Name)"}
     if (($ColumnList_Windows_firewall.Contains("Protocol")) -and 
         ($ColumnList_Windows_firewall.Contains("Profile"))-and 
         ($ColumnList_Windows_firewall.Contains("Inbound ports"))-and 
         ($ColumnList_Windows_firewall.Contains("Outbond Ports"))){

        Write-Host "Excel validation is done successfully for action 2" 
        }
     else {Write-Host "There are missmatches in the Excel column . Kindly check and retrigger the automation "  -ForegroundColor Red 
           exitCode}

$Windows_firewall_Validation =@()
$Inbound_Rule_Final_OP=@()
$Outbound_Rule_Final_OP=@()
  foreach ($Windows_firewall_row in $Windows_firewall_Config_List){

    $Protocol = $Windows_firewall_row.'Protocol'
    if ([string]::IsNullOrWhitespace($Protocol)){
      Continue
    }
    [string]$Inbound_ports = $Windows_firewall_row.'Inbound ports'
    if ([string]::IsNullOrWhitespace($Inbound_ports)){
   
    Continue
    }
    $Profile = $Windows_firewall_row.'Profile'
    if ([string]::IsNullOrWhitespace($Profile)){
     
    Continue
    }
    [string]$Outbond_Ports = $Windows_firewall_row.'Outbond Ports'
    if ([string]::IsNullOrWhitespace($Outbond_Ports)){
   
    Continue
    }

$Port_List_Inbound=@()

$Inbound_ports.split(",")| ForEach{
$Port_List_Inbound+=$_
}
$Port_List_Outbound=@()
$Outbond_Ports.split(",")| ForEach{
$Port_List_Outbound+=$_
}

#Check inbound Rules


Get-NetFirewallRule | Where-Object {($_.Direction -eq "Inbound")}|ForEach-Object {
    $Ports = $_ |Get-NetFirewallPortFilter |Where-Object LocalPort -in ($Port_List_Inbound)
    Write-Host 
    if ($Ports) {
        if($Ports.Protocol -eq $Protocol){
        #$_ |Select-Object Name,DisplayName,Profile,@{n='Protocol';e={$Ports.Protocol} }, @{n='LocalPort';e={$Ports.LocalPort} }|Format-Table | Out-String
            $Inbound_Rule_Final_OP+= $_ |Select-Object Name,DisplayName,Profile,@{n='Protocol';e={$Ports.Protocol} }, @{n='LocalPort';e={$Ports.LocalPort} },@{n='RemotePort';e={$Ports.RemotePort} },@{n='RemoteAddress';e={$Ports.RemoteAddress} },Enabled,Direction,Action
         
            }
     }
}

#Check Outbound Rules



Get-NetFirewallRule | Where-Object {($_.Direction -eq "Outbound")}|ForEach-Object {
    #Write-Host $_
    $Ports = $_ |Get-NetFirewallPortFilter |Where-Object LocalPort -in ($Port_List_Outbound)
    #Write-Host $Ports 
    if ($Ports) {
        if($Ports.Protocol -eq $Protocol){
             #$_ |Select-Object Name,DisplayName,Profile,@{n='Protocol';e={$Ports.Protocol} }, @{n='LocalPort';e={$Ports.LocalPort} }|Format-Table | Out-String
             $Outbound_Rule_Final_OP+= $_ |Select-Object Name,DisplayName,Profile,@{n='Protocol';e={$Ports.Protocol} }, @{n='LocalPort';e={$Ports.LocalPort} },@{n='RemotePort';e={$Ports.RemotePort} },@{n='RemoteAddress';e={$Ports.RemoteAddress} },Enabled,Direction,Action
            }
     }
}





  }

  Write-Host "======================================================================================="  
         Write-Host "Below are the Outputs for Inbopund Rules"  -ForegroundColor Green  
         Write-Host "======================================================================================="

         $Inbound_Rule_Final_OP|Select-Object Name,DisplayName,Profile,Protocol,LocalPort,RemotePort,RemoteAddress,Enabled,Direction,Action|Format-Table | Out-String
         

         #$Inbound_Rule_Final_OP|Select-Object Name,DisplayName,Profile,Protocol,LocalPort| Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Inbound_Rules"
         $Inbound_Rule_Final_OP|Select-Object Name,DisplayName,Profile,Protocol,LocalPort,RemotePort,RemoteAddress,Enabled,Direction,Action| Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Inbound_Rules"


  Write-Host "======================================================================================="  
         Write-Host "Below are the Outputs for Outbound Rules"  -ForegroundColor Green  
         Write-Host "======================================================================================="

         $Outbound_Rule_Final_OP|Select-Object Name,DisplayName,Profile,Protocol,LocalPort,RemotePort,RemoteAddress,Enabled,Direction,Action|Format-Table | Out-String
         $Outbound_Rule_Final_OP|Select-Object Name,DisplayName,Profile,Protocol,LocalPort,RemotePort,RemoteAddress,Enabled,Direction,Action| Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Outbound_Rules"
  }

  


  if ($response_Execute_Operation -eq 3) {
   try {
         $ConfigList_Test_Connection = Import-Excel -Path $inputfile -WorksheetName Test-Connection    
         }
  catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named Test-Connection  "  -ForegroundColor Red  
         Write-Host "=================================================================================="  
         Write-Host "Please see the error below process has been stopped          "  
         throw $_.Exception.Message
         }

  $ColumnList_Test_Connection=$ConfigList_Test_Connection | Get-Member -MemberType NoteProperty | %{"$($_.Name)"}
     if (($ColumnList_Test_Connection.Contains("Computer Name")) -and ($ColumnList_Test_Connection.Contains("Port Number"))){

        Write-Host "Excel validation is done successfully for action 3" 
        }
     else {Write-Host "There are missmatches in the Excel column . Kindly check and retrigger the automation "  -ForegroundColor Red 
           exitCode}
  $Output_Port_Connectivity =@()
  foreach ($Test_Conn in $ConfigList_Test_Connection){

    $Hostname_Test_Conn = $Test_Conn.'Computer Name'
    if ([string]::IsNullOrWhitespace($Hostname_Test_Conn)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $Port_Test_Conn = $Test_Conn.'Port Number'
    if ([string]::IsNullOrWhitespace($Port_Test_Conn)){
    
    
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"} 
    Continue
    }

     $Port_Status=Test-NetConnection -Port $Port_Test_Conn -ComputerName $Hostname_Test_Conn
        
    $Output_Port_Connectivity+=New-Object psobject -Property @{HostName=$Hostname_Test_Conn;Port_No=$Port_Test_Conn;Connection_Status =$Port_Status.TcpTestSucceeded}
    
    }

    Write-Host "======================================================================================="  
         Write-Host "Below are the Final Outputs for - Test Connection w.r.t Hostname & Port"  -ForegroundColor Green  
         Write-Host "======================================================================================="  
         Write-Host ($Output_Port_Connectivity | select HostName,Port_No,Connection_Status| Format-Table | Out-String)
         $Output_Port_Connectivity | select HostName,Port_No,Connection_Status| Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Test_Connection"
    }
  
    if ($response_Execute_Operation -eq 4) {
    $inputfile = $PSScriptRoot+"\Network_Validation.xlsx"
try {
         $ConfigList_Test_Connection = Import-Excel -Path $inputfile -WorksheetName Network_Diagnostic    
         }
  catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named Network_Diagnostic  "  -ForegroundColor Red  
         Write-Host "=================================================================================="  
         Write-Host "Please see the error below process has been stopped          "  
         throw $_.Exception.Message
         }

  
     
  $Output_Network_Diagnostic =@()
  foreach ($Network_Diagnos in $ConfigList_Test_Connection){

    $Direction_Network_Diagnos = $Network_Diagnos.'Direction'
    if ([string]::IsNullOrWhitespace($Direction_Network_Diagnos)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $Protocol_Network_Diagnos = $Network_Diagnos.'Protocol'
    if ([string]::IsNullOrWhitespace($Protocol_Network_Diagnos)){
    
    
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"} 
    Continue
    }
    $Source_IP_Network_Diagnos = $Network_Diagnos.'Source_IP'
    if ([string]::IsNullOrWhitespace($Source_IP_Network_Diagnos)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $Destination_IP_Network_Diagnos = $Network_Diagnos.'Destination_IP'
    if ([string]::IsNullOrWhitespace($Destination_IP_Network_Diagnos)){
    
    
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"} 
    Continue
    }
    $DestinationPort_Network_Diagnos = $Network_Diagnos.'DestinationPort'
    if ([string]::IsNullOrWhitespace($DestinationPort_Network_Diagnos)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $TargetResourceId_Network_Diagnos = $Network_Diagnos.'TargetResourceId'
    if ([string]::IsNullOrWhitespace($TargetResourceId_Network_Diagnos)){
    
    
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"} 
    Continue
    }
    $Location_Network_Diagnos = $Network_Diagnos.'Location'
    if ([string]::IsNullOrWhitespace($Location_Network_Diagnos)){
    
    
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"} 
    Continue
    }
    $Tenant_Network_Diagnos = $Network_Diagnos.'Tenant'
    if ([string]::IsNullOrWhitespace($Tenant_Network_Diagnos)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $Subscription_Network_Diagnos = $Network_Diagnos.'Subscription'
    if ([string]::IsNullOrWhitespace($Subscription_Network_Diagnos)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }

    $connect_Azaccount=Connect-AzAccount -Tenant '72f988bf-86f1-41af-91ab-2d7cd011db47' 
    $Set_azAccount=Set-AzContext -Tenant '72f988bf-86f1-41af-91ab-2d7cd011db47' -Subscription 'cbb956ec-6c04-42ae-8428-91d91154f780'
     $profile = New-AzNetworkWatcherNetworkConfigurationDiagnosticProfile -Direction $Direction_Network_Diagnos -Protocol Tcp -Source $Source_IP_Network_Diagnos -Destination $Destination_IP_Network_Diagnos -DestinationPort $DestinationPort_Network_Diagnos
     $Output_Network_Diagnostic_Status=Invoke-AzNetworkWatcherNetworkConfigurationDiagnostic -Location $Location_Network_Diagnos -TargetResourceId $TargetResourceId_Network_Diagnos -Profile $profile
        
    $Output_Network_Diagnostic+=New-Object psobject -Property @{Source_IP=$Source_IP_Network_Diagnos;Destination_IP=$Destination_IP_Network_Diagnos;Status =$Output_Network_Diagnostic_Status.Results.NetworkSecurityGroupResult.SecurityRuleAccessResult}
    
    }

    Write-Host "======================================================================================="  
         Write-Host "Below are the Final Outputs for - Network Diagnostic"  -ForegroundColor Green  
         Write-Host "======================================================================================="  
         Write-Host ($Output_Network_Diagnostic | select Source_IP,Destination_IP,Status| Format-Table | Out-String)
         $Output_Network_Diagnostic | select Source_IP,Destination_IP,Status| Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Network_Diagnostic"
    }

    if ($response_Execute_Operation -eq 5) {

    try {
         $ConfigList_Test_Connection = Import-Excel -Path $inputfile -WorksheetName Infra_validation    
         }
  catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named Infra_validation  "  -ForegroundColor Red  
         Write-Host "=================================================================================="  
         Write-Host "Please see the error below process has been stopped          "  
         throw $_.Exception.Message
         }

  
     
  $Output_Infra_Validation =@()
  foreach ($Infra_Valid in $ConfigList_Test_Connection){

    $ResourceGroup_Name_Infra_Valid = $Infra_Valid.'ResourceGroup_Name'
    if ([string]::IsNullOrWhitespace($ResourceGroup_Name_Infra_Valid)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $VM_Name_Infra_Valid = $Infra_Valid.'VM_Name'
    if ([string]::IsNullOrWhitespace($VM_Name_Infra_Valid)){
    
    
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"} 
    Continue
    }
    $Tenant_Infra_Valid = $Infra_Valid.'Tenant'
    if ([string]::IsNullOrWhitespace($Tenant_Infra_Valid)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $Subscription_Infra_Valid = $Infra_Valid.'Subscription'
    if ([string]::IsNullOrWhitespace($Subscription_Infra_Valid)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }

    $connect_Azaccount=Connect-AzAccount -Tenant '72f988bf-86f1-41af-91ab-2d7cd011db47' 
    $Set_azAccount=Set-AzContext -Tenant '72f988bf-86f1-41af-91ab-2d7cd011db47' -Subscription 'cbb956ec-6c04-42ae-8428-91d91154f780'
     $Output_Infra_Validation_Status=Get-AzVM -ResourceGroupName $ResourceGroup_Name_Infra_Valid | where-object {$_.Name -eq $VM_Name_Infra_Valid}
     $vmsize=$Output_Infra_Validation_Status.HardwareProfile.VmSize
     #Invoke-AzVMRunCommand -ResourceGroupName Test -VMName VM-1 -CommandId."RunPowerShellCommand" az vm show -g $ResourceGroup_Name_Infra_Valid -n $VM_Name_Infra_Valid --query 'hardwareProfile.vmSize'

     $Output_Infra_Validation+=New-Object psobject -Property @{Resource_Group_Name=$ResourceGroup_Name_Infra_Valid;VM_Name=$VM_Name_Infra_Valid;VM_SKU =$vmsize}
    
    }

    Write-Host "======================================================================================="  
         Write-Host "Below are the Final Outputs for - Infra Validation"  -ForegroundColor Green  
         Write-Host "======================================================================================="  
         Write-Host ($Output_Infra_Validation | select Resource_Group_Name,VM_Name,VM_SKU| Format-Table | Out-String)
         $Output_Infra_Validation | select Resource_Group_Name,VM_Name,VM_SKU| Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Infra_validation"
    }
    if ($response_Execute_Operation -eq 6) {

    try {
         $ConfigList_Test_Connection = Import-Excel -Path $inputfile -WorksheetName Check_DiskSpace    
         }
  catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named Check_DiskSpace  "  -ForegroundColor Red  
         Write-Host "=================================================================================="  
         Write-Host "Please see the error below process has been stopped          "  
         throw $_.Exception.Message
         }

  
     
  $Output_Available_drive_space =@()
  foreach ($Disk_Space in $ConfigList_Test_Connection){

    $Server_IP_Disk_Space = $Disk_Space.'Server_IP'
    if ([string]::IsNullOrWhitespace($Server_IP_Disk_Space)){
    #$Output_Port_Connectivity+=New-Object psobject -Property @{HostName="Missing Data in Input Sheet";Port_No="Missing Data in Input Sheet";Connection_Status ="NA"}  
    Continue
    }
    $cred = Get-Credential
    $session = new-pssession -computername $Server_IP_Disk_Space -credential $cred

    if ($session -eq $null){
    Write-Host "Not able to connect to the remote host"
    Continue
    }
    $available_drive_space=Invoke-Command -Session $session -ScriptBlock { Get-Volume}
    #$available_drive_space=Get-Volume
    foreach($available_drive in $available_drive_space)
    {
        $driveletter =$available_drive.DriveLetter
        
        if(($available_drive.FileSystemLabel -ne "Recovery") )
        {
            
            [int]$drive_available_space_gb=$($available_drive.SizeRemaining/1GB)
            
            $Output_Available_drive_space+=New-Object psobject -Property @{Drive_Letter=$driveletter;Available_Space_in_GB=$drive_available_space_gb}
        }
    }
    #Remove-PSSession $session
    }
    if($Output_Available_drive_space -ne $nul){
    Write-Host "======================================================================================="  
         Write-Host "Below are the Available Drive Space  for the vm"  -ForegroundColor Green  
         Write-Host "======================================================================================="  
         Write-Host ($Output_Available_drive_space | select Drive_Letter,Available_Space_in_GB| Format-Table | Out-String)
         $Output_Available_drive_space | Select-Object Drive_Letter,Available_Space_in_GB| Export-Excel $PSScriptRoot\Output\Output.xlsx -WorksheetName "Diskspace"
    }
    }

} until ($response_Execute_Operation -eq 7)



  

