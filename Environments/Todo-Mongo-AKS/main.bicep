

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

param cosmosAccountName string = ''
param cosmosDatabaseName string = ''
param keyVaultName string = ''
param principalId string = ''
param configStoreName string = ''
param sharedAKSProjectName string
param sharedAKSEnvironmentName string 
var sharedAKSResourceGroup = '${sharedAKSProjectName}-${sharedAKSEnvironmentName}'

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, resourceGroup().id, location))

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    principalId: principalId
  }
}


module aksName 'get-shared-aks-name.bicep' = {
  name: 'get-aks-name'
  params: {
    appDeployName: 'todo-deploy'
    aksResourceGroupName: sharedAKSResourceGroup
    identityName : '${abbrs.managedIdentityUserAssignedIdentities}dp-${resourceToken}'
    location: location
  }
}

module aks 'get-aks-info.bicep' = {
  name: 'aks'
  scope: resourceGroup(sharedAKSResourceGroup)
  params: {
    aksName: aksName.outputs.clusterName
  }
}

module clusterKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'cluster-keyvault-access'
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: aks.outputs.aksIdentityObjectId
  }
}

// Give the API the role to access Cosmos
module apiCosmosSqlRoleAssign './core/database/cosmos/sql/cosmos-sql-role-assign.bicep' = {
  name: 'api-cosmos-access'
  params: {
    accountName: cosmos.outputs.accountName
    roleDefinitionId: cosmos.outputs.roleDefinitionId
    principalId: aks.outputs.aksIdentityObjectId
  }
}

// Give the API the role to access Cosmos
module userComsosSqlRoleAssign './core/database/cosmos/sql/cosmos-sql-role-assign.bicep' = if (principalId != '') {
  name: 'user-cosmos-access'
  params: {
    accountName: cosmos.outputs.accountName
    roleDefinitionId: cosmos.outputs.roleDefinitionId
    principalId: principalId
  }
}

// The application database
module cosmos './app/db.bicep' = {
  name: 'cosmos'
  params: {
    accountName: !empty(cosmosAccountName) ? cosmosAccountName : '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
    databaseName: cosmosDatabaseName
    location: location
    keyVaultName: keyVault.outputs.name
  }
}


@description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
param contentType string = ''


resource configStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: !empty(configStoreName) ? configStoreName : '${abbrs.appConfigurationConfigurationStores}${resourceToken}'
  location: location
  sku: {
    name: 'standard'
  }
}

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStore
  name: 'AZURE_COSMOS_CONNECTION_STRING_KEY'
  properties: {
    value: cosmos.outputs.connectionStringKey
    contentType: contentType
  }
}

resource configStoreKeyValue2 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStore
  name: 'AZURE_COSMOS_DATABASE_NAME'
  properties: {
    value: cosmos.outputs.databaseName
    contentType: contentType
  }
}

resource configStoreKeyValue3 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStore
  name: 'AZURE_KEY_VAULT_ENDPOINT'
  properties: {
    value: keyVault.outputs.endpoint
    contentType: contentType
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
