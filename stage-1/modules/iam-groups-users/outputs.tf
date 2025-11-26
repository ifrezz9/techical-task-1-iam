output "iam_users" {
  description = "All IAM user names created by this module."
  value       = sort([for u in local.all_users : u])
}

output "iam_groups" {
  description = "All IAM group names created by this module."
  value       = sort([for g_name in keys(local.groups_normalized) : g_name])
}

output "memberships" {
  description = "All group-to-user memberships."
  value = [
    for m in local.memberships : {
      group = m.group
      user  = m.user
    }
  ]
}
