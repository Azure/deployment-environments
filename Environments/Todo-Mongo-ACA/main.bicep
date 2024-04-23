@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param apiContainerAppName string = ''
param containerAppsEnvironmentName string
param containerAppsEnvironmentResourceGroupName string = resourceGroup().name
param applicationInsightsName string = ''
param applicationInsightsResourceGroupName string = containerAppsEnvironmentResourceGroupName
param containerRegistryName string = ''
param cosmosAccountName string = ''
param cosmosDatabaseName string = ''
param keyVaultName string = ''
param webContainerAppName string = ''
param apimServiceName string = ''
param apiAppExists bool = false
param webAppExists bool = false

@description('Flag to use Azure API Management to mediate the calls between the Web frontend and the backend API')
param useAPIM bool = false

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('The base URL used by the web service for sending API requests')
param webApiBaseUrl string = ''
param corsAcaUrl string 
param containerRegistryAdminUserEnabled bool = false

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Web frontend
module web './app/web.bicep' = {
  name: 'web'
  params: {
    name: !empty(webContainerAppName) ? webContainerAppName : '${abbrs.appContainerApps}web-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}web-${resourceToken}'
    apiBaseUrl: !empty(webApiBaseUrl) ? webApiBaseUrl : api.outputs.SERVICE_API_URI
    applicationInsightsName: applicationInsightsName
    applicationInsightsResourceGroupName: applicationInsightsResourceGroupName
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerAppsEnvironmentResourceGroupName: containerAppsEnvironmentResourceGroupName
    containerRegistryName: containerRegistry.outputs.name
    exists: webAppExists
  }
}

// Api backend
module api './app/api.bicep' = {
  name: 'api'
  params: {
    name: !empty(apiContainerAppName) ? apiContainerAppName : '${abbrs.appContainerApps}api-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}api-${resourceToken}'
    applicationInsightsName: applicationInsightsName
    applicationInsightsResourceGroupName: applicationInsightsResourceGroupName
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerAppsEnvironmentResourceGroupName: containerAppsEnvironmentResourceGroupName
    containerRegistryName: containerRegistry.outputs.name
    keyVaultName: keyVault.outputs.name
    corsAcaUrl: corsAcaUrl
    exists: apiAppExists
  }
}

module containerRegistry './core/host/container-registry.bicep' = {
  name: 'app-container-registry'
  params: {
    name: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    adminUserEnabled: containerRegistryAdminUserEnabled
    tags: tags
  }
}

// The application database
module cosmos './app/db.bicep' = {
  name: 'cosmos'
  params: {
    accountName: !empty(cosmosAccountName) ? cosmosAccountName : '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
    databaseName: cosmosDatabaseName
    location: location
    tags: tags
    keyVaultName: keyVault.outputs.name
  }
}

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
  }
}


// Creates Azure API Management (APIM) service to mediate the requests between the frontend and the backend API
module apim './core/gateway/apim.bicep' = if (useAPIM) {
  name: 'apim-deployment'
  params: {
    name: !empty(apimServiceName) ? apimServiceName : '${abbrs.apiManagementService}${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: applicationInsightsName
  }
}

// Configures the API in the Azure API Management (APIM) service
module apimApi './app/apim-api.bicep' = if (useAPIM) {
  name: 'apim-api-deployment'
  params: {
    name: useAPIM ? apim.outputs.apimServiceName : ''
    apiName: 'todo-api'
    apiDisplayName: 'Simple Todo API'
    apiDescription: 'This is a simple Todo API'
    apiPath: 'todo'
    webFrontendUrl: web.outputs.SERVICE_WEB_URI
    apiBackendUrl: api.outputs.SERVICE_API_URI
  }
}

// Data outputs
output AZURE_COSMOS_CONNECTION_STRING_KEY string = cosmos.outputs.connectionStringKey
output AZURE_COSMOS_DATABASE_NAME string = cosmos.outputs.databaseName

// App outputs
output API_CORS_ACA_URL string = corsAcaUrl
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output REACT_APP_API_BASE_URL string = useAPIM ? apimApi.outputs.SERVICE_API_URI : api.outputs.SERVICE_API_URI
output REACT_APP_WEB_BASE_URL string = web.outputs.SERVICE_WEB_URI
output SERVICE_API_NAME string = api.outputs.SERVICE_API_NAME
output SERVICE_WEB_NAME string = web.outputs.SERVICE_WEB_NAME
output USE_APIM bool = useAPIM
output SERVICE_API_ENDPOINTS array = useAPIM ? [ apimApi.outputs.SERVICE_API_URI, api.outputs.SERVICE_API_URI ]: []
output registryLoginServer string = containerRegistry.outputs.loginServer
output registryName string = containerRegistry.outputs.name
