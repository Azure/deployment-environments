@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@description('The resource name of the AKS cluster')
param clusterName string = ''

@description('The resource name of the Container Registry (ACR)')
param containerRegistryName string = ''

param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param logAnalyticsName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// The AKS cluster to host applications
module aks './core/host/aks.bicep' = {
  name: 'aks'
  params: {
    location: location
    name: !empty(clusterName) ? clusterName : '${abbrs.containerServiceManagedClusters}${resourceToken}'
    containerRegistryName: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    logAnalyticsName: monitoring.outputs.logAnalyticsWorkspaceName
  }
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

// App outputs
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_AKS_CLUSTER_NAME string = aks.outputs.clusterName
output AZURE_AKS_IDENTITY_CLIENT_ID string = aks.outputs.clusterIdentity.clientId
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = aks.outputs.containerRegistryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = aks.outputs.containerRegistryName
output REACT_APP_APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
