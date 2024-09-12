resource "aws_lambda_function" "lambda" {
  filename      = "lambda.zip"
  function_name = "sms-notification"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x" # I upgrade this to nodejs20
  timeout       = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.phone_numbers.name
    }
  }

  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_lambda_permission" "allow_apigateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.sms-api.id}/*/*/sms"
}
