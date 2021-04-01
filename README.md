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
tf_state_storage_account=$(terraform output -raw storage_account)
```

## Todo List
- [x] Folder for State Management
  - [x] Resource Group
  - [x] Azure Blob Storage
- [ ] Folder for Base Infrastructure
  - [ ] Resource Group
  - [ ] vNET + Subnets
  - [ ] Firewall
- [ ] Folder for Example App
  - [ ] VMSS
  - [ ] Loadbalancer