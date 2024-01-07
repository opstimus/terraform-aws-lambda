# Lambda Deployment Module

## Description
This Terraform module deploys a Lambda function with optional triggers for AWS CloudWatch schedule and SQS queue. It includes resources for CloudWatch log group, Lambda function, and event source mapping.

## Requirements

| Name     | Version |
|----------|---------|
| terraform| >= 1.3.0|
| aws      | >= 4.0  |
| archive  | >= 2.0  |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

## Inputs

| Name                       | Description                                       | Type        | Default                            | Required |
|----------------------------|---------------------------------------------------|-------------|------------------------------------|:--------:|
| project                    | Project name                                      | `string`    | -                                  | yes      |
| environment                | Environment name                                  | `string`    | -                                  | yes      |
| name                       | Function name                                     | `string`    | -                                  | yes      |
| role_arn                   | ARN of IAM role for Lambda function               | `string`    | -                                  | yes      |
| handler                    | Lambda function handler                           | `string`    | `"lambda_function.lambda_handler"` | no       |
| runtime                    | Runtime for the Lambda function                   | `string`    | -                                  | yes      |
| timeout                    | Timeout for the Lambda function                   | `number`    | `300`                              | no       |
| memory_size                | Memory size for the Lambda function               | `number`    | `128`                              | no       |
| source_dir                 | Source directory for the Lambda function          | `string`    | `null`                             | no       |
| image_uri                  | URI of the Lambda function's container image      | `string`    | `null`                             | no       |
| envars                     | Environment variables for the Lambda function     | `map(string)` | `{}`                             | no       |
| log_retention_days         | Number of days to retain CloudWatch logs          | `number`    | `180`                              | no       |
| additional_archive_excludes| Additional patterns to exclude from the archive   | `list(string)` | `[]`                            | no       |
| schedule_expression        | Schedule expression for Lambda invocation         | `string`    | `null`                             | no       |
| sqs_queue_arn              | SQS queue ARN for triggering the Lambda function  | `string`    | `null`                             | no       |

## Outputs

| Name          | Description                           |
|---------------|---------------------------------------|
| function_name | The name of the deployed Lambda function |
| function_arn  | The ARN of the deployed Lambda function |
| invoke_arn    | The invocation ARN of the Lambda function |

## Usage examples

### Basic Lambda Deployment
```hcl
module "lambda_deployment" {
  source = "github.com/opstimus/terraform-aws-lambda?ref=vN.N.N"

  project     = "example_project"
  environment = "production"
  name        = "example_function"
  role_arn    = "arn:aws:iam::123456789012:role/example_role"
  runtime     = "python3.8"
  handler     = "index.handler"
}
```

### Lambda with CloudWatch Schedule
```hcl
module "lambda_scheduled" {
  source = "github.com/opstimus/terraform-aws-lambda?ref=vN.N.N"

  project             = "example_project"
  environment         = "production"
  name                = "scheduled_function"
  role_arn            = "arn:aws:iam::123456789012:role/example_role"
  runtime             = "python3.8"
  schedule_expression = "rate(1 day)"
}
```

### Lambda with SQS Trigger
```hcl
module "lambda_sqs_trigger" {
  source = "github.com/opstimus/terraform-aws-lambda?ref=vN.N.N"

  project       = "example_project"
  environment   = "production"
  name          = "sqs_triggered_function"
  role_arn      = "arn:aws:iam::123456789012:role/example_role"
  runtime       = "python3.8"
  sqs_queue_arn = "arn:aws:sqs:us-west-2:123456789012:example_queue"
}
```
