## Assess an application with Data Access Migration Toolkit

Applications typically connect and persist data to a database. The data access layer of the application provides simplified access to this data. Data Migration Assistant (DMA) enables you to assess your databases and related objects. The latest version of DMA (v5.0) introduces support for analyzing database connectivity and embedded SQL queries in the application code.

To enable this assessment, use the Data Access Migration Toolkit (DAMT), a Visual Studio Code extension. The latest version of this extension (v 0.2) adds support for .NET applications and T-SQL dialect.

1.	Search for **Visual studio code** in Search bar at the bottom and Open it.

    ![AzureMigrate](assets/vscode.jpg)

2.	Now select on **Extensions Marketplace** on the left side and search for **Data Access Migration Toolkit** and Install it.

    ![AzureMigrate](assets/extension.jpg)
    
    ![AzureMigrate](assets/toolkit.jpg)

3.	Then click on **Explorer** and **Open Folder…** and go to C drive and select **AdventureWorks** folder.

    ![AzureMigrate](assets/openfolder.jpg)
    
    ![AzureMigrate](assets/selectfolder.jpg)

4. Press **Ctrl+Shift+P** to start the extension console and then run the **Data Access: Analyze Workspace** command.

    ![AzureMigrate](assets/runcommand.jpg)

5. Select the **SQL Server** dialect.

    ![AzureMigrate](assets/sqlserver.jpg)

   At the end of the analysis, the command produces a report of SQL connectivity commands and queries.

    ![AzureMigrate](assets/report.jpg)

6. To assess the application's data layer, export the report in JSON format. Click on **Save**. Give a file name and choose **JSON Document** from dropdown as file type and **Save**.

    ![AzureMigrate](assets/json.jpg)

7. Open the JSON file. The generated file has these contents:

    ![AzureMigrate](assets/jsonreport.jpg)

8. Copy this JSON file to your local machine. You will need this file in next lab step for generating DMA assessment report. 

## Assess an application's data access layer with Data Migration Assistant

**Data Migration Assistant** enables assessing the queries identified in the application within the context of modernizing the database to Azure Data platform.

1. Copy the JSON file, from your local to this DMA virtual machine, which you generated in the previous lab step.

    ![DMA Assessment](assets/dmajson.jpg)

2. Open **Microsoft Data Migration Assistant** from Desktop.

    ![DMA Assessment](assets/opendma.jpg)

3. Click on ➕ to create an assessment project. Give a project name and choose Assessment type as **Database engine**, Source server type as **SQL Server** and Target server type as **Azure SQL Database**. Click **Create**. 

    ![DMA Assessment](assets/createproject.png)

4. **✔️ Check database compatibility** and **✔️ Check feature parity** options should be selected. Click **Next**. 

    ![DMA Assessment](assets/next.jpg)

5. Select the source SQL Server instance. Copy-paste Source SQL server virtual machine name in Server name field. Choose SQL Server Authentican type. Enter **sqladmin** as username and **Password@123** as password. Check ✔️ connection properties. Click **Connect**.

    ![DMA Assessment](assets/server.jpg)

6. Select the server and both the databases to which the application is connecting. Click **Add**.

    ![DMA Assessment](assets/database.jpg)

    To facilitate data access assessment, DMA introduces the ability to include JSON files with application queries. Next, include the JSON file created earlier with the application queries.

7. Select the database **SampleDatabase1** and browse to the JSON file exported from Data Access Migration Toolkit to include the queries from the application for the assessment. Similarly do it for **SampleDatabase2**.

    ![DMA Assessment](assets/db1.jpg)
    
    ![DMA Assessment](assets/db2.jpg)

8. Select **Start Assessment**.

    ![DMA Assessment](assets/start.jpg)

9. Review the assessment report. The generated report includes any compatibility or feature parity issues detected in the application queries as shown below.

    ![DMA Assessment](assets/assessment.jpg)

Now, in addition to having the database perspective of the migration, users also have a view from the application perspective.
