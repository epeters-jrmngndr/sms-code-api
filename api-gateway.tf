# Configure the API gateway account
resource "aws_api_gateway_account" "account_settings" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
  depends_on = [
    aws_iam_role_policy_attachment.api_gateway_cloudwatch_logs_policy
  ]
}

resource "aws_api_gateway_rest_api" "sms-api" {
  name        = "smsnotification"
  description = "API Gateway for SMS notification"
}

resource "aws_api_gateway_resource" "sms" {
  rest_api_id = aws_api_gateway_rest_api.sms-api.id
  parent_id   = aws_api_gateway_rest_api.sms-api.root_resource_id
  path_part   = "sms"
}

resource "aws_api_gateway_method" "post_sms" {
  rest_api_id   = aws_api_gateway_rest_api.sms-api.id
  resource_id   = aws_api_gateway_resource.sms.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_post_sms" {
  rest_api_id             = aws_api_gateway_rest_api.sms-api.id
  resource_id             = aws_api_gateway_resource.sms.id
  http_method             = aws_api_gateway_method.post_sms.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource "aws_api_gateway_deployment" "sms-api-deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_post_sms
  ]
  rest_api_id = aws_api_gateway_rest_api.sms-api.id
}

resource "aws_api_gateway_stage" "sms-api-gateway-stage" {
  deployment_id = aws_api_gateway_deployment.sms-api-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.sms-api.id
  stage_name    = "prod"
  description   = "Production stage"
}
