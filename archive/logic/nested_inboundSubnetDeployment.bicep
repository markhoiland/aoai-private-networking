resource vnet_aoai_test_02_private_endpoint 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  name: 'vnet-aoai-test-02/private-endpoint'
  properties: {
    delegations: []
    serviceEndpoints: []
    provisioningState: 'Succeeded'
    addressPrefixes: [
      '10.0.0.0/24'
    ]
    networkSecurityGroup: {
      id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/networkSecurityGroups/nsg-aoai-test-02'
    }
    ipConfigurations: [
      {
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/networkInterfaces/PEP-SAAOAITEST02.NIC.79831FF0-C137-48FB-A291-E0251AF00338/ipConfigurations/PRIVATEENDPOINTIPCONFIG.D11B9EE7-C410-4144-9319-F32804195795'
      }
    ]
    privateEndpoints: [
      {
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/privateEndpoints/PEP-SAAOAITEST02'
      }
    ]
    purpose: 'PrivateEndpoints'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}