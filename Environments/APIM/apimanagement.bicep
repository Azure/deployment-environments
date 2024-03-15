param apimServiceName string
param functionAppName string

resource apimService 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimServiceName
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}

resource apimBackend 'Microsoft.ApiManagement/service/backends@2021-12-01-preview' = {
  parent: apimService
  name: functionAppName
  properties: {
    description: functionAppName
    url: 'https://${functionApp.properties.hostNames[0]}'
    protocol: 'http'
    resourceId: '${environment().resourceManager}${functionApp.id}'
    credentials: {
      header: {
        'x-functions-key': [
          '{{function-app-key}}'
        ]
      }
    }
  }
  dependsOn: [apimNamedValuesKey]
}

resource apimNamedValuesKey 'Microsoft.ApiManagement/service/namedValues@2021-12-01-preview' = {
  parent: apimService
  name: 'function-app-key'
  properties: {
    displayName: 'function-app-key'
    value: listKeys('${functionApp.id}/host/default', '2019-08-01').functionKeys.default
    tags: [
      'key'
      'function'
      'auto'
    ]
    secret: true
  }
}

resource apimAPI 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: apimService
  name: 'simple-fastapi-api'
  properties: {
    displayName: 'Protected API Calls'
    apiRevision: '1'
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    path: 'api'
  }
}

resource apimAPIGet 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apimAPI
  name: 'generate-name'
  properties: {
    displayName: 'Generate Name'
    method: 'GET'
    urlTemplate: '/generate_name'
  }
}

resource apimAPIGetPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apimAPIGet
  name: 'policy'
  properties: {
    format: 'xml'
    value: '<policies>\r\n<inbound>\r\n<base />\r\n\r\n<set-backend-service id="apim-generated-policy" backend-id="${functionApp.properties.name}" />\r\n<rate-limit calls="20" renewal-period="90" remaining-calls-variable-name="remainingCallsPerSubscription" />\r\n<cors allow-credentials="false">\r\n<allowed-origins>\r\n<origin>*</origin>\r\n</allowed-origins>\r\n<allowed-methods>\r\n<method>GET</method>\r\n<method>POST</method>\r\n</allowed-methods>\r\n</cors>\r\n</inbound>\r\n<backend>\r\n<base />\r\n</backend>\r\n<outbound>\r\n<base />\r\n</outbound>\r\n<on-error>\r\n<base />\r\n</on-error>\r\n</policies>'
  }
  dependsOn: [apimBackend]
}

resource apimAPIPublic 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: apimService
  name: 'public-docs'
  properties: {
    displayName: 'Public Doc Paths'
    apiRevision: '1'
    subscriptionRequired: false
    protocols: [
      'https'
    ]
    path: 'public'
  }
}

resource apimAPIDocsSwagger 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apimAPIPublic
  name: 'swagger-docs'
  properties: {
    displayName: 'Documentation'
    method: 'GET'
    urlTemplate: '/docs'
  }
}

resource apimAPIDocsSchema 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apimAPIPublic
  name: 'openapi-schema'
  properties: {
    displayName: 'OpenAPI Schema'
    method: 'GET'
    urlTemplate: '/openapi.json'
  }
}

var docsPolicy = '<policies>\r\n<inbound>\r\n<base />\r\n<set-backend-service id="apim-generated-policy" backend-id="${functionApp.properties.name}" />\r\n<cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="false" must-revalidate="false" downstream-caching-type="none" />\r\n</inbound>\r\n<backend>\r\n<base />\r\n</backend>\r\n<outbound>\r\n<base />\r\n<cache-store duration="3600" />\r\n</outbound>\r\n<on-error>\r\n<base />\r\n</on-error>\r\n</policies>'

resource apimAPIDocsSwaggerPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apimAPIDocsSwagger
  name: 'policy'
  properties: {
    format: 'xml'
    value: docsPolicy
  }
  dependsOn: [apimBackend]
}

resource apimAPIDocsSchemaPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apimAPIDocsSchema
  name: 'policy'
  properties: {
    format: 'xml'
    value: docsPolicy
  }
  dependsOn: [apimBackend]
}

resource functionAppProperties 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  kind: 'string'
  parent: functionApp
  properties: {
      apiManagementConfig: {
        id: '${apimService.id}/apis/simple-fastapi-api'
      }
  }
  dependsOn: [
    apimService
  ]
}

output apimServiceUrl string = apimService.properties.gatewayUrl
