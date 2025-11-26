locals {
  # Default tags applied to all IAM users created by the module
  default_tags = {
    environment = "dev"
    account_id  = "000000000000"
    managed_by  = "terraform"
    owner       = "platform-team"
  }

  # IAM model: groups and policy sets
  iam_model = {
    # 1. Groups and their members
    groups = {
      # group1: CLI-only technical users (engine, ci)
      group1 = {
        users = [
          "engine",
          "ci",
        ]
      }

      # group2: full (power) users
      group2 = {
        users = [
          "denys.platon",
          "ivan.petrenko",
        ]
      }
    }

    # 2. Policy sets (logical bundles of policies)
    policies = {
      # Each entry is a named set => list of AWS managed policy ARNs
      managed = {
        # Full (PowerUser) access for group2 "full users"
        managed_policy_full_poweruser = [
          "arn:aws:iam::aws:policy/PowerUserAccess",
        ]
      }
      custom = {
        # Additional CLI baseline permissions for CLI-only group
        cli_baseline_policies = {
          cli-baseline = {
            description = "CLI-only baseline permissions (sts:GetCallerIdentity)"
            document = {
              Version = "2012-10-17"
              Statement = [
                {
                  Effect   = "Allow"
                  Action   = ["sts:GetCallerIdentity"]
                  Resource = "*"
                }
              ]
            }
          }
        }
      }
    }
  }
}
