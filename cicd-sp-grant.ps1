$appId = "CLIENT_ID_FROM_AZURE_APP"
$tenantId = "TENANT_ID"
Add-PowerAppsAccount -Endpoint prod -TenantID $tenantId 
New-PowerAppManagementApp -ApplicationId $appId