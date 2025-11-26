output "custom_policy_arns" {
  description = "All custom IAM policies created by this module (keyed by set_name|policy_name)."
  value       = { for k, p in aws_iam_policy.custom : k => p.arn }
}
