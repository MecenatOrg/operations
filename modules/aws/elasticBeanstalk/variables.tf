

variable "application" {
  type = object({
    name        = string
    description = string
  })
}
variable "environment" {
  type = object({
    name                = string
    solution_stack_name = string
  })
}