param location string
param privateEndpoints array
param resourceGroupId string
param name string

resource privateEndpoints_privateEndpoint_name 'Microsoft.Network/privateEndpoints@2020-03-01' = {
  location: location
  name: privateEndpoints[copyIndex()].privateEndpoint.name
  properties: {
    subnet: {
      id: privateEndpoints[copyIndex()].privateEndpoint.properties.subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpoints[copyIndex()].privateEndpoint.name
        properties: {
          privateLinkServiceId: '${resourceGroupId}/providers/Microsoft.CognitiveServices/accounts/${name}'
          groupIds: privateEndpoints[copyIndex()].privateEndpoint.properties.privateLinkServiceConnections[0].properties.groupIds
        }
      }
    ]
  }
  tags: {}
}