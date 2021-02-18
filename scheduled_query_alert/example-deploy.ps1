az login
terraform init
terraform plan -out=alertPlan
terraform apply "alertPlan"
