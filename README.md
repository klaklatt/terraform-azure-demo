# Terraform Azure Demo
creating infrastructure with terraform in Microsoft Azure.

## Prerequisites

- Terraform installed on machine
- Microsoft Azure account

## Usage

I devided this project in 3 parts:
1. create resources for statemanagement
2. create resources for the base infrastructure
3. create resources for an example application

### 1. Initialize for Remote Management of terraform state and state lock
Folder: 01-state-management

This folder contains files to create following ressources:
- Azure "Admin" Resource group for managing state
- Azure Blob Storage for storing the terraform state files and locks

Commands:
```bash
cd 01-state-management
terraform init
terraform plan
terraform apply
tf_state_resource_group=$(terraform output -raw resource_group)
tf_state_storage_account=$(terraform output -raw storage_account)
```

### 2. Creating infrastructure in Azure
Folder: 02-base-infrastructure

After initialization of the remote state management this folder contains files to create following resources:
- Azure Resource Group
- ...
- ...

Commands:
```bash
cd 02-base-project
terraform init \
    -backend-config="resource_group_name=$tf_state_resource_group" \
    -backend-config="storage_account_name=$tf_state_storage_account" \
    -backend-config="container_name=tf-state-container" \
    -backend-config="key=base-project.terraform.tfstate"
terraform plan
terraform apply
```

### 3. Example App
Commands:
```bash
cd 03-example-app
terraform init \
    -backend-config="resource_group_name=$tf_state_resource_group" \
    -backend-config="storage_account_name=$tf_state_storage_account" \
    -backend-config="container_name=tf-state-container" \
    -backend-config="key=example-app.terraform.tfstate"
terraform plan
terraform apply
```

## Todo List
- [x] Folder for State Management
  - [x] Resource Group
  - [x] Azure Blob Storage
- [ ] Folder for Base Infrastructure
  - [x] Resource Group
  - [ ] vNET + Subnets
  - [ ] Firewall
- [ ] Folder for Example App
  - [ ] VMSS
  - [ ] Loadbalancer