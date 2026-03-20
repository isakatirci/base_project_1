# PowerShell script to create Spring projects online using start.spring.io

function Create-SpringProject {
    param (
        [string]$Name,
        [string]$GroupId,
        [string]$PackageName,
        [string]$Dependencies,
        [string]$Folder,
        [string]$Type = "maven-project",
        [string]$JavaVersion = "24",
        [string]$BootVersion = "3.5.0",
        [string]$Packaging = "jar",
        [string]$Version = "1.0.0-SNAPSHOT"
    )

    if (-not (Test-Path $Folder)) {
        New-Item -ItemType Directory -Path $Folder -Force | Out-Null
    }

    $Url = "https://start.spring.io/starter.zip?type=$Type&javaVersion=$JavaVersion&bootVersion=$BootVersion&packaging=$Packaging&groupId=$GroupId&artifactId=$Name&name=$Name&packageName=$PackageName&version=$Version&dependencies=$Dependencies"

    Write-Host "Downloading $Name from start.spring.io into $Folder..."
    $zipFile = Join-Path $Folder "$Name.zip"
    Invoke-WebRequest -Uri $Url -OutFile $zipFile

    Write-Host "Extracting $Name..."
    $destPath = Join-Path $Folder $Name
    Expand-Archive -Path $zipFile -DestinationPath $destPath -Force
    Remove-Item -Path $zipFile -Force
}

Write-Host "Creating microservices..."
Create-SpringProject -Folder "microservices" -Name "product-service" -GroupId "com.isakatirci.microservices.core.product" -PackageName "com.isakatirci.microservices.core.product" -Dependencies "actuator,webflux,data-mongodb-reactive,cloud-stream,amqp,kafka,distributed-tracing,prometheus"

Create-SpringProject -Folder "microservices" -Name "review-service" -GroupId "com.isakatirci.microservices.core.review" -PackageName "com.isakatirci.microservices.core.review" -Dependencies "actuator,webflux,data-jpa,mysql,cloud-stream,amqp,kafka,distributed-tracing,prometheus"

Create-SpringProject -Folder "microservices" -Name "recommendation-service" -GroupId "com.isakatirci.microservices.core.recommendation" -PackageName "com.isakatirci.microservices.core.recommendation" -Dependencies "actuator,webflux,data-mongodb-reactive,cloud-stream,amqp,kafka,distributed-tracing,prometheus"

Create-SpringProject -Folder "microservices" -Name "product-composite-service" -GroupId "com.isakatirci.microservices.composite.product" -PackageName "com.isakatirci.microservices.composite.product" -Dependencies "actuator,webflux,security,oauth2-resource-server,cloud-stream,amqp,kafka,distributed-tracing,prometheus"

Write-Host "Creating spring-cloud services..."
Create-SpringProject -Folder "spring-cloud" -Name "gateway" -GroupId "com.isakatirci.springcloud" -PackageName "com.isakatirci.springcloud.gateway" -Dependencies "actuator,security,oauth2-resource-server,cloud-gateway,distributed-tracing"

Create-SpringProject -Folder "spring-cloud" -Name "authorization-server" -GroupId "com.isakatirci.springcloud" -PackageName "com.isakatirci.springcloud.authorizationserver" -Dependencies "actuator,security,oauth2-authorization-server,distributed-tracing,prometheus"

Write-Host "Projects created successfully!"
