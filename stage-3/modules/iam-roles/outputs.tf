output "role_arns" {
  description = "ARNs of created IAM roles."
  value       = { for name, r in aws_iam_role.this : name => r.arn }
}
