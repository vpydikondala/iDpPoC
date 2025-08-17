terraform {
  required_providers { kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.27" } }
}
provider "kubernetes" { config_path = var.kubeconfig }
variable "kubeconfig" { type = string  default = "~/.kube/config" }
module "platform_ns"   { source = "../../modules/k8s-namespace"  kubeconfig = var.kubeconfig  name = "platform"   }
module "monitoring_ns" { source = "../../modules/k8s-namespace"  kubeconfig = var.kubeconfig  name = "monitoring" }
module "devteam_ns"    { source = "../../modules/k8s-namespace"  kubeconfig = var.kubeconfig  name = "dev-team"   }
module "argocd_project_default" { source = "../../modules/argocd-project"  kubeconfig = var.kubeconfig  project_name = "default" }
