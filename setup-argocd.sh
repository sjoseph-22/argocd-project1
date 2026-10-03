#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

CLUSTER_NAME="argocd-cluster"
NAMESPACE="argocd"
ARGO_HELM_VERSION="9.1.9"

echo "=== 1. Creating Kind Cluster '${CLUSTER_NAME}' ==="
kind create cluster --name "${CLUSTER_NAME}"

echo "=== 2. Verifying Cluster Info & Nodes ==="
kubectl cluster-info --context "kind-${CLUSTER_NAME}"
kubectl get nodes

echo "=== 3. Adding and Updating Argo Helm Repository ==="
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

echo "=== 4. Creating Namespace '${NAMESPACE}' ==="
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "=== 5. Installing Argo CD via Helm (Version ${ARGO_HELM_VERSION}) ==="
helm install my-argo-cd argo/argo-cd \
  --version "${ARGO_HELM_VERSION}" \
  -n "${NAMESPACE}"

echo "=== 6. Installing Argo CD CLI ==="
if command -v argocd &> /dev/null; then
    echo "Argo CD CLI is already installed. Skipping download."
else
    echo "Downloading latest Argo CD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
    echo "Argo CD CLI installed successfully."
fi

echo "=== 7. Verifying Argo CD CLI ==="
argocd version --client

echo ""
echo "=========================================================================="
echo "SUCCESS! Kind cluster '${CLUSTER_NAME}', Argo CD, and Argo CD CLI are ready."
echo "=========================================================================="