# terraform-kubernetes-development
Development on Kubernetes project's Terraform

## Setup

1. Comment out providers `helm` and `kubernetes` in `config.tf`
2. terraform apply only `01_eks.tf`
3. Uncomment `kubernetes` provider in `config.tf`
4. terraform apply `02_tiller_rbac.tf`
5. Uncomment `helm` provider in `config.tf`
6. `terraform apply` all

## Get Developer's Secret
You can access to the kubernetes-dashboard with this secret.

`kubectl -n default describe secret $(kubectl -n default get secret | grep developer | awk '{print $1}')`
