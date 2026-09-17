################################################################################
# EKS Blueprints Teams Module - Namespaced Admin
################################################################################
module "operations_team" {
  source = "../.."

  name = "operations-team"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  labels = {
    team = "ops"
  }

  annotations = {
    team = "ops"
  }

  cluster_role_name = "ops-team"
  additional_role_ref = {
    name = "admin"
  }
  role_ref = {
    kind = "ClusterRole"
    name = "admin"
  }

  tags = local.tags
}
