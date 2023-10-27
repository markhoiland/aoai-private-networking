resource vnet_aoai_test_02_private_endpoint 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  name: 'vnet-aoai-test-02/private-endpoint'
  properties: {
    delegations: []
    serviceEndpoints: []
    provisioningState: 'Succeeded'
    addressPrefixes: [
      '10.1.0.0/24'
    ]
    networkSecurityGroup: {
      id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/networkSecurityGroups/nsg-aoai-test-02'
    }
    ipConfigurations: [
      {
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/networkInterfaces/PEP-STAOAITEST02.NIC.7D25C2CA-8665-4E0A-9215-19D1032C7718/ipConfigurations/PRIVATEENDPOINTIPCONFIG.3738F364-F046-4806-8A10-2AEEE34C7DD0'
      }
    ]
    privateEndpoints: [
      {
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/privateEndpoints/PEP-STAOAITEST02'
      }
    ]
    purpose: 'PrivateEndpoints'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}