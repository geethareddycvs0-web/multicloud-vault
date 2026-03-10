# 🔐☁️ DevOps Project 6: Multi-Cloud Infrastructure + HashiCorp Vault

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://terraform.io/)
[![Vault](https://img.shields.io/badge/Vault-FFEC6E?logo=vault&logoColor=black)](https://www.vaultproject.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)

**Multi-cloud IaC** with Terraform (AWS + Azure side-by-side), **HashiCorp Vault** for centralized secrets management, **drift detection** via GitHub Actions, and a **Vault-integrated Flask app** that reads secrets dynamically.

---

## 📐 Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Multi-Cloud Architecture                │
│                                                           │
│  ┌─────────────────┐      ┌─────────────────┐           │
│  │      AWS         │      │     Azure        │           │
│  │  ┌───────────┐  │      │  ┌───────────┐  │           │
│  │  │    VPC    │  │      │  │   VNet    │  │           │
│  │  │  Subnets  │  │      │  │  Subnets  │  │           │
│  │  │    IGW    │  │      │  │   NSG     │  │           │
│  │  └───────────┘  │      │  └───────────┘  │           │
│  │  ┌───────────┐  │      │  ┌───────────┐  │           │
│  │  │  S3 (KMS) │  │      │  │  Storage  │  │           │
│  │  │ Lifecycle  │  │      │  │  GRS/LRS  │  │           │
│  │  └───────────┘  │      │  └───────────┘  │           │
│  │  ┌───────────┐  │      │  ┌───────────┐  │           │
│  │  │  IAM Role │  │      │  │  Res Group │  │           │
│  │  └───────────┘  │      │  └───────────┘  │           │
│  └────────┬────────┘      └────────┬────────┘           │
│           └──────────┬─────────────┘                     │
│                      ▼                                    │
│           ┌──────────────────┐                           │
│           │  HashiCorp Vault │                           │
│           │  (K8s Deployed)  │                           │
│           │  • KV Secrets    │                           │
│           │  • Policies      │                           │
│           │  • App Tokens    │                           │
│           └────────┬─────────┘                           │
│                    ▼                                      │
│           ┌──────────────────┐                           │
│           │   Flask App      │                           │
│           │  (reads secrets) │                           │
│           └──────────────────┘                           │
│                                                           │
│  ┌──────────────────────────────────────────┐            │
│  │  GitHub Actions: Drift Detection (daily)  │            │
│  │  → terraform plan → auto-create issues    │            │
│  └──────────────────────────────────────────┘            │
└──────────────────────────────────────────────────────────┘
```

## 🗂️ Project Structure

```
devops-project6-multicloud-vault/
├── terraform/
│   ├── aws/                          # AWS Infrastructure
│   │   ├── main.tf                   # Root config
│   │   ├── modules/vpc/             # VPC + Subnets + IGW
│   │   ├── modules/s3/             # S3 + KMS + Lifecycle
│   │   ├── modules/iam/            # IAM Role + Policies
│   │   └── environments/{dev,prod}/
│   ├── azure/                        # Azure Infrastructure
│   │   ├── main.tf
│   │   ├── modules/resource-group/  # Resource Group
│   │   ├── modules/vnet/           # VNet + NSG
│   │   ├── modules/storage/        # Storage Account
│   │   └── environments/{dev,prod}/
│   └── shared/
│       └── cloud-comparison.tf       # AWS↔Azure↔GCP mapping
├── vault/
│   ├── k8s/vault.yaml               # Vault on Kubernetes
│   ├── policies/
│   │   ├── app-policy.hcl           # Read-only for apps
│   │   └── admin-policy.hcl         # Full admin access
│   └── scripts/init-vault.sh        # Init + unseal + demo secrets
├── app/                              # Vault-integrated Flask app
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── gitops/.github/workflows/
│   └── drift-detection.yml          # Daily drift check + auto-issues
├── scripts/{setup,teardown}.sh
├── Makefile
└── README.md
```

---

## 🧠 Key DevOps Concepts Learned

| Concept | Where You Used It |
|---|---|
| **Multi-Cloud IaC** | Same patterns on AWS + Azure with Terraform |
| **Cloud Resource Mapping** | VPC↔VNet, S3↔Storage Account, IAM↔RBAC |
| **Secrets Management** | Vault KV v2 with policies and tokens |
| **Least Privilege** | App policy: read-only; Admin policy: full access |
| **Vault Init/Unseal** | Shamir's Secret Sharing (key shares/threshold) |
| **Drift Detection** | Scheduled `terraform plan` with auto-issue creation |
| **Dynamic Secrets** | Vault-generated credentials (AWS/DB) with TTL |
| **Infrastructure as Code** | Both clouds fully declarative |
| **Environment Parity** | Same modules, different tfvars for dev/prod |

---

## 🚀 Quick Start

### Part 1: Vault (runs locally on Minikube)
```bash
brew install minikube kubectl vault
cd /Users/nehareddy/.gemini/antigravity/scratch/devops-project6-multicloud-vault

make setup           # Deploys Vault on Minikube
make vault-ui        # Open Vault at http://localhost:8200
make vault-init      # Initialize + write demo secrets
make vault-read      # Read secrets
```

### Part 2: AWS (requires AWS account)
```bash
aws configure        # Enter access keys
make aws-init && make aws-plan && make aws-apply
make aws-destroy     # When done!
```

### Part 3: Azure (requires Azure account)
```bash
az login             # Browser auth
make azure-init && make azure-plan && make azure-apply
make azure-destroy   # When done!
```

---

## ☁️ Cloud Resource Comparison

| Resource | AWS | Azure |
|----------|-----|-------|
| Network | VPC + Subnets | VNet + Subnets |
| Firewall | Security Groups | NSG |
| Storage | S3 (KMS encryption) | Storage Account (GRS) |
| Identity | IAM Role + Policy | Managed Identity + RBAC |
| Secrets | Secrets Manager | Key Vault |
| **Cross-Cloud** | **HashiCorp Vault** | **HashiCorp Vault** |

---

## ✅ All Make Commands

```bash
make setup / teardown        # Vault on Minikube
make vault-ui / init / read  # Vault operations
make aws-init / plan / apply / destroy    # AWS
make azure-init / plan / apply / destroy  # Azure
make status                  # Show Vault pods
make docker-build            # Build app image
```

---

## 👩‍💻 Author
**Geetha Chinthamreddy** — Data Engineer → DevOps Engineer
