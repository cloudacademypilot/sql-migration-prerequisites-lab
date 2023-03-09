# DMA Assessment

## Data Migration Assistant

**The Data Migration Assistant (DMA)** helps you upgrade to a modern data platform by detecting compatibility issues that can impact database functionality in your new version of SQL Server or Azure SQL Database. DMA recommends performance and reliability improvements for your target environment and allows you to move your schema, data, and uncontained objects from your source server to your target server.

## Capabilities of DMA

- Assess on-premises SQL Server instance(s) migrating to Azure SQL database(s). The assessment workflow helps you to detect the following issues that can affect Azure SQL database migration and provides detailed guidance on how to resolve them.

  - Migration blocking issues: Discovers the compatibility issues that block migrating on-premises SQL Server database(s) to Azure SQL Database(s). DMA provides recommendations to help you address those issues.

  - Partially supported or unsupported features: Detects partially supported or unsupported features that are currently in use on the source SQL Server instance. DMA provides a comprehensive set of recommendations, alternative approaches available in Azure, and mitigating steps so that you can incorporate them into your migration projects.

- Discover issues that can affect an upgrade to an on-premises SQL Server. These are described as compatibility issues and are organized in the following categories:
  - Breaking changes
  - Behavior changes
  - Deprecated features

- Discover new features in the target SQL Server platform that the database can benefit from after an upgrade. These are described as feature recommendations and are organized in the following categories:
  - Performance
  - Security
  - Storage

- Migrate an on-premises SQL Server instance to a modern SQL Server instance hosted on-premises or on an Azure virtual machine (VM) that is accessible from your on-premises network. The Azure VM can be accessed using VPN or other technologies. The migration workflow helps you to migrate the following components:
  - Schema of databases
  - Data and users
  - Server roles
  - SQL Server and Windows logins

- After a successful migration, applications can connect to the target SQL Server databases seamlessly.

- Assess on-premises SQL Server Integration Services (SSIS) package(s) migrating to Azure SQL Database or Azure SQL Managed Instance. The assessment helps to discover issues that can affect the migration. These are described as compatibility issues and are organized in the following categories:
  - Migration blockers: discovers the compatibility issues that block migrating source package(s) to Azure. DMA provides recommendations to help you address those issues.
  - Information issues: detects partially supported or deprecated features that are used in source package(s).

## DMA Assessments to migrate to Azure SQL Database(s)

   ![DMA Assessment](assets/DMA.jpg)

## Learning Objectives

This lab step is to provide the detailed procedure/step to use the **Data Migration Assistant (DMA)** automation script (```SMF_DMAPreReqAssessCombo_V5.8.ps1```) to detect/assess the following issues in on-premise SQL Servers:

- Migration blocking issues: 
    - To discover the compatibility issues that block migrating on-premises SQL Server database(s) to Azure SQL Database
    - To discover the compatibility issues that block migrating on-premises SQL Server database(s) to Azure SQL Managed Instance
    - To discover the compatibility issues that block migrating on-premises SQL Server database(s) to SQL Server on Azure Virtual Machines 
- Compatibility issues - Data Migration Assistant also identifies compatibility issues related to the following areas:
    - Breaking changes: The specific schema objects that may break the functionality migrating to the target database. We recommend fixing these schema objects after the database migration.
    - Behavioral changes: The schema objects reported may continue to work, but they may exhibit a different behavior, for example performance degradation.
    - Informational issues: These objects won't impact the migration but may have been deprecated from feature SQL Server releases.
- And to initiate & terminate the data-collection process for the target SKU assessment.

## Prerequisites for DMA Assessment

- Virtual Machine - Already setup for you.
- Software & PowerShell module:
    - .NET Core 3.1.28
    - .NET Framework 4.8
    - Microsoft® Data Migration Assistant v5.6
    - ImportExcel  
- Input Excel File - The DMA automation script is based on the worksheet named ‘DMA-INPUT-FILE.xlsx’ and following columns in worksheet of the Input Excel file:

Column Name | Note
------------- | -------------
Computer Name | SQL Server Name (e.g. 01SQLDEV001)
SQL Server Instance Name | SQL Server Instance Name (e.g. MSSQLSERVER)
SQL Server Product Name | SQL Server Product Name (e.g. Microsoft SQL Server 2016)
Authentication type | Authentication type (e.g. either Windows Authentication or SQL Server Authentication)
DBUserName | Database User Name (e.g. sa) in case of SQL Server Authentication. User must be member of the SQL Server sysadmin role
DBPassword | Database User Password (e.g. Password123) in case of SQL Server Authentication
DBPort | Database Port (e.g. 1433)

## Exercise 1: Connecting to virtual machine via RDP

1. Go to **Azure portal** and click on hamburger button ☰ on top-left side and select **Resource groups**. Select the resource group deployed in the Azure Portal. Amongst the list of resources, open the **virtual machine** starting with name ```Target{*}```.

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

1. Click on **File Explorer** present in Taskbar at the bottom. Go to ```C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.15\Downloads\0``` path. This folder contains ```DMA-INPUT-FILE.xlsx```, ```SMF_DMAPreReqAssessCombo_V5.8.ps1``` and ```Terminate.ps1``` files.

    ![DMA Assessment](assets/14.jpg)
    
    ![DMA Assessment](assets/15.jpg)
    
    ![DMA Assessment](assets/16.jpg)

2. Select these files and right-click on the mouse and select **Copy** or press **Ctrl + C**.

    ![DMA Assessment](assets/17.jpg)

3. Now go to ```C:\Users\sqladmin``` path and right-click on the mouse and select **Paste** or press **Ctrl + V** to paste the files in this folder.

    ![DMA Assessment](assets/18.jpg)
    
    ![DMA Assessment](assets/19.jpg)
    
## Exercise 3: Preparing the Input excel file

1. Search for ```Office``` in the **Search bar** at the bottom and click **Open**.

    ![DMA Assessment](assets/20.jpg)

2. Click **Sign in** and sign into **MS office** using your lab credentials.

    ![DMA Assessment](assets/21.jpg)

3. Select **Excel** and then click **Upload and open...** option. Browse to ```C:\Users\sqladmin``` path and select ```DMA-INPUT-FILE.xlsx``` file and select **Open**. It will be opened in the Microsoft Edge browser.

    ![DMA Assessment](assets/22.jpg)
    
    ![DMA Assessment](assets/23.jpg)

4. This is the sample input file. You need to edit the contents of the excel file ```Computer Name```, ```DBUserName``` and ```DBPassword``` columns and make sure other columns are correct. 

    ![DMA Assessment](assets/24.jpg)

5. Replace ```testuser``` with  ```sqladmin``` in **DBUserName** column and replace```12345``` with  ```Mail@123``` in **DBPassword** column. Ensure that Database User Name and Password are correct and can connect to SQL Server instance to be assessed in case of SQL Server Authentication.

    ![DMA Assessment](assets/25.jpg)

6. To get the **Computer name**, go back to the azure portal opened in your local machine and inside resource group, copy the virtual machine name starting with ```Source{*}```. And switch back to virtual machine and paste it in the excel replacing **localhost**. Ensure the Computer Names are correct and connectivity exists between the virtual machine which runs the DMA assessment and Computer Name provided in the column.

    ![DMA Assessment](assets/26.jpg)
    
    ![DMA Assessment](assets/27.jpg)

7. Ensure the **SQL SERVER Product Name** is one of the below given values:
   - Microsoft SQL Server 2022
   - Microsoft SQL Server 2019
   - Microsoft SQL Server 2017
   - Microsoft SQL Server 2016
   - Microsoft SQL Server 2014
   - Microsoft SQL Server 2012
   - Microsoft SQL Server 2008

    ![DMA Assessment](assets/28.jpg)
 
8. Ensure that **Authentication type** is either **Windows Authentication** or **SQL Server Authentication**.

    ![DMA Assessment](assets/29.jpg)

9. Ensure Database ports are correct and can connect to SQL Server instance with this port. 

    ![DMA Assessment](assets/30.jpg)

10. Once the input file is prepared, Select **File** at top-left side and then **Save As** and click **Download a copy**. 

    ![DMA Assessment](assets/31.jpg)
    
    ![DMA Assessment](assets/32.jpg)

11. Open **File explorer** and Go to **Downloads** folder and select ```DMA-INPUT-FILE.xlsx``` file and right-click on the mouse and select **Copy** or press **Ctrl + C**. Now go to ```C:\Users\sqladmin``` path and right-click on the mouse and select **Paste** or press **Ctrl + V** to replace the existing file. Please make sure that the file name should not be changed.

    ![DMA Assessment](assets/33.jpg)
    
    ![DMA Assessment](assets/34.jpg)

## Exercise 4: Runing DMA assessment powershell script

1. In ```C:\Users\sqladmin``` path, right-click on ```SMF_DMAPreReqAssessCombo_V5.8.ps1``` script and select **Run with PowerShell** to run the script.

    ![DMA Assessment](assets/35.jpg)

2. Now **Windows powershell** will open and ask for your input.

    ![DMA Assessment](assets/36.jpg)

3. Give ```2``` as input value and hit enter to perform DMA Assessment. After triggering the automation all the support folders( Archive , output , Downloads etc. ) will be created automatically by the automation script in the ```C:\Users\sqladmin``` folder. 

    ![DMA Assessment](assets/37.jpg)
    
    ![DMA Assessment](assets/38.jpg)
    
> Note: .Net 4.8, .Net Core, DMA and ImportExcel PS module are required for this assessment.  

4. **.Net 4.8** is already available in the virtual machine. So, it will ask for your input to install **DMA**. Enter ```Y``` to download & install the DMA 5.6.

    ![DMA Assessment](assets/39.jpg)

5. Once DMA is installed, it will check for **.Net Core** availability and ask for your input to install **.Net Core**. Enter ```Y``` to install .Net Core.

    ![DMA Assessment](assets/40.jpg)

6. Next it will check for ImportExcel PowerShell module and then install it.

    ![DMA Assessment](assets/41.jpg)

7. After all the requirements are installed, DMA assessment will run and it will bring up a pop up window where the DMA assessment result is available as shown below.

    ![DMA Assessment](assets/43.jpg)

8. Press any key to continue.

    ![DMA Assessment](assets/42.jpg)

9. Again you need to run the script to Perform performance data gathering. In ```C:\Users\sqladmin``` path, right-click on ```SMF_DMAPreReqAssessCombo_V5.8.ps1``` script and select **Run with PowerShell** to run the script.

    ![DMA Assessment](assets/35.jpg)

10. Give ```3``` as input value to select Perform performance data gathering.

    ![DMA Assessment](assets/44.jpg)

11. It will again check for all the prerequisites and ask for your input. Enter ```Y``` to continue performance data collection. 

    ![DMA Assessment](assets/45.jpg)

12. Upon entering ```Y``` the console will ask for two additional parameters:
   
   - Please Provide the Data Collection duration in Day/s – Here , please put any value between 0 to 15 .
> Note : There might be a situation where user may want to run this for less than 24 hours , in that situation user should put 0.

In the below example we put the day range as 1.

   ![DMA Assessment](assets/46.jpg)
    
   - Next the console will ask Hour value (Please Provide the Data Collection duration Hours) – Here , please put any value between 0 to 23. And press enter.
> Note : If you put the Day value as 0 , please do not put the Hour value as 0 ( It should be anything between 1-23 )

In the below example we put the hour range as 1.

   ![DMA Assessment](assets/47.jpg)

13. After that the process will initiate. The process will continue to run as per the time range provided by the user in the last step and terminate automatically (Note – User also can terminate the process by pressing enter key).

    ![DMA Assessment](assets/48.jpg)

This will allow the performance data to be collected to select the best Azure SQL Database, SQL Managed Instance, or SQL Server on Azure VM target and SKU for your database. Database Migration Assistant (DMA) helps address these questions and make your database migration experience easier by providing these SKU recommendations. It is recommended that the performance data gathering is run for minimum four hours during the peak SQL Server workloads.

After running for a specific period of time, the process will stop executing on its own as per the Day/Hour values provided by the user, otherwise Press Enter Key in the window where the script is running.

14. Wait for 2-3 minutes and press enter to terminate. It will bring up a pop up window where the SKU performance results are available.

    ![DMA Assessment](assets/49.jpg)
    
15. Press Enter key.
    
## Exercise 5: Connecting to Source Virtual Machine

1. Go to **Azure portal** and click on hamburger button ☰ on top-left side and select **Resource groups**. Select the resource group deployed in the Azure Portal. Amongst the list of resources, open the **virtual machine** starting with name ```Source{*}```.

    ![DMA Assessment](assets/1.jpg)
    
    ![DMA Assessment](assets/2.jpg)
    
    ![DMA Assessment](assets/50.jpg)
    
2. Click on **Connect** and then click **Select** to connect via native RDP. Click **Download RDP file** to download.   

    ![DMA Assessment](assets/51.jpg)
    
    ![DMA Assessment](assets/52.jpg)
    
    ![DMA Assessment](assets/53.jpg) 

3. File will be downloaded inside **Downloads** folder in your local system. Open the RDP file. Then select **Connect**.    

    ![DMA Assessment](assets/54.jpg)
    
    ![DMA Assessment](assets/55.jpg) 

4. Click on **More choices** and then select **Use a different account**. Enter ```sqladmin``` as Email address and ```Mail@123``` as Password. Click **Ok**. And Select **Yes** to verify the certificate.

    ![DMA Assessment](assets/56.jpg) 
    
    ![DMA Assessment](assets/57.jpg) 
    
    ![DMA Assessment](assets/58.jpg)
    
    ![DMA Assessment](assets/59.jpg) 

5. Now you are inside the **virtual machine**. **Server Manager** page will pop up. Please close it.

    ![DMA Assessment](assets/60.jpg)    

6. Search for ```SSMS``` in the **Search bar** at the bottom and Open it.

    ![DMA Assessment](assets/61.jpg)

7. **Connect to Server** page will pop up. Click **Connect** to connect to the server. 

    ![DMA Assessment](assets/62.jpg)

8. Expand **Databases** by clicking on ⊕. You will see two databases by default: ```SampleDatabase1``` and ```SampleDatabase2```. Please refresh if you are not able to see the databases.

    ![DMA Assessment](assets/63.jpg)
    
    ![DMA Assessment](assets/64.jpg)

## Exercise 6: Executing SQL queries on source database to increase complexity and create compatibility issues

1. Click on **New Query** and Copy-Paste the following query and click **Execute**. 

    ![DMA Assessment](assets/65.jpg)

    ```
    use SampleDatabase1
    Go
    create proc Display_Files_CDrive
    as
    begin
    DECLARE @CommandL1 varchar(512)
    SET @CommandL1 = 'dir C:\'
    exec master..xp_cmdshell @CommandL1
    end
    GO
    ```
2. Click on **New Query** and Copy-Paste the following query and click **Execute**.
    
    ![DMA Assessment](assets/65.jpg)
    
    ```
    use SampleDatabase1
    Go
    Create proc uspPrintShift
    as
    begin
    select distinct sdb1.Name  from SampleDatabase1.[SalesLT].[Product] sdb1
    left join SampleDatabase2.[SalesLT].[Product] sdb2
    on sdb2.ProductID =sdb1.ProductID
    end
    Go
    ```
3. Click on **New Query** and Copy-Paste the following query and click **Execute**.    
    
    ![DMA Assessment](assets/65.jpg)
    
    ```
    use SampleDatabase1
    Go
    Create table SalesLT.Job_Description
    (
    Jobid int,
    jobDescription Text
    )
    Go
    ```
4. Click on **New Query** and Copy-Paste the following query and click **Execute**.    
    
    ![DMA Assessment](assets/65.jpg)
    
    ```
    ALTER DATABASE SampleDatabase1 SET ENABLE_BROKER WITH ROLLBACK IMMEDIATE
    GO
    ```

5. Now again go back to Target virtual machine and run ```SMF_DMAPreReqAssessCombo_V5.8.ps1``` script following the instructions of previous exercise **Exercise 4**.

## Exercise 7: Comparing compatibility 

Here we will compare the output of **Exercise 4**(without any compatibility issues) and **Exercise 6**(after creating compatibility issues).







