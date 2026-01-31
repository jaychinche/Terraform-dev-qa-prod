# Terraform Multi-Environment Infrastructure (Dev, QA, Prod)

![Project-design](https://github.com/user-attachments/assets/1fa5307c-505f-44e4-9000-0d364ef13b12)



## Project Overview
This Terraform configuration manages AWS infrastructure across three environments: **Development (Dev)**, **Quality Assurance (QA)**, and **Production (Prod)**. Each environment is independently provisioned with identical infrastructure patterns but different configurations.

## Architecture Components

### 📊 Infrastructure Stack

```
┌─────────────────────────────────────────────────────────────┐
│           AWS Multi-Environment Infrastructure               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │     DEV      │  │      QA      │  │     PROD     │       │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤       │
│  │ 1x EC2       │  │ 2x EC2       │  │ 3x EC2       │       │
│  │ t3.micro     │  │ t3.micro     │  │ t3.micro     │       │
│  │ 20GB Storage │  │ 20GB Storage │  │ 20GB Storage │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         ↓                ↓                   ↓               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   S3 Bucket  │  │   S3 Bucket  │  │   S3 Bucket  │       │
│  │ Storage      │  │ Storage      │  │ Storage      │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         ↓                ↓                   ↓               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   DynamoDB   │  │   DynamoDB   │  │   DynamoDB   │       │
│  │ Lock Table   │  │ Lock Table   │  │ Lock Table   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         ↓                ↓                   ↓               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Security    │  │  Security    │  │  Security    │       │
│  │   Groups     │  │   Groups     │  │   Groups     │       │
│  │ SSH(22)      │  │ SSH(22)      │  │ SSH(22)      │       │
│  │ HTTP(80)     │  │ HTTP(80)     │  │ HTTP(80)     │       │
│  │ HTTPS(443)   │  │ HTTPS(443)   │  │ HTTPS(443)   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
infra/
├── main.tf                    # Root module definition with dev, qa, prod
├── provider.tf               # AWS provider configuration
├── terraform.tf              # Terraform backend & version requirements
├── infra/                    # Reusable module for all environments
│   ├── ec2.tf               # EC2 instances, security groups, key pairs
│   ├── s3.tf                # S3 bucket for storage
│   ├── dynamo.tf            # DynamoDB table for state locking
│   ├── variable.tf          # Input variables
│   ├── outputs.tf           # Output values
│   ├── terra-key-ec2        # Private SSH key
│   └── terra-key-ec2.pub    # Public SSH key
└── README.md                # This file
```

---

## 🏗️ Infrastructure Components Breakdown

### 1. **EC2 Instances** (Compute)
- **Purpose**: Runs application servers
- **Dev Configuration**: 1 instance (t3.micro)
- **QA Configuration**: 2 instances (t3.micro)
- **Prod Configuration**: 3 instances (t3.micro)
- **Details**:
  - AMI: Amazon Linux 2 (Free Tier eligible)
  - Storage: 20GB GP2 volumes per instance
  - Public IP: Enabled for SSH access
  - Security: SSH key-based authentication

### 2. **Security Groups**
- **SSH (Port 22)**: Allow SSH from anywhere (0.0.0.0/0)
- **HTTP (Port 80)**: Allow web traffic from anywhere
- **HTTPS (Port 443)**: Allow secure web traffic from anywhere
- **Egress**: Allow all outbound traffic

### 3. **S3 Buckets** (Storage)
- **Purpose**: Object storage for application data
- **Naming**: `{env}-infra-app-bucket` (e.g., `dev-infra-app-bucket`)
- **Billing**: Standard pay-as-you-go
- **Use Case**: Application logs, backups, static files

### 4. **DynamoDB Tables** (Database)
- **Purpose**: State locking and application data
- **Naming**: `{env}-infra-app-dyanamodbtable`
- **Billing Mode**: PAY_PER_REQUEST (pay-as-you-go)
- **Hash Key**: LockID (for state management)
- **Use Case**: Terraform state locking, application metadata storage

### 5. **Key Pairs** (SSH Access)
- **Name**: `{env}-infra-app-keypair`
- **Type**: SSH ED25519
- **Purpose**: Secure SSH access to EC2 instances
- **Files**: `terra-key-ec2` (private), `terra-key-ec2.pub` (public)

---

## 🌍 Environment Configurations

### **Development (Dev)**
```hcl
module "dev-infra" {
    env              = "dev"
    bucket_name      = "infra-app-bucket"
    instance_count   = 1        # Single instance
    instance_type    = "t3.micro"
    hash_key         = "studentID"
}
```
- **Use Case**: Development and testing
- **Cost**: Lowest (1 instance)
- **Availability**: Single instance
- **Naming Prefix**: `dev-`

### **Quality Assurance (QA)**
```hcl
module "qa-infra" {
    env              = "qa"
    bucket_name      = "infra-app-bucket"
    instance_count   = 2        # Two instances
    instance_type    = "t3.micro"
    hash_key         = "studentID"
}
```
- **Use Case**: Testing and validation
- **Cost**: Medium (2 instances)
- **Availability**: Improved with 2 instances
- **Naming Prefix**: `qa-`

### **Production (Prod)**
```hcl
module "prod-infra" {
    env              = "prod"
    bucket_name      = "infra-app-bucket"
    instance_count   = 3        # Three instances
    instance_type    = "t3.micro"
    hash_key         = "studentID"
}
```
- **Use Case**: Live production environment
- **Cost**: Highest (3 instances)
- **Availability**: Better redundancy with 3 instances
- **Naming Prefix**: `prod-`

---

## 📋 What Gets Created

### Per Environment Resources

| Resource | Dev | QA | Prod |
|----------|-----|-----|------|
| EC2 Instances | 1 | 2 | 3 |
| Security Groups | 1 | 1 | 1 |
| S3 Buckets | 1 | 1 | 1 |
| DynamoDB Tables | 1 | 1 | 1 |
| Key Pairs | 1 | 1 | 1 |
| **Total Resources** | **5** | **5** | **5** |

---

## 🔧 Key Features

### ✅ Module-Based Design
- Single reusable module (`infra/`) deployed three times
- Consistent infrastructure across environments
- Easy to maintain and update

### ✅ Automatic Naming
- All resources tagged with environment name
- Naming convention: `{env}-infra-app-{resource-type}`
- Makes resource identification easy

### ✅ Security
- SSH key-based authentication
- Security groups with restricted access
- Public subnet placement with security controls

### ✅ Cost Optimization
- Free Tier eligible instances (t3.micro)
- Pay-as-you-go DynamoDB billing
- Scalable based on environment needs

### ✅ State Management
- DynamoDB state locking
- Prevents concurrent modifications
- Ensures infrastructure consistency

---

## 🚀 How to Deploy

### Prerequisites
```bash
# Install Terraform
brew install terraform

# Configure AWS credentials
aws configure
```

### Deploy All Environments
```bash
cd infra
terraform init       # Initialize Terraform
terraform plan       # Preview changes
terraform apply      # Create infrastructure
```

### Deploy Specific Environment
```bash
# Deploy only dev environment
terraform apply -target=module.dev-infra

# Deploy only qa environment
terraform apply -target=module.qa-infra

# Deploy only prod environment
terraform apply -target=module.prod-infra
```

---

## 📊 Outputs

After deployment, you'll get:

```
Outputs:
  dev-infra_dynamodb_table_name = "dev-infra-app-dyanamodbtable"
  dev-infra_s3_bucket_name = "dev-infra-app-bucket"
  dev-infra_ec2_instance_ids = ["i-0x1x2x3x4x5x"]
  dev-infra_security_group_id = "sg-0x1x2x3x4x"
  
  qa-infra_dynamodb_table_name = "qa-infra-app-dyanamodbtable"
  qa-infra_s3_bucket_name = "qa-infra-app-bucket"
  qa-infra_ec2_instance_ids = ["i-0y1y2y3y4y5y", "i-0z1z2z3z4z5z"]
  qa-infra_security_group_id = "sg-0y1y2y3y4y"
  
  prod-infra_dynamodb_table_name = "prod-infra-app-dyanamodbtable"
  prod-infra_s3_bucket_name = "prod-infra-app-bucket"
  prod-infra_ec2_instance_ids = ["i-0a1a2a3a4a5a", "i-0b1b2b3b4b5b", "i-0c1c2c3c4c5c"]
  prod-infra_security_group_id = "sg-0a1a1a2a3a"
```

---

## 🔐 Security Considerations

1. **SSH Access**: Restricted to authorized key pairs only
2. **Ports**: Only necessary ports (22, 80, 443) are open
3. **VPC**: Uses default VPC with managed security groups
4. **State**: DynamoDB ensures state consistency

---

## 💰 Estimated Costs (Monthly)

### Development
- 1x t3.micro: $4.75
- S3 Storage (minimal): $0.50
- DynamoDB (minimal): $0.25
- **Total**: ~$5/month

### QA
- 2x t3.micro: $9.50
- S3 Storage: $1.00
- DynamoDB: $0.50
- **Total**: ~$11/month

### Production
- 3x t3.micro: $14.25
- S3 Storage: $1.50
- DynamoDB: $0.75
- **Total**: ~$16.50/month

**Total All Environments**: ~$32.50/month

---

## 🛠️ Variables Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `env` | string | dev | Environment name (dev, qa, prod) |
| `bucket_name` | string | - | S3 bucket name |
| `instance_type` | string | t3.micro | EC2 instance type |
| `instance_count` | number | 1 | Number of EC2 instances |
| `hash_key` | string | LockID | DynamoDB hash key |

---

## 📝 File Descriptions

### main.tf
Defines three module blocks, one for each environment. Each module calls the reusable `infra/` module with environment-specific variables.

### provider.tf
Configures AWS provider with region set to `us-east-1`.

### terraform.tf
Specifies Terraform version and required providers.

### infra/ec2.tf
- EC2 instances with count parameter for scaling
- Security groups with ingress/egress rules
- Key pairs for SSH authentication
- Default VPC configuration

### infra/s3.tf
S3 bucket creation with environment tagging.

### infra/dynamo.tf
DynamoDB table for state locking and data storage.

### infra/variable.tf
Input variable definitions for the module.

### infra/outputs.tf
Exports resource IDs and names for reference.

---

## 🔄 Workflow

```
1. Initialize Terraform (terraform init)
   ↓
2. Review Plan (terraform plan)
   ↓
3. Create Infrastructure (terraform apply)
   ↓
4. Verify Resources in AWS Console
   ↓
5. SSH into EC2 instances
   ↓
6. Deploy Applications
   ↓
7. Test in each environment
```

---

## 🗑️ Cleanup

To destroy infrastructure:

```bash
# Destroy all environments
terraform destroy

# Destroy specific environment
terraform destroy -target=module.dev-infra
```

---

## 📚 Additional Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [Terraform Modules](https://www.terraform.io/language/modules)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

**Last Updated**: January 2026
**Terraform Version**: 1.12.2
**AWS Region**: us-east-1

