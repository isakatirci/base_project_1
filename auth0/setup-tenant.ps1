. .\env.ps1

$CLIENT_REDIRECT_URI = "https://my.redirect.uri"
$API_NAME = "product-composite"
$API_URL = "https://localhost:8443/product-composite"

$ErrorActionPreference = "Stop"

$tokenBody = @{
    client_id = $MGM_CLIENT_ID
    client_secret = $MGM_CLIENT_SECRET
    audience = "https://$TENANT/api/v2/"
    grant_type = "client_credentials"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://$TENANT/oauth/token" -Method Post -Headers @{"Content-Type" = "application/json"} -Body $tokenBody
$AT = $response.access_token

# Update the tenant
Write-Host "Update the tenant, set its default connection to a user dictionary..."
$patchBody = @{ default_directory = "Username-Password-Authentication" } | ConvertTo-Json
$tenantResponse = Invoke-RestMethod -Uri "https://$TENANT/api/v2/tenants/settings" -Method Patch -Headers @{"Authorization" = "Bearer $AT"; "Content-Type" = "application/json"} -Body $patchBody
Write-Host $tenantResponse.default_directory

$clients = Invoke-RestMethod -Uri "https://$TENANT/api/v2/clients?fields=name,client_id,client_secret" -Headers @{"Authorization" = "Bearer $AT"}

$createClientBodyStr = '{"callbacks":["https://my.redirect.uri"],"app_type":"non_interactive","grant_types":["authorization_code","implicit","refresh_token","client_credentials","password","http://auth0.com/oauth/grant-type/password-realm"],"oidc_conformant":true,"token_endpoint_auth_method":"client_secret_post"'

# Create reader application
$reader = $clients | Where-Object { $_.name -eq "reader" }
if ($reader) {
    Write-Host "Reader client app already exists"
} else {
    Write-Host "Creates reader client app..."
    $readerBody = $createClientBodyStr + ',"name":"reader"}'
    $reader = Invoke-RestMethod -Uri "https://$TENANT/api/v2/clients" -Method Post -Headers @{"Authorization" = "Bearer $AT"; "Content-Type" = "application/json"} -Body $readerBody
    $reader | ConvertTo-Json | Write-Host
}
$READER_CLIENT_ID = $reader.client_id
$READER_CLIENT_SECRET = $reader.client_secret

# Create writer application
$writer = $clients | Where-Object { $_.name -eq "writer" }
if ($writer) {
    Write-Host "Writer client app already exists"
} else {
    Write-Host "Creates writer client app..."
    $writerBody = $createClientBodyStr + ',"name":"writer"}'
    $writer = Invoke-RestMethod -Uri "https://$TENANT/api/v2/clients" -Method Post -Headers @{"Authorization" = "Bearer $AT"; "Content-Type" = "application/json"} -Body $writerBody
    $writer | ConvertTo-Json | Write-Host
}
$WRITER_CLIENT_ID = $writer.client_id
$WRITER_CLIENT_SECRET = $writer.client_secret

# Sleep 1 sec to avoid a "429: Too Many Requests, global limit has been reached"...'
Start-Sleep -Seconds 1

# Create the API
$resourceServers = Invoke-RestMethod -Uri "https://$TENANT/api/v2/resource-servers" -Headers @{"Authorization" = "Bearer $AT"}
$api = $resourceServers | Where-Object { $_.name -eq $API_NAME }
if ($api) {
    Write-Host "API $API_NAME ($API_URL) already exists"
} else {
    Write-Host "Creates API $API_NAME ($API_URL)..."
    $apiBody = @{
        name = $API_NAME
        identifier = $API_URL
        scopes = @(
            @{ value = "product:read"; description = "Read product information" }
            @{ value = "product:write"; description = "Update product information" }
        )
    } | ConvertTo-Json -Depth 5
    $api = Invoke-RestMethod -Uri "https://$TENANT/api/v2/resource-servers" -Method Post -Headers @{"Authorization" = "Bearer $AT"; "Content-Type" = "application/json"} -Body $apiBody
    $api | ConvertTo-Json | Write-Host
}

# Create the user
$users = Invoke-RestMethod -Uri "https://$TENANT/api/v2/users-by-email?email=$([uri]::EscapeDataString($USER_EMAIL))" -Headers @{"Authorization" = "Bearer $AT"}
$user = $users | Where-Object { $_.email -eq $USER_EMAIL }
if ($user) {
    Write-Host "User with email $USER_EMAIL already exists"
} else {
    Write-Host "Creates user with email $USER_EMAIL..."
    $userBody = @{
        email = $USER_EMAIL
        connection = "Username-Password-Authentication"
        password = $USER_PASSWORD
    } | ConvertTo-Json
    $userResponse = Invoke-RestMethod -Uri "https://$TENANT/api/v2/users" -Method Post -Headers @{"Authorization" = "Bearer $AT"; "Content-Type" = "application/json"} -Body $userBody
    $userResponse | ConvertTo-Json | Write-Host
}

# Grant access to the API for the reader client app
$clientGrants = Invoke-RestMethod -Uri "https://$TENANT/api/v2/client-grants?audience=$([uri]::EscapeDataString($API_URL))&client_id=$([uri]::EscapeDataString($READER_CLIENT_ID))" -Headers @{"Authorization" = "Bearer $AT"}
if (@($clientGrants).Count -gt 0) {
    Write-Host "Client grant for the reader app to access the $API_NAME API already exists"
} else {
    Write-Host "Create client grant for the reader app to access the $API_NAME API..."
    $grantBody = @{
        client_id = $READER_CLIENT_ID
        audience = $API_URL
        scope = @("product:read")
    } | ConvertTo-Json
    $grantResponse = Invoke-RestMethod -Uri "https://$TENANT/api/v2/client-grants" -Method Post -Headers @{"Authorization" = "Bearer $AT"; "Content-Type" = "application/json"} -Body $grantBody
    $grantResponse | ConvertTo-Json | Write-Host
    Write-Host ""
}

# Grant access to the API for the writer client app
$writerGrants = Invoke-RestMethod -Uri "https://$TENANT/api/v2/client-grants?audience=$([uri]::EscapeDataString($API_URL))&client_id=$([uri]::EscapeDataString($WRITER_CLIENT_ID))" -Headers @{"Authorization" = "Bearer $AT"}
if (@($writerGrants).Count -gt 0) {
    Write-Host "Client grant for the writer app to access the $API_NAME API already exists"
} else {
    Write-Host "Create client grant for the writer app to access the $API_NAME API..."
    $grantBody = @{
        client_id = $WRITER_CLIENT_ID
        audience = $API_URL
        scope = @("product:read", "product:write")
    } | ConvertTo-Json
    $grantResponse = Invoke-RestMethod -Uri "https://$TENANT/api/v2/client-grants" -Method Post -Headers @{"Authorization" = "Bearer $AT"; "Content-Type" = "application/json"} -Body $grantBody
    $grantResponse | ConvertTo-Json | Write-Host
    Write-Host ""
}

# Echo Auth0 - OAuth2 settings
Write-Host ""
Write-Host "Auth0 - OAuth2 settings:"
Write-Host ""
Write-Host "export TENANT=$TENANT"
Write-Host "export WRITER_CLIENT_ID=$WRITER_CLIENT_ID"
Write-Host "export WRITER_CLIENT_SECRET=$WRITER_CLIENT_SECRET"
Write-Host "export READER_CLIENT_ID=$READER_CLIENT_ID"
Write-Host "export READER_CLIENT_SECRET=$READER_CLIENT_SECRET"
