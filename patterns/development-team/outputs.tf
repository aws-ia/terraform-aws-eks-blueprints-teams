# Red Team
output "development_team_namespaces" {
  description = "Mapf of Kubernetes namespaces created and their attributes"
  value       = module.development_team.namespaces
}

output "development_team_rbac_group" {
  description = "The name of the Kubernetes RBAC group"
  value       = module.development_team.rbac_group
}

output "development_team_aws_auth_configmap_role" {
  description = "Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap"
  value       = module.development_team.aws_auth_configmap_role
}

output "development_team_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.development_team.iam_role_name
}

output "development_team_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.development_team.iam_role_arn
}

output "development_team_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.development_team.iam_role_unique_id
}

output "development_team_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name} --role-arn ${module.development_team.iam_role_arn}"
}
