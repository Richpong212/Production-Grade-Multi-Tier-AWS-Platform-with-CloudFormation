## Phase 3 — Entry Layer

Now we implement the front door of our application. We shall configure

- Application Load Balancer
- Target Group
- Listener

- Application Load Balancer(ALB) - sits infront of application servers. Recieves incomming requests
  HTTP/HTTPS.

- Instead of users going direct to the EC2 servers, they go through the ALB to access the application. ALB forward traffic to the right backend server.

- Without an ALB, you might expose EC2 directly to the internet and that's a weak design.
  - harder scaling,
  - no central health check
  - direct target for single instance

- ALB, must live in the public subnet, because it needs to communicate with the internet.

#### What is a Target Group?

A target group is where the ALB sends traffic.

- what backend port to use
- health check path
- which target group

#### What is a Listener?

- It tells the ALB, what port to listen on
- Protocols to expect
- what default action to take

###### Lets wire it now in the `alb.yaml` file

###### Important settings

- Scheme: internet-facing → public ALB
- Subnets → must be public subnets
- SecurityGroups → controls who can reach it

###### AppTargetGroup

This is the backend destination group.

###### Important settings

- TargetType: instance → later EC2 instances will register here
- HealthCheckPath: / → ALB checks whether targets are healthy
- VpcId → target group must belong to the same VPC

###### HttpListener

- listen on port 80
- forward to the target group

- Validate the resource
  `aws cloudformation validate-template --template-body file://alb.yaml`

###### Configure HTTPS optional for prod.

To make HTTPS work, you need:

- Domain (e.g. api.codegenitor.com)
- ACM certificate

But we will design it so:

- DEV = HTTP only (works now)
- PROD = HTTPS enabled

#### EnableHTTPS

This controls whether HTTPS is turned on.

false → normal HTTP only
true → create HTTPS listener and redirect HTTP to HTTPS

###### This is good because:

dev can stay simple
prod can be secure
same template works for both

###### SSLCertificateArn

This is the ACM certificate ARN.

It is only used when HTTPS is enabled.

That means:

dev can leave it empty
prod can provide a real certificate

#### Condition

```yaml
Conditions:
  UseHTTPS: !Equals [!Ref EnableHTTPS, "true"]
```

This is the switch.

CloudFormation uses this to decide whether to create the HTTPS listener.

Why this matters:

no duplicate template files
one template handles both environments
cleaner design
