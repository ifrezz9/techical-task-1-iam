variable "aws_region" {
  description = "AWS region (IAM is global, provider still needs region)"
  type        = string
  default     = "eu-central-1"
}

variable "roles" {
  description = "Map of IAM roles to create."
  type = map(object({
    description          = optional(string, "")
    path                 = optional(string, "/")
    max_session_duration = optional(number, 3600)
    assume_role_policy   = any
    tags                 = optional(map(string), {})
  }))
}
