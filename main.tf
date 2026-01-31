module "dev-infra" {
    source = "./infra"
    env = "dev"
    bucket_name = "infra-app-bucket"
    instance_count = 1
    instance_type = "t3.micro"
    hash_key = "studentID"
}
module "qa-infra" {
    source = "./infra"
    env = "qa"
    bucket_name = "infra-app-bucket"
    instance_count = 2
    instance_type = "t3.micro"
    hash_key = "studentID"
}

module "prod-infra" {
    source = "./infra"
    env = "prod"
    bucket_name = "infra-app-bucket"
    instance_count = 3
    instance_type = "t3.micro"
    hash_key = "studentID"
}



