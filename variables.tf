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
  description = "Function name"
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

variable "schedule_expression" {
  type        = string
  default     = null
  description = "Define if Lambda should be invoked in a schedule"
}

variable "enable_sqs_trigger" {
  type        = bool
  default     = false
  description = "Enable SQS trigger"
}

variable "sqs_queue_arn" {
  type        = string
  default     = null
  description = "SQS queue arn to enable SQS trigger"
}

variable "sqs_batch_size" {
  type        = number
  default     = 10
  description = "SQS batch size for a single Lambda invocation"
}

variable "enable_dynanodb_stream_trigger" {
  type        = bool
  default     = false
  description = "Enable DynamoDB stream trigger"
}

variable "dynamodb_stream_arn" {
  type    = string
  default = null
}

variable "dynamodb_stream_batch_size" {
  type    = number
  default = 100
}

variable "dynamodb_stream_filter_pattern" {
  type    = string
  default = null
}

variable "layers" {
  type    = list(string)
  default = []
}
