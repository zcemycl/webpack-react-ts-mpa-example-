param webAppName string
param hostingPlanName string = 'asp-${webAppName}'
param dockerRegistryHost string = 'acrleotest97.azurecr.io'
param dockerImage string = 'bicep-app-service-container:latest'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

param createdBy string = 'Leo Leung'
param projectName string = 'Learn Azure'
param dateTime string = utcNow()


resource Microsoft_Web_sites_webAppName 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('Microsoft.Web/sites/${webAppName}')
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
    principalId: reference(webAppName_resource.id, '2019-08-01', 'full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource webAppName_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    createdBy: createdBy
    projectName: projectName
    dateTime: dateTime
  }
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerRegistryHost}/${dockerImage}' 
      acrUseManagedIdentityCreds: true
    }
    serverFarmId: '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().id}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
  }
  dependsOn: [
    hostingPlanName_resource
  ]
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2022-03-01' = {
  kind: 'linux'
  name: hostingPlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  dependsOn: []
  tags: {
    createdBy: createdBy
    projectName: projectName
    dateTime: dateTime
  }
}
