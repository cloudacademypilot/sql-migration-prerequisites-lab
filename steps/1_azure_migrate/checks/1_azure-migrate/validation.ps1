param(
    [string]
    $Resourcegroupname
)

#Get azure access token
$token = (Get-AzAccessToken).Token

#Get subscription Id
$subscriptionUri = "https://management.azure.com/subscriptions?api-version=2020-01-01"
$headers1 = @{ Authorization = "Bearer $token"; 'ContentType' = "application/json"}
$res1 = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $subscriptionUri -Headers $headers1
$SubscriptionId = $res1.value[0].subscriptionId

#Get project
$projecturi = "https://management.azure.com/subscriptions/"+$SubscriptionId+"/resourcegroups/"+$Resourcegroupname+"/providers/Microsoft.Migrate/migrateProjects?api-version=2018-09-01-preview"
$headers1 = @{ Authorization = "Bearer $token"; 'ContentType' = "application/json"}
$res2 = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $projecturi -Headers $headers1       
$ProjectName=$res2.value.name

if($ProjectName){
    Write-Host "Azure Migrate project is created"
}
else{
    Write-Host "Azure Migrate project is not created"
}

#Get machines
$Appuri="https://management.azure.com/subscriptions/"+$SubscriptionId+"/resourceGroups/"+$Resourcegroupname+"/providers/Microsoft.Migrate/migrateProjects/"+$ProjectName+"/machines?api-version=2018-09-01-preview"
$headers1 = @{ Authorization = "Bearer $token"; 'ContentType' = "application/json"}
$res3 = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $Appuri -Headers $headers1       

$count = 0

foreach($i in $res3.value)
{
    foreach($j in $i)
    {
        $count=$count+1
        
    }
}

if($count -ge 1)
{
    Write-Host "Machine is connected"
}
else
{
    Write-Host "Machine is not connected"
}

#Get assessment
$Assessuri="https://management.azure.com/subscriptions/"+$SubscriptionId+"/resourceGroups/"+$Resourcegroupname+"/providers/Microsoft.Migrate/assessmentProjects?api-version=2019-10-01"
$headers1 = @{ Authorization = "Bearer $token"; 'ContentType' = "application/json"}
$res4 = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $Assessuri -Headers $headers1       
$Assessment=$res4.value.name

if($Assessment){
    Write-Host "Assessment is created"
}
else{
    Write-Host "Assessment is not created"
}

#Get group
$Groupuri="https://management.azure.com/subscriptions/"+$SubscriptionId+"/resourceGroups/"+$Resourcegroupname+"/providers/Microsoft.Migrate/assessmentProjects/"+$Assessment+"/groups?api-version=2019-10-01"
$headers1 = @{ Authorization = "Bearer $token"; 'ContentType' = "application/json"}
$res5 = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $Groupuri -Headers $headers1       
$Group=$res5.value.name

if($Group){
    Write-Host "Group is created"
}
else{
    Write-Host "Group is not created"
}
