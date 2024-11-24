# IAM Role for Lambda Functions
resource "aws_iam_role" "lambda_role" {
  name = "lambda_basic_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function 1
resource "aws_lambda_function" "group1Function1" {
  function_name = "group1Function1"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "group1Function1.zip"
  architectures = ["x86_64"]
  memory_size   = 128
  publish       = true
}

# Lambda Function 2
resource "aws_lambda_function" "group1Function2" {
  function_name = "group1Function2"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "group1Function2.zip"
  architectures = ["x86_64"]
  memory_size   = 128
  publish       = true
}

# Alias for Lambda Functions
resource "aws_lambda_alias" "group1Function1_dev" {
  name             = "dev"
  function_name    = aws_lambda_function.group1Function1.arn
  function_version = aws_lambda_function.group1Function1.version
}

resource "aws_lambda_alias" "group1Function1_prod" {
  name             = "prod"
  function_name    = aws_lambda_function.group1Function1.arn
  function_version = 2
}

resource "aws_lambda_alias" "group1Function2_dev" {
  name             = "dev"
  function_name    = aws_lambda_function.group1Function2.arn
  function_version = aws_lambda_function.group1Function2.version
}

resource "aws_lambda_alias" "group1Function2_prod" {
  name             = "prod"
  function_name    = aws_lambda_function.group1Function2.arn
  function_version = 2
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "example" {
  name = "group1-api"
}

# Resources for first_names and last_names
resource "aws_api_gateway_resource" "first_names" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "group_name/first_names"
}

resource "aws_api_gateway_resource" "last_names" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "group_name/last_names"
}

# Methods for first_names
resource "aws_api_gateway_method" "get_dev_first_names" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.first_names.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_prod_first_names" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.first_names.id
  http_method   = "GET"
  authorization = "NONE"
}

# Methods for last_names
resource "aws_api_gateway_method" "get_dev_last_names" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.last_names.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_prod_last_names" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.last_names.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrations for first_names
resource "aws_api_gateway_integration" "dev_first_names_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.first_names.id
  http_method             = aws_api_gateway_method.get_dev_first_names.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.group1Function1_dev.invoke_arn
}

resource "aws_api_gateway_integration" "prod_first_names_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.first_names.id
  http_method             = aws_api_gateway_method.get_prod_first_names.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.group1Function1_prod.invoke_arn
}

# Integrations for last_names
resource "aws_api_gateway_integration" "dev_last_names_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.last_names.id
  http_method             = aws_api_gateway_method.get_dev_last_names.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.group1Function2_dev.invoke_arn
}

resource "aws_api_gateway_integration" "prod_last_names_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.last_names.id
  http_method             = aws_api_gateway_method.get_prod_last_names.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.group1Function2_prod.invoke_arn
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  # Forces a new deployment when integrations or methods change
  triggers = {
    redeployment = sha1(jsonencode({
      methods = [
        aws_api_gateway_method.get_dev_first_names.id,
        aws_api_gateway_method.get_prod_first_names.id,
        aws_api_gateway_method.get_dev_last_names.id,
        aws_api_gateway_method.get_prod_last_names.id,
      ]
    }))
  }
}

# API Gateway Stages
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "prod"
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "dev"
}
