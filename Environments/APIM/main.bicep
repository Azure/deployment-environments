@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param environmentName string = 'test'

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

var resourceToken = toLower(uniqueString(resourceGroup().id, location))
var tags = { 'azd-env-name': environmentName }

var prefix = '${environmentName}-${resourceToken}'

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    tags: tags
    logAnalyticsName: 'log-${prefix}'
    applicationInsightsName: 'appi-${prefix}'
    applicationInsightsDashboardName: 'appinsights-dashboard'
  }
}

// Backing storage for Azure functions backend API
var validStoragePrefix = toLower(take(replace(prefix, '-', ''), 17))
module storageAccount 'core/storage/storage-account.bicep' = {
  name: 'storage'
  params: {
    name: '${validStoragePrefix}storage'
    location: location
    tags: tags
  }
}


// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  params: {
    name: 'plan-${prefix}'
    location: location
    tags: tags
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
  }
}

module functionApp 'core/host/functions.bicep' = {
  name: 'function'
  params: {
    // Truncating to 32 due to https://github.com/Azure/azure-functions-host/issues/2015
    name: 'func-${take(prefix, 19)}'
    location: location
    tags: union(tags, { 'azd-service-name': 'api' })
    alwaysOn: false
    appSettings: {
      PYTHON_ISOLATE_WORKER_DEPENDENCIES: 1
    }
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.10'
    storageAccountName: storageAccount.outputs.name
  }
}


// Creates Azure API Management (APIM) service to mediate the requests between the frontend and the backend API
module apim './core/gateway/apim.bicep' = {
  name: 'apim-deployment'
  params: {
    name: 'apim-${prefix}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

// Configures the API in the Azure API Management (APIM) service
module apimAPI 'apimanagement.bicep' = {
  name: 'apimanagement-resources'
  params: {
    apimServiceName: apim.outputs.apimServiceName
    functionAppName: functionApp.outputs.name
  }
  dependsOn: [
    functionApp
  ]
}



output SERVICE_API_ENDPOINTS array = ['${apimAPI.outputs.apimServiceUrl}/public/docs']
