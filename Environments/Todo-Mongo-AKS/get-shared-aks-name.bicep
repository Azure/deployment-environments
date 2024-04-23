@description('app deployment name')
param appDeployName string

@description('Shared AKS resource group')
param aksResourceGroupName string

@description('Timestamp - utcNow can only be called as a default value of a parameter.')
param timestamp string = utcNow()

@description('The location to run the deployment script in')
param location string = resourceGroup().location

param identityName string

var scriptToExecute = '''
$output = Get-AzResource -ResourceGroupName $Env:RESOURCEGROUP -ResourceType Microsoft.ContainerService/ManagedClusters

Write-Output $output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output.Name
'''

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module roleAssignemnt './core/security/role.bicep' = {
  name: 'read-role-assignment-to-aks'
  scope: resourceGroup(aksResourceGroupName)
  params: {
    principalId: identity.properties.principalId
    roleDefinitionId: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  }
}

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind: 'AzurePowerShell'
  name: '${appDeployName}-get-aks-script'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}' : {}
    }
  }
  properties: {
    forceUpdateTag: timestamp
    azPowerShellVersion: '7.2.0'
    retentionInterval: 'PT1H'
    scriptContent: scriptToExecute
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'RESOURCEGROUP'
        value: aksResourceGroupName
      }
    ]
  }
}

output clusterName string = empty(script.properties.outputs.text) ? '' : script.properties.outputs.text
