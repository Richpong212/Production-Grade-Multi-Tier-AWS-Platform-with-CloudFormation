## Setup s3 Bucket

- create an s3 bucket manually because our stack is going to depend on it.

`aws s3 mb s3://codegenitor-cfn-templates --region us-east-1`

- After we have created the bucket we need to follow best practice, we need to block public access
  to our bucket.

```yaml
aws s3api put-public-access-block  --bucket codegenitor-cfn-templates --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

- Now we need to enable versioning for the the bucket: so that we we update the files later we keep versions for it.

  ```yaml
  aws s3api put-bucket-versioning --bucket codegenitor-cfn-templates --versioning-configuration Status=Enabled
  ```

- Validate versioning
  `aws s3api get-bucket-versioning --bucket codegenitor-cfn-templates`

- Validate public access block:
  `aws s3api get-public-access-block --bucket codegenitor-cfn-templates`

- Now from the root folder, run the following command to copy the files into `S3 Bucket`

```yaml
aws s3 cp template-structure/network/network.yaml s3://codegenitor-cfn-templates/templates/network.yaml

aws s3 cp template-structure/security/security.yaml s3://codegenitor-cfn-templates/templates/security.yaml

aws s3 cp template-structure/alb/alb.yaml s3://codegenitor-cfn-templates/templates/alb.yaml

aws s3 cp main.yaml s3://codegenitor-cfn-templates/main.yaml
```

- Now, that we have copied to the s3, bucket, lets wire the `main.yaml` file

- After defining the values for the `main.yaml` file, we need to validate it by running the following command:
  `aws cloudformation validate-template --template-body file://main.yaml`

- Now, we need to create the stack from the root file which is the `main.yaml` by running the following command

```yaml
aws cloudformation create-stack \
--stack-name multi-tier-application \
--template-body file://main.yaml \
--parameters \
ParameterKey=TemplateBucketName,ParameterValue=codegenitor-cfn-templates \
ParameterKey=EnvironmentName,ParameterValue=dev \
--capabilities CAPABILITY_NAMED_IAM
```

- Check Status:
  `aws cloudformation describe-stacks \
--stack-name multi-tier-application \
--query "Stacks[0].StackStatus" \
--output text`

- Delete Rollback stack

  ```yaml
  aws cloudformation delete-stack --stack-name multi-tier-application
  aws cloudformation wait stack-delete-complete --stack-name multi-tier-application
  ```

- Diagnos if there is rollback

```yaml
aws cloudformation describe-stack-events \
--stack-name multi-tier-application \
--query "StackEvents[*].[Timestamp,LogicalResourceId,ResourceType,ResourceStatus,ResourceStatusReason]" \
--output table
```

- When New resources are added we must update the resources

```yaml
aws cloudformation update-stack \
--stack-name multi-tier-application \
--template-body file://main.yaml \
--parameters \
ParameterKey=TemplateBucketName,ParameterValue=codegenitor-cfn-templates \
ParameterKey=EnvironmentName,ParameterValue=dev \
--capabilities CAPABILITY_IAM
```
