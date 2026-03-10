#!/bin/bash
set -euo pipefail
echo "🗑️  Removing resources..."
kubectl delete namespace vault --ignore-not-found
echo "✅ Done. minikube stop to shut down."
