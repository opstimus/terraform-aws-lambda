# Lambda Function Module

## Description

This Terraform module deploys an AWS Lambda function along with optional CloudWatch Logs, CloudWatch Events (for scheduling), SQS triggers, and DynamoDB stream triggers. It supports both ZIP-based and container image-based Lambda functions, VPC configuration, and allows extensive configuration options.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 4.0   |
| archive   | >= 2.0   |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

## Inputs

| Name                             | Description                                        | Type          | Default                                     | Required |
|----------------------------------|----------------------------------------------------|---------------|---------------------------------------------|:--------:|
| project                          | Project name                                       | `string`      | `-`                                         | yes      |
| environment                      | Environment name                                   | `string`      | `-`                                         | yes      |
| name                             | Function name                                      | `string`      | `-`                                         | yes      |
| role_arn                         | ARN of the IAM role that the Lambda function assumes | `string`      | `-`                                         | yes      |
| handler                          | Lambda function handler (for ZIP-based functions)  | `string`      | `"lambda_function.lambda_handler"`          | no       |
| runtime                          | Runtime for the Lambda function                    | `string`      | `-`                                         | yes      |
| timeout                          | Maximum execution time for the function (in seconds) | `number`      | `300`                                       | no       |
| memory_size                      | Memory size allocated to the Lambda function (in MB) | `number`      | `128`                                       | no       |
| source_dir                       | Source directory for the Lambda function code      | `string`      | `null`                                      | no       |
| image_uri                        | URI of the container image for the Lambda function | `string`      | `null`                                      | no       |
| envars                           | Environment variables for the Lambda function      | `map(string)` | `{}`                                        | no       |
| log_retention_days               | Number of days to retain logs in CloudWatch        | `number`      | `180`                                       | no       |
| additional_archive_excludes      | Additional patterns to exclude from the archive    | `list(string)`| `[]`                                        | no       |
| schedule_expression              | Cron expression to schedule Lambda invocation      | `string`      | `null`                                      | no       |
| enable_sqs_trigger               | Enable SQS trigger                                 | `bool`        | `false`                                     | no       |
| sqs_queue_arn                    | ARN of the SQS queue to trigger the Lambda function | `string`      | `null`                                      | no       |
| sqs_batch_size                   | SQS batch size for a single Lambda invocation      | `number`      | `10`                                        | no       |
| enable_dynamodb_stream_trigger   | Enable DynamoDB stream trigger                     | `bool`        | `false`                                     | no       |
| dynamodb_stream_arn              | ARN of the DynamoDB stream to trigger the Lambda function | `string`      | `null`                                      | no       |
| dynamodb_stream_batch_size       | DynamoDB stream batch size for a single Lambda invocation | `number`      | `100`                                       | no       |
| dynamodb_stream_filter_pattern   | Filter pattern for the DynamoDB stream             | `string`      | `null`                                      | no       |
| layers                           | List of Lambda layers to attach                    | `list(string)`| `[]`                                        | no       |
| subnet_ids                       | List of subnet IDs for VPC configuration           | `list(string)`| `null`                                      | no       |
| security_group_ids               | List of security group IDs for VPC configuration  | `list(string)`| `null`                                      | no       |

## Outputs

| Name          | Description                        |
|---------------|------------------------------------|
| function_name | The name of the Lambda function    |
| function_arn  | The ARN of the Lambda function     |
| invoke_arn    | The ARN used to invoke the function|

## Usage examples

### Basic Usage

```hcl
module "lambda_function" {
  source             = "github.com/opstimus/terraform-aws-lambda?ref=v<RELEASE>"

  project            = "example-project"
  environment        = "dev"
  name               = "example-function"
  role_arn           = "arn:aws:iam::123456789012:role/lambda-role"
  runtime            = "python3.8"

  # Optional configurations
  log_retention_days = 14
  handler            = "app.handler"
  timeout            = 120
  memory_size        = 256
  envars = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
  }

  # VPC Configuration (optional - both subnet_ids and security_group_ids must be provided together)
  # Note: Lambda execution role must have permissions to create/manage ENIs
  subnet_ids         = ["subnet-12345", "subnet-67890"]
  security_group_ids = ["sg-abc123"]
}
```
