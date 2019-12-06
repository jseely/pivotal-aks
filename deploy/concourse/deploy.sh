#!/usr/bin/env bash
set -eu
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Substitue values into Concourse Values file
echo "Substituting Environment Variables into 'concourse-values.yaml':"
echo -e "\tCI_DOMAIN=${CI_DOMAIN}"
echo -e "\tCI_ADMIN_GROUPID=${CI_ADMIN_GROUPID}"
echo -e "\tCI_TENANT_ID=${CI_TENANT_ID}"
echo -e "\tCI_CLIENT_ID=${CI_CLIENT_ID}"
echo -e "\tCI_CLIENT_SECRET=${CI_CLIENT_SECRET}"

if ! helm ls | grep "concourse" >/dev/null; then
  helm install --name concourse --namespace concourse stable/concourse -f ${DIR}/concourse-values.yaml --version 6.2.2
fi
