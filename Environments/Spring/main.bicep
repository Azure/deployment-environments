@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param environmentName string = 'test'

@description('The instance name of the Azure Spring Cloud resource')
param springCloudInstanceName string = ''

@description('The name of the Application Insights instance for Azure Spring Cloud')
param appInsightsName string = ''

param logAnalyticsWorkspaceName string = ''

@description('The resourceID of the Azure Spring Cloud App Subnet')
param springCloudAppSubnetID string = ''

@description('The resourceID of the Azure Spring Cloud Runtime Subnet')
param springCloudRuntimeSubnetID string = ''

param springCloudServiceCidrs string = '10.20.0.0/16,10.21.0.0/16,10.22.0.1/16'

var resourceToken = toLower(uniqueString(resourceGroup().id, location))

@description('The name of the Virtual Network')
param vnetName string = ''

@description('the app subnet name of the Azure Spring Cloud')
param ascAppSubnetName string = ''

@description('the runtime subnet name of the Azure Spring Cloud')
param ascRuntimeSubnetName string = ''

@description('The address prefixes of the vnet')
param vnetAddressPrefixes string = '10.4.0.0/16'

@description('The Azure Spring Cloud App subnet address prefixes in the vnet')
param ascAppSubnetAddressPrefixes string = '10.4.0.0/24'

@description('The Azure Spring Cloud Runtime subnet address prefixes in the vnet')
param ascRuntimeSubnetAddressPrefixes string = '10.4.1.0/24'

param location string = resourceGroup().location

var tags = { 'env-name': environmentName }

module vnet 'core/network/vnet.bicep' = {
  name: 'vnet'
  params:{
    vnetName: !empty(vnetName) ? vnetName : 'vnet-${resourceToken}'
    location: location
    ascAppSubnetName: !empty(ascAppSubnetName) ? ascAppSubnetName : 'app-sub-${resourceToken}'
    ascRuntimeSubnetName: !empty(ascRuntimeSubnetName) ? ascRuntimeSubnetName : 'runtime-sub-${resourceToken}'
    vnetAddressPrefixes: vnetAddressPrefixes
    ascAppSubnetAddressPrefixes: ascAppSubnetAddressPrefixes
    ascRuntimeSubnetAddressPrefixes: ascRuntimeSubnetAddressPrefixes
    tags: tags
  }
}

module springcloud 'core/host/springapps.bicep' = {
  name: 'springcloud'
  params: {
    springCloudInstanceName: !empty(springCloudInstanceName) ? springCloudInstanceName : 'asa-${resourceToken}'
    location: location
    appInsightsName: !empty(appInsightsName) ? appInsightsName : 'appi-${resourceToken}'
    logAnalyticsWorkspaceName: !empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspaceName : 'log-${resourceToken}'
    springCloudAppSubnetID: !empty(springCloudAppSubnetID) ? springCloudAppSubnetID : vnet.outputs.ascAppSubnetId
    springCloudRuntimeSubnetID: !empty(springCloudRuntimeSubnetID) ? springCloudRuntimeSubnetID : vnet.outputs.ascRuntimeSubetId
    springCloudServiceCidrs: springCloudServiceCidrs
    tags: tags
  }
}
