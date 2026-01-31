variable "env" {
  description = "This is my enviroment for project"
  type=string
  default = "dev"
}

variable "bucket_name" {
    type=string
    description="This is my bucket name"
}

variable "instance_type" {
    description = "Type of AWS EC2 instance"
    type        = string
    default     = "t3.micro"
}

variable "instance_count" {
    description = "Number of EC2 instances to launch"
    type        = number
    default     = 1
  
}

variable "hash_key" {
    description = "Hash key for DynamoDB table"
    type        = string
    default     = "LockID"
}