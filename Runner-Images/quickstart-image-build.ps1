# Copyright (c) Microsoft Corproation.
# Licensed under the MIT License.
[CmdletBinding()]
param (
    [string] $Registry,

    [string] $Directory,

    [string] $Repository = "ade",
    
    [string] $Tag = "latest"
)
Write-Host "Logging into specified Azure Container Registry"
az login
az acr login -n $Registry

if (!$?) {
    Write-Error "Failed to login to Azure Container Registry"
    exit 1
}

Write-Host "Starting Docker Engine"
docker.exe | Out-Null
if (!$?) {
    Write-Error "Failed to start Docker Engine. Please make sure Docker is installed on this machine and available in PATH."
    exit 1
}

Write-Host "Building Docker Image"
docker build -t "${Registry}.azurecr.io/${Repository}:${Tag}" $Directory

if (!$?) {
    Write-Error "Failed to build specified Docker Image. Please check the logs for more details."
    exit 1
}

Write-Host "Pushing Docker Image to Azure Container Registry"
docker push "${Registry}.azurecr.io/${Repository}:${Tag}"

if (!$?) {
    Write-Error "Failed to push specified Docker Image. Please check the logs for more details."
    exit 1
}

Write-Host "Docker Image pushed successfully to ${Registry}.azurecr.io/${Repository}:${Tag}"