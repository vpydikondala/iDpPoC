#!/usr/bin/env bash
set -euo pipefail
kubectl create ns argocd 2>/dev/null || true
helm repo add argo https://argoproj.github.io/argo-helm >/dev/null
helm repo update >/dev/null
helm upgrade --install argocd argo/argo-cd -n argocd   --set server.service.type=NodePort   --set configs.params."server\.insecure"=true
echo "[*] Argo CD installed in 'argocd' (NodePort server)."
echo "ArgoCD URL(s):"
minikube service -n argocd argocd-server --url
