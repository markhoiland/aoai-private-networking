param siteName string

resource privatelink_azurewebsites_net_siteName_scm 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'privatelink.azurewebsites.net/${siteName}.scm'
  location: 'global'
  properties: {
    ttl: 10
    aRecords: [
      {
        ipv4Address: reference(resourceId('Microsoft.Web/Sites', siteName), '2022-03-01', 'Full').properties.privateEndpointConnections[0].properties.ipAddresses[0]
      }
    ]
  }
}