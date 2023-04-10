# Network Validation

## Learning Objectives

This lab step is to provide the detailed procedure/step to use the Network Validation script (Network_Validation.ps1) to perform the following basic checks on target SQL environmnent:
- Check for target server IP address
- Check for network diagnostics
- Check for firewall settings
- Check for infrastructure validation
- Check connection w.r.t port and server
- Check diskspace

## Prerequisites

- Virtual Machine - Already setup for you.
- ImportExcel and Az module  
- Input Excel File - The Network Validation script is based on the worksheet named ‘Network_Validation.xlsx’

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

4. Click on **More choices** and then select **Use a different account**. Enter ```sqladmin``` as Email address and ```Mail@123``` as Password. Click **Ok**. And Select **Yes** to verify the certificate.
    
    ![DMA Assessment](assets/9.jpg)
    
    ![DMA Assessment](assets/10.jpg)
    
    ![DMA Assessment](assets/11.jpg)
    
    ![DMA Assessment](assets/12.jpg)

5. Now you are inside the **virtual machine**.

    ![DMA Assessment](assets/13.jpg)

## Exercise 2: Copying powershell scripts and input excel file for DMA assessment

1. Click on **File Explorer** present in Taskbar at the bottom. Go to ```C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.15\Downloads\0``` path. This folder contains ```Network_Validation.xlsx``` and ```Network_Validation.ps1``` files.

    ![DMA Assessment](assets/14.jpg)
    
    ![DMA Assessment](assets/15.jpg)

2. Select these files and right-click on the mouse and select **Copy** or press **Ctrl + C**.

    ![DMA Assessment](assets/16.jpg)

3. Now go to ```C:\Users\sqladmin``` path and right-click on the mouse and select **Paste** or press **Ctrl + V** to paste the files in this folder.

    ![DMA Assessment](assets/17.jpg)
    
## Exercise 3: Preparing the Input excel file

1. Search for ```Office``` in the **Search bar** at the bottom and click **Open**.

    ![DMA Assessment](assets/25.jpg)

2. Click **Sign in** and sign into **MS office** using your lab credentials if you're not signed in.

    ![DMA Assessment](assets/21.jpg)

3. Select **Excel** and then click **Upload and open...** option. Browse to ```C:\Users\sqladmin``` path and select ```Network_Validation.xlsx``` file and select **Open**. It will be opened in the Microsoft Edge browser.

    ![DMA Assessment](assets/22.jpg)
    
    ![DMA Assessment](assets/23.jpg)

4. This is the sample input file. You need to edit the contents of the excel file and make sure the input values are correct.

    ![DMA Assessment](assets/24.jpg)

5. Open **Nslookup** worksheet. Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Target{*}```. Copy the **DNS name** and Paste it in the field **target server dns name**.

    ![DMA Assessment](assets/26.jpg) 
    
    ![DMA Assessment](assets/27.jpg)

6. Open **Network_Diagnostic** worksheet. 

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

    ![DMA Assessment](assets/35.jpg)
    
    ![DMA Assessment](assets/36.jpg)

    Go to **Azure Portal** opened in your local machine and search for **Azure Active Directory** and open it. Copy the **Tenant ID** and Paste it in the field **Tenant id**.

    ![DMA Assessment](assets/37.jpg)
    
    ![DMA Assessment](assets/38.jpg)

    Go to **Azure Portal** opened in your local machine and open the **Resource group**. Open the **Virtual machine** starting with ```Target{*}```. Copy the **Subscription ID** and Paste it in the field **Subscription**.

    ![DMA Assessment](assets/39.jpg)
    
    ![DMA Assessment](assets/40.jpg)
    
7. Open **Infra_validation** worksheet. Copy-Paste the **Resource group name**, **Target VM name**, **Tenant ID** and **Subscription ID** you copied earlier into the respective fields.

    ![DMA Assessment](assets/41.jpg)
    
8. Open **Windows_firewall** worksheet. Keep the values default.

    ![DMA Assessment](assets/42.jpg)

9. Open **Test-Connection** worksheet. Copy-Paste the **DNS name** of the Target VM into the field **target server dns name**.

    ![DMA Assessment](assets/43.jpg)

5. Open **Check_Diskspace** worksheet. Copy-Paste the **Private IP address** of the Target VM into the field **target server private ip address**.

    ![DMA Assessment](assets/44.jpg)

10. Once the input file is prepared, Select **File** at top-left side and then **Save As** and click **Download a copy**. 

    ![DMA Assessment](assets/45.jpg)

11. Open **File explorer** and Go to **Downloads** folder and select ```DMA-INPUT-FILE.xlsx``` file and right-click on the mouse and select **Copy** or press **Ctrl + C**. Now go to ```C:\Users\sqladmin``` path and right-click on the mouse and select **Paste** or press **Ctrl + V** to replace the existing file. Please make sure that the file name should not be changed.

    ![DMA Assessment](assets/46.jpg)
    
    ![DMA Assessment](assets/47.jpg)

## Exercise 4: Runing DMA assessment powershell script

1. In ```C:\Users\sqladmin``` path, right-click on ```Network_Validation.ps1``` script and select **Run with PowerShell** to run the script.

    ![DMA Assessment](assets/48.jpg)

2. Now **Windows powershell** will open and script will run. Creates the required folders and installs **ImportExcel** and **Az** modules.

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


    
7. Enter ```5``` for Infrastructure validation. Popup window will appear. Please login with your lab credentials.


    
8. Enter ```6``` for Checking Diskspace. Popup window will appear. Enter ```sqladmin``` as User name and ```Mail@123``` as Password. Click **Ok**.

    ![DMA Assessment](assets/56.jpg)
    
    ![DMA Assessment](assets/57.jpg)
    
    ![DMA Assessment](assets/60.jpg)
