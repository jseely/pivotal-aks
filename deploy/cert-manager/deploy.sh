#!/usr/bin/env bash
set -eux

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Substitute Environment Variables into Template
echo "Substituting Environment Variables into 'cluster-issuer.yaml':"
echo "\tACME_REGISTRATION_EMAIL=${ACME_REGISTRATION_EMAIL}"
envsubst <"${DIR}/cluster-issuer.yaml.envsubst" >"${DIR}/cluster-issuer.yaml"

# Create an Ingress Controller
kubectl create namespace ingress-basic
helm install stable/nginx-ingress \
  --namespace ingress-basic

# Install cert-manager
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm install --name my-release --namespace cert-manager jetstack/cert-manager

kubectl apply -f ${DIR}/cluster-issuer.yaml
