param subscriptionId string
param name string
param location string
param use32BitWorkerProcess bool
param ftpsState string
param storageAccountName string
param linuxFxVersion string
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string
param hostingPlanName string
param serverFarmResourceGroup string
param alwaysOn bool

var inboundSubnetDeployment_var = 'inboundSubnetDeployment'
var outboundSubnetDeployment_var = 'outboundSubnetDeployment'
var storageSubnetDeployment = 'storageSubnetDeployment'
var inboundPrivateDnsZoneName = 'privatelink.azurewebsites.net'
var inboundPrivateDnsZoneARecordName = 'inboundPrivateDnsZoneARecordName'

resource name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  kind: 'functionapp,linux'
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
          value: 'python'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('a095d2d5-fd2c-403f-bb29-fad7cad5d098', 'rg-aoai-test-02', 'Microsoft.Storage/storageAccounts', storageAccountName), '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/virtualNetworks/vnet-aoai-test-02/subnets/funcapp-vi'
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true
    httpsOnly: true
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
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
  kind: 'linux'
  tags: {}
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    reserved: true
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

resource pep_func_aoai_test_02 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pep-func-aoai-test-02'
  location: location
  properties: {
    subnet: {
      id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/virtualNetworks/vnet-aoai-test-02/subnets/private-endpoint'
    }
    privateLinkServiceConnections: [
      {
        name: 'pep-func-aoai-test-02'
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

module inboundPrivateDnsZoneARecord './nested_inboundPrivateDnsZoneARecord.bicep' = {
  name: inboundPrivateDnsZoneARecordName
  params: {
    siteName: name
  }
  dependsOn: [
    pep_func_aoai_test_02
    name_resource
  ]
}

module inboundPrivateDnsZoneARecordName_scm './nested_inboundPrivateDnsZoneARecordName_scm.bicep' = {
  name: '${inboundPrivateDnsZoneARecordName}-scm'
  params: {
    siteName: name
  }
  dependsOn: [
    pep_func_aoai_test_02
    name_resource
  ]
}