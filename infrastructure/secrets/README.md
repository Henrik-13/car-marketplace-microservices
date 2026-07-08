# Secrets

The actual Kubernetes Secret values are managed by Terraform in `infrastructure/terraform/kubernetes.tf`.
This directory exists to keep the phase 3 layout explicit without hardcoding credentials into YAML.
