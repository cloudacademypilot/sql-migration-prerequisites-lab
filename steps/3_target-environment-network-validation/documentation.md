# Network Validation

## Learning Objectives

This lab step is to provide the detailed procedure/step to use the Network Validation script (Network_Validation.ps1) to perform the following basic checks on target SQL environmnent:
- Check for target server IP address
- Check for network diagnostics
- Check for firewall settings
- Check for infrastructure validation
- Check connection w.r.t port and server

## Prerequisites

- Virtual Machine - Already setup for you.
- ImportExcel and Az module  
- Input Excel File - The Network Validation script is based on the worksheet named ```Network_Validation.xlsx```

## Exercise 1: Connecting to virtual machine via RDP

1. Go to **Azure portal** and click on hamburger button ☰ on top-left side and select **Resource groups**. Select the resource group deployed in the Azure Portal. Amongst the list of resources, open the **virtual machine** starting with name ```DMA```.

    ![DMA Assessment](assets/1.jpg)
    
    ![DMA Assessment](assets/2.jpg)
    
    ![DMA Assessment](assets/3.jpg)

2. Click on **Connect** and then click **Select** to connect via native RDP. Click **Download RDP file** to download.

    ![DMA Assessment](assets/4.jpg)
    
    ![DMA Assessment](assets/5.jpg)
    
    ![DMA Assessment](assets/6.jpg)

3. File will be downloaded inside **Downloads** folder in your local system. Open the RDP file. Then select **Connect**.

    ![DMA Assessment](assets/7.jpg)
    
    ![DMA Assessment](assets/8.jpg)

4. Click on **More choices** and then select **Use a different account**. Enter ```sqladmin``` as Email address and ```Password@123``` as Password. Click **Ok**. And Select **Yes** to verify the certificate.
    
    ![DMA Assessment](assets/9.jpg)
    
    ![DMA Assessment](assets/10.jpg)
    
    ![DMA Assessment](assets/11.jpg)
    
    ![DMA Assessment](assets/12.jpg)

5. Now you are inside the **virtual machine**.

    ![DMA Assessment](assets/13.jpg)

## Exercise 2: Copying powershell scripts and input excel file for basic target server network validation

1. Click on **File Explorer** present in Taskbar at the bottom. Go to ```C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.15\Downloads\0``` path. This folder contains ```Network_Validation.xlsx``` and ```Network_Validation.ps1``` files.

    ![DMA Assessment](assets/14.jpg)
    
    ![DMA Assessment](assets/15.jpg)

2. Select these files and right-click on the mouse and select **Copy** or press **Ctrl + C**.

    ![DMA Assessment](assets/16.jpg)

3. Now go to ```C:\Users\sqladmin``` path and right-click on the mouse and select **Paste** or press **Ctrl + V** to paste the files in this folder.

    ![DMA Assessment](assets/17.jpg)
    
## Exercise 3: Preparing the Input excel file

1. We need **Excel** to edit the input excel file. Since **CloudAcademy** lab credentials don't have license to MS office. Please use your Microsoft account to use MS office for editing.

2. Search for ```Office``` in the **Search bar** at the bottom and click **Open**.

    ![DMA Assessment](assets/25.jpg)

3. Click **Sign in** and sign into **MS office** using your Microsoft account credentials if you're not signed in. (You have already signed-in in the previous lab step)

    ![DMA Assessment](assets/21.jpg)
    
    **Note: If you are not able to login with your Microsoft account credentials, Please copy-paste the file to your local machine and make the changes and again copy-paste into the virtual machine.**

4. Select **Excel** and then click **Upload and open...** option. Browse to ```C:\Users\sqladmin``` path and select ```Network_Validation.xlsx``` file and select **Open**. It will be opened in the Microsoft Edge browser.

    ![DMA Assessment](assets/22.jpg)
    
    ![DMA Assessment](assets/23.jpg) 

5. This is the sample input file. You need to edit the contents of the excel file and make sure the input values are correct and not prefixed/suffixed with any special characters/whitespaces while copy-pasting to excel file**.

    ![DMA Assessment](assets/24.jpg)

6. Open **Nslookup** worksheet. Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Target{*}```. Copy the **DNS name** and Paste it in the field **target server dns name**.

    ![DMA Assessment](assets/26.jpg) 
    
    ![DMA Assessment](assets/27.jpg)

7. Open **Network_Diagnostic** worksheet. 

    ![DMA Assessment](assets/28.jpg) 
    
    Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Source{*}```. Copy the **Private IP address** and Paste it in the field **source server private ip address**.
    
    ![DMA Assessment](assets/29.jpg)
    
    ![DMA Assessment](assets/30.jpg)
    
    Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Target{*}```. Copy the **Private IP address** and Paste it in the field **target server private ip address**.

    ![DMA Assessment](assets/31.jpg)
    
    ![DMA Assessment](assets/32.jpg)
    
    Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Target{*}```. Copy the **Subscription ID**, **Resource group name** and **Target VM name**. And Paste it in the respective placeholders ```/subscriptions/{SubscriptionID}/resourceGroups/{resourcegroupname}/providers/Microsoft.Compute/virtualMachines/{target vm name}```.

    ![DMA Assessment](assets/33.jpg)
    
    ![DMA Assessment](assets/34.jpg)

    Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Target{*}```. Copy the **Location** and Paste it in the field **location**. 
    Note : **Location** should be in small case letters without any whitespaces. For ex: ```East US``` should be ```eastus```, ```West US 2``` should be ```westus2```.

    ![DMA Assessment](assets/35.jpg)
    
    ![DMA Assessment](assets/36.jpg)

    Go to **Azure Portal** opened in your local machine and search for **Azure Active Directory** and open it. Copy the **Tenant ID** and Paste it in the field **Tenant id**.

    ![DMA Assessment](assets/37.jpg)
    
    ![DMA Assessment](assets/38.jpg)

    Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Target{*}```. Copy the **Subscription ID** and Paste it in the field **Subscription**.

    ![DMA Assessment](assets/39.jpg)
    
    ![DMA Assessment](assets/40.jpg)
    
8. Open **Infra_validation** worksheet. Copy-Paste the **Resource group name**, **Target VM name**, **Tenant ID** and **Subscription ID** you copied earlier into the respective fields.

    ![DMA Assessment](assets/41.jpg)
    
9. Open **Windows_firewall** worksheet. Keep the values default.

    ![DMA Assessment](assets/42.jpg)

10. Open **Test-Connection** worksheet. Copy-Paste the **DNS name** of the Target VM into the field **target server dns name**.

    ![DMA Assessment](assets/43.jpg)

11. Once the input file is prepared, Select **File** at top-left side and then **Save As** and click **Download a copy**. 

    ![DMA Assessment](assets/45.jpg)

12. Open **File explorer** and Go to **Downloads** folder and select ```Network_Validation.xlsx``` file and right-click on the mouse and select **Copy** or press **Ctrl + C**. Now go to ```C:\Users\sqladmin``` path and right-click on the mouse and select **Paste** or press **Ctrl + V** to replace the existing file. Please make sure that the file name should not be changed.

    ![DMA Assessment](assets/46.jpg)
    
    ![DMA Assessment](assets/47.jpg)
    
## Exercise 4: Runing target server network validation powershell script

1. In ```C:\Users\sqladmin``` path, right-click on ```Network_Validation.ps1``` script and select **Run with PowerShell** to run the script.

    ![DMA Assessment](assets/48.jpg)

2. Now **Windows powershell** will open and script will run. Creates the required folders and installs **ImportExcel** and **Az** modules. Please wait for 2-3 minutes.

    ![DMA Assessment](assets/49.jpg)

3. Enter ```1``` for Validation of the IP adress.

    ![DMA Assessment](assets/50.jpg)
    
    ![DMA Assessment](assets/51.jpg)
    
4. Enter ```2``` for Checking inbound and outbound rules of firewall.

    ![DMA Assessment](assets/52.jpg)
    
    ![DMA Assessment](assets/53.jpg)
    
5. Enter ```3``` for Test connection w.r.t target vm and port.

    ![DMA Assessment](assets/54.jpg)
    
    ![DMA Assessment](assets/55.jpg)
    
6. Enter ```4``` for Checking Network diagnostics. Popup window will appear. Please login with your lab credentials.

    ![DMA Assessment](assets/61.jpg)
    
    ![DMA Assessment](assets/58.jpg)
    
    ![DMA Assessment](assets/59.jpg)
    
    ![DMA Assessment](assets/62.jpg)
    
7. Enter ```5``` for Infrastructure validation. Popup window will appear. Please login with your lab credentials.

    ![DMA Assessment](assets/63.jpg)
    
    ![DMA Assessment](assets/58.jpg)
    
    ![DMA Assessment](assets/59.jpg)
    
    ![DMA Assessment](assets/64.jpg)
    
    In the output, you can see that ```VM_SKU``` is **Standard_D2as_v4**. You can compare it with the recommended compute size from SKU recommendation report generated in the previous lab step.
    
    ![DMA Assessment](assets/49-7.jpg)
   
9. Enter ```6``` to Exit. An Excel file will be created with all the information in ```C:\Users\sqladmin\Output``` folder.
