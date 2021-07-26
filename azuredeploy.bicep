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
  kind: 'functionapp'
  sku:{
    name:appservice_plan_sku
    tier:appservice_plan_tier
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
