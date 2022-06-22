@description('The location to deploy our application to. Default is location of resource group')
param location string = resourceGroup().location

@description('Name of our application.')
param applicationName string = uniqueString(resourceGroup().id)

@description('The latest image that the inventory api is using')
param inventoryApiImage string

@description('The latest image that the book api container is using')
param bookApiImage string

@description('The latest image that the web container app is using')
param bookVaultImage string

var containerRegistryName = '${applicationName}acr'
var logAnalyticsWorkspaceName = '${applicationName}law'
var appInsightsName = '${applicationName}ai'
var containerAppEnvironmentName = '${applicationName}env'
var apimInstanceName = '${applicationName}apim'
var booksApiName = 'booksapi'
var inventoryApiName = 'inventoryapi'
var bookvaultWebName = 'bookvaultweb'
var targetPort = 80

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: containerRegistryName
  location: location 
  sku: {
    name: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: containerAppEnvironmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource apim 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apimInstanceName
  location: location
  sku: {
    capacity: 1
    name: 'Developer'
  }
  properties: {
    publisherEmail: 'willvelida@microsoft.com'
    publisherName: 'Will Velida'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource bookApi 'Microsoft.App/containerApps@2022-03-01' = {
  name: booksApiName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'multiple'
      secrets: [
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          identity: 'system'
        }
      ]
      ingress: {
        external: false
        targetPort: targetPort
        transport: 'http'
        allowInsecure: true 
      }
    }
    template: {
      containers: [
        {
          image: bookApiImage
          name: booksApiName
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: appInsights.properties.InstrumentationKey
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsights.properties.ConnectionString
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource inventoryApi 'Microsoft.App/containerApps@2022-03-01' = {
  name: inventoryApiName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'multiple'
      secrets: [
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          identity: 'system'
        }
      ]
      ingress: {
        external: false
        targetPort: targetPort
        transport: 'http'
        allowInsecure: true
      }
    }
    template: {
      containers: [
        {
          image: inventoryApiImage
          name: inventoryApiName
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: appInsights.properties.InstrumentationKey
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsights.properties.ConnectionString
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource bookvaultWeb 'Microsoft.App/containerApps@2022-03-01' = {
  name: bookvaultWebName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'multiple'
      secrets: [
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          identity: 'system'
        }
      ]
      ingress: {
        external: true
        targetPort: targetPort
        transport: 'http'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: bookVaultImage
          name: bookvaultWebName
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
            {
              name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
              value: appInsights.properties.InstrumentationKey
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsights.properties.ConnectionString
            }
            {
              name: 'BooksApi'
              value: 'https://${bookApi.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'InventoryApi'
              value: 'https://${inventoryApi.properties.configuration.ingress.fqdn}'
            }
          ]
          probes: [
            {
              type: 'Readiness'
              httpGet: {
                port: targetPort
                path: '/probes/ready'
              }
              timeoutSeconds: 30
              successThreshold: 1
              failureThreshold: 10
              periodSeconds: 10
            }
            {
              type: 'Startup'
              httpGet: {
                port: targetPort
                path: '/probes/healthz' 
              }
              failureThreshold: 6
              periodSeconds: 10
            }        
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

module bookApiPullRole 'modules/acrPullRoleAssignment.bicep' = {
  name: 'bookApiPullRole'
  params: {
    appId: bookApi.id
    containerRegistryName: containerRegistry.name
    principalId: bookApi.identity.principalId
  }
}

module inventoryApiPullRole 'modules/acrPullRoleAssignment.bicep' = {
  name: 'inventoryApiPullRole'
  params: {
    appId: inventoryApi.id
    containerRegistryName: containerRegistry.name 
    principalId: inventoryApi.identity.principalId
  }
}

module bookvaultWebPullRole 'modules/acrPullRoleAssignment.bicep' = {
  name: 'bookvaultWebPullRole'
  params: {
    appId: bookvaultWeb.id
    containerRegistryName: containerRegistry.name 
    principalId: bookvaultWeb.identity.principalId
  }
}
