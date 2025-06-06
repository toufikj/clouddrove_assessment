# CloudDrove Assessment

This project demonstrates a robust DevOps infrastructure setup using **Terraform**, **Terragrunt**, **Docker Compose**, and **GitHub Actions** for CI/CD. It provisions AWS resources, configures a local ELK stack for log management, and automates infrastructure lifecycle management.

---

## Directory Structure

```
clouddrove_assessment/
│
├── docker-compose.yml           # Docker Compose file for ELK stack
├── prometheus.yml               # (If used) Prometheus config
├── README.md                    # Project documentation
│
├── logstash_pipeline/
│   └── logstash.conf            # Logstash pipeline config (reads /var/log/app.log)
│
├── modules/
│   └── aws/
│       ├── ec2/
│       │   ├── cloudwatch-ec2-policy.json  # IAM policy for CloudWatch
│       │   ├── ec2.tf                      # EC2, SG, user_data, tags
│       │   ├── iam.tf                      # IAM role, policy, instance profile
│       │   ├── output.tf                   # Outputs (instance_id, IPs, etc.)
│       │   └── variables.tf                # Module variables
│       └── s3/
│           └── s3.tf                       # S3 bucket and versioning
│
├── terragrunt/
│   ├── root-config.hcl           # Root Terragrunt config
│   └── aws/
│       └── prod/
│           ├── prod.hcl                  # Environment tags/locals
│           ├── ec2-instance/
│           │   └── terragrunt.hcl        # EC2 instance Terragrunt config
│           └── s3/
│               └── terragrunt.hcl        # S3 bucket Terragrunt config
│
└── .github/
    └── workflows/
        ├── ci.yml                # CI pipeline for linting, security, and plan
        └── destroy.yml           # Automated destroy pipeline
```

---

## Modules & File Purposes

- **modules/aws/ec2/**
  - `ec2.tf`: Provisions EC2 instance, security group, and inlines user_data for bootstrapping and CloudWatch alarm.
  - `iam.tf`: Defines IAM role, policy, and instance profile for EC2 permissions (CloudWatch alarm creation).
  - `cloudwatch-ec2-policy.json`: Policy document for CloudWatch permissions.
  - `output.tf`: Exposes instance details as outputs.
  - `variables.tf`: All input variables for the module.
- **modules/aws/s3/s3.tf**: Provisions S3 bucket with versioning, region, and bucket name as variables.
- **logstash_pipeline/logstash.conf**: Logstash config to read logs from `/var/log/app.log` and send to Elasticsearch.
- **docker-compose.yml**: Defines ELK stack (Elasticsearch, Logstash, Kibana) and a sample Nginx web service.
- **terragrunt/aws/prod/**: Environment-specific Terragrunt configs for S3 and EC2, including tags and region.
- **.github/workflows/ci.yml**: CI pipeline for linting, security checks (Checkov), and Terraform plan.
- **.github/workflows/destroy.yml**: Automated destroy pipeline for tearing down infrastructure.

---

## Docker Compose: ELK Stack

- **Services Created:**
  - `elasticsearch` (port 9200)
  - `logstash` (reads `./app.log` as `/var/log/app.log`)
  - `kibana` (port 5601)
  - `web` (nginx, port 8080)
- **How to Run:**
  1. Place your application log at `./app.log` in the project root.
  2. Start the stack:
     ```powershell
     docker-compose up -d --build
     ```
  3. Access Kibana at [http://localhost:5601](http://localhost:5601)
  4. Access Nginx at [http://localhost:8080](http://localhost:8080)
- **Prerequisites:** Docker, Docker Compose

---

## AWS Infrastructure: How It Works

- **EC2 Instance**: Bootstrapped with user_data to install AWS CLI and create a CloudWatch alarm for high CPU usage.
- **CloudWatch Alarm Creation (user_data):**
  ```sh
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
  aws cloudwatch put-metric-alarm \
    --alarm-name "HighCPUAlarm" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 60 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=InstanceId,Value=$INSTANCE_ID \
    --evaluation-periods 5 \
    --unit Percent \
    --region <region>
  ```
- **How is this possible without `aws configure`?**
  - The EC2 instance is launched with an IAM role (instance profile) that grants permissions to create CloudWatch alarms. The AWS CLI automatically uses these credentials from the instance metadata service.

---

## Deploying Infrastructure from Local

### Prerequisites
- AWS CLI (for remote state bucket creation)
- Terraform & Terragrunt
- AWS credentials with required permissions

### Steps
1. **Create S3 remote state bucket** (required for storing Terraform state):
   - Edit and apply `terragrunt/aws/prod/s3/terragrunt.hcl` first:
     ```powershell
     cd terragrunt/aws/prod/s3
     terragrunt init
     terragrunt apply
     ```
   - This step is necessary before any other infra to ensure remote state is available.
2. **Deploy EC2 and other resources:**
   ```powershell
   cd ../ec2-instance
   terragrunt init
   terragrunt apply
   ```
3. **Destroy infrastructure:**
   ```powershell
   terragrunt destroy
   ```

---

## CI/CD Pipelines

### ci.yml
- **Purpose:**
  - Lint Terraform code
  - Run `terraform plan` and show output
- **Probable Improvements:**
  - Add automated tests for module outputs
  - Integrate notifications (Slack, Teams) for plan/apply status
  - Enforce branch protection and PR checks

### destroy.yml
- **Purpose:**
  - Automate teardown of infrastructure (e.g., on branch delete or manual trigger)
- **Probable Improvements:**
  - Add approval steps before destroy
  - Notify stakeholders on destroy status

---

## Recommendations & Improvements
- **Checkov Security Testing:** Already integrated in CI for best practices and vulnerability scanning.
- **Infra-Provisioning Notifications:** Add Slack/Teams notifications for plan/apply/destroy status in CI/CD.
- **Automated Testing:** Add tests for outputs and resource existence.
- **Tag Consistency:** Ensure all tag keys are unique and consistent (case-insensitive) to avoid AWS errors.
- **Parameterize More Inputs:** For greater flexibility across environments.

---

## Authors
- CloudDrove Assessment by [Toufik Jamadar]

---