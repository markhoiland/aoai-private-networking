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
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/networkInterfaces/PEP-LOGAPP-AOAI-TEST-02.NIC.8EAF9BBA-CFF6-44D4-907E-C4B4228CB58E/ipConfigurations/PRIVATEENDPOINTIPCONFIG.E2A24DC9-4A92-45DF-B9FC-B42DA43E9540'
      }
      {
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/networkInterfaces/PEP-STAOAITEST02.NIC.7495E5A7-2117-4A7E-8375-ECA499ED4602/ipConfigurations/PRIVATEENDPOINTIPCONFIG.27DC14D6-F633-4E2A-A656-5C6769D2EB62'
      }
    ]
    privateEndpoints: [
      {
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/privateEndpoints/PEP-LOGAPP-AOAI-TEST-02'
      }
      {
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/RG-AOAI-TEST-02/providers/Microsoft.Network/privateEndpoints/PEP-STAOAITEST02'
      }
    ]
    purpose: 'PrivateEndpoints'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}