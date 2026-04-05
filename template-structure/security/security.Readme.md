# Phase 2 — Security Foundation

Now, in phase 2, we need to secure our system y defining who is allowed to talk to waht, how EC2, get permission safely and how we reduce exposure in production.

### Goals For This Section

we will create

- ALB Security Group
- App Security Group
- DB Security Group
- EC2 IAM Role
- EC2 Instance Profile

###### Why do we even still need to do this?

Even if your network is crafted well enough, bad
security rules, can still exposes the system.

Example:

- If app servers allow traffic from 0.0.0.0/0, anyone on the internet could try reaching them
- If the database allows inbound from everywhere, that is a serious production risk
- If EC2 uses long-lived access keys stored on disk, that is poor security design

##### So Our main aim is to give least Privillege at this point.

#### Architecture

`Internet
   |>>
ALB Security Group
   |>>
App Security Group
   |>>
DB Security Group`

#### In Plain English

- The ALB accepts public web traffic
- The App Servers are to accept traffic from the ALB
- The Database Should Only accept Traffic from The App Servers

## Part 1 — Security Groups

A security group is a stateful virtual firewall attached to a resource.

- controls inbound traffic
- controls outbound traffic

StateFul: When inbound traffic is allowed, then response is automically allowed back, instead of stateless firewalls.

##### Security group purposes:

- least privilege
- network segmentation
- controlled service to service communication

### The 3 security groups we need

###### 1. ALB Security Group

Allow HTTP/HTTPS traffic from the internet
The load balancer is the public entry point

###### 2. App Security Group

Allow app traffic only from the ALB security group
Access from the internets are blocked by default, they must go through the ALB.

###### 3. DB Security Group

allow database traffic only from the app security group
only the application should talk to the database

## Part 2 — IAM Role for EC2

An IAM role gives AWS permissions to a service or resource without storing long-term credentials manually.

EC2: can assume role, aws provides temporary credentials automatically.

So Instead of creating roles, we avoid harcoding access keys, maually copying credentials to the EC2.

##### Importance of SSM(AwS Systems Manager)

Instead of:

- open port 22
- manage key pairs
- expose ssh

We can use:

- use IAM + SSM
- keep instance private
- reduce risk of attack

### AWS Instance Profile

Since we cannot use IAM role directly on an Instance, we will use `Instance Profile` that attaches role to the instance.

So:

- IAM Role = Permission
- Instance Profile = The main thing EC2 attches to itself.

#### We shall be working in the `security.yaml`

##### Lets Break it down

###### VpcId parameter

This tells the stack which VPC to place the security groups in.
Security groups are VPC-scoped, so they must belong to a VPC.

###### AlbSecurityGroup

This allows:

- port 80 from anywhere
- port 443 from anywhere

We need the ALB to be public facing

###### AppSecurityGroup

This does not allow `0.0.0.0/0`
It only allows traffic from:
`SourceSecurityGroupId: !Ref AlbSecurityGroup`
Instead of allowing based on IP ranges, you allow based on another security group.

##### DbSecurityGroup

The DB accepts traffic only from the app security group.

- not from the internet
- not from the ALB

## validate the body format for the cloud formation

aws cloudformation validate-template --template-body file://security.yaml
