#!/usr/bin/env bash
set -eux

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

az group create -n ${RESOURCE_GROUP} -l ${LOCATION}
az group deployment create -g ${RESOURCE_GROUP} --template-file ${DIR}/azureDeploy.json --parameters clientId=${CLIENT_ID} clientSecret=${CLIENT_SECRET}
az aks get-credentials -g ${RESOURCE_GROUP} -n jseely-pivotal-aks
