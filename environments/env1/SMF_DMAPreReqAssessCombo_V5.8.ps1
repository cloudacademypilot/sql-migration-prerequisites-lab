#---------------------------------------------------------------------------------------------------------------------------*
#  Purpose        : Script to install pre-requisites for Microsoft DMA and perform the assessment for a given input list
#  Schedule       : Ad-Hoc / On-Demand
#  Date           : 18-August-2022
#  Author         : Sherbaz Mohamed, Rackimuthu Kandaswamy
#  Version        : 5.8
#   
#  INPUT          : DMA Input Folder, Server List in Excel file
#  VARIABLE       : NONE
#  PARENT         : NONE
#  CHILD          : NONE
#---------------------------------------------------------------------------------------------------------------------------*
#---------------------------------------------------------------------------------------------------------------------------*
#
#  IMPORTANT NOTE : The script has to be run on Non-Mission-Critical systems ONLY and not on any production server...
#
#---------------------------------------------------------------------------------------------------------------------------*
#---------------------------------------------------------------------------------------------------------------------------*
# Usage:
# Powershell.exe -File .\SMF_DMAandSKUAssessmentsCombo.ps1
#
<#
    Change Log
    ----------
        23 August 2022 - Sherbaz - SKU Assessment incorporated
        26 August 2022 - Sherbaz - V4.0 - Paramter input to select DMA or SKU
        26 August 2022 - Sherbaz - V4.1 - DMA Assessment progres bar
        07 September 2022 - Sherbaz - V5.0 - DMARunStatus.csv - retry only failed
        27 September 2022 - Sherbaz - v5.2 - TLS error for Excel module import
        08 February 2023 - Sireesha - v5.8 - SQL Server 2022 is Added
#>
#$folder = "C:\DMAAssessment"
#$folder = Read-Host -Prompt 'Working Folder Path'
# TO be added: Check target disk space available to generate reports
#----Libraries-----
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing


#----FUNCTIONS-----
function exitCode{
    Write-Host "-Ending Execution"
    exit
}

function launchDMA{
    Write-Host "-Preparing to launch DMA..."
    write-host "-Fetching .Net Core Version installed..."

    if(Test-Path "C:\Program Files\dotnet\shared\Microsoft.NETCore.App")
    {
        Write-Host "-C:\Program Files\dotnet Folder Exists... checking .net Core version installed"
        #$dotnetcoreVersion = Get-ChildItem -Path "C:\Program Files\dotnet\shared\Microsoft.NETCore.App" -Directory | Sort-Object -Property Name -Descending |select Name -First 1

        $dotnetcoreVersion = (dir (Get-Command dotnet).Path.Replace('dotnet.exe', 'shared\Microsoft.NETCore.App')) | Sort-Object -Property Name -Descending |select Name -First 1
        $nodotnetcore = 0
        [int]$dotnetcoreVersion_root=$dotnetcoreVersion.Name.Split(".")[0]
        #if($dotnetcoreVersion -notmatch "3.1.28")
        #if ([string]::IsNullOrWhitespace($dotnetcoreVersion))
        if(-not $dotnetcoreVersion_root -ge 3)
        {
            $nodotnetcore = 1
        }
    }
    else
    {
        $nodotnetcore = 1
    }

    if($nodotnetcore -eq 1)
    {
        Write-Host "-.Net Core is not available to perform DMA SKU Assessment..."
        $response = read-host "
            ===> Enter 'Y' to continue to download and install or press any other key to continue with DMA Launch"
        if($response -eq "Y")
        {
            Write-Host '-Downloading...'
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Adding exception block for invoke web request
            try { $response =Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/83149576-180d-49ab-be17-83110eb2379b/9dfe3f504f0bd38d2d8d4bd1c544f6ce/dotnet-runtime-3.1.28-win-x64.exe" -OutFile "$folder\Downloads\DotNetCoreInstaller.exe"} 
            catch {

               Write-Host "======================================================================================="  
               Write-Host "Error while downloading .Net core package  "  -ForegroundColor Red  
               Write-Host "======================================================================================="  
               Write-Host "Please see the error below & execution has been stopped          " 
            throw  $_.Exception.Response.StatusCode.Value__
            }
            Write-Host '-Installating .Net Core ...'
            & $folder'\Downloads\DotNetCoreInstaller.exe' /install /passive /norestart /log $folder"\Logs\DotNETCore-Install.log" | Out-Null

        }
    }
    Write-Host "
    -Launching DMA...
    "
     #& 'C:\Program Files\Microsoft Data Migration Assistant\Dma.exe'

}

#-------------GET FOLDER LOCATION-------------------
function getFolderLocation {
            $form = New-Object System.Windows.Forms.Form
            $form.Text = 'Data Entry Form'
            $form.Size = New-Object System.Drawing.Size(300,200)
            $form.StartPosition = 'CenterScreen'

            $okButton = New-Object System.Windows.Forms.Button
            $okButton.Location = New-Object System.Drawing.Point(75,120)
            $okButton.Size = New-Object System.Drawing.Size(75,23)
            $okButton.Text = 'OK'
            $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.AcceptButton = $okButton
            $form.Controls.Add($okButton)

            $cancelButton = New-Object System.Windows.Forms.Button
            $cancelButton.Location = New-Object System.Drawing.Point(150,120)
            $cancelButton.Size = New-Object System.Drawing.Size(75,23)
            $cancelButton.Text = 'Cancel'
            $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton = $cancelButton
            $form.Controls.Add($cancelButton)

            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,20)
            $label.Size = New-Object System.Drawing.Size(280,20)
            $label.Text = 'Enter Working Folder Path below:'
            $form.Controls.Add($label)

            $textBox = New-Object System.Windows.Forms.TextBox
            $textBox.Location = New-Object System.Drawing.Point(10,40)
            $textBox.Size = New-Object System.Drawing.Size(260,20)
            $form.Controls.Add($textBox)

            $form.Topmost = $true

            $form.Add_Shown({$textBox.Select()})
            $result = $form.ShowDialog()

            if ($result -eq [System.Windows.Forms.DialogResult]::OK)
            {
                $x = $textBox.Text
                $folder = $x
            }
            else
            {
                write-host "-Error In Input...Using default path..."
                $folder = "C:\DMAAssessment"
            }

            if(Test-Path $folder)
            {
                Write-Host "-Folder Exist"
            }
            else
            {
                New-Item $folder -ItemType Directory
                Write-Host "-$folder folder created..."
            }


            Write-Output $folder

}
function selectFolder{
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    Write-Host "Input Section "   -ForegroundColor Green
    Write-Host "======================================================================================="
    Write-Host "Select the Working folder in the Popup window" -ForegroundColor Green
    $foldername.Description = "Select a working Folder for DMA..."
    $foldername.rootfolder = "MyComputer"
    #$foldername.SelectedPath = $initialDirectory

    Start-Sleep -Seconds 5

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder = $foldername.SelectedPath
    }
    else
    {
        exitCode
    }
    return $folder
}
#----------ENDS GET FOLDER LOCATION----------
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

#----variables
    $exit = 0
    $nodotnetcore = 0

#----ENDS variables

$ErrorActionPreference = "Stop"
#$ErrorActionPreference = "SilentlyContinue"

#---------------------------------------------------------PROGRAM BEGINS HERE----------------------------------------------------------
CLS

write-host "                                                                            " -BackgroundColor DarkMagenta
Write-Host "                  Welcome to SMF - DMA Assessment                           " -ForegroundColor white -BackgroundColor DarkMagenta
write-host "                     (SQL Migration factory)                                " -BackgroundColor DarkMagenta
write-host "                              V5.8                                          " -BackgroundColor DarkMagenta
Write-Host " "

Write-Host "Please select the assessment operation to perform" -ForegroundColor Green
Write-Host "===================================================================="
Write-Host "1. Perform both DMA assessment and Performance data gathering"
Write-Host "2. Perform DMA assessment only"
Write-Host "3. Perform Performance data gathering only"
Write-Host "4. Exit"

$validInputs = "1", "2", "3", "4"
do {
    $response = Read-Host -Prompt "Enter value"
    if(-not $validInputs.Contains($response)){write-host "Please select the choice between 1 - 4"}
} until ($validInputs.Contains($response))

$taskToPerform = $response


Write-Host "======================================================================================="
Write-Host "Reviewing Installed Softwares on this machine..."
#$softwares = Get-WmiObject -Class Win32_Product
$softwares=Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* 
if($softwares.DisplayName -like "*SQL Server*Engine*")
{
    Write-Host "======================================================================================="  
    Write-Host "SQL Server product installed/detected on this server...  "  -ForegroundColor Red  -BackgroundColor yellow
    foreach ($name in $Softwares) {if($name.DisplayName -ilike "*SQL Server*Engine*") {$name.DisplayName}}
    Write-host "It is recommended to use a separate non-critical server to perform assessment."
    Write-Host "Input Section "   -ForegroundColor Green
    Write-Host "======================================================================================="
    $response = read-host "Enter 'Y' to continue or any other key to abort"
    if($response -ne "Y")
    {
        exitCode
    }
}

#write-host "Checking Windows features"
#$winFeatures = Get-WindowsFeature

$folder = $PSScriptRoot


cd $folder

Write-host "Copying old files to Archieve..."

If(!(test-path -PathType container $folder\Archive))
{
      createFolder $folder\Archive
}

if ((Test-Path -Path $folder\output) -or 
     (Test-Path -Path $folder\Compressed) -or
     (Test-Path -Path $folder\Downloads) -or
     (Test-Path -Path $folder\Logs) -or
     (Test-Path -Path $folder\Config) ){

     $FolderTimestamp=Get-Date -Format "MM_dd_yyyy_HH_mm"
     $Archive_Folder="DMA_Logs_"+$FolderTimestamp
     createFolder $folder\Archive\$Archive_Folder

     
     try {Move-Item -Path $folder\output -Destination $folder\Archive\$Archive_Folder}catch {}
     try {Move-Item -Path $folder\Compressed -Destination $folder\Archive\$Archive_Folder}catch {}
     try {Move-Item -Path $folder\Downloads -Destination $folder\Archive\$Archive_Folder}catch {}
     try {Move-Item -Path $folder\Logs -Destination $folder\Archive\$Archive_Folder}catch {}
     try {Move-Item -Path $folder\Config -Destination $folder\Archive\$Archive_Folder}catch {}
     
     try {Get-ChildItem -Path $folder\output -Recurse | Move-Item -Destination $folder\Archive\$Archive_Folder\output}catch {}


     #try {Move-Item -Path $folder\Config -Destination $folder\Archive\$Archive_Folder}catch {}

} 


#createFolder $folder
createFolder $folder\output\
createFolder $folder\output\Compressed\
createFolder $folder\Downloads\
createFolder $folder\Logs\
createFolder $folder\Config\
Write-Host "-Sub-directories created..."




write-host "-Fetching .Net FrameWork Version installed..."
$dotnet=Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where { $_.PSChildName -Match '^(?!S)\p{L}'} | Select PSChildName, version

$(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Version).Version


if($dotnet -match "4.8")
{
    Write-Host "-.Net 4.8 available"
}
else
{
    Write-Host "=======================================================================================" 
    Write-Host ".Net 4.8 not available" -ForegroundColor Red
    Write-Host "=======================================================================================" 
    $response = read-host "Enter 'Y' to continue to download and install or press any other key to abort"

    if($response -eq "Y")
    {
        Write-Host '-Downloading...'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        #Adding exception block for invoke web request
            try { $response =Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2088631" -OutFile "$folder\Downloads\DotNetInstaller.exe"} 
            catch {

               Write-Host "======================================================================================="  
               Write-Host "Error while downloading .Net package , Please make sure computer is connected to internet  "  -ForegroundColor Red  
               Write-Host "======================================================================================="  
               Write-Host "Please see the error below & execution has been stopped          " 
            throw  $_.Exception.Response.StatusCode.Value__
            }

        
        Write-Host '-Installing .Net 4.8 ...Please wait!' -ForegroundColor Green
        & $folder'\Downloads\DotNetInstaller.exe' /install /passive /showfinalerror /showrmui /promptrestart /log $folder"\Logs\DotNET48-Install.log" | Out-Null

        Write-Host "=======================================================================================" 
        Write-Host ".Net 4.8 installation completed. Please restart this machine and rerun this script. Thank you!" -ForegroundColor Green
        Write-Host "======================================================================================="
        
        timeout /t -1

        exitCode
    }
    else
    {
        exitCode
    }
}


#check if DMA is installed

if($softwares.DisplayName -match "Microsoft Data Migration Assistant")
{
    Write-Host "=======================================================================================" 
    write-host "DMA already installed..." -ForegroundColor Green
    Write-Host "=======================================================================================" 
    launchDMA
}
else
{
    Write-Host "======================================================================================="  
    Write-Host "DMA Not Installed...  "  -ForegroundColor Red  
    Write-Host "======================================================================================="  
    $response = read-host "Enter 'Y' to continue to download and install or any other key to abort"
    
    if($response -eq "Y")
    {
        Write-Host "Downloading DMA Binaries..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      #Adding exception block for invoke web request
            try { $response =Invoke-WebRequest -Uri "https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi" -OutFile "$folder\Downloads\DMAInstaller.msi"} 
            catch {

               Write-Host "======================================================================================="  
               Write-Host "Error while downloading DMA package , Please make sure computer is connected to internet "  -ForegroundColor Red  
               Write-Host "======================================================================================="  
               Write-Host "Please see the error below & execution has been stopped          " 
            throw  $_.Exception.Response.StatusCode.Value__
            }
        #Start-Process msiexec /a "$folder\DataMigrationAssistant.msi" TARGETDIR="C:\Program Files\" /q /lv* "$folder\DataMigrationAssistantInstall.log"
        Write-Host 'Installing DMA...'
        $MSIArguments = @(
                "/i"
                ('"{0}"' -f "$folder\Downloads\DMAInstaller.msi")
                "/qn"
                "/norestart"
                "/L*v"
                "$folder\Logs\DMAInstalllog.txt"
        )

        Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
        write-host "Preparing to Launch DMA. Please Stand-By..." -ForegroundColor Green
        launchDMA
    }
    else
    {
        exitCode
    }
    
}

#
#
#
#---------------------------------------- ASSESSMENT STARTS -----------------------------
#
#
#

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


$outputfolder = $null
$inputfile = $null

Write-Host "Input Section "   -ForegroundColor Green
Write-Host "===================================================================="
Write-Host "Fe the Input file name with Full Path " -ForegroundColor Green
#$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    #InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    #Filter = 'SpreadSheet (*.xlsx)|*.xlsx'
#}
#$null = $FileBrowser.ShowDialog()


$inputfile = $PSScriptRoot+"\DMA-INPUT-FILE.xlsx"
Write-Host "Input file is $inputfile." -ForegroundColor Green
Write-Host "===================================================================="  

IF ([string]::IsNullOrWhitespace($inputfile)){$inputfile="C:\DMA\DMA-INPUT-FILE.xlsx"}
$inputfilecheck=-1;

if (-not(Test-Path -Path $inputfile -PathType Leaf)) {
     try {    
         Write-Host "======================================================================================="  
         Write-Host "Unable to read the input file [$inputfile]. Check file & its permission...  "  -ForegroundColor Red  
         Write-Host "======================================================================================="  
         Write-Host "Please see the error below & DMA assessment has been stopped          "  
         throw $_.Exception.Message                      
     }
     catch {
         throw $_.Exception.Message
     }
 }
else
{
     try {
         $sqllist = Import-Excel -Path $inputfile -WorksheetName input-to-dma-for-assessment

         

         $Rowcount=0

          foreach($row in $sqllist){

         $Hostname = $row.'Computer Name'
          $Rowcount=$Rowcount+1

           }

 
       
              }
     catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named input-to-dma-for-assessment  "  -ForegroundColor Red  
         Write-Host "=================================================================================="  
         Write-Host "Please see the error below & DMA assessment has been stopped          "  
         throw $_.Exception.Message
     }

    # Check if Column "Computer Name"  and Value exist 
      try {
          $namelist = $sqllist."Computer Name"
           IF ([string]::IsNullOrWhitespace($namelist)){throw "'Computer Name' is not valid in the input-to-dma-for-assessment worksheet" }
          }
     catch {
         Write-Host "======================================================================================="  
         Write-Host "Error while reading 'Computer Name' from the woksheet named input-to-dma-for-assessment  "  -ForegroundColor Red  
         Write-Host "======================================================================================="  
         Write-Host "Please see the error below & DMA assessment has been stopped          " 
         throw $_.Exception.Message
     }
    
    # Check if Column "SQL Server Instance Name"  and Value exist 
      try {
          $instancelist = $sqllist."SQL Server Instance Name"
           IF ([string]::IsNullOrWhitespace($instancelist)){throw "'SQL Server Instance Name' is not valid in the input-to-dma-for-assessment worksheet" }
          }
     catch {
         Write-Host "=================================================================================================="  
         Write-Host "Error while reading 'SQL Server Instance Name' from the woksheet named input-to-dma-for-assessment  "  -ForegroundColor Red  
         Write-Host "=================================================================================================="  
         Write-Host "Please see the error below & DMA assessment has been stopped          "  
         throw $_.Exception.Message
     }

     
    # Check if Column "Authentication type"  and Value exist 
      try {
          $authlist = $sqllist."Authentication type"
           IF ([string]::IsNullOrWhitespace($authlist)){throw "'Authentication type' is not valid in the input-to-dma-for-assessment worksheet" }
          }
     catch {
         Write-Host "=============================================================================================="  
         Write-Host "Error while reading 'Authentication type' from the woksheet named input-to-dma-for-assessment "  -ForegroundColor Red  
         Write-Host "=============================================================================================="   
         Write-Host "Please see the error below & DMA assessment has been stopped          "  
         throw $_.Exception.Message
     }

  
       # Check if Column "DBUserName"  and Value exist 
      try {
          $userlist = $sqllist."DBUserName"
          
           # IF ([string]::IsNullOrWhitespace($userlist)) {throw "'DBUserName' is not valid in the input-to-dma-for-assessment worksheet" }
               # DBUserName exist check only performed and it can be NULL for the WINDOWS AUTHENTICATION }
          }
     catch {
         Write-Host "===================================================================================="  
         Write-Host "Error while reading 'DBUserName' from the woksheet named input-to-dma-for-assessment "  -ForegroundColor Red  
         Write-Host "===================================================================================="   
         Write-Host "Please see the error below & DMA assessment has been stopped          "  
         throw $_.Exception.Message
     }


      # Check if Column "DBPassword"  and Value exist 
      try {
          $pwdlist = $sqllist."DBPassword"
          #  IF ([string]::IsNullOrWhitespace($pwdlist)){throw "'DBPassword' is not valid in the input-to-dma-for-assessment worksheet" }
          }
     catch {
         Write-Host "===================================================================================="  
         Write-Host "Error while reading 'DBPassword' from the woksheet named input-to-dma-for-assessment "  -ForegroundColor Red  
         Write-Host "===================================================================================="   
         Write-Host "Please see the error below & DMA assessment has been stopped          " 
         throw $_.Exception.Message
     }
   # Check if Column "DBPort"  and Value exist  
      try {
          $portlist = $sqllist."DBPort"
          # IF ([string]::IsNullOrWhitespace($portlist)){throw "'DBPort' is not valid in the input-to-dma-for-assessment worksheet" }
          }
     catch {
         Write-Host "================================================================================"  
         Write-Host "Error while reading 'DBPort' from the woksheet named input-to-dma-for-assessment "  -ForegroundColor Red  
         Write-Host "================================================================================"  
         Write-Host "Please see the error below & DMA assessment has been stopped          " -ForegroundColor white
         throw $_.Exception.Message
     }
       
   # Check if Column "SQL Server Product Name"  and Value exist  
      try {
          $productlist = $sqllist."SQL Server Product Name"
           IF ([string]::IsNullOrWhitespace($productlist)){throw "'SQL Server Product Name' is not valid in the input-to-dma-for-assessment worksheet" }
          }
     catch {
         Write-Host "================================================================================"  
         Write-Host "Error while reading 'SQL Server Product Name' from the woksheet named input-to-dma-for-assessment "  -ForegroundColor Red  
         Write-Host "================================================================================"  
         Write-Host "Please see the error below & DMA assessment has been stopped          " -ForegroundColor white
         throw $_.Exception.Message
     }
  $inputfilecheck=0;
} # Input file else

#Write-host "Inputfile check $($inputfilecheck) "



$ouputflodercheck=-1;
if ($inputfilecheck -eq 0)
{
<#
Write-Host "===================================================================="
Write-Host "Enter the Output file name with Full Path " -ForegroundColor Green
$outputfolder = Read-Host "Enter the Output folder name (Default: $folder\output\) "
Write-Host "===================================================================="  
#>

IF ([string]::IsNullOrWhitespace($outputfolder)){$outputfolder="$folder\output\"}

if (-not(Test-Path -Path $outputfolder)) {
     try {    
         Write-Host "======================================================================================="  
         Write-Host "Unable to locate the ouput folder [$outputfolder]. Check folder & its permission...  "  -ForegroundColor Red  
         Write-Host "======================================================================================="  
         Write-Host "Please see the error below & DMA assessment has been stopped          "  
         throw $_.Exception.Message                      
     }
     catch {
         throw $_.Exception.Message
     }
}
else
{ 
$ouputflodercheck=0;
}
}

<#
          $namelist     = $sqllist."Computer Name"
          $instancelist = $sqllist."SQL Server Instance Name"
          $userlist     = $sqllist."DBUserName"
          $pwdlist      = $sqllist."DBPassword"
          $portlist     = $sqllist."DBPort"
          $productlist  = $sqllist."SQL Server Product Name"
          $authlist     = $sqllist."Authentication type"
#>



#check input and output files then proceed <-- Main Loop
if ({($ouputflodercheck -eq 0) -and ($inputfilecheck -eq 0)})
{

Start-Transcript -path  $folder\Logs\DMA_Assessment_Transcript.txt -Append
$Report_start_time=Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss K"

# - For SKU

"{" | Out-File $folder\Config\SKUConfig.json

' "action": "PerfDataCollection",' | Out-File -Append $folder\Config\SKUConfig.json

' "sqlConnectionStrings": [' | Out-File -Append $folder\Config\SKUConfig.json

Write-Host "DMA Assessment Starting......: " $Report_start_time  -ForegroundColor Green
    try {

        #-------- GRAPHICAL PROGRESS BAR INIT
            #title for the winform
            $Title = "DMA Assessment"
            #winform dimensions
            $height=100
            $width=400
            #winform background color
            $color = "White"


            #create the form
            $pbform1 = New-Object System.Windows.Forms.Form
            $pbform1.Text = $title
            $pbform1.Height = $height
            $pbform1.Width = $width
            $pbform1.BackColor = $color

            $pbform1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
            #display center screen
            $pbform1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

            # create label
            $label1 = New-Object system.Windows.Forms.Label
            $label1.Text = "not started"
            $label1.Left=5
            $label1.Top= 10
            $label1.Width= $width - 20
            #adjusted height to accommodate progress bar
            $label1.Height=15
            $label1.Font= "Verdana"
            #optional to show border
            #$label1.BorderStyle=1

            #add the label to the form
            $pbform1.controls.add($label1)

            $progressBar1 = New-Object System.Windows.Forms.ProgressBar
            $progressBar1.Name = 'progressBar1'
            $progressBar1.Value = 0
            $progressBar1.Style="Continuous"

            $System_Drawing_Size = New-Object System.Drawing.Size
            $System_Drawing_Size.Width = $width - 40
            $System_Drawing_Size.Height = 20
            $progressBar1.Size = $System_Drawing_Size

            $progressBar1.Left = 5
            $progressBar1.Top = 40
            
            $pbform1.Controls.Add($progressBar1)
            
            $pbform1.Show()| out-null

            #give the form focus
            $pbform1.Focus() | out-null

            #update the form
            $label1.text="Preparing..."
            $pbform1.Refresh()

        #----------GRAPHICS PROGRESS BAR INIT ---ENDS

        #----- CHECK DBA RUN STATUS DMARunsStatus.csv
            if(-not((Test-Path -Path $folder\Logs\DMARunStatus.csv)))
            {
                Write-Host "Creating DMARunStatus Log..."
                $newcsv = {} | Select "ServerName","InstanceName","Status" | Export-Csv "$folder\Logs\DMARunStatus.csv"
            }
            else
            {
                Write-Host "DMARunStatus.csv exist. Retrying only failed instances..."
            }
            
            $dmarunstatus = Import-Csv "$folder\Logs\DMARunStatus.csv"
        #----- DMARunStatus.csv ends

        $i = 0
              # For ($i=0; $i -lt $Rowcount; $i++) {
        foreach ($row_Content in $sqllist) {
   
          $namelist = $row_Content."Computer Name"
          $instancelist = $row_Content."SQL Server Instance Name"
          $authlist = $row_Content."Authentication type"
          $userlist = $row_Content."DBUserName"
          $pwdlist = $row_Content."DBPassword"
          $portlist = $row_Content."DBPort"
          $productlist = $row_Content."SQL Server Product Name"
                    # $sqllist.count;

          #$userlist
          # $pwdlist
          # $portlist
          # $productlist 
          # $authlist

          IF ([string]::IsNullOrWhitespace($namelist)){continue;}

          #---UPDATE PROGRESS--------------==================----------------
            
           Write-Progress -Activity "DMA Assessment" -PercentComplete $(($i/$Rowcount)*100) -CurrentOperation "$($i+1). $($namelist)\$($instancelist) ($($i+1) out of $($Rowcount))"

            #graphical progress bar
           [int]$pct = $(($i/$Rowcount)*100)
            #update the progress bar
            $progressbar1.Value = $pct

            $label1.text="$($i+1).$($namelist)\$($instancelist) ($($i+1) out of $($Rowcount))"
            $pbform1.Refresh()
 
          #---PROGRESS BAR ENDS------------==================-----------------

          $authcheck=-1; # 1 is for Windows and 2 is for SQL Server Authentication

          if ( $authlist.ToUpper() -notin ("WINDOWS AUTHENTICATION", "SQL SERVER AUTHENTICATION") )
          {
           try {    
            Write-Host "======================================================================================================="  
            Write-Host "Currently Supported 'Authentication types' are 'WINDOWS AUTHENTICATION' or 'SQL SERVER AUTHENTICATION' "  -ForegroundColor Red  
            Write-Host "======================================================================================================="  
            Write-Host "Please see the error below & DMA assessment has been stopped          "  
            throw $_.Exception.Message                      
           }
           catch { throw $_.Exception.Message            }
          }
          else
          {
           if ( $authlist.ToUpper() -eq "WINDOWS AUTHENTICATION") { $authcheck=1} else { $authcheck=2} 
          }


          if ($authcheck -eq 2)
          {
              if (  
                  ( $null -ne $namelist     -and $namelist     -ne ''  ) -and
                  ( $null -ne $instancelist -and $instancelist -ne ''  ) -and
                  ( $null -ne $userlist     -and $userlist     -ne ''  ) -and
                  ( $null -ne $pwdlist      -and $pwdlist      -ne ''  ) -and
              #    ( $null -ne $portlist     -and $portlist     -ne ''  ) -and
                  ( $null -ne $productlist  -and $productlist  -ne ''  )
                 )
                 {
                      try  {     #SQL Server Auth validation passed
                      }
                      catch { throw $_.Exception.Message            }
                 }
                 else
                 {throw "'Computer Name', 'SQL Server Instance Name', 'DBUserName' ,'DBPassword, 'DBPort' or 'SQL Server Product Name' is not available." }
           }
           else
           {
             if (  
                  ( $null -ne $namelist     -and $namelist     -ne ''  ) -and
                  ( $null -ne $instancelist -and $instancelist -ne ''  ) -and
                 # ( $null -ne $userlist     -and $userlist     -ne ''  ) -and
                 # ( $null -ne $pwdlist      -and $pwdlist      -ne ''  ) -and
                 # ( $null -ne $portlist     -and $portlist     -ne ''  ) -and
                  ( $null -ne $productlist  -and $productlist  -ne ''  )
                 )
                 {
                      try  {     #Windows Auth , no userid and password check 
                       
                      }
                      catch { throw $_.Exception.Message            }
                 }
                 else
                 {throw "'Computer Name', 'SQL Server Instance Name', 'DBPort' or 'SQL Server Product Name' is not available." }
           }
         
$defualtinstancecheck=-1;
$db_connection_string="";

  if ( $instancelist.ToUpper() -eq "MSSQLSERVER") { $defualtinstancecheck=1} else { $defualtinstancecheck=2} 

  if ( $defualtinstancecheck -eq 1) 
      { $db_connection_string=-join("Server=",$namelist)} 
  else 
      { $db_connection_string=-join("Server=",$namelist,"\",$instancelist)} 

     if (($portlist -ne 1433) -And (-not [string]::IsNullOrWhitespace($portlist)))
      {$db_connection_string=-join($db_connection_string,",",$portlist)}
   
      if ( $authcheck -eq 2) 
      { $db_connection_string=-join($db_connection_string,";User ID=",$userlist,";Password=",$pwdlist,";Integrated Security=false")} 
      else 
      { $db_connection_string=-join($db_connection_string,";Integrated Security=true")} 

      #/AssessmentDatabases="Server=sqltest-ms\mssqlserver1;User ID=sqltestuser1;Password=Mindtree123!;Integrated Security=false" 

      write-host $db_connection_string
      # --------------------------
      #---------- For SKU---------
      if($i -eq 0){
      
             
        """$($($db_connection_string -replace '[\\/]','\\') -replace "Server=","Data Source=")""" | Out-File -Append $folder\Config\SKUConfig.json
      }else{
              
        ",""$($($db_connection_string -replace '[\\/]','\\') -replace "Server=","Data Source=")""" | Out-File -Append $folder\Config\SKUConfig.json
      }
      #
      #----------------------------

      if ($outputfolder.Substring($outputfolder.Length - 1) -ne "\")
      {
      $file_name = -join( $outputfolder.Replace('\', '\\'), "`\`\" ,  $namelist , "_" , $instancelist ) }
      else
      { 
      $file_name = -join( $outputfolder.Replace('\', '\\'),  $namelist , "_" , $instancelist ) }

      $target="";

      <#
      AzureSqlDatabase, 
      ManagedSqlServer, 
      SqlServer2012, 
      SqlServer2014, 
      SqlServer2016, 
      SqlServerLinux2017
      SqlServerWindows2017
      SqlServerLinux2019
      SqlServerWindows2019
      SqlServerWindows2022
      #>
  
      # Main Running: DMA (Compatibility) assessment starts from here...
      Write-host "Running: DMA (Compatibility) assessment for :$($namelist) \  $($instancelist)" -ForegroundColor green

      $dmacommand="";

      For ($j=1; $j -le 3; $j++) {

      if($j -eq 1) {
        $target="AzureSqlDatabase";
       }elseif($j -eq 2) {
        $target="ManagedSqlServer";
       }else {
          if($productlist -like "*2022*") {
            $target="SqlServerWindows2022";
           }elseif($productlist -like "*2019*") {
            $target="SqlServerWindows2019";
           }elseif($productlist -like "*2017*") {
            $target="SqlServerWindows2017";
           }elseif($productlist -like "*2016*") {
            $target="SqlServer2016";
           }elseif($productlist -like "*2014*") {
            $target="SqlServer2014";
           }elseif($productlist -like "*2012*") {
            $target="SqlServer2012";
           }elseif($productlist -like "*2008*") {
            $target="SqlServer2012";
           }else {
            $target="SqlServer2012"
           }
       }


     
      try
      {
          $dmacommand=".\DmaCmd.exe"
          $dmaparam=-join(" /AssessmentName=", '"' , $namelist , "_" , $instancelist ,"_",$target ,'" ',
           "/AssessmentDatabases=",'"',  $db_connection_string,'" ', 
           "/AssessmentSourcePlatform=",'"',"SqlOnPrem",'" ',
           "/AssessmentTargetPlatform=",'"',$target,'" ', 
           "/AssessmentEvaluateCompatibilityIssues ",
           "/AssessmentOverwriteResult " ,
           "/AssessmentResultCsv=",'"',$file_name,"_",$target,".csv",'" ',
           "/AssessmentResultJson=",'"',$file_name,"_",$target,".json",'" ',
           "/AssessmentResultDma=",'"',$file_name,"_",$target,".dma",'" ')
      }
      catch
      {
        throw $_.Exception.Message 
      }
      cd "C:\Program Files\Microsoft Data Migration Assistant"
      
          $DMANeeded = "1", "2"
          if($DMANeeded.Contains($taskToPerform))
          {
            if(($dmarunstatus | where {$_.ServerName -eq $namelist -and $_.InstanceName -eq $instancelist}).Status -ne "S")
            {
                if(($dmarunstatus | where {$_.ServerName -eq $namelist -and $_.InstanceName -eq $instancelist}))
                {
                    Write-Host "Retrying previously failed instance" -ForegroundColor Yellow
                }
                Invoke-Expression "$dmacommand $dmaparam"
            }
            else
            {
                Write-Host "Assessment already done successfully. Hence skipped" -ForegroundColor Green
            }
          }

      } # Three time Loop
           
           
          #DMARunStatus.csv Update
          $DMANeeded = "1","2"
          if($DMANeeded.Contains($taskToPerform))
          {
            if(($dmarunstatus | where {$_.ServerName -eq $namelist -and $_.InstanceName -eq $instancelist}))
            {
                Write-Host "Updating progress..."
                foreach($server in $dmarunstatus)
                {
                    if($server.ServerName -eq $namelist -and $server.InstanceName -eq $instancelist)
                    {
                        if((Test-Path "$($file_name)_AzureSqlDatabase.*") -and (Test-Path "$($file_name)_ManagedSqlServer.*") -and (Test-Path "$($file_name)_$($target).*"))
                        {
                            $server.Status = "S"
                        }
                        else
                        {
                            $server.Status = "F"   
                        }
                        $dmarunstatus | Export-Csv "$folder\Logs\DMARunStatus.csv"
                    }
                }
            }
            else
            {
                $dmarunstatus.ServerName = $namelist
                $dmarunstatus.InstanceName = $instancelist
                if((Test-Path "$($file_name)_AzureSqlDatabase.*") -and (Test-Path "$($file_name)_ManagedSqlServer.*") -and (Test-Path "$($file_name)_$($target).*"))
                {
                    $dmarunstatus.Status = "S"
                }
                else
                {
                    $dmarunstatus.Status = "F"   
                }
                $dmarunstatus | Export-Csv -Append "$folder\Logs\DMARunStatus.csv"
             }
          }



           # Main Running: DMA (Compatibility) assessment starts from here...
           #   Write-host "Running: DMA (Compatibility) assessment for : $dmacommand "

          $i = $i + 1
          } #main FOR (loop ) each row in the input excel 
                  
        } # main for loop try
     catch {
         Write-Host "================================================================================"  
         Write-Host "Error while running the assessment for $($namelist) "  -ForegroundColor Red  
         Write-Host "================================================================================"  
         Write-Host "Please see the error below & DMA assessment has been stopped          " -ForegroundColor white
         throw $_.Exception.Message
     } #main for loop catch


$DMANeeded = "1","2"
if($DMANeeded.Contains($taskToPerform))
{
    $Report_start_time=Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss K"
    $strdate = Get-Date -Format "MMddyyyy_HHmm"
    Compress-Archive -Path "$folder\output\*.*" -DestinationPath "$folder\output\Compressed\SMF_DMAAssessment_$strdate.zip"
    Write-Host "DMA Assessment Completed.....: " $Report_start_time  -ForegroundColor Green
}
else
{
    Write-Host "DMA Assessment Skipped.....: " $Report_start_time  -ForegroundColor Green
}

if(Test-Path "$folder\Logs\DMARunStatus.csv")
{
    Import-Csv "$folder\Logs\DMARunStatus.csv"
}
else
{
    $dmarunstatus
}
<#
--------------FOR SKU ASSESSMENT-----
#>


"]," | Out-file -Append $folder\Config\SKUConfig.json
"""outputFolder"": ""$($folder -replace '[\\/]','\\')\\output\\PerfData""" | Out-file -Append $folder\Config\SKUConfig.json
"}" | Out-File -Append $folder\Config\SKUConfig.json
<#
----------------------------------
#>


$pbform1.Close()

Write-Host "============================================================================================================"  
Write-Host "Assessment data stored compressed at $folder\output\Compressed" -ForegroundColor Green -BackgroundColor Black
Write-Host "============================================================================================================" 
Invoke-Item "$folder\output\Compressed"

}  # if input and output 
else
{    
         Write-Host "============================================================================================================"  
         Write-Host "Unable to locate the ouput folder [$outputfolder] or Inputfile [$inputfile] , Check folder & its permission...  "  -ForegroundColor Red  
         Write-Host "============================================================================================================"  
}
Stop-Transcript

$SKUNeeded = "1", "3"
if($SKUNeeded.Contains($taskToPerform))
{
        Write-Host "======================================================================================="  
        Write-Host "Continue Performance Data Collection ?  "  -ForegroundColor Green
        Write-Host "======================================================================================="
        $response = read-host "Enter 'Y' to continue or any other key to abort"
    
        if($response -eq "Y")
        {

        Write-Host "Please Provide the Data Collection duration in Day/s " -ForegroundColor Green
    Write-Host "===================================================================="
    Write-Host "Valid Inputs for Date Range is 0 to 15" 
    Write-Host "If you want to run the data collections below one day please enter 0 "

    #$validInputs_Days = "0", "1", "2", "3", "4" ,"5", "6", "7", "8" , "9", "10", "11", "12" , "13", "14", "15"
    $validInputs_Days = 0..15
    do {
    [int]$Day_response = Read-Host -Prompt "Enter Day value"
    if(-not $validInputs_Days.Contains($Day_response)){write-host "Please select the choice between 0 - 15"}
    } until ($validInputs_Days.Contains($Day_response))

            Write-Host "Please Provide the Data Collection duration Hours " -ForegroundColor Green
    Write-Host "===================================================================="
    Write-Host "Valid Inputs for Hour Range is 1 to 23" 
    Write-Host "If you do not want to add Hours please enter 0 "

    $validInputs_Hours = 0..23
    do {
   [int]$Hour_response = Read-Host -Prompt "Enter  Hour value"
    if(-not $validInputs_Hours.Contains($Hour_response)){write-host "Please select the choice between 0 - 23"}
    } until ($validInputs_Hours.Contains($Hour_response))

   [int]$Delay_Time = (($Day_response*24*60*60)+($Hour_response*60*60))

   write-host $Delay_Time -ForegroundColor Green
            Write-Host "Config file ready..."
            Write-Host "Triggering Performance data collection"
            createFolder $folder\output\PerfData
            Start-Job -FilePath $PSScriptRoot\Terminate.ps1 -ArgumentList $Delay_Time
            #Start-Process PowerShell -Arg $PSScriptRoot/Terminate.ps1
            cd "C:\Program Files\Microsoft Data Migration Assistant\SqlAssessmentConsole"
               # C:\Program Files\Microsoft Data Migration Assistant\SqlAssessmentConsole\SqlAssessment.exe
            .\SqlAssessment.exe --configFile $folder\Config\SKUConfig.json
            $strdate = Get-Date -Format "MMddyyyy_HHmm"
            Compress-Archive -Path "$folder\output\PerfData\*.*" -DestinationPath "$folder\output\Compressed\SMF_SKUAssessment_$strdate.zip"
            Write-Host "=============================================================================================================="  
            Write-Host "Performance data stored compressed at $folder\output\Compressed" -ForegroundColor Green -BackgroundColor Black
            Write-Host "==============================================================================================================" 
            Invoke-Item "$folder\output\Compressed"


        }
        else
        {
            exitCode
        }
}

$username = "student-1545-1760379@labscloudacademy.onmicrosoft.com"
$password= "Ca1_xFfgb8W0"
az login -u $username -p $password
$SecurePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($username, $SecurePassword)
Login-AzAccount -Credential $credentials
$resourceGroupNames = Get-AzResourceGroup
$resourceGroupName = $resourceGroupNames[0].ResourceGroupName
$StorageAccountNames = Get-AzStorageAccount -ResourceGroupName $resourceGroupName
$StorageAccountName = $StorageAccountNames[0].StorageAccountName

$Context = $StorageAccountNames[0].Context
$ContainerName = 'backup'

$SKUNeed = "1", "2"
if($SKUNeed.Contains($taskToPerform))
{
Write-Host "Server Name : " $namelist

# upload a file to the default account (inferred) access tier
$Blob1HT = @{
  File             = 'C:\Users\sqladmin\output\'+$namelist+'_MSSQLSERVER_AzureSqlDatabase.csv'
  Container        = $ContainerName
  Blob             = "$namelist"+"_MSSQLSERVER_AzureSqlDatabase1.csv"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob1HT
}

$SKUNeed1 = "1", "3"
if($SKUNeed1.Contains($taskToPerform))
{

# upload a file to the default account (inferred) access tier
$Blob1HT = @{
  File             = 'C:\Users\sqladmin\output\'+$namelist+',MSSQLSERVER_PerformanceAggregated_Counters.csv'
  Container        = $ContainerName
  Blob             = "$namelist"+",MSSQLSERVER_PerformanceAggregated_Counters.csv"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob1HT
}

timeout /t -1
