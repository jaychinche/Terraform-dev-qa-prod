resource "aws_dynamodb_table" "terraform_lock" {
  name           = "${var.env}-infra-app-dyanamodbtable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "${var.env}"
  }
}