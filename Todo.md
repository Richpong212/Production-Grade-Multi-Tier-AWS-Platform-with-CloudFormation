- create the folders and files for modular stack
  cloudformation-project/
  ├── main.yaml
  ├── templates/
  │ ├── network.yaml
  │ ├── security.yaml
  │ ├── alb.yaml
  │ ├── compute.yaml
  │ ├── database.yaml
  │ ├── monitoring.yaml
  │ └── s3.yaml
  ├── parameters/
  │ ├── dev.json
  │ └── prod.json
  ├── scripts/
  │ ├── deploy.sh
  │ └── validate.sh
  └── app/
  └── userdata.sh

## BUILD STAGES

## Phase 1

Network foundation

VPC
subnets
IGW
NAT
route tables

## Phase 2

Security foundation

security groups
IAM role
instance profile

## Phase 3

App entry

ALB
target group
listener

## Phase 4

Compute

Launch Template
Auto Scaling Group
user data

## Phase 5

Database

DB subnet group
RDS
DB SG rules

## Phase 6

Monitoring

CloudWatch alarms
SNS

## Phase 7

Hardening

S3 encryption
SSM access
optional HTTPS/WAF
