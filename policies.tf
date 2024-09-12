resource "aws_iam_policy" "lambda_policy" {
  name        = "${data.aws_region.current.name}-smsnotification-policy"
  path        = "/"
  description = "IAM policy to grant to the Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "sns:Publish",
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      "Resource": [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*",
        "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
        "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.phone_numbers.name}"

      ],
      "Effect": "Allow"
    },
    {
       "Effect": "Allow",
       "Action": "SNS:Publish",
       "Resource": [
         "*"
       ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
