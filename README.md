# CloudDrove Assessment

This project demonstrates a DevOps infrastructure setup using Terraform, Terragrunt, and Docker Compose. It provisions AWS resources and configures a basic ELK stack for log management.

## Features

- **AWS EC2 Instance**: Launches an EC2 instance with a security group, IAM role, and CloudWatch alarm for high CPU utilization.
- **AWS S3 Bucket**: Provisions an S3 bucket with versioning enabled.
- **IAM Role & Policy**: Grants EC2 permissions to create CloudWatch alarms.
- **Terragrunt**: Manages environment-specific configurations and DRY infrastructure code.
- **Docker Compose ELK Stack**: Runs Elasticsearch, Logstash, and Kibana locally for log aggregation and visualization.

## Structure

```
modules/
  aws/
    ec2/         # EC2, IAM, and security group Terraform modules
    s3/          # S3 bucket Terraform module
logstash_pipeline/
  logstash.conf  # Logstash pipeline config
terragrunt/
  aws/
    prod/
      ec2-instance/terragrunt.hcl
      s3/terragrunt.hcl
  root-config.hcl
```

## Usage

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [Docker & Docker Compose](https://docs.docker.com/get-docker/)
- AWS credentials with permissions for EC2, S3, IAM, and CloudWatch

### Deploy AWS Infrastructure
1. **Initialize and apply S3 bucket:**
   ```sh
   cd terragrunt/aws/prod/s3
   terragrunt init
   terragrunt apply
   ```
2. **Initialize and apply EC2 instance:**
   ```sh
   cd ../ec2-instance
   terragrunt init
   terragrunt apply
   ```

### Run ELK Stack Locally
1. Place your application log at `./app.log` in the project root.
2. Start the stack:
   ```sh
   docker-compose up -d
   ```
3. Access Kibana at [http://localhost:5601](http://localhost:5601)

## Notes
- The EC2 instance user data installs AWS CLI and sets up a CloudWatch alarm for high CPU usage.
- Logstash is configured to read from `/var/log/app.log` (mount your log file as `./app.log`).
- Tag keys must be unique (case-insensitive) across all resources.

## Authors
- CloudDrove Assessment by [Your Name]

---

Feel free to customize this README for your specific use case.