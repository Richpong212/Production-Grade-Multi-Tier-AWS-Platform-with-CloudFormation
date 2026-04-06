## Setting up CICD through github actions

We are going to create a CICD pipeline that

- checkout code
- configure AWS credentials
- validate template for cloud formation
- run the deploy script
- deploy eith dev or prod

### CICD Flow

##### DEV

when the code is pushed to main, we deploy dev automatically

##### Prod

This is going to be triggered only manually.

##### Required GitHub Secrets

Lets add these in the repo

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
