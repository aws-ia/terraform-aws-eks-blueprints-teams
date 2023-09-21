# Amazon EKS Blueprints Teams - Cluster Admin

This example shows how to create a team with Cluster Admin privileges for the specified identities (`users/role`). For this to work, the created team will be tied to the `system:masters` Kubernetes RBAC group, that will give them the *super-user* permissions, as defined in the `cluster-admin` Kubernetes clusterRole.

- RBAC Authorization for User-facing roles [documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)

## Areas of Interest

- `teams.tf` contains a sample configuration of the `teams` module, in this case with a `cluster-admin` or *super-user* privileges for the provided identities.

https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/main/patterns/cluster-admin/teams.tf#L5-L15

- `eks.tf` holds the EKS Cluster configuration and the setup of the `aws-auth` configMap, providing the EKS authentication model for the identities and RBAC authorization created by the `teams` module.

https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/main/patterns/cluster-admin/eks.tf#L28-L33

## Deploy

Configuration in this directory creates:

- A VPC (required to support module/eks)
- An EKS cluster (required to support module/teams)
- A team with `cluster-admin` privileges

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
| <a name="module_admin_team"></a> [admin\_team](#module\_admin\_team) | ../.. | n/a |
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
| <a name="output_admin_team_aws_auth_configmap_role"></a> [admin\_team\_aws\_auth\_configmap\_role](#output\_admin\_team\_aws\_auth\_configmap\_role) | Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap |
| <a name="output_admin_team_iam_role_arn"></a> [admin\_team\_iam\_role\_arn](#output\_admin\_team\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_admin_team_iam_role_name"></a> [admin\_team\_iam\_role\_name](#output\_admin\_team\_iam\_role\_name) | The name of the IAM role |
| <a name="output_admin_team_iam_role_unique_id"></a> [admin\_team\_iam\_role\_unique\_id](#output\_admin\_team\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_admin_team_kubeconfig"></a> [admin\_team\_kubeconfig](#output\_admin\_team\_kubeconfig) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_admin_team_namespaces"></a> [admin\_team\_namespaces](#output\_admin\_team\_namespaces) | Map of Kubernetes namespaces created and their attributes |
| <a name="output_admin_team_rbac_group"></a> [admin\_team\_rbac\_group](#output\_admin\_team\_rbac\_group) | The name of the Kubernetes RBAC group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/main/LICENSE)
