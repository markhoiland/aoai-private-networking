param virtualNetworkType string
param vnet object
param defaultVNetName string
param location string
param defaultAddressPrefix string
param defaultSubnetName string

resource virtualNetworkType_External_vnet_name_defaultVNet 'Microsoft.Network/virtualNetworks@2020-04-01' = {
  name: ((virtualNetworkType == 'External') ? vnet.name : defaultVNetName)
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ((virtualNetworkType == 'External') ? vnet.addressPrefixes : json('[{"${defaultAddressPrefix}"}]'))
    }
    subnets: [
      {
        name: ((virtualNetworkType == 'External') ? vnet.subnets.subnet.name : defaultSubnetName)
        properties: {
          serviceEndpoints: [
            {
              service: 'Microsoft.CognitiveServices'
              locations: [
                location
              ]
            }
          ]
          addressPrefix: ((virtualNetworkType == 'External') ? vnet.subnets.subnet.addressPrefix : defaultAddressPrefix)
        }
      }
    ]
  }
}