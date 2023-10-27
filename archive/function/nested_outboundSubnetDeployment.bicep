resource vnet_aoai_test_02_funcapp_vi 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  name: 'vnet-aoai-test-02/funcapp-vi'
  properties: {
    delegations: [
      {
        name: 'delegation'
        id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/virtualNetworks/vnet-aoai-test-02/subnets/funcapp-vi/delegations/delegation'
        etag: 'W/"67a438c5-ad86-4469-a644-fb01ae5c0fe1"'
        properties: {
          provisioningState: 'Succeeded'
          serviceName: 'Microsoft.Web/serverfarms'
          actions: [
            'Microsoft.Network/virtualNetworks/subnets/action'
          ]
        }
        type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
      }
    ]
    serviceEndpoints: [
      {
        provisioningState: 'Succeeded'
        service: 'Microsoft.Storage'
        locations: [
          'northcentralus'
          'southcentralus'
        ]
      }
    ]
    provisioningState: 'Succeeded'
    addressPrefixes: [
      '10.1.2.0/24'
    ]
    networkSecurityGroup: {
      id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/networkSecurityGroups/nsg-aoai-test-02'
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}