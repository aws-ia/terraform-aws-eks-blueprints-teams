# Amazon EKS Blueprints Teams - Complete

Configuration in this directory creates:

- An EKS cluster (required to support module/tests)
- An administrative team
- A red team which demonstrates creating one team per module definition
- Blue teams which demonstrates creating multiple teams per module definition

## Usage

To run this example you need to execute:

```bash
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
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.13 |
| <a name="module_operations_team"></a> [operations\_team](#module\_operations\_team) | ../.. | n/a |
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
| <a name="output_operations_team_aws_auth_configmap_role"></a> [operations\_team\_aws\_auth\_configmap\_role](#output\_operations\_team\_aws\_auth\_configmap\_role) | Dictionary containing the necessary details for adding the role created to the `aws-auth` configmap |
| <a name="output_operations_team_iam_role_arn"></a> [operations\_team\_iam\_role\_arn](#output\_operations\_team\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_operations_team_iam_role_name"></a> [operations\_team\_iam\_role\_name](#output\_operations\_team\_iam\_role\_name) | The name of the IAM role |
| <a name="output_operations_team_iam_role_unique_id"></a> [operations\_team\_iam\_role\_unique\_id](#output\_operations\_team\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_operations_team_kubeconfig"></a> [operations\_team\_kubeconfig](#output\_operations\_team\_kubeconfig) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_operations_team_namespaces"></a> [operations\_team\_namespaces](#output\_operations\_team\_namespaces) | Map of Kubernetes namespaces created and their attributes |
| <a name="output_operations_team_rbac_group"></a> [operations\_team\_rbac\_group](#output\_operations\_team\_rbac\_group) | The name of the Kubernetes RBAC group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams/blob/main/LICENSE)