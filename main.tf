locals {
  use_filename = var.deployment_mode == "filename"
  use_s3       = var.deployment_mode == "s3"
  use_image    = var.deployment_mode == "image"
}

data "archive_file" "main" {
  count       = local.use_filename || local.use_s3 ? 1 : 0
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "/tmp/${var.project}-${var.environment}-${var.name}.zip"
  excludes = concat(
    [".git", ".terraform", ".gitignore", "iac", "__pycache__"],
    var.additional_archive_excludes
  )
}

resource "aws_s3_object" "main_zip" {
  count  = local.use_s3 ? 1 : 0
  bucket = var.bucket_name
  key    = "lambda-deployments/${var.environment}-${var.name}/${data.archive_file.main[0].output_sha256}.zip"
  source = data.archive_file.main[0].output_path
  etag   = data.archive_file.main[0].output_md5
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.project}-${var.environment}-${var.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "main" {
  function_name    = "${var.project}-${var.environment}-${var.name}"
  role             = var.role_arn
  package_type     = local.use_image ? "Image" : "Zip"
  filename         = local.use_filename ? "/tmp/${var.project}-${var.environment}-${var.name}.zip" : null
  s3_bucket        = local.use_s3 ? var.bucket_name : null
  s3_key           = local.use_s3 ? aws_s3_object.main_zip[0].key : null
  image_uri        = local.use_image ? var.image_uri : null
  source_code_hash = local.use_image ? null : data.archive_file.main[0].output_base64sha256
  handler          = local.use_image ? null : var.handler
  runtime          = local.use_image ? null : var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  layers           = length(var.layers) > 0 ? var.layers : null

  environment {
    variables = var.envars
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && var.security_group_ids != null ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.main,
    aws_s3_object.main_zip
  ]
}

# Schedule job (optional)
resource "aws_cloudwatch_event_rule" "schedule" {
  count               = var.schedule_expression != null ? 1 : 0
  name                = "${var.project}-${var.environment}-${var.name}-lambda"
  description         = "Schedule for Lambda Function"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "schedule" {
  count = var.schedule_expression != null ? 1 : 0
  rule  = aws_cloudwatch_event_rule.schedule[0].name
  arn   = aws_lambda_function.main.arn
}

resource "aws_lambda_permission" "schedule" {
  count         = var.schedule_expression != null ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.id
  principal     = "events.amazonaws.com"
}

# SQS trigger (optional)
resource "aws_lambda_event_source_mapping" "sqs" {
  count                   = var.enable_sqs_trigger ? 1 : 0
  event_source_arn        = var.sqs_queue_arn
  function_name           = aws_lambda_function.main.arn
  batch_size              = var.sqs_batch_size
  function_response_types = ["ReportBatchItemFailures"]
}

# DynamoDB Stream trigger (optional)
resource "aws_lambda_event_source_mapping" "dynamodb" {
  count                   = var.enable_dynamodb_stream_trigger ? 1 : 0
  event_source_arn        = var.dynamodb_stream_arn
  function_name           = aws_lambda_function.main.arn
  batch_size              = var.dynamodb_stream_batch_size
  starting_position       = "LATEST"
  function_response_types = ["ReportBatchItemFailures"]
  dynamic "filter_criteria" {
    for_each = var.dynamodb_stream_filter_pattern != null ? [1] : []
    content {
      filter {
        pattern = var.dynamodb_stream_filter_pattern
      }
    }
  }
}
