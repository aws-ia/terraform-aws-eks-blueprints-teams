################################################################################
# K8s Namespace
################################################################################

output "namespaces" {
  description = "Map of Kubernetes namespaces created and their attributes"
  value       = kubernetes_namespace_v1.this
}

################################################################################
# K8s RBAC
################################################################################

output "rbac_group" {
  description = "The name of the Kubernetes RBAC group"
  value       = var.enable_admin ? "system:masters" : var.name
}

output "aws_auth_configmap_role" {
  description = "Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap"
  value = {
    rolearn  = try(aws_iam_role.this[0].arn, var.iam_role_arn)
    username = var.name
    groups   = [var.enable_admin ? "system:masters" : var.name]
  }
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this[0].arn, var.iam_role_arn)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}
