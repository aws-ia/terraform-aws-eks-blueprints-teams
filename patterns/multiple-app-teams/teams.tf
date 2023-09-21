################################################################################
# EKS Blueprints Teams Module - Multiple Application Teams
################################################################################

module "application_teams" {
  source = "../.."

  for_each = {
    one = {}
    two = {}
  }
  name = "app-team-${each.key}"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  namespaces = {
    "app-${each.key}" = {
      labels = {
        teamName    = "${each.key}-team",
        projectName = "${each.key}-project",
      }

      resource_quota = {
        hard = {
          "requests.cpu"    = "2000m",
          "requests.memory" = "4Gi",
          "limits.cpu"      = "4000m",
          "limits.memory"   = "16Gi",
          "pods"            = "20",
          "secrets"         = "20",
          "services"        = "20"
        }
      }
    }
  }

  tags = local.tags
}
