locals {
  bindings = {
    groups = {
      # group1 (CLI-only users) - only custom CLI baseline policy set
      group1 = {
        managed_sets = []
        custom_sets  = [
          "cli_baseline_policies",
        ]
      }

      # group2 (full users) - AWS managed PowerUserAccess
      group2 = {
        managed_sets = [
          "managed_policy_full_poweruser",
        ]
        custom_sets = []
      }
    }

    # No direct user bindings for stage 1
    users = {}
  }
}

module "iam_groups_users" {
  source = "./modules/iam-groups-users"

  aws_region = var.aws_region

  # Pass down the groups and their users from the IAM model
  groups = {
    for group_name, g in local.iam_model.groups :
    group_name => {
      users = toset(g.users)
    }
  }

  default_user_force_destroy = true

  tags = local.default_tags
}

module "iam_policies_bindings" {
  source = "./modules/iam-policies-bindings"

  aws_region = var.aws_region

  policies   = local.iam_model.policies
  bindings   = local.bindings
  depends_on = [module.iam_groups_users]
}
