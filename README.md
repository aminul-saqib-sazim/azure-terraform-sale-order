# Azure Terraform Infrastructure for Sale Order Application

## Purpose

This repository contains Terraform configurations to deploy the Sale Order full-stack application to Azure App Service.

### What's Deployed

| Component | Azure Resource | Description |
|-----------|---------------|-------------|
| **Frontend** | App Service (Linux) | Next.js application |
| **Backend** | App Service (Linux) | NestJS API |
| **Database** | PostgreSQL Flexible Server | Managed PostgreSQL |
| **Storage** | Azure Container Registry | Docker image storage |
| **Secrets** | App Service settings + local tfvars | Production secrets are kept out of git |
| **Monitoring** | Application Insights + Log Analytics | Observability |

---

## Repository Structure

```
azure-terraform-sale-order/
├── modules/                              # Provider-specific reusable modules
│   ├── azure/
│   │   ├── app-service/
│   │   └── database/
│   ├── aws/
│   └── gcp/
│
├── stacks/                               # Deployable stacks by provider/app/env
│   ├── azure/
│   │   └── sale-order/
│   │       └── production/
│   │           ├── main.tf
│   │           ├── variables.tf
│   │           ├── terraform.tfvars.example
│   │           └── README.md
│   ├── aws/
│   └── gcp/
│
└── README.md                            # This file
```

---

## Quick Start

### Prerequisites

- Azure CLI >= 2.50.0
- Terraform >= 1.9.0
- Docker >= 20.10

### Deployment Steps

1. **Navigate to production directory**
   ```bash
   cd stacks/azure/sale-order/production
   ```

2. **Copy and configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values (all environment variables included)
   ```

3. **Set sensitive variables** (optional - can also be in tfvars)
   ```bash
   export TF_VAR_db_admin_password="YourPassword123"
   export TF_VAR_better_auth_secret="$(openssl rand -hex 32)"
   ```

4. **Deploy infrastructure** (all env vars auto-configured in App Service)
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Build and deploy applications**
    
   See [stacks/azure/sale-order/production/README.md](stacks/azure/sale-order/production/README.md) for complete Docker build and App Service configuration steps.

> **Note:** Environment variables are now automatically configured via Terraform. No manual portal configuration is required.

---

## Environment Variables

All environment variables are now **automatically configured via Terraform** - no manual portal configuration needed!

### For Terraform

| Variable | Description | Sensitive | How to Set |
|----------|-------------|-----------|------------|
| `TF_VAR_db_admin_password` | Database admin password | Yes | Export or in tfvars |
| `TF_VAR_better_auth_secret` | Better Auth secret | Yes | Export or in tfvars |

### User-Provided Variables (in terraform.tfvars)

All application environment variables are configured in `terraform.tfvars`:

| Category | Variables |
|----------|------------|
| **AWS/S3** | `aws_access_key_id`, `aws_secret_access_key`, `do_spaces_bucket_name`, `do_spaces_bucket_url`, etc. |
| **Microsoft SSO** | `microsoft_client_id`, `microsoft_client_secret`, `microsoft_tenant_id` |
| **DocuSeal** | `docuseal_api_key`, `docuseal_webhook_secret` |
| **Mailgun** | `mailgun_api_key`, `mailgun_domain`, `send_from_email` |
| **Admin Accounts** | `developer_email`, `admin_email`,  etc. |

All these variables are automatically applied to App Service when you run `terraform apply`.

---

## Azure Resources Created

### Resource Group: rg-hd-sales

| Resource | Name | SKU/Type |
|----------|------|----------|
| App Service Plan | sale-order-prod-sp | Standard S1 |
| Azure Container Registry | salescontractapp | Basic |
| Linux Web App (Backend) | sale-order-backend | Linux, Standard S1 |
| Linux Web App (Frontend) | sale-order-web | Linux, Standard S1 |
| Web App Slot (Backend) | prod | Included |
| Web App Slot (Frontend) | prod | Included |
| PostgreSQL Flexible Server | sale-order-prod-db | B_Standard_B1ms |
| Application Insights | sale-order-prod-ai | web |
| Log Analytics Workspace | sale-order-prod-law | PerGB2018 |

---

## Documentation

| Document | Description |
|----------|-------------|
| [stacks/azure/sale-order/production/README.md](stacks/azure/sale-order/production/README.md) | Detailed deployment guide |
| [../../azure-migration-plan.md](../../azure-migration-plan.md) | Migration plan from DigitalOcean |

---

## Common Tasks

### View Outputs After Deployment

```bash
cd stacks/azure/sale-order/production
terraform output
```

### Update Infrastructure

```bash
# Make changes to main.tf or variables
terraform plan
terraform apply
```

### Destroy All Resources

```bash
cd stacks/azure/sale-order/production
terraform destroy
```

---

## Cost Estimation

| Resource | Estimated Monthly Cost |
|----------|----------------------|
| App Service Plan (1x S1) | ~$73 |
| PostgreSQL Flexible (B1ms) | ~$30 |
| Azure Container Registry (Basic) | ~$5 |
| Application Insights | ~$10 |
| Log Analytics | ~$10 |
| **Total** | **~$130/month** |

**Note:** A single shared App Service Plan is used for both frontend and backend.

---

## Security Best Practices

1. **Never commit terraform.tfvars** - Add to `.gitignore`
2. **Keep tfvars local** - Store production secrets in ignored `terraform.tfvars`
3. **Enable Managed Identity** - Already configured for ACR pull
4. **Use RBAC** - Assign minimum required roles

---

## Troubleshooting

### Azure Authentication Issues
```bash
az login
az account set --subscription "Azure subscription 1"
```

### Terraform Init Fails
```bash
cd stacks/azure/sale-order/production
rm -rf .terraform
terraform init
```

### View Resource Logs
```bash
az webapp log tail --name sale-order-backend --resource-group rg-hd-sales
```

---

## Support

For questions or issues, contact the engineering team.

---

**Maintainer:** Engineering Team  
**Version:** 1.0  
**Last Updated:** April 2026
