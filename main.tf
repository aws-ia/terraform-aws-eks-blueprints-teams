################################################################################
# K8s Namespace
################################################################################

resource "kubernetes_namespace_v1" "this" {
  for_each = { for k, v in var.namespaces : k => v if try(v.create, true) }

  metadata {
    name        = each.key
    annotations = merge(var.annotations, try(each.value.annotations, {}))
    labels      = merge(var.labels, try(each.value.labels, {}))
  }
}

################################################################################
# K8s Network Policy
################################################################################

resource "kubernetes_network_policy_v1" "this" {
  for_each = { for k, v in var.namespaces : k => v if try(v.create, true) && length(try(v.network_policy, {})) > 0 }

  metadata {
    name        = try(each.value.network_policy.name, each.key)
    namespace   = try(each.value.create, true) ? kubernetes_namespace_v1.this[each.key].metadata[0].name : each.key
    annotations = merge(var.annotations, try(each.value.network_policy.annotations, {}))
    labels      = merge(var.labels, try(each.value.network_policy.labels, {}))
  }

  spec {

    dynamic "ingress" {
      for_each = try(each.value.network_policy.ingress, [])

      content {
        dynamic "ports" {
          for_each = try(ingress.value.ports, [])

          content {
            port     = try(ports.value.port, null)
            protocol = try(ports.value.protocol, null)
          }
        }

        dynamic "from" {
          for_each = try(ingress.value.from, [])

          content {
            dynamic "ip_block" {
              for_each = try([from.value.ip_block], [])

              content {
                cidr   = try(ip_block.value.cidr, null)
                except = try(ip_block.value.except, null)
              }
            }

            dynamic "namespace_selector" {
              for_each = try([from.value.namespace_selector], [])

              content {
                dynamic "match_expressions" {
                  for_each = try(namespace_selector.value.match_expressions, [])

                  content {
                    key      = try(match_expressions.value.key, null)
                    operator = try(match_expressions.value.operator, null)
                    values   = try(match_expressions.value.values, null)
                  }
                }

                match_labels = try(namespace_selector.value.match_labels, null)
              }
            }

            dynamic "pod_selector" {
              for_each = try([from.value.pod_selector], [])

              content {
                dynamic "match_expressions" {
                  for_each = try(pod_selector.value.match_expressions, [])

                  content {
                    key      = try(match_expressions.value.key, null)
                    operator = try(match_expressions.value.operator, null)
                    values   = try(match_expressions.value.values, null)
                  }
                }

                match_labels = try(pod_selector.value.match_labels, null)
              }
            }
          }
        }
      }
    }

    dynamic "egress" {
      for_each = try(each.value.network_policy.egress, [])

      content {
        dynamic "ports" {
          for_each = try(egress.value.ports, [])

          content {
            port     = try(ports.value.port, null)
            protocol = try(ports.value.protocol, null)
          }
        }

        dynamic "to" {
          for_each = try(egress.value.to, [])

          content {
            dynamic "ip_block" {
              for_each = try([to.value.ip_block], [])

              content {
                cidr   = try(ip_block.value.cidr, null)
                except = try(ip_block.value.except, null)
              }
            }

            dynamic "namespace_selector" {
              for_each = try([to.value.namespace_selector], [])

              content {
                dynamic "match_expressions" {
                  for_each = try(namespace_selector.value.match_expressions, [])

                  content {
                    key      = try(match_expressions.value.key, null)
                    operator = try(match_expressions.value.operator, null)
                    values   = try(match_expressions.value.values, null)
                  }
                }

                match_labels = try(namespace_selector.value.match_labels, null)
              }
            }

            dynamic "pod_selector" {
              for_each = try([to.value.pod_selector], [])

              content {
                dynamic "match_expressions" {
                  for_each = try(pod_selector.value.match_expressions, [])

                  content {
                    key      = try(match_expressions.value.key, null)
                    operator = try(match_expressions.value.operator, null)
                    values   = try(match_expressions.value.values, null)
                  }
                }

                match_labels = try(pod_selector.value.match_labels, null)
              }
            }
          }
        }
      }
    }

    dynamic "pod_selector" {
      for_each = try(each.value.network_policy.pod_selector, [])

      content {
        dynamic "match_expressions" {
          for_each = try(pod_selector.value.match_expressions, [])

          content {
            key      = try(match_expressions.value.key, null)
            operator = try(match_expressions.value.operator, null)
            values   = try(match_expressions.value.values, null)
          }
        }

        match_labels = try(pod_selector.value.match_labels, null)
      }
    }

    policy_types = each.value.network_policy.policy_types
  }
}

################################################################################
# K8s Service Account
################################################################################

resource "kubernetes_service_account_v1" "this" {
  for_each = { for k, v in var.namespaces : k => v if try(v.create, true) && try(v.create_service_account, true) }

  metadata {
    name      = try(each.value.service_account.name, each.key)
    namespace = try(each.value.create, true) ? kubernetes_namespace_v1.this[each.key].metadata[0].name : each.key
    annotations = merge(
      var.annotations,
      try(each.value.service_account.annotations, {}),
      { "eks.amazonaws.com/role-arn" : var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn }
    )
    labels = merge(var.labels, try(each.value.service_account.labels, {}))
  }

  dynamic "image_pull_secret" {
    for_each = try(each.value.service_account.image_pull_secrets, [])

    content {
      name = secret.value.name
    }
  }

  dynamic "secret" {
    for_each = try(each.value.service_account.secrets, [])

    content {
      name = secret.value.name
    }
  }

  automount_service_account_token = false
}

resource "kubernetes_secret_v1" "service_account_token" {
  for_each = { for k, v in var.namespaces : k => v if try(v.create, true) && try(v.create_service_account, true) && try(v.service_account.create_token, false) }

  metadata {
    name      = try(each.value.service_account.name, each.key)
    namespace = try(each.value.create, true) ? kubernetes_namespace_v1.this[each.key].metadata[0].name : each.key
    annotations = merge(
      var.annotations,
      try(each.value.service_account.annotations, {}),
      { "kubernetes.io/service-account.name" : kubernetes_service_account_v1.this[each.key].metadata[0].name }
    )
    labels = merge(var.labels, try(each.value.service_account.labels, {}))
  }

  type = "kubernetes.io/service-account-token"
}

################################################################################
# K8s Resource Quota
################################################################################

resource "kubernetes_resource_quota_v1" "this" {
  for_each = { for k, v in var.namespaces : k => v if try(v.create, true) && length(try(v.resource_quota, {})) > 0 }

  metadata {
    name        = try(each.value.resource_quota.name, each.key)
    namespace   = try(each.value.create, true) ? kubernetes_namespace_v1.this[each.key].metadata[0].name : each.key
    annotations = merge(var.annotations, try(each.value.resource_quota.annotations, {}))
    labels      = merge(var.labels, try(each.value.resource_quota.labels, {}))
  }

  spec {
    hard   = try(each.value.resource_quota.hard, null)
    scopes = try(each.value.resource_quota.scopes, null)

    dynamic "scope_selector" {
      for_each = try([each.value.resource_quota.scope_selector], [])

      content {
        dynamic "match_expression" {
          for_each = try(scope_selector.value.match_expression, [])

          content {
            scope_name = match_expression.value.scope_name
            operator   = match_expression.value.operator
            values     = try(match_expression.value.values, null)
          }
        }
      }
    }
  }
}

################################################################################
# K8s Limit Range
################################################################################

resource "kubernetes_limit_range_v1" "this" {
  for_each = { for k, v in var.namespaces : k => v if try(v.create, true) && length(try(v.limit_range, {})) > 0 }

  metadata {
    name        = try(each.value.limit_range.name, each.key)
    namespace   = try(each.value.create, true) ? kubernetes_namespace_v1.this[each.key].metadata[0].name : each.key
    annotations = merge(var.annotations, try(each.value.limit_range.annotations, {}))
    labels      = merge(var.labels, try(each.value.limit_range.labels, {}))
  }

  spec {
    dynamic "limit" {
      for_each = try(each.value.limit_range.limit, [])

      content {
        default                 = try(limit.value.default, null)
        default_request         = try(limit.value.default_request, null)
        max                     = try(limit.value.max, null)
        max_limit_request_ratio = try(limit.value.max_limit_request_ratio, null)
        min                     = try(limit.value.min, null)
        type                    = try(limit.value.type, null)
      }
    }
  }
}

################################################################################
# K8s Cluster Role
################################################################################

resource "kubernetes_cluster_role_v1" "this" {
  count = var.create_cluster_role && !var.enable_admin ? 1 : 0

  metadata {
    name        = coalesce(var.cluster_role_name, "${var.name}-cluster")
    annotations = var.annotations
    labels      = var.labels
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  count = var.create_cluster_role && !var.enable_admin ? 1 : 0

  metadata {
    name        = kubernetes_cluster_role_v1.this[0].metadata[0].name
    annotations = var.annotations
    labels      = var.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.this[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = var.name
    api_group = "rbac.authorization.k8s.io"
    namespace = ""
  }
}

################################################################################
# K8s Role Binding
################################################################################

resource "kubernetes_role_binding_v1" "this" {
  for_each = { for k, v in var.namespaces : k => v if var.create_role && !var.enable_admin }

  metadata {
    name        = "${coalesce(var.role_name, var.name)}-${each.key}"
    namespace   = try(each.value.create, true) ? kubernetes_namespace_v1.this[each.key].metadata[0].name : each.key
    annotations = var.annotations
    labels      = var.labels
  }
  # Note: We are using a cluster role but using a role binding
  # this allows us to have one role but bind it to n-number of namespaces.
  # Just because its a cluster role does not mean it has cluster access, its all
  # determined by the fact that this is a role binding (kubernetes_role_binding_v1).
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "Group"
    name      = var.name
    api_group = "rbac.authorization.k8s.io"
    namespace = try(each.value.create, true) ? kubernetes_namespace_v1.this[each.key].metadata[0].name : each.key
  }
}

################################################################################
# IAM Role
################################################################################

locals {
  iam_role_name = coalesce(var.iam_role_name, var.name)
}

data "aws_iam_policy_document" "this" {
  count = var.create_iam_role ? 1 : 0

  statement {
    sid     = "AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.users
    }
  }

  # IRSA
  dynamic "statement" {
    for_each = var.enable_admin ? [] : [1]

    content {
      sid     = "IRSA"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [var.oidc_provider_arn]
      }

      condition {
        test     = "StringEquals"
        variable = "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
        values   = [for k, v in var.namespaces : "system:serviceaccount:${try(v.name, k, "*")}:${try(v.service_account.name, v.name, k, "*")}"]
      }

      condition {
        test     = "StringEquals"
        variable = "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.this[0].json
  max_session_duration  = var.iam_role_max_session_duration
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.iam_role_policies : k => v if var.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

################################################################################
# Admin IAM Role Policy
################################################################################

locals {
  admin_policy_name = coalesce(var.admin_policy_name, local.iam_role_name)

  arn_base = join(":", slice(split(":", var.cluster_arn), 0, 5))
}

data "aws_iam_policy_document" "admin" {
  count = var.create_iam_role && var.enable_admin ? 1 : 0

  statement {
    sid = "List"
    actions = [
      "eks:ListFargateProfiles",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "eks:ListAddons"
    ]
    resources = [
      var.cluster_arn,
      "${local.arn_base}:nodegroup/*/*/*",
      "${local.arn_base}:addon/*/*/*",
    ]
  }

  statement {
    sid = "ListDescribeAll"
    actions = [
      "eks:DescribeAddonConfiguration",
      "eks:DescribeAddonVersions",
      "eks:ListClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid = "Describe"
    actions = [
      "eks:DescribeNodegroup",
      "eks:DescribeFargateProfile",
      "eks:ListTagsForResource",
      "eks:DescribeUpdate",
      "eks:AccessKubernetesApi",
      "eks:DescribeCluster",
      "eks:DescribeAddon"
    ]
    resources = [
      var.cluster_arn,
      "${local.arn_base}:fargateprofile/*/*/*",
      "${local.arn_base}:nodegroup/*/*/*",
      "${local.arn_base}:addon/*/*/*",
    ]
  }
}

resource "aws_iam_policy" "admin" {
  count = var.create_iam_role && var.enable_admin ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.admin_policy_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.admin_policy_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  policy = data.aws_iam_policy_document.admin[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "admin" {
  count = var.create_iam_role && var.enable_admin ? 1 : 0

  policy_arn = aws_iam_policy.admin[0].arn
  role       = aws_iam_role.this[0].name
}
