#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== 1. Updating System Packages ==="
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl docker.io

echo "=== 2. Starting and Enabling Docker Service ==="
sudo systemctl start docker
sudo systemctl enable docker

echo "=== Adding current user ($USER) to docker group ==="
sudo usermod -aG docker "$USER"

echo "=== 3. Installing kubectl ==="
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "=== 4. Installing kind ==="
KIND_VERSION="v0.22.0"
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

echo "=== 5. Installing Helm ==="
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

echo "=== 6. Verifying Installations ==="
echo "Docker version:" $(sudo docker --version)
echo "kubectl version:" $(kubectl version --client --output=yaml | grep gitVersion)
echo "kind version:" $(kind --version)
echo "Helm version:" $(helm version --short)

echo ""
echo "=========================================================================="
echo "SUCCESS! Docker, kubectl, kind, and Helm have been installed."
echo "Activating 'docker' group membership for the current session..."
echo "=========================================================================="

# Switch group context to docker so non-sudo docker works immediately
exec newgrp docker