$currentAzureContext = Get-AzContext
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile);
$Accesstoken = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken;

$token = "Bearer " + $AccessToken

$headers = @{
    Authorization = $token
    "Content-Type" = "application/json"
}

#number of owners to start
$numofowners = 0

#RBAC role ID for owner
$ownerid = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"

#get all subscriptions
$subs = get-azsubscription

#first subscription in array of subscriptions
$sub = $subs[0]



foreach($sub in $subs){
    $subid = $sub.Id

    $endpoint = "https://management.azure.com/subscriptions/$subId/providers/Microsoft.Authorization/roleAssignments?api-version=2018-01-01-preview"

    $output = Invoke-WebRequest -Method Get -Headers $headers -uri $endpoint -UseBasicParsing

    

    $myarray = $output.Content | Convertfrom-Json

    # $myarray | ConvertTo-Json | out-file "./roleassignments.json" generated the roleassignments.json file

    # you're going to want to run another for loop here $myarray.value[0]

    foreach($role in $myarray.value){
    
        
        $roleid = $role.properties.roleDefinitionId

    if($roleid -eq "/subscriptions/$subid/providers/Microsoft.Authorization/roleDefinitions/$ownerid"){
        $numofowners += 1
    }
        
            
        
    }
    #write $numofowners

    $tags = @{"Owner" = $numofowners}
    new-aztag -ResourceId "/subscriptions/$subid" -Tag $tags

}









