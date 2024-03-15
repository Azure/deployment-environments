@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param environmentName string = 'test'

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@secure()
@description('PostGreSQL Server administrator password')
param databasePassword string

@secure()
@description('Django SECRET_KEY for securing signed data')
param secretKey string

var resourceToken = toLower(uniqueString(resourceGroup().id, location))
var tags = { 'azd-env-name': environmentName }

module resources 'resources.bicep' = {
  name: 'resources'
  params: {
    name: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
    databasePassword: databasePassword
    secretKey: secretKey
  }
}

output AZURE_LOCATION string = location
output APPLICATIONINSIGHTS_CONNECTION_STRING string = resources.outputs.APPLICATIONINSIGHTS_CONNECTION_STRING
output WEB_URI string = resources.outputs.WEB_URI
