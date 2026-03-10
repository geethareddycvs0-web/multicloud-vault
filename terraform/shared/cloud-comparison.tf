# Multi-Cloud Comparison: AWS ↔ Azure equivalent resources
# This is a documentation module showing cloud-agnostic patterns

locals {
  cloud_comparison = {
    networking = {
      aws   = "VPC + Subnets + Internet Gateway + Route Tables"
      azure = "Virtual Network + Subnets + NSG"
      gcp   = "VPC + Subnets + Firewall Rules"
    }
    storage = {
      aws   = "S3 Bucket (KMS encryption, lifecycle, versioning)"
      azure = "Storage Account (Blob, GRS replication, retention)"
      gcp   = "Cloud Storage (KMS, lifecycle, versioning)"
    }
    identity = {
      aws   = "IAM Role + Policy + Instance Profile"
      azure = "Managed Identity + RBAC"
      gcp   = "Service Account + IAM Binding"
    }
    secrets = {
      aws   = "AWS Secrets Manager / SSM Parameter Store"
      azure = "Azure Key Vault"
      gcp   = "Secret Manager"
      all   = "HashiCorp Vault (cloud-agnostic!)"
    }
    container_orchestration = {
      aws   = "EKS (Elastic Kubernetes Service)"
      azure = "AKS (Azure Kubernetes Service)"
      gcp   = "GKE (Google Kubernetes Engine)"
    }
  }
}

output "cloud_comparison" {
  value       = local.cloud_comparison
  description = "Multi-cloud resource mapping for learning reference"
}
