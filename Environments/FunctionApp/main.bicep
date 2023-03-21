// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('Name of the Function App')
param name string = ''

@description('Location to deploy the environment resources')
param location string = resourceGroup().location

@description('Allows https traffic only to Storage Account and Functions App if set to true.')
param supportsHttpsTrafficOnly bool = true

@description('The language worker runtime to load in the function app')
@allowed([
  'dotnet'
  'dotnet-isolated'
  'java'
  'node'
  'powershell'
  'python'
])
param runtime string = 'dotnet-isolated'

@description('Tags to apply to environment resources')
param tags object = {}

var linexFxVersions = {
  dotnet: 'DOTNET|6.0'
  'dotnet-isolated': 'DOTNET-ISOLATED|7.0'
  java: 'JAVA|17'
  node: 'NODE|18'
  powershell: 'POWERSHELL|7.2'
  python: 'PYTHON|3.10'
}

var resourceName = !empty(name) ? replace(name, ' ', '-') : 'a${uniqueString(resourceGroup().id)}'

// storage account names can be no longer than 24 chars
var storageAcctName = take(toLower(replace(replace(resourceName, '-', ''), '_', '')), 24)

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  kind: 'web'
  name: resourceName
  location: location
  properties: {
    Application_Type: 'web'
  }
  tags: tags
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: resourceName
  location: location
  kind: 'functionapp,linux'
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
  properties: {
    reserved: true
  }
  tags: tags
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAcctName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
  }
  tags: tags
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  kind: 'functionapp,linux'
  name: resourceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: supportsHttpsTrafficOnly
    siteConfig: {
      linuxFxVersion: linexFxVersions[runtime]
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AZURE_FUNCTIONS_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
      ]
    }
  }
  tags: tags
}
