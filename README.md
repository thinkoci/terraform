# Terraform Projects
Terraform Scripts for various OCI Projects
For any issues/clarifications, send out an email to shivinvijai@gmail.com

# How to use this repo?
Once you check out this terraform repo, you can see various projects. You can ignore the folders which you don't need. Its a single repo for various OCI projects related to OCI DevOps using terraform.

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
