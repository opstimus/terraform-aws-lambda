variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "name" {
  type        = string
  description = "Secret name | i.e mail-password"
}

variable "role_arn" {
  type = string
}

variable "handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  type = string
}

variable "timeout" {
  type    = number
  default = 300
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "source_dir" {
  type    = string
  default = null
}

variable "image_uri" {
  type    = string
  default = null
}

variable "envars" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the Lambda function"
}

variable "log_retention_days" {
  type    = number
  default = 180
}

variable "additional_archive_excludes" {
  type        = list(string)
  default     = []
  description = "Additional patterns to exclude from the archive"
}