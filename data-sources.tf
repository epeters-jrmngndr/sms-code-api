data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "external" "deployment_random_id"{
  program = ["python3", "${path.module}/src/gen_id.py"]
}
