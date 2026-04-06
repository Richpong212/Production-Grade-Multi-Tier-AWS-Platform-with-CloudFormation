### Hardening Secrets

We are now going to make the hardening of secrets
We will move the harcoded secrets into AWS secrets.

###### Before

- password is in JSON
- password is manually chosen
- password is passed around more

###### After

- password is generated automatically
- password is generated automatically
- password is stored in Secrets Manager

##### What changes we will make

- create `secrets.yaml`
- update `database.yaml`
- update `main.yaml`
- remove DBPassword from `dev.json` / `prod.json`
- update deploy.sh to upload `secrets.yaml`
- update validate.sh to validate `secrets.yaml`

#### Breakdown of secrets.yaml

- AWS::SecretsManager::Secret

This creates a real secret in AWS Secrets Manager.

- SecretStringTemplate

We pre-fill:

username
dbname
GenerateStringKey: "password"

AWS generates the password automatically and inserts it into the secret.

So the final secret looks like this conceptually:

```json
{
  "username": "appadmin",
  "dbname": "appdb",
  "password": "generated-random-password"
}
```
