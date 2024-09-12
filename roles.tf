# Create a role for the SMS Lambda to assume
resource "aws_iam_role" "lambda_iam" {
  name = "${data.aws_region.current.name}-smsnotification-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create a role for CloudWatch to assume
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name               = "api-gateway-cloudwatch-logs-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the cloudwatch role
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_logs_policy" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
