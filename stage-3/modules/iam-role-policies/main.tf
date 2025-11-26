locals {
  # Normalize bindings
  roles_bindings = {
    for r_name, b in var.bindings.roles :
    r_name => {
      managed_sets = coalesce(b.managed_sets, [])
      custom_sets  = coalesce(b.custom_sets, [])
    }
  }

  # Flatten custom policy sets
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

  custom_policies_map = {
    for p in local.custom_policies_flat :
    "${p.set_name}|${p.policy_name}" => p
  }

  # Managed policy attachments to roles
  managed_role_attachments = flatten([
    for role_name, binding in local.roles_bindings : [
      for set_name in binding.managed_sets : [
        for arn in lookup(var.policies.managed, set_name, []) : {
          role = role_name
          arn  = arn
        }
      ]
    ]
  ])

  managed_role_attachments_map = {
    for a in local.managed_role_attachments :
    "${a.role}|${a.arn}" => a
  }

  # Custom policy attachments to roles
  role_custom_policy_attachments = flatten([
    for role_name, binding in local.roles_bindings : [
      for set_name in binding.custom_sets : [
        for policy_name, policy_def in lookup(var.policies.custom, set_name, {}) : {
          role        = role_name
          set_name    = set_name
          policy_name = policy_name
        }
      ]
    ]
  ])

  role_custom_policy_attachments_map = {
    for a in local.role_custom_policy_attachments :
    "${a.role}|${a.set_name}|${a.policy_name}" => a
  }
}

resource "aws_iam_policy" "custom" {
  for_each = local.custom_policies_map

  name        = "${each.value.set_name}-${each.value.policy_name}"
  description = each.value.description
  policy      = jsonencode(each.value.document)
}

resource "aws_iam_role_policy_attachment" "managed_roles" {
  for_each = local.managed_role_attachments_map

  role       = each.value.role
  policy_arn = each.value.arn
}

resource "aws_iam_role_policy_attachment" "custom_roles" {
  for_each = local.role_custom_policy_attachments_map

  role = each.value.role

  policy_arn = aws_iam_policy.custom[
    "${each.value.set_name}|${each.value.policy_name}"
  ].arn
}
