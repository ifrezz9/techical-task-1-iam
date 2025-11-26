variable "aws_region" {
  description = "AWS region (IAM is global, provider still needs region)."
  type        = string
  default     = "eu-central-1"
}

variable "policies" {
  description = "Policy sets definition (managed + custom) for roles."
  type = object({
    managed = map(list(string))
    custom  = map(map(object({
      description = optional(string, "")
      document    = any
    })))
  })
}

variable "bindings" {
  description = "Bindings of policy sets to IAM roles."
  type = object({
    roles = map(object({
      managed_sets = optional(list(string), [])
      custom_sets  = optional(list(string), [])
    }))
  })
}
