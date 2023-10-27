param variables_defaultVNetName ? /* TODO: fill in correct type */
param variables_defaultAddressPrefix ? /* TODO: fill in correct type */
param variables_defaultSubnetName ? /* TODO: fill in correct type */
param virtualNetworkType string
param vnet object
param location string

resource virtualNetworkType_External_vnet_name_variables_defaultVNet 'Microsoft.Network/virtualNetworks@2020-04-01' = {
  name: ((virtualNetworkType == 'External') ? vnet.name : variables_defaultVNetName)
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ((virtualNetworkType == 'External') ? vnet.addressPrefixes : json('[{"${variables_defaultAddressPrefix}"}]'))
    }
    subnets: [
      {
        name: ((virtualNetworkType == 'External') ? vnet.subnets.subnet.name : variables_defaultSubnetName)
        properties: {
          serviceEndpoints: [
            {
              service: 'Microsoft.CognitiveServices'
              locations: [
                location
              ]
            }
          ]
          addressPrefix: ((virtualNetworkType == 'External') ? vnet.subnets.subnet.addressPrefix : variables_defaultAddressPrefix)
        }
      }
    ]
  }
}