resource vnet_aoai_test_02_logapp_vi 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  name: 'vnet-aoai-test-02/logapp-vi'
  properties: {
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
    provisioningState: 'Succeeded'
    addressPrefixes: [
      '10.0.1.0/24'
    ]
    networkSecurityGroup: {
      id: '/subscriptions/a095d2d5-fd2c-403f-bb29-fad7cad5d098/resourceGroups/rg-aoai-test-02/providers/Microsoft.Network/networkSecurityGroups/nsg-aoai-test-02'
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}