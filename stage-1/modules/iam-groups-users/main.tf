locals {
  groups_normalized = {
    for g_name, g in var.groups : g_name => {
      path  = coalesce(g.path, "/")
      users = coalesce(g.users, [])
    }
  }

  all_users = toset(flatten([
    for g_name, g in local.groups_normalized : tolist(g.users)
  ]))

  memberships = flatten([
    for g_name, g in local.groups_normalized : [
      for user in g.users : {
        group = g_name
        user  = user
      }
    ]
  ])
}

resource "aws_iam_user" "this" {
  for_each = local.all_users

  name          = each.value
  force_destroy = var.default_user_force_destroy
  tags          = var.tags
}

resource "aws_iam_group" "this" {
  for_each = local.groups_normalized

  name = each.key
  path = each.value.path
}

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for m in local.memberships : "${m.user}|${m.group}" => m
  }

  user   = aws_iam_user.this[each.value.user].name
  groups = [aws_iam_group.this[each.value.group].name]
}
