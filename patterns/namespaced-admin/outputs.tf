# Platform Team
output "platform_team_namespaces" {
  description = "Map of Kubernetes namespaces created and their attributes"
  value       = module.platform_team.namespaces
}

output "platform_team_rbac_group" {
  description = "The name of the Kubernetes RBAC group"
  value       = module.platform_team.rbac_group
}

output "platform_team_aws_auth_configmap_role" {
  description = "Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap"
  value       = module.platform_team.aws_auth_configmap_role
}

output "platform_team_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.platform_team.iam_role_name
}

output "platform_team_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.platform_team.iam_role_arn
}

output "platform_team_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.platform_team.iam_role_unique_id
}

output "platform_team_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name} --role-arn ${module.platform_team.iam_role_arn}"
}

# Red Team
output "red_team_namespaces" {
  description = "Mapf of Kubernetes namespaces created and their attributes"
  value       = module.red_team.namespaces
}

output "red_team_rbac_group" {
  description = "The name of the Kubernetes RBAC group"
  value       = module.red_team.rbac_group
}

output "red_team_aws_auth_configmap_role" {
  description = "Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap"
  value       = module.red_team.aws_auth_configmap_role
}

output "red_team_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.red_team.iam_role_name
}

output "red_team_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.red_team.iam_role_arn
}

output "red_team_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.red_team.iam_role_unique_id
}

output "red_team_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name} --role-arn ${module.red_team.iam_role_arn}"
}

# Blue Teams (creates multiple teams)
output "blue_teams_namespaces" {
  description = "Mapf of Kubernetes namespaces created and their attributes"
  value       = [for team in module.blue_teams : team.namespaces]
}

output "blue_teams_rbac_group" {
  description = "The name of the Kubernetes RBAC group"
  value       = [for team in module.blue_teams : team.rbac_group]
}

output "blue_teams_aws_auth_configmap_role" {
  description = "Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap"
  value       = [for team in module.blue_teams : team.aws_auth_configmap_role]
}

output "blue_teams_iam_role_name" {
  description = "The name of the IAM role"
  value       = [for team in module.blue_teams : team.iam_role_name]
}

output "blue_teams_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = [for team in module.blue_teams : team.iam_role_arn]
}

output "blue_teams_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = [for team in module.blue_teams : team.iam_role_unique_id]
}

output "blue_teams_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = [for team in module.blue_teams : "aws eks update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name} --role-arn ${team.iam_role_arn}"]
}
