import os
import json
import datetime
from flask import Flask, jsonify

app = Flask(__name__)

# Try to import hvac (Vault client) — graceful fallback if not available
try:
    import hvac
    VAULT_AVAILABLE = True
except ImportError:
    VAULT_AVAILABLE = False

VAULT_ADDR = os.getenv("VAULT_ADDR", "http://vault:8200")
VAULT_TOKEN = os.getenv("VAULT_TOKEN", "")


def get_vault_client():
    if not VAULT_AVAILABLE or not VAULT_TOKEN:
        return None
    client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)
    return client if client.is_authenticated() else None


def read_secret(path):
    client = get_vault_client()
    if not client:
        return {"error": "Vault not configured"}
    try:
        result = client.secrets.kv.v2.read_secret_version(path=path)
        return result["data"]["data"]
    except Exception as e:
        return {"error": str(e)}


@app.route("/")
def home():
    return jsonify({
        "message": "Geetha's Multi-Cloud + Vault Demo 🔐☁️",
        "vault_connected": bool(get_vault_client()),
        "clouds": ["AWS", "Azure"],
        "features": ["Secrets Management", "Multi-Cloud IaC", "Drift Detection"],
    })


@app.route("/health")
def health():
    vault_status = "connected" if get_vault_client() else "disconnected"
    return jsonify({
        "status": "healthy",
        "vault": vault_status,
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    })


@app.route("/api/secrets")
def list_secrets():
    """Show which secrets are available (keys only, NOT values)."""
    secrets = read_secret("app/config")
    if "error" in secrets:
        return jsonify({"error": secrets["error"], "hint": "Set VAULT_TOKEN env var"}), 503
    # Return only key names for security
    return jsonify({
        "available_secrets": list(secrets.keys()),
        "count": len(secrets),
        "path": "secret/app/config",
        "note": "Values hidden — use Vault CLI to read",
    })


@app.route("/api/cloud-status")
def cloud_status():
    """Shows multi-cloud config (from Vault)."""
    aws = read_secret("app/aws")
    azure = read_secret("app/azure")
    return jsonify({
        "aws": {"region": aws.get("AWS_REGION", "N/A"), "configured": "error" not in aws},
        "azure": {"tenant": azure.get("AZURE_TENANT_ID", "N/A")[:8] + "...", "configured": "error" not in azure},
    })


@app.route("/api/info")
def info():
    return jsonify({
        "app": "multicloud-vault-demo",
        "author": "Geetha Chinthamreddy",
        "tech_stack": [
            "Terraform (AWS + Azure)", "HashiCorp Vault",
            "Kubernetes", "GitHub Actions", "Docker",
        ],
        "devops_skills": [
            "Multi-Cloud IaC", "Secrets Management",
            "Drift Detection", "GitOps Automation",
        ],
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
