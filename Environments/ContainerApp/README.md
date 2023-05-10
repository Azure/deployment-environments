# Container App
This template helps the developer quickly set up the infrastructure about Container App.

This repo is just infrastructure part. If you want to deploy application and data, please refer to [repo](https://github.com/luxu-ms/simple-flask-api-container.git)

## Prerequisites
* Docker 
* Azure Deployment Environment has provisioned the environment

## QuickStart
1. Clone this repo

2. Go to the folder "src", ensure you have login to docker server. 
```
docker login <Container Registry Server>
```
>NOTE: You can go to Azure Portal and find the "Access Keys" info in Azure Container Registry which is provisioned by ADE.

use docker build to create the image.
```
docker build -t <Container Registry Server>/simple-flask-api-container:0.0.1 .
```

After the build completed, use docker push to upload to container registry.
```
docker push <Container Registry Server>/simple-flask-api-container:0.0.1
```

3. Go to Container Apps in Azure Portal, select the Container App provisioned, click "Containers", click "Edit and Deploy", select the container image and click "Edit". 
4. Select "Azure Container Registry" for "Image Source", select "Registry", "Image" and "Image tag" and click "Save", click "Create". Wait a while to let it take effect.

## How to verify
Go to your Container App's overview, click "Application Url" and add "/generate_name" in the URL, there will be a generated name.