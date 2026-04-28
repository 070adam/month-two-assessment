#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${IMAGE_NAME:-muchtodo-backend:latest}"

docker build -t "${IMAGE_NAME}" -f "${ROOT_DIR}/Dockerfile" "${ROOT_DIR}"
