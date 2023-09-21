################################################################################
# EKS Blueprints Teams Module - Multi-Tenancy
################################################################################
module "admin_team" {
  source = "../.."

  name = "admin-team"

  enable_admin = true
  users        = [data.aws_caller_identity.current.arn]
  cluster_arn  = module.eks.cluster_arn

  tags = local.tags
}

module "platform_team" {
  source = "../.."

  name = "platform-team"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  labels = {
    team = "platform"
  }

  annotations = {
    team = "platform"
  }

  cluster_role_name     = "platform-team"
  cluster_role_ref_name = "admin"
  role_ref = {
    kind = "ClusterRole"
    name = "admin"
  }

  tags = local.tags
}

module "red_team" {
  source = "../.."

  name = "red-team"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  labels = {
    team = "red-team"
  }

  annotations = {
    team = "red-team"
  }

  namespaces = {
    default = {
      # Provides access to an existing namespace
      create = false
    }
    red = {
      labels = {
        projectName = "red-app",
      }

      resource_quota = {
        hard = {
          "requests.cpu"    = "1000m",
          "requests.memory" = "4Gi",
          "limits.cpu"      = "2000m",
          "limits.memory"   = "8Gi",
          "pods"            = "10",
          "secrets"         = "10",
          "services"        = "10"
        }
      }

      limit_range = {
        limit = [
          {
            type = "Pod"
            max = {
              cpu    = "200m"
              memory = "1Gi"
            }
          },
          {
            type = "PersistentVolumeClaim"
            min = {
              storage = "24M"
            }
          },
          {
            type = "Container"
            default = {
              cpu    = "50m"
              memory = "24Mi"
            }
          }
        ]
      }

      network_policy = {
        pod_selector = {
          match_expressions = [{
            key      = "name"
            operator = "In"
            values   = ["webfront", "api"]
          }]
        }

        ingress = [{
          ports = [
            {
              port     = "http"
              protocol = "TCP"
            },
            {
              port     = "53"
              protocol = "TCP"
            },
            {
              port     = "53"
              protocol = "UDP"
            }
          ]

          from = [
            {
              namespace_selector = {
                match_labels = {
                  name = "default"
                }
              }
            },
            {
              ip_block = {
                cidr = "10.0.0.0/8"
                except = [
                  "10.0.0.0/24",
                  "10.0.1.0/24",
                ]
              }
            }
          ]
        }]

        egress = [] # single empty rule to allow all egress traffic

        policy_types = ["Ingress", "Egress"]
      }
    }
  }

  tags = local.tags
}

module "blue_teams" {
  source = "../.."

  for_each = {
    one = {}
    two = {}
  }
  name = "blue-team-${each.key}"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  namespaces = {
    "blue-${each.key}" = {
      labels = {
        appName     = "blue-team-app",
        projectName = "project-blue",
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
