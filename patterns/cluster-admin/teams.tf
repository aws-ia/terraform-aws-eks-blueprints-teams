################################################################################
# EKS Blueprints Teams Module - Cluster Admin
################################################################################

module "admin_team" {
  source = "../.."

  name = "admin-team"

  enable_admin = true
  users        = [data.aws_caller_identity.current.arn]
  cluster_arn  = module.eks.cluster_arn

  tags = local.tags
}
