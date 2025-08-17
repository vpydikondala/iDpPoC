#!/usr/bin/env bash
set -euo pipefail
kubectl create ns argocd 2>/dev/null || true
helm repo add argo https://argoproj.github.io/argo-helm >/dev/null
helm repo update >/dev/null
helm upgrade --install argocd argo/argo-cd -n argocd   --set server.service.type=NodePort   --set configs.params."server\.insecure"=true
echo "[*] Argo CD installed in namespace 'argocd'."
echo "Access: kubectl -n argocd port-forward svc/argocd-server 8080:80"
echo "Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
