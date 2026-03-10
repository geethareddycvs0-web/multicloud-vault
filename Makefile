.PHONY: help setup teardown vault-ui vault-init vault-read \
       aws-init aws-plan aws-apply aws-destroy azure-init azure-plan azure-apply azure-destroy

help: ## Show all commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

# ── Setup ──
setup: ## Deploy Vault on Minikube
	bash scripts/setup.sh

teardown: ## Remove everything
	bash scripts/teardown.sh

# ── Vault ──
vault-ui: ## Port-forward Vault UI → localhost:8200
	@echo "Vault UI: http://localhost:8200"
	kubectl port-forward svc/vault -n vault 8200:8200

vault-init: ## Initialize and configure Vault with demo secrets
	bash vault/scripts/init-vault.sh

vault-read: ## Read demo secrets from Vault
	vault kv get secret/app/config

vault-status: ## Check Vault status
	vault status

# ── AWS Terraform ──
aws-init: ## Init AWS Terraform
	cd terraform/aws && terraform init

aws-plan: ## Plan AWS infrastructure
	cd terraform/aws && terraform plan -var-file=environments/dev/terraform.tfvars

aws-apply: ## Apply AWS (costs money!)
	cd terraform/aws && terraform apply -var-file=environments/dev/terraform.tfvars

aws-destroy: ## Destroy AWS resources
	cd terraform/aws && terraform destroy -var-file=environments/dev/terraform.tfvars

# ── Azure Terraform ──
azure-init: ## Init Azure Terraform
	cd terraform/azure && terraform init

azure-plan: ## Plan Azure infrastructure
	cd terraform/azure && terraform plan -var-file=environments/dev/terraform.tfvars

azure-apply: ## Apply Azure (costs money!)
	cd terraform/azure && terraform apply -var-file=environments/dev/terraform.tfvars

azure-destroy: ## Destroy Azure resources
	cd terraform/azure && terraform destroy -var-file=environments/dev/terraform.tfvars

# ── Status ──
status: ## Show Vault pods
	kubectl get pods -n vault -o wide
	@echo ""
	kubectl get svc -n vault

docker-build: ## Build app image in Minikube
	eval $$(minikube docker-env) && docker build -t multicloud-vault-demo:latest ./app/
