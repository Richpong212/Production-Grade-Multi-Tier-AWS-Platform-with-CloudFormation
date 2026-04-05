# Phase 4 — Compute Layer

Now, lets deploy application onto the plaftorm.

### What is a Launch Template?

The blueprint that EC2 uses when creating an instance is known as the launch template.

Inside a launch template we can find:

- AMI
- Instance Type
- Security Group
- userData
- metaData Options

Its important to define the resource in the template once and reuse over and over.

You might wonder why must we do this.

That is critical for:

- repeatability
- scaling
- consistency

###### This brings us to the concept of AutoScaling.

To manage a fleet of EC2 instance at scale, we use autoscaling known as (ASG) - Auto Scaling group

Deploying on a single instance means whenever that server is down, then we faces the challenge of all our application been down. Also much resilient when we need to server thousands of users at will.

###### Now, we go to talk about User Data

- This is a startup script that we use to configure, our server.
- Through user Data, you can deploy your application such as Nginx, or deploy kubernetes resources onto the server to manage your deployments

##### We are going to run a simple Nginx application on our webserver.

##### Now create the `compute.yaml` file

### Lets break it down

###### ImageId

We use an SSM dynamic reference:
`ImageId: "{{resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64}}"`

- AWS resolves the latest Amazon Linux AMI at deployment time
- no hardcoded AMI IDs needed

###### IamInstanceProfile

- This attaches the instance profile from Phase 2.

- That gives EC2:
  - SSM access
  - temporary credentials

##### SecurityGroupIds

- The APP is going to only accept traffic from the ALB.

###### UserData

This installs Nginx and writes a tiny HTML page.

###### AutoScalingGroup

This launches 2 instances across the private app subnets.

###### Important settings:

VPCZoneIdentifier
This tells the ASG where to place instances.
TargetGroupARNs
This automatically registers the instances with the ALB target group.

###### HealthCheckType: ELB

This tells the ASG to use load balancer health checks too.

#### Validate

`aws cloudformation validate-template --template-body file://compute.yaml`

#### Check and Open the ALB

```yaml
aws cloudformation describe-stacks \
--stack-name multi-tier-application \
--query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDnsName'].OutputValue" \
--output text
```

Example: `dev-alb-1787097591.us-east-1.elb.amazonaws.com`

- now when we run this command, just need to use the output in the browser to access our web application
