# Amazon EKS Blueprints Teams Terraform module

Terraform module which creates multi-tenancy resources on Amazon EKS.

## Usage

See [`tests`](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/tree/main/test) directory for working tests to reference:


### Standalone - Admin Team

```hcl
module "admin_team" {
  source = "aws-ia/eks-blueprints-teams/aws"

  name = "admin-team"

  # Enables elevated, admin privileges for this team
  enable_admin = true
  users        = ["arn:aws:iam::111122223333:role/my-admin-role"]
  cluster_arn  = "arn:aws:eks:us-west-2:111122223333:cluster/my-cluster"

  tags = {
    Environment = "dev"
  }
}
```

### Standalone - Developer Team

```hcl
module "development_team" {
  source = "aws-ia/eks-blueprints-teams/aws"

  name = "development-team"

  users             = ["arn:aws:iam::012345678901:role/my-developer"]
  cluster_arn       = "arn:aws:eks:us-west-2:012345678901:cluster/my-cluster"
  oidc_provider_arn = "arn:aws:iam::012345678901:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"

  # Labels applied to all Kubernetes resources
  # More specific labels can be applied to individual resources under `namespaces` below
  labels = {
    team = "development"
  }

  # Annotations applied to all Kubernetes resources
  # More specific labels can be applied to individual resources under `namespaces` below
  annotations = {
    team = "development"
  }

  namespaces = {
    default = {
      # Provides access to an existing namespace
      create = false
    }

    development = {
      labels = {
        projectName = "project-awesome",
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

  tags = {
    Environment = "dev"
  }
}
```

### Multiple Teams

You can utilize a module level `for_each` to create multiple teams with the same configuration, and even allow some of those values to be defaults that can be overridden.

```hcl
module "development_team" {
  source = "aws-ia/eks-blueprints-teams/aws"

  for_each = {
    one = {
      # Add any additional variables here and update definition below to use
      users = ["arn:aws:iam::012345678901:role/developers-one"]
    }
    two = {
      users = ["arn:aws:iam::012345678901:role/developers-two"]
    }
    three = {
      users = ["arn:aws:iam::012345678901:role/developers-three"]
    }
  }

  name = "${each.key}-team"

  users             = each.value.users
  cluster_arn       = "arn:aws:eks:us-west-2:012345678901:cluster/my-cluster"
  oidc_provider_arn = "arn:aws:iam::012345678901:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"

  # Labels applied to all Kubernetes resources
  # More specific labels can be applied to individual resources under `namespaces` below
  labels = {
    team = each.key
  }

  # Annotations applied to all Kubernetes resources
  # More specific labels can be applied to individual resources under `namespaces` below
  annotations = {
    team = each.key
  }

  namespaces = {
    (each.key) = {
      labels = {
        projectName = "project-awesome",
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
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.17 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.17 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_cluster_role_binding_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_v1) | resource |
| [kubernetes_limit_range_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range_v1) | resource |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_network_policy_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |
| [kubernetes_resource_quota_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota_v1) | resource |
| [kubernetes_role_binding_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |
| [kubernetes_secret_v1.service_account_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_account_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [aws_iam_policy_document.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_policy_name"></a> [admin\_policy\_name](#input\_admin\_policy\_name) | Name to use on admin IAM policy created | `string` | `""` | no |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | A map of Kubernetes annotations to add to all resources | `map(string)` | `{}` | no |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster | `string` | `""` | no |
| <a name="input_cluster_role_name"></a> [cluster\_role\_name](#input\_cluster\_role\_name) | Name to use on Kubernetes cluster role created | `string` | `""` | no |
| <a name="input_create_cluster_role"></a> [create\_cluster\_role](#input\_create\_cluster\_role) | Determines whether a Kubernetes cluster role is created | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether an IAM role is created or to use an existing IAM role | `bool` | `true` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Determines whether a Kubernetes role is created. Note: the role created is a cluster role but its bound to only namespaced role bindings | `bool` | `true` | no |
| <a name="input_enable_admin"></a> [enable\_admin](#input\_enable\_admin) | Determines whether an IAM role policy is created to grant admin access to the Kubernetes cluster | `bool` | `false` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the node group. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours | `number` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | IAM policies to be added to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of Kubernetes labels to add to all resources | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | A common name used across resources created unless a more specific resource name is provdied | `string` | `""` | no |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | A map of Kubernetes namespace definitions to create | `any` | `{}` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN of the OIDC provider created by the EKS cluster | `string` | `""` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name to use on Kubernetes role created | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all AWS resources | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | A list of IAM user and/or role ARNs that can assume the IAM role created | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_configmap_role"></a> [aws\_auth\_configmap\_role](#output\_aws\_auth\_configmap\_role) | Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_namespaces"></a> [namespaces](#output\_namespaces) | Map of Kubernetes namespaces created and their attributes |
| <a name="output_rbac_group"></a> [rbac\_group](#output\_rbac\_group) | The name of the Kubernetes RBAC group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/main/LICENSE)
