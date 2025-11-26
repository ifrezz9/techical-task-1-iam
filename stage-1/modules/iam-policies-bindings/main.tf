locals {
  groups_bindings = {
    for g_name, b in var.bindings.groups :
    g_name => {
      managed_sets = coalesce(b.managed_sets, [])
      custom_sets  = coalesce(b.custom_sets, [])
    }
  }

  users_bindings = {
    for u_name, b in coalesce(var.bindings.users, {}) :
    u_name => {
      managed_sets = coalesce(b.managed_sets, [])
      custom_sets  = coalesce(b.custom_sets, [])
    }
  }

  # ---------- CUSTOM POLICIES DEFINITION ----------

  # Flatten custom policy sets into a list of:
  # { set_name, policy_name, description, document }
  custom_policies_flat = flatten([
    for set_name, set_policies in var.policies.custom : [
      for policy_name, policy_def in set_policies : {
        set_name    = set_name
        policy_name = policy_name
        description = lookup(policy_def, "description", "")
        document    = policy_def.document
      }
    ]
  ])

  # Map for aws_iam_policy.custom for_each:
  # key = "set_name|policy_name"
  custom_policies_map = {
    for p in local.custom_policies_flat :
    "${p.set_name}|${p.policy_name}" => p
  }

  # ---------- MANAGED POLICY ATTACHMENTS (GROUPS) ----------

  # Build list of { group, arn } for all managed policy attachments to groups
  managed_group_attachments = flatten([
    for group_name, binding in local.groups_bindings : [
      for set_name in binding.managed_sets : [
        for arn in lookup(var.policies.managed, set_name, []) : {
          group = group_name
          arn   = arn
        }
      ]
    ]
  ])

  managed_group_attachments_map = {
    for a in local.managed_group_attachments :
    "${a.group}|${a.arn}" => a
  }

  # ---------- CUSTOM POLICY ATTACHMENTS (GROUPS) ----------

  # Expand custom policy sets for groups:
  # For each group and each custom_set, attach all policies in that set.
  group_custom_policy_attachments = flatten([
    for group_name, binding in local.groups_bindings : [
      for set_name in binding.custom_sets : [
        for policy_name, policy_def in lookup(var.policies.custom, set_name, {}) : {
          group       = group_name
          set_name    = set_name
          policy_name = policy_name
        }
      ]
    ]
  ])

  group_custom_policy_attachments_map = {
    for a in local.group_custom_policy_attachments :
    "${a.group}|${a.set_name}|${a.policy_name}" => a
  }

  # ---------- MANAGED POLICY ATTACHMENTS (USERS) ----------
  managed_user_attachments = flatten([
    for user_name, binding in local.users_bindings : [
      for set_name in binding.managed_sets : [
        for arn in lookup(var.policies.managed, set_name, []) : {
          user = user_name
          arn  = arn
        }
      ]
    ]
  ])

  managed_user_attachments_map = {
    for a in local.managed_user_attachments :
    "${a.user}|${a.arn}" => a
  }

  # ---------- CUSTOM POLICY ATTACHMENTS (USERS) ----------
  user_custom_policy_attachments = flatten([
    for user_name, binding in local.users_bindings : [
      for set_name in binding.custom_sets : [
        for policy_name, policy_def in lookup(var.policies.custom, set_name, {}) : {
          user        = user_name
          set_name    = set_name
          policy_name = policy_name
        }
      ]
    ]
  ])

  user_custom_policy_attachments_map = {
    for a in local.user_custom_policy_attachments :
    "${a.user}|${a.set_name}|${a.policy_name}" => a
  }
}

# ---------- RESOURCES ----------
resource "aws_iam_policy" "custom" {
  for_each = local.custom_policies_map

  name        = "${each.value.set_name}-${each.value.policy_name}"
  description = each.value.description
  policy      = jsonencode(each.value.document)
}

resource "aws_iam_group_policy_attachment" "managed_groups" {
  for_each = local.managed_group_attachments_map

  group      = each.value.group   # IAM group name (must already exist)
  policy_arn = each.value.arn
}

resource "aws_iam_group_policy_attachment" "custom_groups" {
  for_each = local.group_custom_policy_attachments_map

  group = each.value.group

  policy_arn = aws_iam_policy.custom[
    "${each.value.set_name}|${each.value.policy_name}"
  ].arn
}

resource "aws_iam_user_policy_attachment" "managed_users" {
  for_each = local.managed_user_attachments_map

  user       = each.value.user   # IAM user name (must already exist)
  policy_arn = each.value.arn
}

resource "aws_iam_user_policy_attachment" "custom_users" {
  for_each = local.user_custom_policy_attachments_map

  user = each.value.user

  policy_arn = aws_iam_policy.custom[
    "${each.value.set_name}|${each.value.policy_name}"
  ].arn
}
