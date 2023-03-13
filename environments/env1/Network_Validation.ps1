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

$validInputs = 1..4
    $User_Exit_Response = "F"

do {
    Write-Host "=======================================================================================" 
    Write-Host "Please enter enter the Action names to be esecuted - " -ForegroundColor Green
    Write-Host "===================================================================="
    Write-Host "1. Validate the ip address is in private range or not"
    Write-Host "2. Windows Firewall for Inbound & Outbound rules"
    Write-Host "3. Test Connection w.r.t Hostname & Port"
    Write-Host "4. Exit"
    
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
    
    if ($Ports) {
        if($Ports.Protocol -eq $Protocol){
        #$_ |Select-Object Name,DisplayName,Profile,@{n='Protocol';e={$Ports.Protocol} }, @{n='LocalPort';e={$Ports.LocalPort} }|Format-Table | Out-String
            $Inbound_Rule_Final_OP+= $_ |Select-Object Name,DisplayName,Profile,@{n='Protocol';e={$Ports.Protocol} }, @{n='LocalPort';e={$Ports.LocalPort} },@{n='RemotePort';e={$Ports.RemotePort} },@{n='RemoteAddress';e={$Ports.RemoteAddress} },Enabled,Direction,Action
         
            }
     }
}

#Check Outbound Rules



Get-NetFirewallRule | Where-Object {($_.Direction -eq "Outbound")}|ForEach-Object {
    $Ports = $_ |Get-NetFirewallPortFilter |Where-Object LocalPort -in $Port_List_Outbound
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
  




} until ($response_Execute_Operation -eq 4)



  

