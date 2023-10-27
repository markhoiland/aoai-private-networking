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
    addressPrefix: '10.1.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}