# Vault Policy: App Read-Only Access
# This policy allows apps to read secrets but not write/delete them
path "secret/data/app/*" {
  capabilities = ["read", "list"]
}

path "secret/metadata/app/*" {
  capabilities = ["read", "list"]
}

# Database credentials (dynamic secrets)
path "database/creds/app-role" {
  capabilities = ["read"]
}

# AWS credentials (dynamic secrets)
path "aws/creds/app-role" {
  capabilities = ["read"]
}
