#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-muchtodo}"
IMAGE_NAME="${IMAGE_NAME:-muchtodo-backend:latest}"

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is not installed."
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is not installed."
  exit 1
fi

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config "${ROOT_DIR}/kind-config.yaml"
fi

docker build -t "${IMAGE_NAME}" -f "${ROOT_DIR}/Dockerfile" "${ROOT_DIR}"
kind load docker-image "${IMAGE_NAME}" --name "${CLUSTER_NAME}"

if ! kubectl get namespace ingress-nginx >/dev/null 2>&1; then
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/kind/deploy.yaml
fi

kubectl apply -f "${ROOT_DIR}/kubernetes/namespace.yaml"
kubectl apply -f "${ROOT_DIR}/kubernetes/mongodb/"
kubectl apply -f "${ROOT_DIR}/kubernetes/backend/"
kubectl apply -f "${ROOT_DIR}/kubernetes/ingress.yaml"

kubectl -n muchtodo rollout status deployment/mongodb --timeout=180s
kubectl -n muchtodo rollout status deployment/backend --timeout=180s

echo "Cluster ready."
echo "NodePort:  http://localhost:30080"
echo "Ingress:   http://muchtodo.local"
