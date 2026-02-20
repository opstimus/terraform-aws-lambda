# Lambda Function Module

## Description

This Terraform module deploys an AWS Lambda function along with optional CloudWatch Logs, CloudWatch Events (for scheduling), SQS triggers, and DynamoDB stream triggers. It supports three deployment modes: local ZIP files, S3-based deployment packages, and container images. It also supports VPC configuration and extensive customization options.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 6.0   |
| archive   | >= 2.0   |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 6.0  |

## Inputs

| Name                             | Description                                        | Type          | Default                                     | Required |
|----------------------------------|----------------------------------------------------|---------------|---------------------------------------------|:--------:|
| project                          | Project name                                       | `string`      | `-`                                         | yes      |
| environment                      | Environment name                                   | `string`      | `-`                                         | yes      |
| name                             | Function name                                      | `string`      | `-`                                         | yes      |
| role_arn                         | ARN of the IAM role that the Lambda function assumes | `string`      | `-`                                         | yes      |
| deployment_mode                  | Deployment mode for the Lambda function ('filename', 's3', or 'image') | `string`      | `"filename"`                               | no       |
| bucket_name                      | S3 bucket name for deployment package (required if deployment_mode is 's3') | `string`      | `null`                                      | no       |
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

### Basic Usage (Local ZIP File)

```hcl
module "lambda_function" {
  source             = "github.com/opstimus/terraform-aws-lambda?ref=v<RELEASE>"
  project            = "example-project"
  environment        = "dev"
  name               = "example-function"
  role_arn           = "arn:aws:iam::123456789012:role/lambda-role"
  runtime            = "python3.8"
  deployment_mode    = "filename"
  source_dir         = "./lambda_code"

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

### S3 Deployment

```hcl
module "lambda_function" {
  source             = "github.com/opstimus/terraform-aws-lambda?ref=v<RELEASE>"
  project            = "example-project"
  environment        = "dev"
  name               = "example-function"
  role_arn           = "arn:aws:iam::123456789012:role/lambda-role"
  runtime            = "python3.8"
  deployment_mode    = "s3"
  bucket_name        = "my-lambda-deployments"
  source_dir         = "./lambda_code"
  handler            = "app.handler"
  timeout            = 120
  memory_size        = 256
}
```

### Container Image Deployment

```hcl
module "lambda_function" {
  source             = "github.com/opstimus/terraform-aws-lambda?ref=v<RELEASE>"
  project            = "example-project"
  environment        = "dev"
  name               = "example-function"
  role_arn           = "arn:aws:iam::123456789012:role/lambda-role"
  deployment_mode    = "image"
  image_uri          = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-lambda:latest"
  timeout            = 120
  memory_size        = 256
}
```

## Important Considerations

### Deployment Mode Considerations

- **filename** (default): Use this for local development and smaller Lambda functions. The module automatically creates a ZIP archive from your source directory. Best for rapid iteration.
- **s3**: Use this for CI/CD pipelines and larger deployments. The module creates a ZIP archive and uploads it to your S3 bucket, then deploys from S3. Provides better versioning and sharing capabilities.
- **image**: Use this for containerized Lambda functions. When using this mode, `handler` and `runtime` parameters are not required and will be ignored. The container image must be pushed to ECR beforehand.

### S3 Deployment Details

- The S3 bucket specified in `bucket_name` must already exist and be accessible from your AWS account.
- The module will automatically create a ZIP archive from your source directory and upload it to the bucket under the path: `lambda-deployments/{environment}-{name}/{sha256_hash}.zip`
- The SHA256 hash ensures different versions of your code are tracked separately in S3, enabling safe rollbacks and version management.
- Ensure your IAM role has `s3:PutObject` permissions on the specified bucket.

### Source Directory Requirements

- For `filename` (ZIP) and `s3` deployment modes, `source_dir` is required and must point to a valid directory containing your Lambda function code.
- The following patterns are automatically excluded from the archive: `.git`, `.terraform`, `.gitignore`, `iac`, and `__pycache__`.
- Additional exclusion patterns can be specified using the `additional_archive_excludes` parameter (e.g., `node_modules`, `.env` files, test directories).
- For `image` mode, `source_dir` should be omitted or set to `null` as the code is already packaged in the container image.
