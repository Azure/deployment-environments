@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = 'test'

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

param openAiAccountName string = ''
param storageAccountName string = ''
param searchServicesName string = ''

@description('Id of the user or app to assign application roles')
param principalId string

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(resourceGroup().id, location))
var tags = { 'azd-env-name': environmentName }

module openAiAccount 'core/ai/openai-account.bicep' = {
  name: 'openai'
  params: {
    name: !empty(openAiAccountName) ? openAiAccountName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: location
    tags: tags
    deployments: [
      {
        name: 'davinci-instruct'
        model: {
          format: 'OpenAI'
          name: 'text-davinci-001'
          version: '1'
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
      }
      {
        name: 'text-search-curie-doc-001'
        model: {
          format: 'OpenAI'
          name: 'text-search-curie-doc-001'
          version: '1'
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
      }
      {
        name: 'text-search-curie-query-001'
        model: {
          format: 'OpenAI'
          name: 'text-search-curie-query-001'
          version: '1'
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
      }
    ]
  }
}

module searchServices 'core/search/search-services.bicep' = {
  name: 'search-services'
  params: {
    name: !empty(searchServicesName) ? searchServicesName : '${abbrs.searchSearchServices}${resourceToken}'
    location: location
    tags: tags
  }
}

// Backing storage for Azure functions backend API
module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  params: {
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    location: location
    tags: tags
    publicNetworkAccess: 'Enabled'
    containers: [
      {
        name: 'openaiblob'
      }
    ]
  }
}

module searchRole 'core/security/role.bicep' = {
  name: 'search-role'
  params: {
    principalId: principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: 'User'
  }
}

module searchIndexDataReaderRole 'core/security/role.bicep' = {
  name: 'search-index-data-reader-role'
  params: {
    principalId: principalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'User'
  }
}

module searchServiceContribRole 'core/security/role.bicep' = {
  name: 'search-service-contrib-role'
  params: {
    principalId: principalId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
    principalType: 'User'
  }
}


module blobRole 'core/security/role.bicep' = {
  name: 'blob-role'
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'User'
  }
}

module openAiRole 'core/security/role.bicep' = {
  name: 'openai-role'
  params: {
    principalId: principalId
    roleDefinitionId: 'a001fd3d-188f-4b5d-821b-7da978bf7442'
    principalType: 'User'
  }
}

// App outputs
output AZURE_LOCATION string = location
//output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_STORAGE_ACCOUNT_NAME string = storage.outputs.name
output OPENAI_ENDPOINT string = openAiAccount.outputs.endpoint
output SEARCH_ENDPOINT string = searchServices.outputs.endpoint
