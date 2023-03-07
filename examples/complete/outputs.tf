# Admin
output "admin_team_namespaces" {
  description = "Mapf of Kubernetes namespaces created and their attributes"
  value       = module.admin_team.namespaces
}

output "admin_team_rbac_group" {
  description = "The name of the Kubernetes RBAC group"
  value       = module.admin_team.rbac_group
}

output "admin_team_aws_auth_configmap_role" {
  description = "Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap"
  value       = module.admin_team.aws_auth_configmap_role
}

output "admin_team_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.admin_team.iam_role_name
}

output "admin_team_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.admin_team.iam_role_arn
}

output "admin_team_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.admin_team.iam_role_unique_id
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
