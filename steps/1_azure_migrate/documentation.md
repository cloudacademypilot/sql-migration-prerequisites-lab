Azure Migrate Application Dependency Mapping/Assessment

This exercise provides step by step procedures to configure dependency analysis in Azure Migrate: Discovery and assessment.
Dependency analysis identifies dependencies between discovered on-premises servers. It provides these advantages:

• This lets us to gather servers into groups for assessment more accurately. 

• Identification of servers that must be migrated together. This is especially useful if there are no data about app dependency.

• Analyzing dependencies helps ensure that nothing is left behind, and thus avoids surprise outages after migration.

Excercise 1 : 
Create a project for the first time
Set up a new project in an Azure subscription.
1. In the Azure portal, search for Azure Migrate.
2. In Services, select Azure Migrate.
3. In Overview, select Discover, assess, and migrat
<image>
4. In Servers, databases, and web apps, select Create project.
5. In Create project, select the Azure subscription, and resource group. Create a resource 
group if you don't have one.
6. In Project Details, specify the project name and the geography in which you want to 
create the project.
o The geography is only used to store the metadata gathered from onpremises servers. You can assess or migrate servers for any target region 
regardless of the selected geography.
7. Select Create to initiate Project deployment
