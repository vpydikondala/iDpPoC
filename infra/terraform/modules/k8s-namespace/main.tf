terraform {
  required_providers { kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.27" } }
}
provider "kubernetes" { config_path = var.kubeconfig }
variable "kubeconfig" { type = string }
variable "name"       { type = string }
variable "labels"     { type = map(string) default = {} }
resource "kubernetes_namespace" "ns" { metadata { name = var.name, labels = var.labels } }
output "namespace" { value = kubernetes_namespace.ns.metadata[0].name }
