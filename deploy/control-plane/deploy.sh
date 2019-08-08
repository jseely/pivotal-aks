#!/usr/bin/env bash
set -eu
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Substitue values into Concourse Values file
echo "Substituting Environment Variables into 'concourse-values.yaml' and 'uaa-values.yaml':"
echo -e "\tCONTROLPLANE_DOMAIN=${CONTROLPLANE_DOMAIN}"
echo ""
echo -e "\tCI_ADMIN_GROUPID=${CI_ADMIN_GROUPID}"
echo -e "\tCI_TENANT_ID=${CI_TENANT_ID}"
echo -e "\tCI_CLIENT_ID=${CI_CLIENT_ID}"
echo -e "\tCI_CLIENT_SECRET=${CI_CLIENT_SECRET}"
echo ""
echo -e "\tUAA_ADMIN_CLIENT_SECRET=${UAA_ADMIN_CLIENT_SECRET}"
envsubst <"${DIR}/concourse-values.yaml.envsubst" >"${DIR}/concourse-values.yaml"
envsubst <"${DIR}/uaa-values.yaml.envsubst" >"${DIR}/uaa-values.yaml"

helm install --name concourse --namespace control-plane stable/concourse -f ${DIR}/concourse-values.yaml --version 6.2.2
helm install --name uaa --namespace uaa ${DIR}/../../submodules/eirini-release/helm/uaa -f ${DIR}/uaa-values.yaml
