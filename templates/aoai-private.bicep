@description('Azure region for the deployment, resource group and resources.')
param location string = 'northcentralus'

@description('Name of the virtual network resource.')
param virtualNetworkName string = 'vnet-aoai-test-02'

@description('Array of address blocks reserved for this virtual network, in CIDR notation.')
param addressPrefixes array = [
  '10.1.0.0/16'
]

@description('Name of the private endpoint subnet for this virtual network.')
param subnetName_Pep string = 'private-endpoint'

@description('Address block reserved for the private endpoint subnet, in CIDR notation.')
param subnetPrefix_Pep string = '10.1.0.0/24'

@description('Name of the Logic App VNet integration  subnet for this virtual network.')
param subnetName_ViLog string = 'logapp-vi'

@description('Address block reserved for the Logic App VNet integration  subnet, in CIDR notation.')
param subnetPrefix_ViLog string = '10.1.1.0/24'

@description('Name of the Function App VNet integration subnet for this virtual network.')
param subnetName_ViFnc string = 'funcapp-vi'

@description('Address block reserved for the Function App VNet integration subnet, in CIDR notation.')
param subnetPrefix_ViFnc string = '10.1.2.0/24'

@description('Name of the network security group.')
param networkSecurityGroupName string = 'nsg-aoai-test-02'

@description('Name of the storage account.')
param storageAccountName string = 'staoaitest02'

@description('Access tier for the storage account.')
@allowed([
  'Hot'
  'Cool'
])
param storageAccessTier string = 'Hot'

@description('Enable Hierarchical Namespace for the storage account.')
param storageIsHnsEnabled bool = false

@description('Enable SFTP for the storage account.')
param storageIsSftpEnabled bool = false

@description('Replication type for storage account.')
param storageAccountType string = 'Standard_LRS'

@description('Kind of storage account.')
param storageKind string = 'StorageV2'

@description('Optional tags for the resources.')
param tagsByResource object = {
  'Microsoft.Network/virtualNetworks': {
    environment: 'poc'
  }
  'Microsoft.Network/networkSecurityGroups': {
    environment: 'poc'
  }
  'Microsoft.Storage/storageAccounts': {
    environment: 'poc'
  }
  'Microsoft.Web/sites': {
    environment: 'poc'
  }
}
/////Logic App Params/////
@description('Name of the Login App.')
param logicAppName string = 'logapp-aoai-test-02'

@description('Name of the storage account for Logic and Function Apps.')
param aspStorageAccountName string = 'staoaitestasp02'

@description('.NET Framework version.')
param netFrameworkVersion string = 'v6.0'

@description('Name of the hosting plan / server farm.')
param hostingPlanName string = 'asplog-aoai-test-02'

@description('Hosting Plan / Server Farm SKU.')
param hostingPlanSku string = 'WorkflowStandard'

@description('Hosting Plan / Server Farm SKU code.')
param hostingPlanSkuCode string = 'WS1'
param hostingPlanWorkerSize string = '3'
param hostingPlanWorkerSizeId string = '3'
param numberOfWorkers string = '1'
param vnetPrivatePortsCount int = 2

/////Function App Params/////
@description('Name of the Function App.')
param funcAppName string = 'funcapp-aoai-test-02'

@description('Language and version for the language-specific worker process. For example, "Python|3.11".')
param linuxFxVersion string = 'Python|3.11'

@description('Name of the Function App hosting plan / server farm.')
param hostingPlanNameFunc string = 'aspfnc-aoai-test-02'

@description('Hosting Plan / Server Farm SKU for the Function App.')
@allowed([
  'Basic'
  'PremiumV2'
  'PremiumV3'
])
param hostingPlanSkuFunc string = 'Basic'

@description('Hosting Plan / Server Farm SKU code for the Function App.')
@allowed(
  [
    'B1'
    'P1V2'
    'P1V3'
    'P2V2'
    'P2V3'
    'P3V2'
    'P3V3'
  ]
)
param hostingPlanSkuCodeFunc string = 'B1'

@description('Hosting Plan / Server Farm worker size for the Function App.')
param hostingPlanWorkerSizeFunc string = '6'

@description('Hosting Plan / Server Farm worker size ID for the Function App.')
param hostingPlanWorkerSizeIdFunc string = '6'

@description('Hosting Plan / Server Farm number of workers for the Function App.')
param numberOfWorkersFunc string = '1'

@description('AlwaysOn setting for the Function App. True or False.')
param funcAlwaysOn bool = false

var virtualNetworkId = virtualNetwork.id
var subnetId_Pep = '${virtualNetworkId}/subnets/${subnetName_Pep}'
var subnetId_ViLog = '${virtualNetworkId}/subnets/${subnetName_ViLog}'
var subnetId_ViFnc = '${virtualNetworkId}/subnets/${subnetName_ViFnc}'
var networkSecurityGroupId = networkSecurityGroup.id
var privateEndpointResourceId = pep_storageAccount.id

///Network Resources///

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  tags: (contains(tagsByResource, 'Microsoft.Network/virtualNetworks') ? tagsByResource['Microsoft.Network/virtualNetworks'] : {})
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: subnetName_Pep
        properties: {
          addressPrefixes: [
            subnetPrefix_Pep
          ]
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnetName_ViLog
        properties: {
          addressPrefixes: [
            subnetPrefix_ViLog
          ]
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnetName_ViFnc
        properties: {
          addressPrefixes: [
            subnetPrefix_ViFnc
          ]
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroupName
  location: location
  tags: (contains(tagsByResource, 'Microsoft.Network/networkSecurityGroups') ? tagsByResource['Microsoft.Network/networkSecurityGroups'] : {})
  properties: {}
}

/////Storage Account Resources/////

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    accessTier: storageAccessTier
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
    }
    dnsEndpointType: 'Standard'
    isHnsEnabled: storageIsHnsEnabled
    isSftpEnabled: storageIsSftpEnabled
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        table: {
          enabled: true
        }
        queue: {
          enabled: true
        }
      }
      requireInfrastructureEncryption: false
    }
  }
  sku: {
    name: storageAccountType
  }
  kind: storageKind
  tags: (contains(tagsByResource, 'Microsoft.Storage/storageAccounts') ? tagsByResource['Microsoft.Storage/storageAccounts'] : {})
  dependsOn: []
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource storageAccountName_file_default 'Microsoft.Storage/storageAccounts/fileservices@2022-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: false
    }
  }
  dependsOn: [
    storageAccountName_default
  ]
}

resource pep_storageAccount 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pep-${storageAccountName}'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pepconn-${storageAccountName}'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: subnetId_Pep
    }
  }
  tags: (contains(tagsByResource, 'Microsoft.Storage/storageAccounts') ? tagsByResource['Microsoft.Storage/storageAccounts'] : {})
}

resource privateDnsZone_blob 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
  tags: {}
  properties: {}
  dependsOn: [
    pep_storageAccount
  ]
}

resource privateDnsZone_blob_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${string('privatelink.blob.core.windows.net')}/${uniqueString(virtualNetworkId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
  dependsOn: [
    privateDnsZone_blob
  ]
}

resource privateDnsZoneGroups_blob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  parent: pep_storageAccount
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', 'privatelink.blob.core.windows.net')
        }
      }
    ]
  }
  dependsOn: [
    privateDnsZone_blob
  ]
}

/////Logic App Resources/////

resource logicApp_site 'Microsoft.Web/sites@2018-11-01' = {
  name: logicAppName
  kind: 'functionapp,workflowapp'
  location: location
  tags: (contains(tagsByResource, 'Microsoft.Web/sites') ? tagsByResource['Microsoft.Web/sites'] : {})
  properties: {
    name: logicAppName
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${aspStorageAccountName};AccountKey=${listKeys(aspStorageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${aspStorageAccountName};AccountKey=${listKeys(aspStorageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'logapp-aoai-test-028765'
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
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      vnetPrivatePortsCount: vnetPrivatePortsCount
      netFrameworkVersion: netFrameworkVersion
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-aoai-test-02', 'logapp-vi')
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true
    httpsOnly: true
    serverFarmId: logicAppHostingPlan.id
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: []
}

resource logicAppHostingPlan 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  tags: (contains(tagsByResource, 'Microsoft.Web/sites') ? tagsByResource['Microsoft.Web/sites'] : {})
  properties: {
    name: hostingPlanName
    workerSize: hostingPlanWorkerSize
    workerSizeId: hostingPlanWorkerSizeId
    numberOfWorkers: numberOfWorkers
    maximumElasticWorkerCount: '20'
    zoneRedundant: false
  }
  sku: {
    tier: hostingPlanSku
    name: hostingPlanSkuCode
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource pep_logicApp 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pep-${logicAppName}'
  location: location
  properties: {
    subnet: {
      id: subnetId_Pep
    }
    privateLinkServiceConnections: [
      {
        name: 'pepconn-${logicAppName}'
        properties: {
          privateLinkServiceId: logicApp_site.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone_website 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
  dependsOn: [
    pep_logicApp
    pep_funcApp
  ]
}

resource privateDnsZoneGroups_website 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  parent: pep_logicApp
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', 'privatelink.azurewebsites.net')
        }
      }
    ]
  }
  dependsOn: [
    privateDnsZone_website
  ]
}

resource privateDnsZone_website_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZone_website
  name: '${logicAppName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
  dependsOn: [
    pep_logicApp
  ]
}

resource aspStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: aspStorageAccountName
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

/////Function App Resources/////

resource funcApp_site 'Microsoft.Web/sites@2018-11-01' = {
  name: funcAppName
  kind: 'functionapp,linux'
  location: location
  tags: {}
  properties: {
    name: funcAppName
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${aspStorageAccountName};AccountKey=${listKeys(aspStorageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      linuxFxVersion: linuxFxVersion
      alwaysOn: funcAlwaysOn
    }
    clientAffinityEnabled: false
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName_ViFnc)
    publicNetworkAccess: 'Disabled'
    vnetRouteAllEnabled: true
    httpsOnly: true
    serverFarmId: funcAppHostingPlan.id
  }
  dependsOn: []
}

resource funcAppHostingPlan 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanNameFunc
  location: location
  kind: 'linux'
  tags: {}
  properties: {
    name: hostingPlanNameFunc
    workerSize: hostingPlanWorkerSizeFunc
    workerSizeId: hostingPlanWorkerSizeIdFunc
    numberOfWorkers: numberOfWorkersFunc
    reserved: true
    zoneRedundant: false
  }
  sku: {
    tier: hostingPlanSkuFunc
    name: hostingPlanSkuCodeFunc
  }
  dependsOn: []
}

resource pep_funcApp 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pep-${funcAppName}'
  location: location
  properties: {
    subnet: {
      id: subnetId_Pep
    }
    privateLinkServiceConnections: [
      {
        name: 'pepconn-${funcAppName}'
        properties: {
          privateLinkServiceId: funcApp_site.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroups_websiteFunc 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  parent: pep_funcApp
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.azurewebsites.net-config'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', 'privatelink.azurewebsites.net')
        }
      }
    ]
  }
  dependsOn: [
    privateDnsZone_website
  ]
}
