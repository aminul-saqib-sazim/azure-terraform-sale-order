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
| **Secrets** | Key Vault | Secure secret storage |
| **Monitoring** | Application Insights + Log Analytics | Observability |

---

## Repository Structure

```
azure-terraform-sale-order/
├── modules/                              # Reusable Terraform modules
│   └── azure/
│       ├── app-service/                  # App Service + Plan + Slot
│       └── database/                    # PostgreSQL Flexible Server
│
├── projects/                            # Project-specific configurations
│   └── sale-order/
│       └── production/
│           ├── main.tf                  # Main configuration
│           ├── variables.tf             # Variable definitions
│           ├── terraform.tfvars.example # Example variables
│           ├── README.md                # Deployment guide
│           └── outputs.tf               # Output values
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
   cd projects/sale-order/production
   ```

2. **Configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Set sensitive variables**
   ```bash
   export TF_VAR_db_admin_password="YourPassword123"
   export TF_VAR_better_auth_secret="$(openssl rand -hex 32)"
   ```

4. **Deploy infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Build and deploy applications**
   
   See [projects/sale-order/production/README.md](projects/sale-order/production/README.md) for complete Docker build and App Service configuration steps.

---

## Environment Variables Required

### For Terraform

| Variable | Description | Sensitive |
|----------|-------------|-----------|
| `TF_VAR_db_admin_password` | Database admin password | Yes |
| `TF_VAR_better_auth_secret` | Better Auth secret | Yes |

### For Backend App Service

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment | `production` |
| `DATABASE_URL` | PostgreSQL connection | From Terraform output |
| `BETTER_AUTH_SECRET` | Auth secret | Generated |
| `BETTER_AUTH_URL` | Frontend URL | `https://sale-order-web.azurewebsites.net` |
| `AWS_ACCESS_KEY_ID` | AWS access key | From AWS IAM |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | From AWS IAM |
| `AWS_REGION` | AWS region | `ca-central-1` |
| `AWS_S3_BUCKET` | S3 bucket name | `sale-order-prod` |
| `MICROSOFT_CLIENT_ID` | Azure AD client ID | From Azure Portal |
| `MICROSOFT_CLIENT_SECRET` | Azure AD client secret | From Azure Portal |
| `DOCUSEAL_API_KEY` | DocuSeal API key | From DocuSeal |
| `MAILGUN_API_KEY` | Mailgun API key | From Mailgun |

### For Frontend App Service

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment | `production` |
| `NEXT_PUBLIC_API_BASE_URL` | Backend API URL | `https://sale-order-backend.azurewebsites.net/api/v1/` |
| `BETTER_AUTH_SECRET` | Auth secret | Same as backend |
| `BETTER_AUTH_URL` | Frontend URL | `https://sale-order-web.azurewebsites.net` |

---

## Azure Resources Created

### Resource Group: rg-hd-sales

| Resource | Name | SKU/Type |
|----------|------|----------|
| App Service Plan (Backend) | sale-order-prod-sp | Standard S1 |
| App Service Plan (Frontend) | sale-order-prod-fe-sp | Standard S1 |
| Linux Web App (Backend) | sale-order-backend | Linux, Standard S1 |
| Linux Web App (Frontend) | sale-order-web | Linux, Standard S1 |
| Web App Slot (Backend) | staging | Included |
| Web App Slot (Frontend) | staging | Included |
| PostgreSQL Flexible Server | sale-order-prod-db | B_Standard_B1ms |
| Key Vault | sale-order-prod-kv | Standard |
| Application Insights | sale-order-prod-ai | web |
| Log Analytics Workspace | sale-order-prod-law | PerGB2018 |

---

## Documentation

| Document | Description |
|----------|-------------|
| [projects/sale-order/production/README.md](projects/sale-order/production/README.md) | Detailed deployment guide |
| [../../azure-migration-plan.md](../../azure-migration-plan.md) | Migration plan from DigitalOcean |

---

## Common Tasks

### View Outputs After Deployment

```bash
cd projects/sale-order/production
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
cd projects/sale-order/production
terraform destroy
```

---

## Cost Estimation

| Resource | Estimated Monthly Cost |
|----------|----------------------|
| App Service Plan (1x S1 - shared) | ~$73 |
| PostgreSQL Flexible (B1ms) | ~$30 |
| Application Insights | ~$10 |
| Log Analytics | ~$10 |
| **Total** | **~$123/month** |

**Note:** Single shared App Service Plan for both frontend and backend for cost optimization.

---

## Security Best Practices

1. **Never commit terraform.tfvars** - Add to `.gitignore`
2. **Use Azure Key Vault** - Store secrets in KV for production
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
cd projects/sale-order/production
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
