provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  region = "us-west-2"
  name   = "ex-teams-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/aws-ia/terraform-aws-eks-blueprints-teams"
  }
}

################################################################################
# EKS Development Teams Module
################################################################################

module "development_team" {
  source = "../.."

  name = "development-team"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  labels = {
    team = "dev"
  }

  annotations = {
    team = "dev"
  }

  namespaces = {
    default = {
      # Provides access to an existing namespace
      create = false
    }
    app = {

      labels = {
        projectName = "project-app",
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

################################################################################
# Supporting Resources
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = flatten(
    [
      module.development_team.aws_auth_configmap_role,
    ]
  )

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
