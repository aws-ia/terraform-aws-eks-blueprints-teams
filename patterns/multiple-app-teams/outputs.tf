# Application Teams (creates multiple teams)
output "application_teams_namespaces" {
  description = "Mapf of Kubernetes namespaces created and their attributes"
  value       = [for team in module.application_teams : team.namespaces]
}

output "application_teams_rbac_group" {
  description = "The name of the Kubernetes RBAC group"
  value       = [for team in module.application_teams : team.rbac_group]
}

output "application_teams_aws_auth_configmap_role" {
  description = "Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap"
  value       = [for team in module.application_teams : team.aws_auth_configmap_role]
}

output "application_teams_iam_role_name" {
  description = "The name of the IAM role"
  value       = [for team in module.application_teams : team.iam_role_name]
}

output "application_teams_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = [for team in module.application_teams : team.iam_role_arn]
}

output "application_teams_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = [for team in module.application_teams : team.iam_role_unique_id]
}

output "application_teams_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = [for team in module.application_teams : "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name} --role-arn ${team.iam_role_arn}"]
}
