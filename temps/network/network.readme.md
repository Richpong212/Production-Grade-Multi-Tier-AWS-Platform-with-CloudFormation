## Networking Phase

1. What is a VPC? - Virtual Private Computer
   This is your own private network inside AWS.
   Without a VPC, there is no real network design.
   Inside the VPC, you can define the following:

- subnets
- EC2 instances
- load balancers
- databases
- route tables
- gateways

2. Why is it important?
   In production we do not just throw servers onto the internet. Control is very important.
   You need control over:

- IP ranges
- network isolation
- public and private access
- routing
- security boundaries
  This is crucial to have a solid production environment.

3. Why must you/companies care about this?
   We need to know
   - which resources are public
   - which resources are private
   - how traffic flows
   - how systems are isolated
   - how to reduce exposure

##### If the network is badly designed, everything built on top of it becomes risky.

4. Goals for this networking phase
   - 1 VPC
   - 2 public subnets
   - 2 private app subnets
   - 2 private DB subnets
   - 1 Internet Gateway
   - public route table
   - private route tables
   - subnet associations

##### 5 Architecture

```
VPC: 10.0.0.0/16

AZ1
- Public Subnet A      10.0.1.0/24
- Private App Subnet A 10.0.11.0/24
- Private DB Subnet A  10.0.21.0/24

AZ2
- Public Subnet B      10.0.2.0/24
- Private App Subnet B 10.0.12.0/24
- Private DB Subnet B  10.0.22.0/24
```

###### 6. Why multiple Availability Zones?

Because one AZ can have issues.
If you place everything in one AZ, your app has a single point of failure.
Using two AZs improves

- availability
- resilience
- fault tolerance

###### 7. What makes a subnet public or private?

A subnet is not public just because you call it public.
A subnet becomes public when:
its route table has a route to an Internet Gateway
`0.0.0.0/0 -> Internet Gateway`

A subnet is private when it does not have direct internet routing through an Internet Gateway.

###### 8. Create the network.yaml

This is where we difine all the resources we need for creating our VPC and subnets as well as all the required network permission lives.

###### 9. Let’s break down the important parts

###### EnableDnsSupport: true

This allows DNS resolution inside the VPC.

Without this, name resolution becomes painful.

Important because many AWS services rely on DNS.

###### EnableDnsHostnames: true

This allows instances to get DNS hostnames.

Very useful for EC2 naming and service communication.

###### MapPublicIpOnLaunch: true for public subnets

This means instances launched in public subnets automatically get public IPs.

That is useful for truly public-facing resources or temporary test EC2 instances.

For private subnets, we keep this false.

###### !GetAZs ''

This fetches the Availability Zones in the current region.

!Select [0, ...]

Takes the first AZ.

!Select [1, ...]

Takes the second AZ.

This is how we spread resources across AZs dynamically.

##### 0.0.0.0/0

This means “all destinations.”

So this route says:

“Send all non-local traffic to the Internet Gateway.”

That is what gives internet access to the public subnets.

###### Now, lets Validate the template body

cd /temps/network
aws cloudformation validate-template --template-body file://network.yaml

###### Creat the Stack

`aws cloudformation create-stack --stack-name multi-tier-application --template-body file://network.yaml`

###### check the status

`aws cloudformation describe-stacks --stack-name multi-tier-application --query "Stacks[0].StackStatus" --output text`

### NOW, PRIVATE SUBNETS DO NOT HAVE ACCESS TO INTERNET

we need to give it access to internet so that when we deploy apps on it, we
can install the packages and pull

###### Why NAT matters

A NAT Gateway lets resources in a private subnet go out to the internet without letting the internet start connections back in.

In simple words
Internet Gateway = for public-facing access
NAT Gateway = for safe outbound internet from private subnets

Our app servers needs to be private and we must not
render it useless too

#### Why each new resource exists for the NAT

Elastic IP

A NAT Gateway needs a public IP.
That is what the Elastic IP gives it.
Without it, the NAT Gateway cannot send traffic to the internet properly.

NAT Gateway
Lives in a public subnet.

Why public?
Because it needs internet connectivity through the Internet Gateway.
But it is used by private subnets.

Private app route tables
These decide where traffic from app subnets goes.

We add:
`0.0.0.0/0 -> NAT Gateway`
So app servers can go out, but they are still not directly exposed.

Route table associations

A route table does nothing unless attached to the subnet.

Very important cost note
NAT Gateway costs money even when lightly used.
When you finish practicing, delete the stack to avoid unnecessary cost.

#### Deployment flow

Because the stack already exists, do not run create-stack again.

`aws cloudformation update-stack --stack-name multi-tier-application  --template-body file://network.yaml`

### check status

`aws cloudformation describe-stacks 
  --stack-name multi-tier-application 
  --query "Stacks[0].StackStatus" 
  --output text`

### Confirm NAT Gateways exist

`aws ec2 describe-nat-gateways`

`aws ec2 describe-nat-gateways \
  --query "NatGateways[*].{Id:NatGatewayId,State:State,SubnetId:SubnetId,PublicIp:NatGatewayAddresses[0].PublicIp}" \
  --output table`

- we must see 2 NAT Gateways
- both in available state
- each in a public subnet
- each with a public IP

## NOW, Remember to destroy your work if you are only testing the networking section:

`aws cloudformation delete-stack 
  --stack-name multi-tier-application && 
aws cloudformation wait stack-delete-complete --stack-name multi-tier-application`
