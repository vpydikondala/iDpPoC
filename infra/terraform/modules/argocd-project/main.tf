terraform {
  required_providers { kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.27" } }
}
provider "kubernetes" { config_path = var.kubeconfig }
variable "kubeconfig"   { type = string }
variable "project_name" { type = string  default = "default" }
resource "kubernetes_manifest" "app_project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = { name = var.project_name, namespace = "argocd" }
    spec = {
      description = "Terraform-provisioned project"
      sourceRepos = ["*"]
      destinations = [{ namespace = "*", server = "https://kubernetes.default.svc" }]
      clusterResourceWhitelist    = [{ group = "*", kind = "*" }]
      namespaceResourceWhitelist  = [{ group = "*", kind = "*" }]
    }
  }
}
