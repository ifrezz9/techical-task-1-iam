
locals {
  # Trust policies (who can assume these roles)
  # Build a Principal AWS list based on external_trust definitions.
  role_assume_policies = {
    for role_name, role_def in local.iam_roles_model.roles :
    role_name => {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = [
              for src in lookup(local.iam_roles_model.external_trust, role_name, []) :
              "arn:aws:iam::${src.account_id}:role/${src.role_name}"
            ]
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  }

  # Data prepared for iam-roles module
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

  # Policy sets for roles module (same structure as in Stage 1/2)
  roles_policies = {
    managed = {}

    # Custom policy sets
    custom = {
      # roleC: access to S3 bucket aws-test-bucket
      roleC_policies = {
        s3-aws-test-bucket-access = {
          description = "Allow access to S3 bucket aws-test-bucket"
          document = {
            Version = "2012-10-17"
            Statement = [
              # Bucket-level permissions (list)
              {
                Effect   = "Allow"
                Action   = [
                  "s3:ListBucket",
                ]
                Resource = "arn:aws:s3:::aws-test-bucket"
              },
              # Object-level permissions (read/write)
              {
                Effect   = "Allow"
                Action   = [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:DeleteObject",
                ]
                Resource = "arn:aws:s3:::aws-test-bucket/*"
              }
            ]
          }
        }
      }
    }
  }

  # Bindings: which policy sets are attached to which roles
  roles_bindings = {
    roles = {
      roleC = {
        managed_sets = []
        custom_sets  = ["roleC_policies"]
      }
    }
  }
}

module "iam_roles" {
  source = "./modules/iam-roles"

  aws_region = "eu-central-1"
  roles      = local.roles_for_module
}

module "iam_role_policies" {
  source = "./modules/iam-role-policies"

  aws_region = "eu-central-1"
  policies   = local.roles_policies
  bindings   = local.roles_bindings

  depends_on = [module.iam_roles]
}
