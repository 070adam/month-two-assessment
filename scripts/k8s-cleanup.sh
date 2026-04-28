#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-muchtodo}"

if command -v kubectl >/dev/null 2>&1; then
  kubectl delete namespace muchtodo --ignore-not-found=true
fi

if command -v kind >/dev/null 2>&1 && kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind delete cluster --name "${CLUSTER_NAME}"
fi
