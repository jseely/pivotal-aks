#!/usr/bin/env bash
set -eux

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

helm install --name concourse --namespace control-plane stable/concourse -f ${DIR}/concourse-values.yaml --version 6.2.2
