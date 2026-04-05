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
