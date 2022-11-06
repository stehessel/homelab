# Infrastructure repository

## Terraform

To initialize terraform run:

```sh
terraform init \
    -backend-config="access_key=$(sops --decrypt --extract '["backblaze"]["keyID"]' secrets/prod.yaml)" \
    -backend-config="secret_key=$(sops --decrypt --extract '["backblaze"]["applicationKey"]' secrets/prod.yaml)"
```
