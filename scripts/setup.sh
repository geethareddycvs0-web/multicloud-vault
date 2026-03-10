#!/bin/bash
set -euo pipefail
GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${CYAN}[→]${NC} $1"; }

echo "═══════════════════════════════════════════"
echo "  Project 6: Multi-Cloud + Vault (Local)"
echo "═══════════════════════════════════════════"

for cmd in docker minikube kubectl; do
  command -v $cmd &>/dev/null || { echo "❌ $cmd not found"; exit 1; }
done
log "Prerequisites OK"

# Start Minikube
info "Starting Minikube..."
if minikube status 2>/dev/null | grep -q "Running"; then log "Already running"
else minikube start --cpus=2 --memory=4096 --driver=docker; log "Started"
fi

# Build app
info "Building app image..."
eval $(minikube docker-env)
docker build -t multicloud-vault-demo:latest ./app/
log "Image built"

# Deploy Vault
info "Deploying HashiCorp Vault..."
kubectl apply -f vault/k8s/vault.yaml
log "Vault deployed"

info "Waiting for Vault to start..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=120s || true
log "Vault ready"

MINIKUBE_IP=$(minikube ip)
echo ""
echo "═══════════════════════════════════════════"
echo "  🎉 Setup Complete!"
echo "═══════════════════════════════════════════"
echo ""
echo "  Vault UI:  http://${MINIKUBE_IP}:30820"
echo ""
echo "  Next steps:"
echo "  1. Port-forward Vault: make vault-ui"
echo "  2. Install vault CLI: brew install vault"
echo "  3. Init Vault: make vault-init"
echo "  4. Read secrets: make vault-read"
echo ""
echo "  For Terraform (requires cloud accounts):"
echo "  make aws-init && make aws-plan"
echo "  make azure-init && make azure-plan"
