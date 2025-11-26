output "custom_role_policy_arns" {
  description = "All custom IAM policies created for roles."
  value       = { for k, p in aws_iam_policy.custom : k => p.arn }
}
