variable "name" {
  description = "A common name used across resources created unless a more specific resource name is provdied"
  type        = string
  default     = ""
}

variable "annotations" {
  description = "A map of Kubernetes annotations to add to all resources"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "A map of Kubernetes labels to add to all resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all AWS resources"
  type        = map(string)
  default     = {}
}

################################################################################
# K8s Namespace
################################################################################

variable "namespaces" {
  description = "A map of Kubernetes namespace definitions to create"
  type        = any
  default     = {}
}

################################################################################
# K8s Cluster Role
################################################################################

variable "create_cluster_role" {
  description = "Determines whether a Kubernetes cluster role is created"
  type        = bool
  default     = true
}

variable "cluster_role_name" {
  description = "Name to use on Kubernetes cluster role created"
  type        = string
  default     = ""
}

variable "additional_role_ref" {
  description = "Existing Role or ClusterRole to be referenced on the Kubernetes clusterRoleBinding created"
  type        = any
  default     = {}
}

variable "cluster_role_rule" {
  description = "Defines the Kubernetes RBAC based `api_groups`, `resources`, and `verbs` Rules for the role created"
  type        = any
  default     = {}
}

################################################################################
# K8s Role
################################################################################

variable "create_role" {
  description = "Determines whether a Kubernetes role is created. Note: the role created is a cluster role but its bound to only namespaced role bindings"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name to use on Kubernetes role created"
  type        = string
  default     = ""
}

variable "role_ref" {
  description = "Defines the reference for an existing Kubernetes role"
  type        = any
  default     = {}
}
################################################################################
# IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the node group. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours"
  type        = number
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "IAM policies to be added to the IAM role created"
  type        = map(string)
  default     = {}
}

# IRSA
variable "users" {
  description = "A list of IAM user and/or role ARNs that can assume the IAM role created"
  type        = list(string)
  default     = []
}

variable "principal_arns" {
  description = "A list of IAM principal arns to support passing wildcards for AWS Identity Center (SSO) roles. [Reference](https://docs.aws.amazon.com/singlesignon/latest/userguide/referencingpermissionsets.html#custom-trust-policy-example)"
  type        = list(string)
  default     = []
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider created by the EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  type        = string
  default     = ""
}

################################################################################
# Admin IAM Role Policy
################################################################################

variable "enable_admin" {
  description = "Determines whether an IAM role policy is created to grant admin access to the Kubernetes cluster"
  type        = bool
  default     = false
}

variable "admin_policy_name" {
  description = "Name to use on admin IAM policy created"
  type        = string
  default     = ""
}
