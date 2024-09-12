resource "aws_dynamodb_table" "phone_numbers" {
  name           = "phone-numbers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "phone_number"

  attribute {
    name = "phone_number"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}
