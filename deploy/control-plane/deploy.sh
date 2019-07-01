#!/usr/bin/env bash
set -eux
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Substitue values into Concourse Values file
echo "Substituting Environment Variables into 'concourse-values.yaml':"
echo "\tCI_HOSTNAME=${CI_HOSTNAME}"
echo "\tCI_ADMIN_USERID=${CI_ADMIN_USERID}"
echo "\tCI_TENANT_ID=${CI_TENANT_ID}"
echo "\tCI_CLIENT_ID=${CI_CLIENT_ID}"
echo "\tCI_CLIENT_SECRET=${CI_CLIENT_SECRET}"
envsubst <"${DIR}/concourse-values.yaml.envsubst" >"${DIR}/concourse-values.yaml"

helm install --name concourse --namespace control-plane stable/concourse -f ${DIR}/concourse-values.yaml --version 6.2.2
