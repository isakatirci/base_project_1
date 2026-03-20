#
# *** THIS SCRIPT RESET THE DEFINITIPONS IN THE TENANT ***
#

. .\env.ps1

$CLIENT_REDIRECT_URI = "https://my.redirect.uri"
$API_NAME = "product-composite"
$API_URL = "https://localhost:8443/product-composite"

$ErrorActionPreference = "Stop"

$body = @{
    client_id = $MGM_CLIENT_ID
    client_secret = $MGM_CLIENT_SECRET
    audience = "https://$TENANT/api/v2/"
    grant_type = "client_credentials"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://$TENANT/oauth/token" -Method Post -Headers @{"Content-Type" = "application/json"} -Body $body
$AT = $response.access_token

# Delete reader application
$clients = Invoke-RestMethod -Uri "https://$TENANT/api/v2/clients?fields=name,client_id" -Headers @{"Authorization" = "Bearer $AT"}
$reader = $clients | Where-Object { $_.name -eq "reader" }
if ($reader) {
    Write-Host "Delete reader client app..."
    Invoke-RestMethod -Uri "https://$TENANT/api/v2/clients/$($reader.client_id)" -Method Delete -Headers @{"Authorization" = "Bearer $AT"}
} else {
    Write-Host "Reader client app already deleted"
}

# Delete writer application
$writer = $clients | Where-Object { $_.name -eq "writer" }
if ($writer) {
    Write-Host "Delete writer client app..."
    Invoke-RestMethod -Uri "https://$TENANT/api/v2/clients/$($writer.client_id)" -Method Delete -Headers @{"Authorization" = "Bearer $AT"}
} else {
    Write-Host "Writer client app already deleted"
}

# Delete the API
$resourceServers = Invoke-RestMethod -Uri "https://$TENANT/api/v2/resource-servers" -Headers @{"Authorization" = "Bearer $AT"}
$api = $resourceServers | Where-Object { $_.name -eq $API_NAME }
if ($api) {
    Write-Host "Delete API $API_NAME ($API_URL)..."
    Invoke-RestMethod -Uri "https://$TENANT/api/v2/resource-servers/$($api.id)" -Method Delete -Headers @{"Authorization" = "Bearer $AT"}
} else {
    Write-Host "API $API_NAME ($API_URL) already deleted"
}

# Delete the user
$users = Invoke-RestMethod -Uri "https://$TENANT/api/v2/users-by-email?email=$([uri]::EscapeDataString($USER_EMAIL))" -Headers @{"Authorization" = "Bearer $AT"}
$user = $users | Where-Object { $_.email -eq $USER_EMAIL }
if ($user) {
    Write-Host "Delete user with email $USER_EMAIL..."
    Invoke-RestMethod -Uri "https://$TENANT/api/v2/users/$($user.user_id)" -Method Delete -Headers @{"Authorization" = "Bearer $AT"}
} else {
    Write-Host "User with email $USER_EMAIL already deleted"
}
