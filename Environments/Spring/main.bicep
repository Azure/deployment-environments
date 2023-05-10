@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = 'test'

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

param appName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param appServicePlanName string = ''
param mySqlServerName string = ''
param mySqlServerAdminName string = 'petclinic'
@secure()
param mySqlServerAdminPassword string
param mySqlDatabaseName string = 'petclinic'
param keyVaultName string = ''
param logAnalyticsName string = ''

@description('Id of the user or app to assign application roles')
param principalId string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(resourceGroup().id, location))
var tags = { 'azd-env-name': environmentName }

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B1'
    }
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

// The application database
module mySql './core/database/mysql/mysql-db.bicep' = {
  name: 'mysql-db'
  params: {
    location: location
    tags: tags
    serverName: !empty(mySqlServerName) ? mySqlServerName : '${abbrs.dBforMySQLServers}${resourceToken}'
    serverAdminName: mySqlServerAdminName
    serverAdminPassword: mySqlServerAdminPassword
    databaseName: !empty(mySqlDatabaseName) ? mySqlDatabaseName : 'petclinic'
    keyVaultName: keyVault.outputs.name
  }
}

// The application backend
module app './app/app.bicep' = {
  name: 'app'
  params: {
    name: !empty(appName) ? appName : '${abbrs.webSitesAppService}petclinic-${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVault.outputs.name
    appSettings: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: monitoring.outputs.applicationInsightsConnectionString
      AZURE_KEY_VAULT_ENDPOINT: keyVault.outputs.endpoint
      SPRING_PROFILES_ACTIVE: 'azure,mysql'
      MYSQL_URL: mySql.outputs.endpoint
      MYSQL_USER: mySqlServerAdminName
    }
  }
}

// Give the API access to KeyVault
module appKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'app-keyvault-access'
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: app.outputs.APP_IDENTITY_PRINCIPAL_ID
  }
}

// Data outputs
output MYSQL_URL string = mySql.outputs.endpoint
output MYSQL_USER string = mySqlServerAdminName

// App outputs
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output SPRING_PROFILES_ACTIVE string = 'azure,mysql'
