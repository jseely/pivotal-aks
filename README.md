# Pivotal on Azure Kubernetes Service

This repo contains integrations of Pivotal products on Azure's Kubernetes Service.

## Control Plane

Control Plane is a concept thought of within Pivotal as the a collection of CI/CD systems, secrets management and configuration that produces working deployments of Pivotal Cloud Foundry and other platforms via pipelines.

This Control Plane currently contains:

* Authentication (Azure Active Directory via OpenID)
* Concourse

To deploy this solution execute the `deploy.sh` scripts in the following order:

1. [`./deploy/0-aks/deploy.sh`](/deploy/0-aks/deploy.sh)
2. [`./deploy/tiller/deploy.sh`](/deploy/tiller/deploy.sh)
3. [`./deploy/cert-manager/deploy.sh`](/deploy/cert-manager/deploy.sh)
4. [`./deploy/control-plane/deploy.sh`](/deploy/control-plane/deploy.sh)
