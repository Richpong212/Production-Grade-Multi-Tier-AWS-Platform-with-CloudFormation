## Phase 6 — Monitoring and Alerts

Now we need to monitor our system so that we can get alert when something goes wrong before clients
do.

We would need to create:

- SNS Topic
- CloudWatch Alarm for ALB healthy hosts
- CloudWatch Alarm for EC2 CPU
- RDS alarms

Without Monitoring, the app can fail silently without us knowing about.

Instance can be overloaded when we do not monitor the system.

#### What is SNS?

This means simple Notification Service.
It is a notification channel.
So we can get alerts from cloud watch alarms
And it can be publish through SNS to notify us via

- Email
- SMS
- Lambda - configured to take action when an alart occurs.

#### What is a CloudWatch Alarm?

We use CloudWatch to monitor metrics threshold for the system such CPU utilization of the EC2 server.

For Example:

- CPU too high
- healthy target count too low
- RDS CPU too high
- free storage too low

##### Now lets create the `monitoring.yaml`

#### Lets take a deep dive

#### AlertsTopic

This creates the notification topic.

Important

The email subscription will send a confirmation email.
You must confirm it before notifications work.

That is normal SNS behavior.

###### UnHealthyHostCountAlarm

This watches the ALB target group.

If healthy targets drop below 1, it alarms.

That is a very practical production signal.

##### HighCPUAlarm

This watches the average EC2 CPU for the ASG.

If it stays above 70%, it alarms.

That is a simple but useful first compute alarm.

##### Validate the template

```yaml
aws cloudformation validate-template \
--template-body file://template-structure/monitoring/monitoring.yaml
```
