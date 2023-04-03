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

6. In Project Details , specify the **project name** and the **geography** in which you want to create the project.

    - The geography is only used to store the metadata gathered from on-premises servers. You can assess or migrate servers for any target region regardless of the selected geography.

7. Select **Create** to initiate Project deployment.

    ![AzureMigrate](assets/image3.png)

## Azure Migrate appliance – Agentless Migration:

Set up the appliance by with below steps:

1. In Azure Migrate Hub, under **Migration tools** select **Discover**.

    ![AzureMigrate](assets/image4.png)

2. In Discover page, select **Yes, with _Physical or other_**.

    ![AzureMigrate](assets/image5.png)

3. Under _How do you want to replicate?_ Select **Using agentless replication**.

    ![AzureMigrate](assets/image6.png)

4. Specify a _name to the appliance_ as shown below and click **Generate Key**.

    ![AzureMigrate](assets/image8.png)

5. Once Key has been generated, click **Download** to get the OVA file.

    ![AzureMigrate](assets/image10.png)

6. Go to **Downloads** folder on the VM and **unzip** the Azure migrate folder.

    ![AzureMigrate](assets/image11.png)

7. Run the **Azure migrate installer** PowerShell script as specified below.

    ![AzureMigrate](assets/image12.png)
    
    ![AzureMigrate](assets/image13.png)
    
    ![AzureMigrate](assets/image15.png)

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

## DEPENDANCY ANALYSIS:

18. Go back to Discovered server in Azure Migrate Hub, to enable the dependency mapping.

    ![AzureMigrate](assets/image50.png)

    ![AzureMigrate](assets/image51.png)
    
19. Click on **Dependency analysis** and select **Add servers**.

    ![AzureMigrate](assets/image52.png)

20. Select the **servers** that needs dependency mapping to initiate the analysis.

    ![AzureMigrate](assets/image53.png)

    ![AzureMigrate](assets/image54.png)

21. Once servers are added to analysis, you can now see option to **view dependencies**.

    ![AzureMigrate](assets/image55.png)

22. Click on each server to view respective dependency analysis.

    ![AzureMigrate](assets/image56.png)

#### SAMPLE MAPPING VIEW:

   ![AzureMigrate](assets/image57.png)
    
   ![AzureMigrate](assets/image58.png)
    
   ![AzureMigrate](assets/image59.png)

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
    
31. Click **Export Assessment** to download the XLSX version.

    ![AzureMigrate](assets/image73.png)
    
    ![AzureMigrate](assets/image74.png)
    
    ![AzureMigrate](assets/image75.png)

