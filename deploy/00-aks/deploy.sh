#!/usr/bin/env bash
set -eux

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

authJson="${DIR}/auth.json"
if [ ! -f "${authJson}" ]; then
  az ad sp create-for-rbac --skip-assignment -o json > "${authJson}"
fi
appId=$(jq -r ".appId" "${authJson}")
appSecret=$(jq -r ".password" "${authJson}")
appObjectId=$(az ad sp show --id "${appId}" --query "objectId" -o tsv)

paramFile="${DIR}/parameters.json"
cat <<EOF >"${paramFile}"
{
  "aksServicePrincipalAppId": { "value": "${appId}" },
  "aksServicePrincipalClientSecret": { "value": "${appSecret}" },
  "aksServicePrincipalObjectId": { "value": "${appObjectId}" },
  "aksEnableRBAC": { "value": true }
}
EOF

deployOutput="${DIR}/deployment-outputs.json"
if [ ! -f "${deployOutput}" ]; then
  if [[ "$(az group exists -n ${RESOURCE_GROUP})" == "true" ]]; then
    echo "Resource group '${RESOURCE_GROUP}' already exists. Exiting..."
    exit 1
  fi

  az group create -n ${RESOURCE_GROUP} -l ${LOCATION}
  deployName="ingress-appgw"
  az group deployment create -g ${RESOURCE_GROUP} --template-file ${DIR}/azureDeploy.json --parameters ${paramFile} -n ${deployName}
  az group deployment show -g ${RESOURCE_GROUP} -n ${deployName} --query "properties.outputs" -o json > ${DIR}/deployment-outputs.json
fi

# Update ~/.kube/config
aksClusterName=$(jq -r ".aksClusterName.value" ${deployOutput})
if ! cat ~/.kube/config | grep "name: $aksClusterName" >/dev/null; then
  az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${aksClusterName}
fi
if ! cat ~/.kube/config | grep "current-context: $aksClusterName" > /dev/null; then
  kubectl config set-context $aksClusterName
fi

# Install AAD Pod Identity
kubectl apply -f ${DIR}/aad-pod-identity-rbac.yaml

# Install Helm
if ! helm version 2>&1 >/dev/null; then
  kubectl apply -f ${DIR}/tiller-rbac.yaml
  helm init --tiller-namespace kube-system --service-account tiller-sa
fi

# Install Application Gateway Ingress repo
if ! helm repo list | grep application-gateway-kubernetes-ingress > /dev/null; then
  helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
  helm repo update
fi

ingressConfig="${DIR}/ingress-config.yaml"
cat <<EOF > ${ingressConfig}
verbosityLevel: 3
appgw:
  subscriptionId: "$(jq -r ".subscriptionId.value" ${deployOutput})"
  resourceGroup: "${RESOURCE_GROUP}"
  name: "$(jq -r ".applicationGatewayName.value" ${deployOutput})"
  shared: false
armAuth:
  type: aadPodIdentity
  identityResourceID: "$(jq -r ".identityResourceId.value" ${deployOutput})"
  identityClientID: "$(jq -r ".identityClientId.value" ${deployOutput})"
rbac:
  enabled: true
EOF

helm install -f ${ingressConfig} application-gateway-kubernetes-ingress/ingress-azure
