param subscriptionId string
param name string
param location string
param use32BitWorkerProcess bool
param ftpsState string
param storageAccountName string
param netFrameworkVersion string
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string
param hostingPlanName string
param serverFarmResourceGroup string
param alwaysOn bool
param vnetPrivatePortsCount int

var inboundSubnetDeployment_var = 'inboundSubnetDeployment'
var outboundSubnetDeployment_var = 'outboundSubnetDeployment'
var storageSubnetDeployment = 'storageSubnetDeployment'
var inboundPrivateDnsZoneName = 'privatelink.azurewebsites.net'
var inboundPrivateDnsZoneARecordName = 'inboundPrivateDnsZoneARecordName'

resource name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  kind: 'functionapp,workflowapp'
  location: location
  tags: {}
  properties: {
    name: name
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'logapp-aoai-test-02bb9d'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
      ]
      cors: {}
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      vnetPrivatePortsCount: vnetPrivatePortsCount
      netFrameworkVersion: netFrameworkVersion
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/virtualNetworks/vnet-aoai-test-02/subnets/logapp-vi'
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true
    httpsOnly: true
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    hostingPlan

    outboundSubnetDeployment
    inboundSubnetDeployment
  ]
}

resource hostingPlan 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  tags: {}
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    maximumElasticWorkerCount: '20'
    zoneRedundant: false
  }
  sku: {
    tier: sku
    name: skuCode
  }
  dependsOn: []
}

module inboundSubnetDeployment './nested_inboundSubnetDeployment.bicep' = {
  name: inboundSubnetDeployment_var
  scope: resourceGroup('a095d2d5-fd2c-403f-bb29-fad7cad5d098', 'rg-aoai-test-02')
  params: {}
  dependsOn: []
}

module outboundSubnetDeployment './nested_outboundSubnetDeployment.bicep' = {
  name: outboundSubnetDeployment_var
  scope: resourceGroup('a095d2d5-fd2c-403f-bb29-fad7cad5d098', 'rg-aoai-test-02')
  params: {}
  dependsOn: [
    inboundSubnetDeployment
  ]
}

resource pep_logapp_aoai_test_02 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pep-logapp-aoai-test-02'
  location: location
  properties: {
    subnet: {
      id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/virtualNetworks/vnet-aoai-test-02/subnets/private-endpoint'
    }
    privateLinkServiceConnections: [
      {
        name: 'pep-logapp-aoai-test-02'
        properties: {
          privateLinkServiceId: name_resource.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource inboundPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: inboundPrivateDnsZoneName
  location: 'global'
  dependsOn: [
    pep_logapp_aoai_test_02
  ]
}

resource pep_logapp_aoai_test_02_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: pep_logapp_aoai_test_02
  name: 'default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${inboundPrivateDnsZoneName}-config'
        properties: {
          privateDnsZoneId: inboundPrivateDnsZone.id
        }
      }
    ]
  }
}

resource inboundPrivateDnsZoneName_name_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: inboundPrivateDnsZone
  name: '${name}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: resourceId('rg-aoai-test-02', 'Microsoft.Network/virtualNetworks', 'vnet-aoai-test-02')
    }
    registrationEnabled: false
  }
  dependsOn: [
    pep_logapp_aoai_test_02

  ]
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  tags: {}
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
  }
}