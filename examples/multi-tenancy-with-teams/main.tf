#---------------------------------------------------------------
# EKS
#---------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = var.name
  cluster_version = "1.24"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.large"]
      subnet_ids      = module.vpc.private_subnets
    }
  }
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = ["audit", "api", "authenticator", "scheduler", "controllerManager"]
}

#---------------------------------------------------------------
# EKS Blueprints Teams
#---------------------------------------------------------------
module "eks_blueprints_teams" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-teams"

  eks_cluster_id = module.eks.cluster_name

  platform_teams = {
    admin = {
      users = [data.aws_caller_identity.current.arn]
    }
  }

  application_teams = {
    team-red = {
      "labels" = {
        "appName"     = "read-team-app",
        "projectName" = "project-red",
        "environment" = "example",
        "domain"      = "example",
        "uuid"        = "example",
        "billingCode" = "example",
        "branch"      = "example"
      }
      "quota" = {
        "requests.cpu"    = "1000m",
        "requests.memory" = "4Gi",
        "limits.cpu"      = "2000m",
        "limits.memory"   = "8Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }

      manifests_dir = "./manifests-team-red"
      users         = [data.aws_caller_identity.current.arn]
    }

    team-blue = {
      "labels" = {
        "appName"     = "blue-team-app",
        "projectName" = "project-blue",
      }
      "quota" = {
        "requests.cpu"    = "2000m",
        "requests.memory" = "4Gi",
        "limits.cpu"      = "4000m",
        "limits.memory"   = "16Gi",
        "pods"            = "20",
        "secrets"         = "20",
        "services"        = "20"
      }

      manifests_dir = "./manifests-team-blue"
      users         = [data.aws_caller_identity.current.arn]
    }
  }

  tags = local.tags

  depends_on = [
    module.eks
  ]
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------'

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }

  map_public_ip_on_launch = false

  # Enable Flow Logs
  # Adding TFSec targeted ignore due a bug in tfsec v1.28.1
  # https://github.com/aquasecurity/tfsec/issues/1941
  #tfsec:ignore:aws-vpc-require-vpc-flow-logs-for-all-vpcs
  enable_flow_log                           = true
  create_flow_log_cloudwatch_log_group      = true
  create_flow_log_cloudwatch_iam_role       = true
  flow_log_max_aggregation_interval         = 60
  flow_log_cloudwatch_log_group_name_prefix = "/aws/eks-vpc-flow-logs/"
  flow_log_cloudwatch_log_group_name_suffix = "multi-tenancy-with-teams"

  tags = local.tags
}
