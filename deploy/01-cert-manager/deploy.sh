#!/usr/bin/env bash
set -eux

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "Substituting Environment Variables into 'cluster-issuer.yaml':"
echo -e "\tACME_REGISTRATION_EMAIL=${ACME_REGISTRATION_EMAIL}"
envsubst <"${DIR}/cluster-issuer.yaml.envsubst" > "${DIR}/cluster-issuer.yaml"

kubectl apply -f 00-crds.yaml
kubectl apply -f namespace.yaml

if ! helm repo list | grep "https://charts.jetstack.io" | grep "jetstack" >/dev/null; then
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
fi

if ! helm ls | grep "cert-manager" >/dev/null; then
  helm install --name cert-manager --namespace cert-manager --version v0.11.0 jetstack/cert-manager
fi

kubectl apply -f "${DIR}/cluster-issuer.yaml"
