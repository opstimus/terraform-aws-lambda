data "archive_file" "main" {
  count       = var.source_dir != null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "/tmp/${var.project}-${var.environment}-${var.name}.zip"
  excludes = concat(
    [".git", ".terraform", ".gitignore", "iac", "__pycache__"],
    var.additional_archive_excludes
  )
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.project}-${var.environment}-${var.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "main" {
  function_name = "${var.project}-${var.environment}-${var.name}"
  role          = var.role_arn
  filename      = var.source_dir != null ? "/tmp/${var.project}-${var.environment}-${var.name}.zip" : null
  image_uri     = var.image_uri != null ? var.image_uri : null
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  source_code_hash = var.source_dir != null ? data.archive_file.main[0].output_base64sha256 : null

  environment {
    variables = var.envars
  }

  depends_on = [
    aws_cloudwatch_log_group.main
  ]
}

resource "aws_iam_role" "scheduler_execution_role" {
  count = var.schedule_expression != null ? 1 : 0
  name  = "${var.project}-${var.environment}-${var.name}-scheduler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })

  inline_policy {
    name = "${var.project}-${var.environment}-${var.name}-scheduler"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = "lambda:InvokeFunction",
          Resource = aws_lambda_function.main.arn
        },
      ]
    })
  }
}


resource "aws_scheduler_schedule" "main" {
  count      = var.schedule_expression != null ? 1 : 0
  name       = "${var.project}-${var.environment}-${var.name}-lambda"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_expression

  target {
    arn      = aws_lambda_function.main.arn
    role_arn = aws_iam_role.scheduler_execution_role[0].arn
  }
}
