# Azure Migrate Application Dependency Mapping/Assessment

This lab provides step by step procedures to configure dependency analysis in **Azure Migrate: Discovery and assessment**.

Dependency analysis identifies dependencies between discovered on-premises servers. It provides these advantages:

- This lets us to gather servers into groups for assessment more accurately.
- Identification of servers that must be migrated together. This is especially useful if there are no data about app dependency.
- Analyzing dependencies helps ensure that nothing is left behind, and thus avoids surprise outages after migration.

## Create a project for the first time

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

## Azure Migrate appliance – Agentless Migration:

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

7. Run the **Azure migrate installer** PowerShell script as specified below.

    ![AzureMigrate](assets/image12.png)
    
    Enter 3 to select "Physical or other"
    
    ![AzureMigrate](assets/image13.png)
    
    Enter 1 to select "Azure Public"
    
    ![AzureMigrate](assets/image15.png)
    
    Enter 1 to select "Public Endpoint option"

    ![AzureMigrate](assets/image17.png)
    
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
    
    ![AzureMigrate](assets/image41.png)

13. Now **add discovery source**. Specify the IP address and the friendly name with given format.

    ![AzureMigrate](assets/image42.png)

14. **Verify** the input post adding the values.

    ![AzureMigrate](assets/image43.png)

15. If any validation fails, fix the error, and do **revalidate**.

    ![AzureMigrate](assets/image44.png)
        
    ![AzureMigrate](assets/image45.png)

16. Specify the **SQL credentials** for SQL DB discovery.

    ![AzureMigrate](assets/image46.png)

    ![AzureMigrate](assets/image47.png)
    
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
    
## DEPENDANCY ANALYSIS:

When migrating a workload to Azure, it is important to understand all workload dependencies. A broken dependency could mean that the application doesn't run properly in Azure, perhaps in hard-to-detect ways. Some dependencies, such as those between application tiers, are obvious. Other dependencies, such as DNS lookups, Kerberos ticket validation or certificate revocation checks, are not.

In this task, you will configure the Azure Migrate dependency visualization feature. This requires you to first create a Log Analytics workspace, and then to deploy agents on the to-be-migrated VMs.

1. Return to the Azure Migrate blade in the Azure Portal, and select Servers databases and web apps. Under Azure Migrate: Discovery and assessment select Groups, then select the AdventureVMs group to see the group details. Note that each VM has their Dependencies status as Requires agent installation. Select Requires agent installation for the web1 VM.

2. On the Dependencies blade, select Configure OMS workspace.

3. Create a new OMS workspace. Use AzureMigrateWS<unique number> as the workspace name, where <unique number> is a random number. Choose a workspace location close to your lab deployment, then select Configure.
    
4.Wait for the Log Analytics workspace to be deployed. Once it is deployed, navigate to it, and select Agents management under Settings on the left. Make a note of the Workspace ID and Primary Key (for example by using Notepad). 
    
5. Return to the Azure Migrate 'Dependencies' blade. Copy each of the 2 agent download URLs and paste them alongside the Workspace ID and key you noted in the previous step.
    
6. Connect to the Web server1 and Open Edge, and paste the link to the 64-bit Microsoft Monitoring Agent for Windows, which you noted earlier. When prompted, Run the installer.
    
7. Select through the installation wizard until you get to the Agent Setup Options page. From there, select Connect the agent to Azure Log Analytics (OMS) and select Next. Enter the Workspace ID and Workspace Key that you copied earlier, and select Azure Commercial from the Azure Cloud drop-down. Select through the remaining pages and install the agent.

8. Now paste the link to the Dependency Agent Windows installer into the browser address bar. Run the installer and select through the install wizard to complete the installation.
    
9. Connect to the SQL and web2 VM and repeat the installation process (steps 6-8) for both agents.

