variable "aws_region" {
  description = "AWS region for the provider (IAM is global, but a region is still required)."
  type        = string
  default     = "eu-central-1"
}

variable "policies" {
  description = "Policy sets definition (managed + custom)."

  type = object({
    managed = map(list(string))

    custom = map(map(object({
      description = optional(string, "")
      document    = any
    })))
  })
}

variable "bindings" {
  description = "Bindings of policy sets to IAM groups and IAM users."
  type = object({
    groups = map(object({
      managed_sets = optional(list(string), [])
      custom_sets  = optional(list(string), [])
    }))

    users = optional(map(object({
      managed_sets = optional(list(string), [])
      custom_sets  = optional(list(string), [])
    })), {})
  })
}
