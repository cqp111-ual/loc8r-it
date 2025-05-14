# tf-azure

Infrastructure deployment with Terraform on Azure cloud provider.

## Prerequisites

- Copy your public SSH key in folder `keys/`.

- Create file `terraform.tfvars` based on the example, insert your credentials for `azure-tenant` and `azure-subscription`. To obtain your credentials, run the next command (requires client-tool `azure-cli` installed):
  
```bash
az account show
```

## Deployment

After prerrequisites, deploy your infrastructure with:

```bash
terraform init
terraform plan
terraform apply
```
