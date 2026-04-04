- create the folders and files for modular stack
  cloudformation-project/
  ├── main.yaml
  ├── templates/
  │ ├── network.yaml
  │ ├── security.yaml
  │ ├── alb.yaml
  │ ├── compute.yaml
  │ ├── database.yaml
  │ ├── monitoring.yaml
  │ └── s3.yaml
  ├── parameters/
  │ ├── dev.json
  │ └── prod.json
  ├── scripts/
  │ ├── deploy.sh
  │ └── validate.sh
  └── app/
  └── userdata.sh
