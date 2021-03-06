locals {
  application_name = var.application_name
  k8s_service_namespace = var.k8s_service_namespace
  k8s_service_account_name = var.k8s_service_account_name
  iam_policy_name_prefix = "${var.prefix}-adceet-${local.application_name}"
  iam_role_name =  "${var.prefix}-adceet-${local.application_name}"
}