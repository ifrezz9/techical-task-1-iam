variable "aws_region" {
  description = "AWS region for the provider (IAM is global, but a region is still required)."
  type        = string
  default     = "eu-central-1"
}

variable "groups" {
  description = "Map of IAM groups and their member users."
  type = map(object({
    path  = optional(string, "/")
    users = optional(set(string), [])
  }))
}

variable "default_user_force_destroy" {
  description = "Whether to force-destroy IAM users on deletion (removes access keys, login profile, etc.)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Default tags to apply to all IAM users."
  type        = map(string)
  default     = {}
}
