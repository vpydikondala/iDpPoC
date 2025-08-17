# Internal Developer Platform (IDP) – PoC
Backstage + Argo CD (GitOps) + Terraform + Monitoring (Prometheus/Grafana) on Kubernetes.

This PoC delivers a self‑service developer platform:
- Backstage as the developer portal and service catalog (with scaffolder templates).
- Argo CD for GitOps (App-of-Apps) managing platform and app workloads.
- Terraform for day‑0/day‑1 platform provisioning (namespaces, RBAC, Argo CD projects).
- Monitoring via kube‑prometheus‑stack (Prometheus, Alertmanager, Grafana) and optional Loki/Promtail.

> Works on any K8s (kind/minikube/AKS/EKS/GKE). All manifests and Helm values are in this repo.
> Update the ArgoCD Application repoURL to point at *your* Git host before syncing.



## Architecture (high level)

flowchart LR
  dev[Developer] -->|Self-service| backstage[Backstage Portal]
  backstage -->|Scaffolder| repo[(Git Repo)]
  repo --> argocd[Argo CD]
  repo --> tf[Terraform]
  argocd -->|sync| k8s[(Kubernetes)]
  subgraph K8s Cluster
    platform[Platform NS: argocd, monitoring]
    apps[App NS: dev-team]
    mon[Prometheus/Grafana]
  end
  k8s --> mon


Flow
1. Developers use Backstage templates to scaffold new services (Helm chart + Argo CD Application + CI stub + catalog).
2. Git changes are the single source of truth. Argo CD syncs to the cluster.
3. Terraform provisions namespaces/RBAC and Argo CD Projects (optionally cloud infra in real use).
4. Monitoring is installed via GitOps (kube‑prometheus‑stack).



## Prerequisites
- kubectl, helm, argocd CLI, terraform (≥1.5)
- a Kubernetes cluster (e.g. `kind create cluster` or `minikube start`)
- optional: Node.js if running Backstage locally (`yarn`/`npm`)



## Quick Start

# 1) Install Argo CD (Helm) and expose it (NodePort for PoC)
./scripts/bootstrap-argocd.sh

# 2) Point the Argo CD Applications to THIS repo URL
#    (edit k8s/argocd/bootstrap/app-of-apps.yaml -> spec.source.repoURL)

# 3) Apply the App of Apps (installs monitoring, backstage, sample app)
kubectl apply -f k8s/argocd/bootstrap/app-of-apps.yaml -n argocd

# 4) (Optional) Provision namespaces/RBAC/Argo projects with Terraform
(cd infra/terraform/environments/dev && terraform init && terraform apply -auto-approve)

# 5) Access
# - Argo CD UI: kubectl -n argocd port-forward svc/argocd-server 8080:80 &
# - Backstage UI: kubectl -n platform port-forward svc/backstage 7007:80 &
# - Grafana: kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80 &

Default Argo CD admin password (Helm chart default): run `argocd admin initial-password -n argocd`.



## Repo Layout

idp-backstage-argocd-poc/
├── README.md
├── scripts/
│   ├── bootstrap-argocd.sh
│   └── register-repo.sh
├── k8s/
│   ├── argocd/
│   │   ├── bootstrap/app-of-apps.yaml
│   │   └── apps/
│   │       ├── monitoring.yaml
│   │       ├── backstage.yaml
│   │       └── sample-service.yaml
│   ├── apps/
│   │   ├── backstage/ (K8s Deploy, Service, ConfigMap, values)
│   │   └── monitoring/ (Helm values for kube-prometheus-stack)
│   └── charts/sample-service/ (Helm chart)
├── backstage/
│   ├── app-config.yaml
│   ├── catalog-info.yaml
│   └── scaffolder-templates/template-service/
│       ├── template.yaml
│       └── skeleton/ (service skeleton + Helm + ArgoCD app + catalog)
└── infra/terraform/
    ├── modules/
    │   ├── k8s-namespace/
    │   └── argocd-project/
    └── environments/dev/main.tf




## Notes
- This PoC intentionally uses NodePort/port-forward for simplicity.
- Please set repoURL in Argo CD `Application` manifests before syncing.
- Backstage actions that publish to GitHub are commented; add your token/host to enable.



## Next Steps
- Add golden paths for APIs, batch jobs, data pipelines.
- Enable CI templates (GitHub Actions) in the Backstage scaffolder.
- Add SSO/OIDC for Backstage and Argo CD; multi-tenant projects.
- Layer in policies (OPA/Gatekeeper, Kyverno) and SLO dashboards.



## Minikube Setup (recommended)


# Start a fresh cluster
minikube start --kubernetes-version=v1.29.2 --cpus=4 --memory=8192

# (Optional) enable addons you may want later
minikube addons enable metrics-server
# minikube addons enable ingress   # if you later add Ingress resources


### Install Argo CD and platform apps

./scripts/bootstrap-argocd.sh

# Set your Git repo URL in k8s/argocd/bootstrap/app-of-apps.yaml (spec.source.repoURL), commit & push
kubectl apply -n argocd -f k8s/argocd/bootstrap/app-of-apps.yaml


### Open the UIs using minikube

# Argo CD
minikube service -n argocd argocd-server --url

# Backstage
minikube service -n platform backstage --url

# Grafana
minikube service -n monitoring kube-prometheus-stack-grafana --url

