# Terraform Project - Object Storage Bucket creation
This project is to create an Object Storage Bucket in an existing compartment. Assuming you already have OCI CLI authentication is already set up, we’ll keep the Terraform simple and rely on the default OCI config (~/.oci/config).

Below is a minimal, Terraform script to create a private OCI Object Storage bucket in a compartment, with the compartment OCID coming from terraform.tfvars.

For any issues/clarifications, send out an email to shivinvijai@gmail.com

# Prerequisite
Assume you already installed OCI CLI in your workstation/laptop and configure your OCI authentication using command 'oci setup config'. You need to key in your tenancy OCID, user OCID, fingerprint, keys etc. Before executing any of these terraform scripts make sure you got your Object Storage namespace details using this command 'oci os ns get'. If you facing error in this step you need to fix it first before running terraform.

# What files I added in gitignore?
I am not sharing any of my OCI related files in this git repo

.terraform/

*.tfstate*

*.tfvars

crash.log

*.tfplan

.DS_Store

# How to run these projects

1. Check out the git repo.
2. cd object-storage
3. terraform init
4. terraform plan
5. terraform apply
# To destroy the OCI infrastructure you created, you need to use
terraform destroy