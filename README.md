# graph-teams-presence

https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions

graph.teams.presence
az group create -n graph.teams.presence -l westeurope

az ad sp create-for-rbac --name {myApp} --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{MyResourceGroup} --sdk-auth