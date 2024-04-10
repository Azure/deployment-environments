@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}
@secure()
param inputs object


var resourceToken = uniqueString(resourceGroup().id)

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${resourceToken}'
  location: location
  tags: tags
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: replace('acr-${resourceToken}', '-', '')
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tags
}

resource caeMiRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, managedIdentity.id, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d'))
  scope: containerRegistry
  properties: {
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId:  subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law-${resourceToken}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
  tags: tags
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'cae-${resourceToken}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
  tags: tags
}

resource eventbus 'Microsoft.App/containerApps@2023-05-02-preview' = {
  name: 'eventbus'
  location: location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 5672
        transport: 'tcp'
      }
      secrets: [
        {
          name: 'rabbitmq-default-pass'
          value: inputs.eventbus.password
        }    
      ]
    }
    template: {
      containers: [
        {
          image: 'rabbitmq:3'
          name: 'eventbus'
          env: [
            {
              name: 'RABBITMQ_DEFAULT_USER'
              value: 'guest'
            }
            {
              name: 'RABBITMQ_DEFAULT_PASS'
              secretRef: 'rabbitmq-default-pass'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  tags: union(tags, {'aspire-resource-name': 'eventbus'})
}

resource postgres 'Microsoft.App/containerApps@2023-05-02-preview' = {
  name: 'postgres'
  location: location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 5432
        transport: 'tcp'
      }
      secrets: [
        {
          name: 'postgres-password'
          value: inputs.postgres.password
        }    
      ]
    }
    template: {
      containers: [
        {
          image: 'ankane/pgvector:latest'
          name: 'postgres'
          env: [
            {
              name: 'POSTGRES_HOST_AUTH_METHOD'
              value: 'scram-sha-256'
            }
            {
              name: 'POSTGRES_INITDB_ARGS'
              value: '--auth-host=scram-sha-256 --auth-local=scram-sha-256'
            }
            {
              name: 'POSTGRES_PASSWORD'
              secretRef: 'postgres-password'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  tags: union(tags, {'aspire-resource-name': 'postgres'})
}

resource redis 'Microsoft.App/containerApps@2023-05-02-preview' = {
  name: 'redis'
  location: location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 6379
        transport: 'tcp'
      }
    }
    template: {
      containers: [
        {
          image: 'redis:7.2.4'
          name: 'redis'
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  tags: union(tags, {'aspire-resource-name': 'redis'})
}

output MANAGED_IDENTITY_CLIENT_ID string = managedIdentity.properties.clientId
output MANAGED_IDENTITY_NAME string = managedIdentity.name
output MANAGED_IDENTITY_PRINCIPAL_ID string = managedIdentity.properties.principalId
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.name
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.properties.loginServer
output AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID string = managedIdentity.id
output AZURE_CONTAINER_APPS_ENVIRONMENT_ID string = containerAppEnvironment.id
output AZURE_CONTAINER_APPS_ENVIRONMENT_DEFAULT_DOMAIN string = containerAppEnvironment.properties.defaultDomain
