#!/usr/bin/env bash
set -eux

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

kubectl apply -f ${DIR}/helm-rbac.yml
helm init --service-account tiller --node-selectors "beta.kubernetes.io/os"="linux"
