
locals {
  iam_roles_model = {
    # Roles in account 000000000000
    roles = {
      roleA = {
        description          = "Admin role with access to all services except IAM"
        path                 = "/"
        max_session_duration = 3600
      }

      roleB = {
        description          = "Service role that can assume roleC in external account 1111111111"
        path                 = "/"
        max_session_duration = 3600
      }
    }

    # External roles that local roles are allowed to assume - (used to build sts:AssumeRole permission policies)
    external_assume = {
      # roleB can assume roleC in account 1111111111
      roleB = [
        {
          account_id = "1111111111"
          role_name  = "roleC"
        }
      ]
    }
  }

  # Default tags for IAM roles
  default_role_tags = {
    environment = "dev"
    account_id  = "000000000000"
    managed_by  = "terrafrom"
    owner       = "platform-team"
  }
}
