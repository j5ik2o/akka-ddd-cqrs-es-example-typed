variable "create" {
  default = true
}

variable "prefix" {
  default = "sg"
}

variable "dependencies" {
  type = list(string)
  default = []
}


variable "k8s_service_account_name" {
  default = "adceet"
}

variable "k8s_service_namespace" {
  default = "adceet"
}

variable "eks_cluster_id" {
}

variable "eks_cluster_version" {
}

variable "eks_cluster_oidc_issuer_url" {
}