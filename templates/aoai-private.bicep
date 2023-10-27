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
}

var virtualNetworkId = virtualNetwork.id
var subnetId_Pep = '${virtualNetworkId}/subnets/${subnetName_Pep}'
var networkSecurityGroupId = networkSecurityGroup.id
var privateEndpointResourceId = pep_storageAccount.id

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

resource Microsoft_Storage_storageAccounts_fileservices_storageAccountName_default 'Microsoft.Storage/storageAccounts/fileservices@2022-05-01' = {
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
  tags: {}
}

resource privatelink_blob_core_windows_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
  tags: {}
  properties: {}
  dependsOn: [
    pep_storageAccount
  ]
}

resource privatelink_blob_core_windows_net_virtualNetworkId 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${string('privatelink.blob.core.windows.net')}/${uniqueString(virtualNetworkId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: true
  }
  dependsOn: [
    privatelink_blob_core_windows_net
  ]
}

resource Microsoft_Network_privateEndpoints_privateDnsZoneGroups_storageAccount 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
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
    privatelink_blob_core_windows_net
  ]
}
