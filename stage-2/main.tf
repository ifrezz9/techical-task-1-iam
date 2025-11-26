locals {
  role_assume_policies = {
    for role_name, role_def in local.iam_roles_model.roles :
    role_name => {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::000000000000:root"
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  }

  roles_for_module = {
    for role_name, role_def in local.iam_roles_model.roles :
    role_name => {
      description          = lookup(role_def, "description", "")
      path                 = lookup(role_def, "path", "/")
      max_session_duration = lookup(role_def, "max_session_duration", 3600)
      assume_role_policy   = local.role_assume_policies[role_name]
      tags                 = local.default_role_tags
    }
  }

  roles_policies = {
    managed = {}

    # Custom policy sets
    custom = {
      # RoleA: admin everywhere except IAM
      roleA_policies = {
        admin-without-iam = {
          description = "Admin permissions for all AWS services except IAM"
          document = {
            Version = "2012-10-17"
            Statement = [
              {
                Effect    = "Allow"
                NotAction = "iam:*"
                Resource  = "*"
              }
            ]
          }
        }
      }

      # RoleB: sts:AssumeRole into roleC in 1111111111
      roleB_policies = {
        assume-roleC-1111111111 = {
          description = "Allow sts:AssumeRole into roleC in account 1111111111"
          document = {
            Version = "2012-10-17"
            Statement = [
              for target in lookup(local.iam_roles_model.external_assume, "roleB", []) : {
                Effect = "Allow"
                Action = ["sts:AssumeRole"]
                Resource = "arn:aws:iam::${target.account_id}:role/${target.role_name}"
              }
            ]
          }
        }
      }
    }
  }

  roles_bindings = {
    roles = {
      roleA = {
        managed_sets = []
        custom_sets  = ["roleA_policies"]
      }
      roleB = {
        managed_sets = []
        custom_sets  = ["roleB_policies"]
      }
    }
  }
}

module "iam_roles" {
  source = "./modules/iam-roles"

  aws_region = var.aws_region
  roles      = local.roles_for_module
}

module "iam_role_policies" {
  source = "./modules/iam-role-policies"

  aws_region = var.aws_region  
  policies   = local.roles_policies
  bindings   = local.roles_bindings

  depends_on = [module.iam_roles]
}
