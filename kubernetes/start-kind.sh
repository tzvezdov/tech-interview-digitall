#!/bin/bash

set -euo pipefail

CLUSTER_NAME="single-node-cluster"
CONFIG_FILE="kind-config.yaml"

# Check prerequisites
command -v kind >/dev/null 2>&1 || {
  echo "kind is not installed"
  exit 1
}

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl is not installed"
  exit 1
}

# Delete existing cluster if present
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "Deleting existing cluster: ${CLUSTER_NAME}"
  kind delete cluster --name "${CLUSTER_NAME}"
fi

# Create cluster
echo "Creating kind cluster: ${CLUSTER_NAME}"
kind create cluster \
  --name "${CLUSTER_NAME}" \
  --config "${CONFIG_FILE}"

# Verify cluster
echo "Verifying cluster status..."
kubectl cluster-info
kubectl get nodes -o wide

status_code=$?

if [ $? -ne 0 ]; then
  echo "Failed to fetch cluster info"
  exit status_code
fi

echo "Kind single-node cluster is ready ✅"
