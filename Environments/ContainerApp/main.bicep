@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param environmentName string = 'test'

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@description('The image name for the api service')
param apiImageName string = ''

@description('Id of the user or app to assign application roles')
param principalId string = ''

var resourceToken = toLower(uniqueString(resourceGroup().id, location))
var tags = { 'azd-env-name': environmentName }

var prefix = '${environmentName}-${resourceToken}'

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    name: 'kv-${take(replace(prefix, '-', ''), 17)}'
    location: location
    tags: tags
    principalId: principalId
  }
}

// Container apps host (including container registry)
module containerApps 'core/host/container-apps.bicep' = {
  name: 'container-apps'
  params: {
    name: 'app'
    location: location
    containerAppsEnvironmentName: 'cae-${prefix}'
    containerRegistryName: 'cr${replace(prefix, '-', '')}'
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
  }
}

// API app
module api 'api.bicep' = {
  name: 'api'
  params: {
    name: 'ca-${take(prefix,19)}'
    location: location
    imageName: apiImageName
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
    keyVaultName: keyVault.outputs.name
  }
}


module logAnalyticsWorkspace 'core/monitor/loganalytics.bicep' = {
  name: 'loganalytics'
  params: {
    name: 'log-${prefix}'
    location: location
    tags: tags
  }
}

output AZURE_LOCATION string = location
output AZURE_CONTAINER_ENVIRONMENT_NAME string = containerApps.outputs.environmentName
output AZURE_CONTAINER_REGISTRY_NAME string = containerApps.outputs.registryName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerApps.outputs.registryLoginServer
output SERVICE_API_IDENTITY_PRINCIPAL_ID string = api.outputs.SERVICE_API_IDENTITY_PRINCIPAL_ID
output SERVICE_API_NAME string = api.outputs.SERVICE_API_NAME
output SERVICE_API_URI string = api.outputs.SERVICE_API_URI
output SERVICE_API_IMAGE_NAME string = api.outputs.SERVICE_API_IMAGE_NAME
output SERVICE_API_ENDPOINTS array = ['${api.outputs.SERVICE_API_URI}/generate_name']
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
