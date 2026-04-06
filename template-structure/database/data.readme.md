## Phase 5 — Data Layer

Production applications needs a place to store and retrieve data.
So In this layer we are going to configure a Database Layer to be access by our application.

### Setting Up RDS in the private Db subnet

Databases must not be exposed to the internet. It can become expensive for
business when real user data is at hand. So keep the data private it the best approach.

- We are going to create POSTGRESSQL DB in the Private DB subnet

#### Now lets create `database.yaml`

#### Lets break it down

##### PubliclyAccessible: false

This is one of the most important settings here.

It means the database is not exposed publicly.

That matches our design goal.

##### VPCSecurityGroups

This attaches the DB security group from Phase 2.

That enforces:

only app instances can talk to DB

#### DBSubnetGroupName

This places RDS in the private DB subnets.

Without this, the database placement would not follow our intended design.

#### StorageEncrypted: true

This gives encryption at rest.

That is a strong production habit.

#### BackupRetentionPeriod: 7

This enables automated backups for 7 days.

Even in a learning environment, it is good to see this setting because backup thinking is part of real infra work.

##### Validate

`aws cloudformation validate-template --template-body file://template-structure/database/database.yaml`
