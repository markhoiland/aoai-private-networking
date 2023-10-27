param privateEndpoints array
param location string
param resourceGroupId string
param privateDnsZone string

resource privateEndpoints_privateEndpoint_name_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: '${privateEndpoints[copyIndex()].privateEndpoint.name}/default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-cognitiveservices'
        properties: {
          privateDnsZoneId: '${resourceGroupId}/providers/Microsoft.Network/privateDnsZones/${privateDnsZone}'
        }
      }
    ]
  }
}