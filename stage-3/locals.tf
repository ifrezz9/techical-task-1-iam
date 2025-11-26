locals {
  iam_roles_model = {
    # Roles in account 1111111111
    roles = {
      roleC = {
        description          = "Service role with access to S3 bucket aws-test-bucket"
        path                 = "/"
        max_session_duration = 3600
      }
    }

    # External principals that are allowed to assume local roles
    # Here: roleB from account 000000000000 can assume roleC.
    external_trust = {
      roleC = [
        {
          account_id = "000000000000"
          role_name  = "roleB"
        }
      ]
    }
  }

  # Default tags for IAM roles in account 1111111111
  default_role_tags = {
    environment = "dev"
    account_id  = "1111111111"
    managed_by  = "terraform"
    owner       = "platform-team"
  }
}
