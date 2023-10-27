param name string
param location string
param sku string
param tagValues object
param virtualNetworkType string
param vnet object
param ipRules array
param privateEndpoints array
param privateDnsZone string
param resourceGroupName string
param resourceGroupId string
param defaultVNetName string
param defaultAddressPrefix string
param defaultSubnetName string

module deployVnet './nested_deployVnet.bicep' = if (((!empty(vnet)) && (vnet.newOrExisting == 'new')) && (virtualNetworkType == 'External')) {
  name: 'deployVnet'
  params: {
    virtualNetworkType: virtualNetworkType
    vnet: vnet
    defaultVNetName: defaultVNetName
    location: location
    defaultAddressPrefix: defaultAddressPrefix
    defaultSubnetName: defaultSubnetName
  }
}

resource name_resource 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: name
  location: location
  tags: (contains(tagValues, 'Microsoft.CognitiveServices/accounts') ? tagValues['Microsoft.CognitiveServices/accounts'] : json('{}'))
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: toLower(name)
    publicNetworkAccess: ((virtualNetworkType == 'Internal') ? 'Disabled' : 'Enabled')
    networkAcls: {
      defaultAction: ((virtualNetworkType == 'External') ? 'Deny' : 'Allow')
      virtualNetworkRules: ((virtualNetworkType == 'External') ? json('[{"id": "${subscription().id}/resourceGroups/${vnet.resourceGroup}/providers/Microsoft.Network/virtualNetworks/${vnet.name}/subnets/${vnet.subnets.subnet.name}"}]') : json('[]'))
      ipRules: ((empty(ipRules) || empty(ipRules[0].value)) ? json('[]') : ipRules)
    }
  }
  dependsOn: [
    deployVnet
  ]
}

module deployPrivateEndpoint_privateEndpoints_privateEndpoint_name './nested_deployPrivateEndpoint_privateEndpoints_privateEndpoint_name.bicep' = [for item in privateEndpoints: {
  name: 'deployPrivateEndpoint-${item.privateEndpoint.name}'
  scope: resourceGroup(item.subscription.subscriptionId, item.resourceGroup.value.name)
  params: {
    location: location
    privateEndpoints: privateEndpoints
    resourceGroupId: resourceGroupId
    name: name
  }
  dependsOn: [
    name_resource
  ]
}]

module deployDnsZoneGroup_privateEndpoints_privateEndpoint_name './nested_deployDnsZoneGroup_privateEndpoints_privateEndpoint_name.bicep' = [for item in privateEndpoints: {
  name: 'deployDnsZoneGroup-${item.privateEndpoint.name}'
  scope: resourceGroup(item.subscription.subscriptionId, item.resourceGroup.value.name)
  params: {
    privateEndpoints: privateEndpoints
    location: location
    resourceGroupId: resourceGroupId
    privateDnsZone: privateDnsZone
  }
  dependsOn: [
    'Microsoft.Resources/deployments/deployPrivateEndpoint-${item.privateEndpoint.name}'
  ]
}]