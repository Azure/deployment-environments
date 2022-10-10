// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('Location to deploy the environment resources')
param location string = resourceGroup().location

param resourcePrefix string = 'a${uniqueString(resourceGroup().id)}'

@description('Tags to apply to environment resources')
param tags object = {}

var hostingPlanName = '${resourcePrefix}-hp'
var webAppName = '${resourcePrefix}-hp'

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  tags: tags
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
  }
  tags: tags
}
