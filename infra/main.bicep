targetScope = 'resourceGroup'

@description('Base name for all resources')
param baseName string = 'ghcp-hackathon'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Container image tag')
param imageTag string = 'latest'

module acr 'modules/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    name: replace('${baseName}acr', '-', '')
    location: location
  }
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    name: '${baseName}-logs'
    location: location
  }
}

module containerApp 'modules/container-app.bicep' = {
  name: 'container-app-deployment'
  params: {
    name: '${baseName}-app'
    location: location
    containerRegistryName: acr.outputs.name
    containerRegistryLoginServer: acr.outputs.loginServer
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    imageName: '${acr.outputs.loginServer}/hackathon:${imageTag}'
  }
}

output appUrl string = containerApp.outputs.fqdn
output acrLoginServer string = acr.outputs.loginServer
output acrName string = acr.outputs.name
