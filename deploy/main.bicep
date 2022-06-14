@description('The location to deploy our application to. Default is location of resource group')
param location string = resourceGroup().location

@description('Name of our application.')
param applicationName string = uniqueString(resourceGroup().id)

var containerRegistryName = '${applicationName}acr'
var logAnalyticsWorkspaceName = '${applicationName}law'
var appInsightsName = '${applicationName}ai'
var containerAppEnvironmentName = '${applicationName}env'
var apimInstanceName = '${applicationName}apim'
var booksApiName = 'booksapi'
var inventoryApiName = 'inventoryapi'
var bookvaultWebName = 'bookvaultweb'
var bookEndpointName = 'Book'
var inventoryEndpointName = 'Inventory'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: containerRegistryName
  location: location 
  sku: {
    name: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: true
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
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: false
        targetPort: 80
        transport: 'http'
        allowInsecure: true 
      }
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
        maxReplicas: 3
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
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: false
        targetPort: 80
        transport: 'http'
        allowInsecure: true
      }
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
        maxReplicas: 3
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
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: true
        targetPort: 80
        transport: 'http'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource bookApiEndpoint 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: bookEndpointName
  parent: apim
  properties: {
    path: 'Book'
    apiType: 'http'
    displayName: bookEndpointName
    format: 'swagger-json'
    type: 'http'
    serviceUrl: 'https://${bookApi.properties.configuration.ingress.fqdn}'
    protocols: [
     'http'
     'https' 
    ]
  }
}

resource getBooksOperations 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  name: 'getBooks'
  parent: bookApiEndpoint
  properties: {
    displayName: 'GET Books'
    method: 'GET'
    urlTemplate: '/books' 
  }
}

resource inventoryApiEndpoint 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: inventoryEndpointName
  parent: apim
  properties: {
    path: 'Inventory'
    apiType: 'http'
    displayName: inventoryEndpointName
    format: 'swagger-json'
    type: 'http'
    serviceUrl: 'https://${inventoryApi.properties.configuration.ingress.fqdn}'
    protocols: [
      'http'
      'https'
    ]
  }
}

resource getInventoryOperations 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  name: 'getInventory'
  parent: inventoryApiEndpoint
  properties: {
    displayName: 'GET Inventory'
    method: 'GET'
    urlTemplate: '/inventory/{productId}' 
  }
}
