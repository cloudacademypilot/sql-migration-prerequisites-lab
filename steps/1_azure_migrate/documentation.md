# Azure Migrate Application Dependency Mapping/Assessment

This lab provides step by step procedures to configure dependency analysis in **Azure Migrate: Discovery and assessment**.

Dependency analysis identifies dependencies between discovered on-premises servers. It provides these advantages:

- This lets us to gather servers into groups for assessment more accurately.
- Identification of servers that must be migrated together. This is especially useful if there are no data about app dependency.
- Analyzing dependencies helps ensure that nothing is left behind, and thus avoids surprise outages after migration.

## Hosting Web Application

## Connecting to application server virtual machine via RDP

1. Go to **Azure portal** and click on hamburger button ☰ on top-left side and select **Resource groups**. Select the resource group deployed in the Azure Portal. Amongst the list of resources, open the **virtual machine** .

2. Click on **Connect** and then click **Select** to connect via native RDP. Click **Download RDP file** to download.

3. File will be downloaded inside **Downloads** folder in your local system. Open the RDP file. Then select **Connect**.

4. Click on **More choices** and then select **Use a different account**. Enter ```sqladmin``` as Email address and ```Mail@123``` as Password. Click **Ok**. And Select **Yes** to verify the certificate.

5. Now you are inside the **virtual machine**.

### IIS Configuration

Before hosting any site on the WebServer(IIS), We need to activate the **server** role for the IIS and ASP.NET 4.7.

Connect Webserver1 as mentions above and follow below steps :

1. Inside server, Open **Server Manager** and click on **Add roles and feature**.

    ![AzureMigrate](assets/image76.png)

2. Go to Server Roles by clicking on **Next** button.

3. Search for **WebServer (IIS)** and check the checkbox. Use **Add Features** button to add the feature.

    ![AzureMigrate](assets/image77.png)

4.	Click on **next** and then **install**.

    ![AzureMigrate](assets/image78.png)
    
    ![AzureMigrate](assets/image79.png)
    
5.	Reopen **Add Roles and Feature Wizard** by clicking on **Add roles and feature**. 

6.	Go to server role and Check the **ASP.NET 4.7** check box.

    ![AzureMigrate](assets/image80.png)

7.	Click on **next** and then **install**.

    ![AzureMigrate](assets/image81.png)

8.	Close the wizard.

> Note: VM Restart is not required.

### Hosting Application

Now we have activated the Server Role for the IIS and ASP.NET 4.7. Next, we will publish the website over the IIS.

1.	Open ```C drive``` and extract the **adventure.zip** file.

2.	Open the extracted folder and open **web.config** in notepad to edit.

3.	Replace the **server name** in the connection string with the **Source Server IP or hostname**.

    ![AzureMigrate](assets/image82.png)

4.	Open Run Window using **Ctrl + R** and enter **inetmgr** and press enter.

    ![AzureMigrate](assets/image83.png)

5.	This will open the **IIS Manager**.

6.	First we will delete the default website hosted on Port number 80 then host our website. Right click on the **Default Web Site** and remove.

    ![AzureMigrate](assets/image83_1.jpg)

7.	Right click on **Sites** and select **Add Website**.

    ![AzureMigrate](assets/image84.png)

8.	Provide the site name as ```adventure```.

9.	Select the **Physical Path** as ```C:/adventure``` and use Port number ```80```.

    ![AzureMigrate](assets/image85.png)

10.	Add default document as **home.aspx**.

    ![AzureMigrate](assets/image86_1.jpg)
    ![AzureMigrate](assets/image86.png)

11.	Now Browse the application and check data.

     ![AzureMigrate](assets/image87.jpg)

## Create a project in Azure Migrate

Set up a new project in an Azure subscription -

1. In the Azure portal, search for **Azure Migrate**.

2. In Services , select **Azure Migrate**.

3. In Overview , select **Discover, assess, and migrate**.

    ![AzureMigrate](assets/image1.png)

4. In Servers, databases, and web apps , select **Create project**.

    ![AzureMigrate](assets/image2.png)

5. In Create project , select the **Azure subscription**, and **resource group**.

6. In Project Details , specify the **project name** as **adventureMigrate** and the **geography** in which you want to create the project.

    - The geography is only used to store the metadata gathered from on-premises servers. You can assess or migrate servers for any target region regardless of the selected geography.

7. Select **Create** to initiate Project deployment.

    ![AzureMigrate](assets/image3.png)

## Azure Migrate appliance:

Set up the appliance by with below steps:

1. In Azure Migrate Hub, under **Migration tools** select **Discover**.

    ![AzureMigrate](assets/image4.png)

2. In Discover page, select **Yes, with _Physical or other_**.

    ![AzureMigrate](assets/image5.png)

3. Under Name your appliance provide name as **SQLDISCOVERYAZ**.

    ![AzureMigrate](assets/image6.png)

4. Specify a _name to the appliance_ as shown below and click **Generate Key**.

    ![AzureMigrate](assets/image8.png)

5. Once Key has been generated, Right click on **Download** and copy link adress to get the OVA file link.

    ![AzureMigrate](assets/image10.png)

6. Open Source VM and open the link on Microsoft Edge. Now Go to **Downloads** folder on the VM and **unzip** the Azure migrate folder.

    ![AzureMigrate](assets/image11.png)

7. Run the **Azure migrate installer** PowerShell(As Administrator ) script as specified below.

    ![AzureMigrate](assets/image12.png)
    
    Enter 3 to select "Physical or other"
    
    ![AzureMigrate](assets/image13.png)
    
    Enter 1 to select "Azure Public"
    
    ![AzureMigrate](assets/image15.png)
    
    Enter 1 to select "Public Endpoint option"

    ![AzureMigrate](assets/image17.png)
    
    Enter N to continue

    ![AzureMigrate](assets/image17_1.jpg)
    
8. Once setup is completed, go to Desktop to run the **Migrate Appliance configuration webpage**.

    ![AzureMigrate](assets/image25.png)

    ![AzureMigrate](assets/image26.png)
    
    ![AzureMigrate](assets/image27.png)
    
9. Now **Set up Prerequisites**.

    ![AzureMigrate](assets/image28.png)
    
    ![AzureMigrate](assets/image29.png)
    
10. Provide the **Appliance Key** that was generated on the Azure Portal and click **verify**.

    ![AzureMigrate](assets/image30.png)
    
    ![AzureMigrate](assets/image31.png)
    
    ![AzureMigrate](assets/image32.png)

11. Click **login** to authenticate with your lab Credentials.

    ![AzureMigrate](assets/image33.png)
    
    ![AzureMigrate](assets/image34.png)

    ![AzureMigrate](assets/image35.png)

    ![AzureMigrate](assets/image39.png)
    
12. Once Azure credentials are authenticated. Proceed adding **Domain credentials**.

    ![AzureMigrate](assets/image40.png)
    
    ![AzureMigrate](assets/image41.jpg)

13. Now **add discovery source**. Specify the IP address and the friendly name with given format.

    ![AzureMigrate](assets/image42.jpg)

14. Add WebServer1 and WebServer2 similarily as discovery source

    ![AzureMigrate](assets/image43.jpg)

15. If any validation fails, fix the error, and do **revalidate**.

16. Specify the **SQL credentials** for SQL DB discovery.

    ![AzureMigrate](assets/image46.jpg)
   
17. Now click **Start discovery** to initiate the discovery process.

    ![AzureMigrate](assets/image48.png)
    
    ![AzureMigrate](assets/image49.png)


## ASSESSMENT:

23. Click **create group** to Group the servers for assessment.

    ![AzureMigrate](assets/image60.png)

24. Provide **group name** and select the **discovered machines**. Click **create**.

    ![AzureMigrate](assets/image61.png)
    
    ![AzureMigrate](assets/image62.png)

25. Select **Create Assessment** and choose **Azure VM**.

    ![AzureMigrate](assets/image63.png)
    
    ![AzureMigrate](assets/image64.png)
    
26. Select the **Group** that was created earlier to perform the assessment on those servers.

    ![AzureMigrate](assets/image65.png)

27. Review and **create assessment**.

    ![AzureMigrate](assets/image66.png)
    
    ![AzureMigrate](assets/image67.png)

28. Go to **Azure Migrate Hub** overview page and select the **assessment** that has been populated.

    ![AzureMigrate](assets/image68.png)

29. Click on the **assessment report** that has been generated.

    ![AzureMigrate](assets/image69.png)

30. Click on the various options available assessment details blade to see **Azure Readiness & Cost details**.

    ![AzureMigrate](assets/image70.png)
    
    ![AzureMigrate](assets/image71.png)
    
    ![AzureMigrate](assets/image72.png)
    
DEPENDANCY ANALYSIS:


When migrating a workload to Azure, it is important to understand all workload dependencies. A broken dependency could mean that the application doesn't run properly in Azure, perhaps in hard-to-detect ways. Some dependencies, such as those between application tiers, are obvious. Other dependencies, such as DNS lookups, Kerberos ticket validation or certificate revocation checks, are not.

In this task, you will configure the Azure Migrate dependency visualization feature. This requires you to first create a Log Analytics workspace, and then to deploy agents on the to-be-migrated VMs.

1. Return to the Azure Migrate blade in the Azure Portal, and select Servers databases and web apps. Under Azure Migrate: Discovery and assessment select Groups, then select the AdventureVMs group to see the group details. Note that each VM has their Dependencies status as Requires agent installation. Select Requires agent installation for the web1 VM.
    
    ![AzureMigrate](assets/dependency1.jpg)
    
2. On the Dependencies blade, select Configure OMS workspace.
    
    ![AzureMigrate](assets/dependency2.png)
    
3. Create a new OMS workspace. Use AzureMigrateWS as the workspace name, where is a random number. Choose a workspace location close to your lab deployment, then select Configure.
    
    ![AzureMigrate](assets/dependency3.png)
    
4. Wait for the Log Analytics workspace to be deployed. Once it is deployed, navigate to it, and select Agents under Settings on the left. Make a note of the Workspace ID and Primary Key (for example by using Notepad).
    
    ![AzureMigrate](assets/dependency4.jpg)
    
5. Return to the Azure Migrate 'Dependencies' blade. Copy each of the 2 agent download URLs and paste them alongside the Workspace ID and key you noted in the previous step.
    
    ![AzureMigrate](assets/dependency5.jpg)
    
6. Connect to the Web server1 and Open Edge, and paste the link to the 64-bit Microsoft Monitoring Agent for Windows, which you noted earlier. When prompted, Run the installer. First you need to unistall.
Note : Machine Restart is NOT required.
   
   ![AzureMigrate](assets/dependency6_1.jpg)
    
Re launch the installer 
   
   ![AzureMigrate](assets/dependency6_2.jpg)
    
7. Select through the installation wizard until you get to the Agent Setup Options page. From there, select Connect the agent to Azure Log Analytics (OMS) and select Next. Enter the Workspace ID and Workspace Key that you copied earlier, and select Azure Commercial from the Azure Cloud drop-down. Select through the remaining pages and install the agent.
    
    ![AzureMigrate](assets/dependency7_1.jpg)
    
    ![AzureMigrate](assets/dependency7_2.jpg)
    
8. Now paste the link to the Dependency Agent Windows installer into the browser address bar. Run the installer and select through the install wizard to complete the installation.
    
    ![AzureMigrate](assets/dependency8.jpg)
    
Connect to the SQL and web2 VM and repeat the installation process (steps 6-8) for both agents.

The agent installation is now complete. Next, you need to generate some traffic on the hosted application so the dependency visualization has some data to work with. Browse to the public IP address of the Web1 server, and spend a few minutes refreshing the page.

####Explore dependency visualization

In this task, you will explore the dependency visualization feature of Azure Migrate. This feature uses data gathered by the dependency agent you installed in above task.

1. Return to the Azure Portal and refresh the Azure Migrate adventureGroup VMs group blade. The 3 VMs on which the dependency agent was installed should now show their status as 'Installed'. (If not, refresh the page using the browser refresh button, not the refresh button in the blade. It may take up to 5 minutes after installation for the status to be updated.)

    ![AzureMigrate](assets/dependency9.jpg)

2. Select View dependencies.

    ![AzureMigrate](assets/dependency10.jpg)

3. Take a few minutes to explore the dependencies view. Expand each server to show the processes running on that server. Select a process to see process information. See which connections each server makes.

    ![AzureMigrate](assets/dependency11.jpg)

In this exercise, you used Azure Migrate to assess the on-premises environment. This included selecting Azure Migrate tools, deploying the Azure Migrate appliance into the on-premises environment, creating a migration assessment, and using the Azure Migrate dependency visualization.

Next you can proceed with Actual lift and sift of server using the Azure Migrate. For details please go thorugh below link :

If you need to migrate only the application then you can use app service migration tool. Next excercise will go through the steps :

1. Download and install AppServiceMigrationAssistant using below link on WebServer1 

https://azure.microsoft.com/en-au/services/app-service/migration-assistant/thank-you/?download=windows

2. Open the AppServiceMigrationAssistant using shortcut present on Desktop. Select the hosted site and click on next.

    ![AzureMigrate](assets/sma1.jpg)

3. Check the report and resolved errors if any. Click on next

    ![AzureMigrate](assets/sma2.jpg)

4. Click on “copy code and open browser” and login.

    ![AzureMigrate](assets/sma4.jpg)

5. Go back to the App Service Migration Assistant and select the Azure Migrate Project () which was created before .

    ![AzureMigrate](assets/sma4_1.jpg)

6. Select Subscription, Use existing Resource group, and Provide site name as “adventureweb”

    ![AzureMigrate](assets/sma5.jpg)

7. Select “Create new” in App service plan and no other changes. Click on Migrate.
    
    ![AzureMigrate](assets/sma6.jpg)
    ![AzureMigrate](assets/sma6_1.jpg)
    
8. Select "Automatically install and complete HCM setup on this server" and download the setup using link provided and complete the installation.

    ![AzureMigrate](assets/sma7.jpg)
    ![AzureMigrate](assets/sma8.jpg)
    
9. Click next after installation to see the Migration Result. Click on "Go to your website" to view the migrated site.
    
     ![AzureMigrate](assets/sma9.jpg)
     ![AzureMigrate](assets/sma10.jpg)
    
