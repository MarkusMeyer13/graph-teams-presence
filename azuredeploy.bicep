param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
// param storage_account_name string = 'str${uniqueString(resourceGroup().id)}'
param storage_account_name string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'
resource storage_account 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storage_account_name
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
  }
}
output storage_account_connectionstring string = 'DefaultEndpointsProtocol=https;AccountName=${storage_account_name};AccountKey=${listKeys(resourceId(resourceGroup().name, 'Microsoft.Storage/storageAccounts', storage_account_name), '2021-02-01').keys[0].value};EndpointSuffix=core.windows.net'


param appservice_plan_name string
param appservice_plan_location string = resourceGroup().location
param appservice_plan_sku string ='Y1'
param appservice_plan_tier string = 'Dynamic'

resource appservice_plan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name:appservice_plan_name
  location:appservice_plan_location
  kind: 'functionapp,linux'
  sku:{
    name:appservice_plan_sku
    tier:appservice_plan_tier
  }
  properties:{
    reserved: true
  }
  
}

output appservice_plan_id string = appservice_plan.id

param appinsights_name string = 'appi-${uniqueString(resourceGroup().id)}'
resource appinsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  location: location
  name: appinsights_name
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

param function_app_name string
resource function_app 'Microsoft.Web/sites@2020-06-01' = {
  name: function_app_name
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: appservice_plan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.8'
      use32BitWorkerProcess: false
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appinsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage_account.id, storage_account.apiVersion).keys[0].value}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage_account.id, storage_account.apiVersion).keys[0].value}'
        }
      ]
    }
  }
}


param service_bus_name string
resource service_bus 'Microsoft.ServiceBus/namespaces@2021-01-01-preview' = {
  name: service_bus_name
  location: location
  tags: {}
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

//name: '${service_bus}/${topic.name}/${subscription.name}'
param service_bus_topic_name string = '${service_bus_name}/t.graph.presence.change'   
resource service_bus_topic 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-01-01-preview' = {
  name: service_bus_topic_name
}

// var massiveBiceps = [
//   'Arnold'
//   'Sylvester'
//   'Dolph'
// ]

// resource topic 'Microsoft.ServiceBus/namespaces/topics@2021-01-01-preview' = [for (topic, index) in serviceBusConfig.topics: {
//   name: '${service_bus}/${topic.name}'

//   resource sub 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-01-01-preview' = [for subscription in ${topic[index].subscriptions}: {
//     name: '${service_bus}/${topic.name}/${subscription.name}'
//   }]
// }]

// param service_bus_topic_name string = 't.graph.presence.change'
// resource service_bus_topic 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-01-01-preview' = {
//   name: service_bus_topic_name
// }

// param service_bus_topic_subscription_name string = 't.graph.presence.change'
// resource service_bus_topic_subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-01-01-preview' = {
//   name: service_bus_topic_subscription_name
//   properties: {
//     lockDuration: 'string'
//     requiresSession: bool
//     defaultMessageTimeToLive: 'string'
//     deadLetteringOnFilterEvaluationExceptions: bool
//     deadLetteringOnMessageExpiration: bool
//     duplicateDetectionHistoryTimeWindow: 'string'
//     maxDeliveryCount: int
//     status: 'string'
//     enableBatchedOperations: bool
//     autoDeleteOnIdle: 'string'
//     forwardTo: 'string'
//     forwardDeadLetteredMessagesTo: 'string'
//   }
// }
