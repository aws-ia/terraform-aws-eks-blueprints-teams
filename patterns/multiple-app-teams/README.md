# Amazon EKS Blueprints Teams - Multiple Application Teams

This example shows how to create a multiple teams using the same approach of the [`patterns/development-team`](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/tree/main/patterns/development-team) pattern. Each team will be restricted to the Namespaces they own, together with fine grained permissions and resource access through the definition of Role's Resources, Verbs and API Groups using Kubernetes constructs, and also define LimitRanges, ResourceQuotas, amd NetworkPolicies for each one. In this example, teams will have *read-only* access to list Namespaces and Nodes.

- RBAC Authorization [documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- Namespaced vs. non-Namespaced objects [documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#not-all-objects-are-in-a-namespace)
- Resource Quotas [documentation](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- Limit Ranges [documentation](https://kubernetes.io/docs/concepts/policy/limit-range/)
- Network Policy [documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

## Areas of Interest

- `teams.tf` contains a sample configuration of the `teams` module, using the `for_each` Terraform Meta-Argument at the Module level creating multiple teams with the same configuration, in this case providing restricted access to specific Namespaces, and *read-only* access to list Namespaces and Nodes for the specified identities.

https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/bcc264abb8b0c76fba5a14a38d522a73d70015ae/patterns/multiple-app-teams/teams.tf#L5-L40

- `eks.tf` holds the EKS Cluster configuration and the setup of the `aws-auth` configMap, providing the EKS authentication model for the identities and RBAC authorization created by the `teams` module.

https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/4def6e7e437c5b8f2c5e6479f2585fac58bf060c/patterns/multiple-app-teams/eks.tf#L28-L33

## Deploy

Configuration in this directory creates:

- A VPC (required to support module/eks)
- An EKS cluster (required to support module/teams)
- Creation of two teams with restricted privileges inside their specific Namespaces, and no access to each other Namespaces.
- Read-only access to list Namespaces and Nodes for each team.

To run this pattern you need to execute:

```bash
$ cd patterns/cluster-admin
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_teams"></a> [application\_teams](#module\_application\_teams) | ../.. | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.13 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_teams_aws_auth_configmap_role"></a> [application\_teams\_aws\_auth\_configmap\_role](#output\_application\_teams\_aws\_auth\_configmap\_role) | Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap |
| <a name="output_application_teams_iam_role_arn"></a> [application\_teams\_iam\_role\_arn](#output\_application\_teams\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_application_teams_iam_role_name"></a> [application\_teams\_iam\_role\_name](#output\_application\_teams\_iam\_role\_name) | The name of the IAM role |
| <a name="output_application_teams_iam_role_unique_id"></a> [application\_teams\_iam\_role\_unique\_id](#output\_application\_teams\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_application_teams_kubeconfig"></a> [application\_teams\_kubeconfig](#output\_application\_teams\_kubeconfig) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_application_teams_namespaces"></a> [application\_teams\_namespaces](#output\_application\_teams\_namespaces) | Mapf of Kubernetes namespaces created and their attributes |
| <a name="output_application_teams_rbac_group"></a> [application\_teams\_rbac\_group](#output\_application\_teams\_rbac\_group) | The name of the Kubernetes RBAC group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/main/LICENSE)
