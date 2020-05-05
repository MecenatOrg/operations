terraform {
  experiments = [variable_validation]
}

variable domain {
  type        = string
  description = "domain for certificate sign"
  validation {
    condition = length(split(".",var.domain)) > 0
    error_message = "Enter valid domain name."
  }
}

variable tags {
  type        = map
  description = "tags to attach for each resource"
  default     = {}
}

variable "sld" {
  default = false
  type = bool
  description = "does the domain include second level domain. Default is false" 
} 
variable alt_domains {
  type        = list(string)
  description = "extra domains for certificate. can be in wildcard form or other"
  default     = []
}
