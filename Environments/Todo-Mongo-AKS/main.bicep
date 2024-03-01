@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

param cosmosAccountName string = ''
param cosmosDatabaseName string = ''
param keyVaultName string = ''
param principalId string = ''
param aksClusterIdentityObjectId string

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

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

module clusterKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'cluster-keyvault-access'
  params: {
    keyVaultName: keyVaultName
    principalId: aksClusterIdentityObjectId
  }
}

// Data outputs
output AZURE_COSMOS_CONNECTION_STRING_KEY string = cosmos.outputs.connectionStringKey
output AZURE_COSMOS_DATABASE_NAME string = cosmos.outputs.databaseName

// App outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
