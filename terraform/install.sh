#!/bin/bash
terraform validate
terraform init
terraform plan -out planfile
terraform apply -auto-approve planfile
rm planfile