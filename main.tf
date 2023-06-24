resource "aws_dynamodb_table" "Dev_Dynamo" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }
}

# Create S3 bucket to store our application source code.
resource "aws_s3_bucket" "Dev_s3" {
  bucket = var.code_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket_public_access" {
  bucket = aws_s3_bucket.Dev_s3.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Initialize module containing IAM policies.
module "iam_policies" {
  source = "./tf-modules/iam-policies"
  table_name = aws_dynamodb_table.Dev_Dynamo.name
}

## Update Product Lambda
module "update_product_lambda" {
  source = "./tf-modules/lambda-function"
  lambda_bucket_id = aws_s3_bucket.Dev_s3.id
  publish_dir = "${path.module}/../build/updateproduct"
  zip_file = "updateproduct.zip"
  function_name = "updateproduct"
  lambda_handler = "updateproduct"
  environment_variables = {
    "product_TABLE_NAME" = aws_dynamodb_table.Dev_Dynamo.name
  }
}

module "update_product_lambda_api" {
  source = "./tf-modules/api-gateway-lambda-integration"
  api_id = module.product_api_gateway.api_id
  api_arn = module.product_api_gateway.api_arn
  function_arn = module.update_product_lambda.function_arn
  function_name = module.update_product_lambda.function_name
  http_method = "PUT"
  route = "/"
}

resource "aws_iam_role_policy_attachment" "update_product_lambda_dynamo_db_write" {
  role       = module.update_product_lambda.function_role_name
  policy_arn = module.iam_policies.dynamo_db_write
}

resource "aws_iam_role_policy_attachment" "update_product_lambda_dynamo_db_read" {
  role       = module.update_product_lambda.function_role_name
  policy_arn = module.iam_policies.dynamo_db_read
}

resource "aws_iam_role_policy_attachment" "update_product_lambda_cw_metrics" {
  role       = module.update_product_lambda.function_role_name
  policy_arn = module.iam_policies.cloud_watch_put_metrics
}

# Create Product Lambda
module "create_product_lambda" {
  source = "./tf-modules/lambda-function"
  lambda_bucket_id = aws_s3_bucket.Dev_s3.id
  publish_dir = "${path.module}/../build/createproduct"
  zip_file = "createproduct.zip"
  function_name = "createproduct"
  lambda_handler = "createproduct"
  environment_variables = {
    "product_TABLE_NAME" = aws_dynamodb_table.Dev_Dynamo.name
  }
}

module "create_product_lambda_api" {
  source = "./tf-modules/api-gateway-lambda-integration"
  api_id = module.product_api_gateway.api_id
  api_arn = module.product_api_gateway.api_arn
  function_arn = module.create_product_lambda.function_arn
  function_name = module.create_product_lambda.function_name
  http_method = "POST"
  route = "/"
}

resource "aws_iam_role_policy_attachment" "create_product_lambda_dynamo_db_write" {
  role       = module.create_product_lambda.function_role_name
  policy_arn = module.iam_policies.dynamo_db_write
}

resource "aws_iam_role_policy_attachment" "create_product_lambda_cw_metrics" {
  role       = module.create_product_lambda.function_role_name
  policy_arn = module.iam_policies.cloud_watch_put_metrics
}

# Get Product Lambda
module "get_product_lambda" {
  source = "./tf-modules/lambda-function"
  lambda_bucket_id = aws_s3_bucket.Dev_s3.id
  publish_dir = "${path.module}/../build/getproduct"
  zip_file = "getproduct.zip"
  function_name = "getproduct"
  lambda_handler = "getproduct"
  environment_variables = {
    "PROJECT_TABLE_NAME" = aws_dynamodb_table.Dev_Dynamo.name
  }
}

module "get_product_lambda_api" {
  source = "./tf-modules/api-gateway-lambda-integration"
  api_id = module.product_api_gateway.api_id
  api_arn = module.product_api_gateway.api_arn
  function_arn = module.get_product_lambda.function_arn
  function_name = module.get_product_lambda.function_name
  http_method = "GET"
  route = "/{partitionKey}"
}

resource "aws_iam_role_policy_attachment" "get_product_lambda_dynamo_db_read" {
  role       = module.get_product_lambda.function_role_name
  policy_arn = module.iam_policies.dynamo_db_read
}

resource "aws_iam_role_policy_attachment" "get_product_lambda_cw_metrics" {
  role       = module.get_product_lambda.function_role_name
  policy_arn = module.iam_policies.cloud_watch_put_metrics
}

# Get all products Lambda
module "get_products_lambda" {
  source = "./tf-modules/lambda-function"
  lambda_bucket_id = aws_s3_bucket.Dev_s3.id
  publish_dir = "${path.module}/../build/getproducts"
  zip_file = "getproducts.zip"
  function_name = "getproducts"
  lambda_handler = "getproducts"
  environment_variables = {
    "product_TABLE_NAME" = aws_dynamodb_table.Dev_Dynamo.name
  }
}

module "get_products_lambda_api" {
  source = "./tf-modules/api-gateway-lambda-integration"
  api_id = module.product_api_gateway.api_id
  api_arn = module.product_api_gateway.api_arn
  function_arn = module.get_products_lambda.function_arn
  function_name = module.get_products_lambda.function_name
  http_method = "GET"
  route = "/"
}

resource "aws_iam_role_policy_attachment" "get_products_lambda_dynamo_db_read" {
  role       = module.get_products_lambda.function_role_name
  policy_arn = module.iam_policies.dynamo_db_read
}

resource "aws_iam_role_policy_attachment" "get_products_lambda_cw_metrics" {
  role       = module.get_products_lambda.function_role_name
  policy_arn = module.iam_policies.cloud_watch_put_metrics
}

## Delete Project lambda
module "delete_product_lambda" {
  source = "./tf-modules/lambda-function"
  lambda_bucket_id = aws_s3_bucket.Dev_s3.id
  publish_dir = "${path.module}/../build/deleteproduct"
  zip_file = "deleteproduct.zip"
  function_name = "deleteproduct"
  lambda_handler = "deleteproduct"
  environment_variables = {
    "product_TABLE_NAME" = aws_dynamodb_table.Dev_Dynamo.name
  }
}

module "delete_product_lambda_api" {
  source = "./tf-modules/api-gateway-lambda-integration"
  api_id = module.product_api_gateway.api_id
  api_arn = module.product_api_gateway.api_arn
  function_arn = module.delete_product_lambda.function_arn
  function_name = module.delete_product_lambda.function_name
  http_method = "DELETE"
  route = "/{partitionKey}"
}

resource "aws_iam_role_policy_attachment" "delete_product_lambda_dynamo_db_delete" {
  role       = module.delete_product_lambda.function_role_name
  policy_arn = module.iam_policies.dynamo_db_delete
}

resource "aws_iam_role_policy_attachment" "delete_product_lambda_dynamo_db_read" {
  role       = module.delete_product_lambda.function_role_name
  policy_arn = module.iam_policies.dynamo_db_read
}

resource "aws_iam_role_policy_attachment" "delete_product_lambda_cw_metrics" {
  role       = module.delete_product_lambda.function_role_name
  policy_arn = module.iam_policies.cloud_watch_put_metrics
}


module "product_api_gateway" {
  source = "./tf-modules/api-gateway"
  api_name = "implant-wise-product-api"
  stage_name = "dev"
  stage_auto_deploy = true
}

    #------------------------------------------------------

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  default     = "my-user-pool"
}

variable "admin_group_name" {
  description = "Name of the Cognito admin user group"
  default     = "AdminUser"
}

variable "standard_group_name" {
  description = "Name of the Cognito standard user group"
  default     = "StandardUser"
}

module "cognito" {
  source = "./tf-modules/cognito"

  user_pool_name     = var.user_pool_name
  admin_group_name   = var.admin_group_name
  standard_group_name = var.standard_group_name
}

module "api_gateway_endpoints" {
  source = "./tf-modules/restricting-api-methods"

  api_name               = "my-api"
  cognito_user_pool_id   = "your-cognito-user-pool-id"
  admin_group_name       = "AdminUsers"
  standard_group_name    = "StandardUsers"
}