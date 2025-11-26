locals {
  roles_normalized = {
    for name, r in var.roles :
    name => {
      description          = coalesce(r.description, "")
      path                 = coalesce(r.path, "/")
      max_session_duration = coalesce(r.max_session_duration, 3600)
      assume_role_policy   = r.assume_role_policy
      tags                 = coalesce(r.tags, {})
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = local.roles_normalized

  name                 = each.key
  description          = each.value.description
  path                 = each.value.path
  max_session_duration = each.value.max_session_duration

  assume_role_policy = jsonencode(each.value.assume_role_policy)

  tags = each.value.tags
}
