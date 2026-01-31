output "dynamodb_table_name" {
  description = "Name of DynamoDB table"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "s3_bucket_name" {
  description = "Name of S3 bucket"
  value       = aws_s3_bucket.remote_s3.bucket
}

output "ec2_instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.my_instance[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.allow_tls.id
}
