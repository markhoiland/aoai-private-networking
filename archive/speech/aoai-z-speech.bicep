param name string
param location string
param resourceGroupId string
param resourceGroupName string
param sku string
param tagValues object
param virtualNetworkType string
param vnet object
param ipRules array
param identity object
param privateEndpoints array
param privateDnsZone string
param isCommitmentPlanForDisconnectedContainerEnabledForSTT bool
param commitmentPlanForDisconnectedContainerForSTT object
param isCommitmentPlanForDisconnectedContainerEnabledForNeuralTTS bool
param commitmentPlanForDisconnectedContainerForNeuralTTS object
param isCommitmentPlanForDisconnectedContainerEnabledForCustomSTT bool
param commitmentPlanForDisconnectedContainerForCustomSTT object

var defaultVNetName = 'speechCSDefaultVNet9901'
var defaultSubnetName = 'speechCSDefaultSubnet9901'
var defaultAddressPrefix = '13.41.6.0/26'
var vnetProperties = {
  publicNetworkAccess: ((virtualNetworkType == 'Internal') ? 'Disabled' : 'Enabled')
  networkAcls: {
    defaultAction: ((virtualNetworkType == 'External') ? 'Deny' : 'Allow')
    virtualNetworkRules: ((virtualNetworkType == 'External') ? json('[{"id": "${subscription().id}/resourceGroups/${vnet.resourceGroup}/providers/Microsoft.Network/virtualNetworks/${vnet.name}/subnets/${vnet.subnets.subnet.name}"}]') : json('[]'))
    ipRules: ((empty(ipRules) || empty(ipRules[0].value)) ? json('[]') : ipRules)
  }
}
var vnetPropertiesWithCustomDomain = {
  customSubDomainName: toLower(name)
  publicNetworkAccess: ((virtualNetworkType == 'Internal') ? 'Disabled' : 'Enabled')
  networkAcls: {
    defaultAction: ((virtualNetworkType == 'External') ? 'Deny' : 'Allow')
    virtualNetworkRules: ((virtualNetworkType == 'External') ? json('[{"id": "${subscription().id}/resourceGroups/${vnet.resourceGroup}/providers/Microsoft.Network/virtualNetworks/${vnet.name}/subnets/${vnet.subnets.subnet.name}"}]') : json('[]'))
    ipRules: ((empty(ipRules) || empty(ipRules[0].value)) ? json('[]') : ipRules)
  }
}

module deployVnet './nested_deployVnet.bicep' = if (((!empty(vnet)) && (vnet.newOrExisting == 'new')) && (virtualNetworkType == 'External')) {
  name: 'deployVnet'
  params: {
    variables_defaultVNetName: defaultVNetName
    variables_defaultAddressPrefix: defaultAddressPrefix
    variables_defaultSubnetName: defaultSubnetName
    virtualNetworkType: virtualNetworkType
    vnet: vnet
    location: location
  }
}

resource name_resource 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: name
  location: location
  kind: 'SpeechServices'
  tags: (contains(tagValues, 'Microsoft.CognitiveServices/accounts') ? tagValues['Microsoft.CognitiveServices/accounts'] : json('{}'))
  sku: {
    name: sku
  }
  identity: identity
  properties: ((virtualNetworkType != 'None') ? vnetPropertiesWithCustomDomain : vnetProperties)
  dependsOn: [
    deployVnet
  ]
}

resource name_DisconnectedContainer_STT_1 'Microsoft.CognitiveServices/accounts/commitmentPlans@2021-10-01' = if (isCommitmentPlanForDisconnectedContainerEnabledForSTT) {
  parent: name_resource
  name: 'DisconnectedContainer-STT-1'
  properties: commitmentPlanForDisconnectedContainerForSTT
}

resource name_DisconnectedContainer_NeuralTTS_1 'Microsoft.CognitiveServices/accounts/commitmentPlans@2021-10-01' = if (isCommitmentPlanForDisconnectedContainerEnabledForNeuralTTS) {
  parent: name_resource
  name: 'DisconnectedContainer-NeuralTTS-1'
  properties: commitmentPlanForDisconnectedContainerForNeuralTTS
}

resource name_DisconnectedContainer_CustomSTT_1 'Microsoft.CognitiveServices/accounts/commitmentPlans@2021-10-01' = if (isCommitmentPlanForDisconnectedContainerEnabledForCustomSTT) {
  parent: name_resource
  name: 'DisconnectedContainer-CustomSTT-1'
  properties: commitmentPlanForDisconnectedContainerForCustomSTT
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