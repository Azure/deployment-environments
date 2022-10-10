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
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'

@description('Tags to apply to environment resources')
param tags object = {}

param resourceName string = !empty(name) ? replace(name, ' ', '-') : 'a${uniqueString(resourceGroup().id)}'

var storageAcctName = toLower(replace(resourceName, '-', ''))

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
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
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
  kind: 'functionapp'
  name: resourceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: supportsHttpsTrafficOnly
    siteConfig: {
      appSettings: [
        // {
        //   name: 'AzureWebJobsDashboard'
        //   value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        // }
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
