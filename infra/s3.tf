resource "aws_s3_bucket" "remote_s3" {
    bucket = "${var.env}-infra-app-bucket-jay"
    tags = {
      Enviroment =var.env
    }
}