param aksName string
resource aks 'Microsoft.ContainerService/managedClusters@2023-10-02-preview' existing = {
  name: aksName
}
output aksIdentityObjectId string = aks.properties.identityProfile.kubeletidentity.objectId
