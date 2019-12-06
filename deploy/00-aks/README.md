# Azure Kubernetes Service

This directory deploys an Azure managed Kubernetes cluster with the following command.

```
RESOURCE_GROUP=<your-rg-name> LOCATION=<azure-region> ./deploy.sh
```

On completion you will have:

1. Azure Virtual Network
1. Azure Application Gateway w/ public IP address (for ingress) 
1. An Azure Kubernetes Cluster
  1. AAD Pod Identity Installed
  1. Helm Installed
  1. Application Gateway Ingress Controller installed
1. State files
  1. `auth.json` - Service Principal
  1. `deployment-outputs.json` - Output of the deployment
1. Updated `~/.kube/config` with new context merged and selected
