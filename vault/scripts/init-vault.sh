#!/bin/bash
# Initialize and configure Vault with secrets
set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
export VAULT_ADDR

echo "═══════════════════════════════════════"
echo "  Vault Initialization & Configuration"
echo "═══════════════════════════════════════"

# Initialize Vault
echo "[→] Initializing Vault..."
INIT_OUTPUT=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
UNSEAL_KEY=$(echo "$INIT_OUTPUT" | jq -r '.unseal_keys_b64[0]')
ROOT_TOKEN=$(echo "$INIT_OUTPUT" | jq -r '.root_token')

echo "[✓] Vault initialized"
echo "    Unseal Key: $UNSEAL_KEY"
echo "    Root Token: $ROOT_TOKEN"
echo ""
echo "⚠️  SAVE THESE SECURELY — YOU CANNOT RECOVER THEM!"
echo ""

# Unseal
echo "[→] Unsealing Vault..."
vault operator unseal "$UNSEAL_KEY"
echo "[✓] Vault unsealed"

# Login
export VAULT_TOKEN="$ROOT_TOKEN"
vault login "$ROOT_TOKEN" > /dev/null

# Enable KV secrets engine
echo "[→] Enabling KV secrets engine..."
vault secrets enable -version=2 -path=secret kv
echo "[✓] KV v2 enabled at secret/"

# Write demo secrets
echo "[→] Writing demo secrets..."
vault kv put secret/app/config \
  DATABASE_URL="postgresql://admin:superSecret123@db.example.com:5432/appdb" \
  REDIS_URL="redis://cache.example.com:6379" \
  API_KEY="sk-demo-key-abc123xyz789" \
  JWT_SECRET="jwt-super-secret-key-2024" \
  APP_ENV="production"

vault kv put secret/app/aws \
  AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE" \
  AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  AWS_REGION="us-east-1"

vault kv put secret/app/azure \
  AZURE_CLIENT_ID="00000000-0000-0000-0000-000000000000" \
  AZURE_CLIENT_SECRET="azure-secret-demo-value" \
  AZURE_TENANT_ID="00000000-0000-0000-0000-000000000001"

echo "[✓] Demo secrets written"

# Apply policies
echo "[→] Applying policies..."
vault policy write app-policy /vault/policies/app-policy.hcl 2>/dev/null || \
  vault policy write app-policy vault/policies/app-policy.hcl
vault policy write admin-policy /vault/policies/admin-policy.hcl 2>/dev/null || \
  vault policy write admin-policy vault/policies/admin-policy.hcl
echo "[✓] Policies applied"

# Create app token
echo "[→] Creating app token..."
APP_TOKEN=$(vault token create -policy=app-policy -period=24h -format=json | jq -r '.auth.client_token')
echo "[✓] App token: $APP_TOKEN"

echo ""
echo "═══════════════════════════════════════"
echo "  ✅ Vault Setup Complete!"
echo "═══════════════════════════════════════"
echo ""
echo "  Read a secret:"
echo "    vault kv get secret/app/config"
echo ""
echo "  List secrets:"
echo "    vault kv list secret/app/"
echo ""
echo "  Use app token:"
echo "    export VAULT_TOKEN=$APP_TOKEN"
echo "    vault kv get secret/app/config"
