Instead of writing:
`--parameters ParameterKey=TemplateBucketName,ParameterValue=... ParameterKey=EnvironmentName,ParameterValue=...`

We will use the file instead
`--parameters file://parameters/dev.json`

Why?

So that we can manage our variable in one centralize location with ease.
