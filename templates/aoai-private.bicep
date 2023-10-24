@description('Region where all resources will be deployed.')
param location string = 'northcentralus'

@description('The name of the virtual network.')
param virtualNetworkName string = 'vnet-aoai-test-01'

@description('The address prefix for the virtual network.')
param virtualNetworkAddressPrefix string = '10.0.0.0/16'

@description('Name of the subnet.')
param subnetName string = 'private-endpoint-01'

@description('IP Address Prefix of the virtual network.')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('The name of the OpenAI resource.')
param openaiName string = 'aoai-test-01'

@description('The name of the storage account.')
param storageAccountName string = 'staoaitest01'

@description('The name of the Cognitive Services resource.')
param cognitiveServicesName string = 'cog-aoai-test-01'

@description('The name of the Function App.')
param functionAppName string = 'func-aoai-test-01'

@description('The name of the Logic App.')
param logicAppName string = 'logapp-aoai-test-01'

var openaiPrivateEndpointName = 'pep-${openaiName}'
var storageAccountPrivateEndpointName = 'pep-${storageAccountName}'
var cognitiveServicesPrivateEndpointName = 'pep-${cognitiveServicesName}'
var functionAppPrivateEndpointName = 'pep-${functionAppName}'
var logicAppPrivateEndpointName = 'pep-${logicAppName}'
var virtualNetworkSubnetName = 'default'
var openaiSubnetName = 'openai'
var storageAccountSubnetName = 'storage'
var cognitiveServicesSubnetName = 'cognitiveservices'
var functionAppSubnetName = 'functionapp'
var logicAppSubnetName = 'logicapp'
var virtualNetworkSubnetAddressPrefix = '${virtualNetworkAddressPrefix}/24'
var openaiSubnetAddressPrefix = '10.0.1.0/24'
var storageAccountSubnetAddressPrefix = '10.0.2.0/24'
var cognitiveServicesSubnetAddressPrefix = '10.0.3.0/24'
var functionAppSubnetAddressPrefix = '10.0.4.0/24'
var logicAppSubnetAddressPrefix = '10.0.5.0/24'
var virtualNetworkId = virtualNetwork.id
var virtualNetworkSubnetId = '${virtualNetworkId}/subnets/${virtualNetworkSubnetName}'
var subnetId = '${virtualNetworkId}/subnets/${subnetName}'
var openaiSubnetId = '${virtualNetworkId}/subnets/${openaiSubnetName}'
var storageAccountSubnetId = '${virtualNetworkId}/subnets/${storageAccountSubnetName}'
var cognitiveServicesSubnetId = '${virtualNetworkId}/subnets/${cognitiveServicesSubnetName}'
var functionAppSubnetId = '${virtualNetworkId}/subnets/${functionAppSubnetName}'
var logicAppSubnetId = '${virtualNetworkId}/subnets/${logicAppSubnetName}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

resource openai 'Microsoft.OpenAI/openais@2021-06-01-preview' = {
  name: openaiName
  location: location
  sku: {
    name: 'dav4'
    tier: 'Standard'
  }
  properties: {}
}

resource openaiName_openaiPrivateEndpoint 'Microsoft.OpenAI/openais/privateEndpoints@2021-02-01' = {
  parent: openai
  name: '${openaiPrivateEndpointName}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'openai'
        properties: {
          privateLinkServiceId: openai.id
          groupIds: [
            'openai'
          ]
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {}
}

resource storageAccountName_storageAccountPrivateEndpoint 'Microsoft.Storage/storageAccounts/privateEndpoints@2021-02-01' = {
  parent: storageAccount
  name: storageAccountPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'storage'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2021-04-30-preview' = {
  name: cognitiveServicesName
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
  kind: 'TextAnalytics'
  properties: {}
}

resource cognitiveServicesName_cognitiveServicesPrivateEndpoint 'Microsoft.CognitiveServices/accounts/privateEndpoints@2021-02-01' = {
  parent: cognitiveServices
  name: cognitiveServicesPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'cognitiveservices'
        properties: {
          privateLinkServiceId: cognitiveServices.id
          groupIds: [
            'cognitiveservices'
          ]
        }
      }
    ]
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {}
}

resource functionAppName_functionAppPrivateEndpoint 'Microsoft.Web/sites/privateEndpoints@2021-02-01' = {
  parent: functionApp
  name: '${functionAppPrivateEndpointName}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'functionapp'
        properties: {
          privateLinkServiceId: functionApp.id
          groupIds: [
            'functionapp'
          ]
        }
      }
    ]
  }
}

resource logicApp 'Microsoft.Logic/workflows@2017-07-01' = {
  name: logicAppName
  location: location
  properties: {}
}

resource logicAppName_logicAppPrivateEndpoint 'Microsoft.Logic/workflows/privateEndpoints@2021-02-01' = {
  parent: logicApp
  name: '${logicAppPrivateEndpointName}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'logicapp'
        properties: {
          privateLinkServiceId: logicApp.id
          groupIds: [
            'logicapp'
          ]
        }
      }
    ]
  }
}

resource privatelink_openai_azure_com 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: string('privatelink.openai.azure.com')
  location: 'global'
  properties: {}
}

resource privatelink_openai_azure_com_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privatelink_openai_azure_com
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    privatelink_openai_azure_com

  ]
}

resource privatelink_blob_core_windows_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: string('privatelink.blob.core.windows.net')
  location: 'global'
  properties: {}
}

resource privatelink_blob_core_windows_net_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privatelink_blob_core_windows_net
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    privatelink_blob_core_windows_net

  ]
}

resource privatelink_search_windows_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: string('privatelink.search.windows.net')
  location: 'global'
  properties: {}
}

resource privatelink_search_windows_net_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privatelink_search_windows_net
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    privatelink_search_windows_net

  ]
}

resource privatelink_azurewebsites_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: string('privatelink.azurewebsites.net')
  location: 'global'
  properties: {}
}

resource privatelink_azurewebsites_net_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privatelink_azurewebsites_net
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    privatelink_azurewebsites_net

  ]
}

output openaiEndpoint string = reference('Microsoft.Network/privateEndpoints/${openaiPrivateEndpointName}').privateLinkServiceConnections[0].properties.privateEndpoint
output storageAccountEndpoint string = reference('Microsoft.Network/privateEndpoints/${storageAccountPrivateEndpointName}').privateLinkServiceConnections[0].properties.privateEndpoint
output cognitiveServicesEndpoint string = reference('Microsoft.Network/privateEndpoints/${cognitiveServicesPrivateEndpointName}').privateLinkServiceConnections[0].properties.privateEndpoint
output functionAppEndpoint string = reference('Microsoft.Network/privateEndpoints/${functionAppPrivateEndpointName}').privateLinkServiceConnections[0].properties.privateEndpoint
output logicAppEndpoint string = reference('Microsoft.Network/privateEndpoints/${logicAppPrivateEndpointName}').privateLinkServiceConnections[0].properties.privateEndpoint
