param name string
param location string = resourceGroup().location
param tags object = {}

resource search 'Microsoft.Search/searchServices@2021-04-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    authOptions: {
      apiKeyOnly: {
      }
    }
    disableLocalAuth: false
    disabledDataExfiltrationOptions: []
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    hostingMode: 'default'
    networkRuleSet: {
      bypass: 'None'
      ipRules: []
    }
    partitionCount: 1
    publicNetworkAccess: 'Enabled'
    replicaCount: 1
    semanticSearch: 'disabled'
  }
  sku: {
    name: 'standard'
  }
}

output id string = search.id
output endpoint string = 'https://${name}.search.windows.net/'
