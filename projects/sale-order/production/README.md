# Azure Deployment Guide for Sale Order Application

## Overview

This guide provides step-by-step instructions to deploy the Sale Order full-stack application to Azure App Service.

> **Important:** All environment variables are now **automatically configured via Terraform** - no manual Azure Portal configuration needed!

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Azure Cloud                                   │
│                                                                      │
│   ┌─────────────────────┐        ┌─────────────────────────────┐   │
│   │   App Service       │        │   Azure Container Registry  │   │
│   │   (Frontend)        │        │   (salescontractapp)       │   │
│   │   sale-order-web    │        │                             │   │
│   └──────────┬──────────┘        └─────────────────────────────┘   │
│              │                                                         │
│              │ API calls                                               │
│              ▼                                                         │
│   ┌─────────────────────┐        ┌─────────────────────────────┐   │
│   │   App Service       │        │   Azure Database            │   │
│   │   (Backend)         │───────▶│   for PostgreSQL            │   │
│   │   sale-order-backend    │        │   Flexible Server           │   │
│   └─────────────────────┘        │   B_Standard_B1ms (1vCore) │   │
│                                  └─────────────────────────────┘   │
│   ┌─────────────────────┐                                           │
│   │   AWS S3            │                                           │
│   │   (Production)      │                                           │
│   └─────────────────────┘                                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Azure CLI | >= 2.50.0 | Manage Azure resources |
| Terraform | >= 1.9.0 | Infrastructure as Code |
| Docker | >= 20.10 | Build container images |

### Verify Prerequisites

```bash
az --version
terraform --version
docker --version
```

---

## Step 1: Azure Authentication

```bash
# Login to Azure
az login

# Set the subscription (if you have multiple)
az account set --subscription "Azure subscription 1"
```

---

## Step 2: Configure Terraform Variables

### 2.1 Copy the example file

```bash
cd projects/sale-order/production
cp terraform.tfvars.example terraform.tfvars
```

### 2.2 Edit terraform.tfvars

Open `terraform.tfvars` and fill in all the values. The file includes:

- **General**: resource_group_name, location, acr_name
- **App Service**: app_service_plan_sku, backend_app_name, frontend_app_name, startup commands
- **Database**: db_sku_name, db_storage_mb, db_admin_username, db_name
- **AWS/S3**: aws_access_key_id, aws_secret_access_key, do_spaces_bucket_name, etc.
- **Microsoft SSO**: microsoft_client_id, microsoft_client_secret, microsoft_tenant_id
- **DocuSeal**: docuseal_api_key, docuseal_webhook_secret
- **Mailgun**: mailgun_api_key, mailgun_domain, send_from_email
- **Admin Accounts**: developer_email, admin_email, etc.

### 2.3 Set Sensitive Variables

Sensitive values can be set via environment variables (recommended) or in tfvars:

```bash
# Database admin password
export TF_VAR_db_admin_password="YourSecurePassword123!"

# Better Auth secret (generate with: openssl rand -hex 32)
export TF_VAR_better_auth_secret="$(openssl rand -hex 32)"

# Optional: Additional sensitive variables
export TF_VAR_developer_password="..."
export TF_VAR_admin_password="..."
export TF_VAR_organization_owner_password="..."
```

---

## Step 3: Deploy Infrastructure

### 3.1 Initialize Terraform

```bash
terraform init
```

### 3.2 Plan the deployment

```bash
terraform plan
```

Review the output to ensure it matches your expectations.

### 3.3 Apply the deployment

```bash
terraform apply
```

This will create:
- ✅ Shared App Service Plan (S1)
- ✅ Backend Linux Web App with prod slot
- ✅ Frontend Linux Web App with prod slot
- ✅ PostgreSQL Flexible Server
- ✅ Application Insights
- ✅ Log Analytics Workspace
- ✅ **All environment variables** automatically configured in App Service
- ✅ ACR credentials for image pull (via app_settings)

### 3.4 Note the outputs

After deployment, note the following outputs:
- `backend_app_url` - Backend URL
- `frontend_app_url` - Frontend URL
- `db_fqdn` - Database hostname
- `db_connection_string` - Database connection string
- `key_vault_name` - Key Vault name

---

## Step 4: Build and Push Docker Images

### 4.1 Login to ACR

```bash
az acr login --name salescontractapp
```

### 4.2 Build Backend Image

```bash
# Navigate to backend directory
cd ../../../sales-order-backend

# Build the Docker image
docker build \
  -t salescontractapp.azurecr.io/sale-order-backend:latest \
  -f infra/dockerfiles/Dockerfile .

# Push to ACR
docker push salescontractapp.azurecr.io/sale-order-backend:latest
```

### 4.3 Build Frontend Image

```bash
# Navigate to frontend directory
cd ../sales-order-web

# Build the Docker image
docker build \
  -t salescontractapp.azurecr.io/sale-order-web:latest \
  -f infra/dockerfiles/Dockerfile .

# Push to ACR
docker push salescontractapp.azurecr.io/sale-order-web:latest
```

> **Important:** Container image pull works automatically because ACR admin is enabled. No manual ACR credentials needed!

---

## Step 5: Verify Deployment

### 5.1 Restart App Services (to pull new images)

```bash
az webapp restart --name sale-order-backend --resource-group rg-hd-sales
az webapp restart --name sale-order-web --resource-group rg-hd-sales
```

### 5.2 Check Backend Health

```bash
curl https://sale-order-backend.azurewebsites.net/api/v1/health
```

Expected response: `OK`

### 5.3 Check Frontend

```bash
curl https://sale-order-web.azurewebsites.net
```

Expected: Next.js application loads

---

## Environment Variables (Automatic)

All environment variables are automatically configured by Terraform. Here's what's set:

### Backend App Settings

| Variable | Value | Source |
|----------|-------|--------|
| `NODE_ENV` | `production` | Static |
| `STAGE_ENV` | `production` | Static |
| `BE_PORT` | `5000` | Static |
| `API_BASE_URL` | Backend URL | Auto-generated |
| `API_HEALTH_URL` | Backend URL + /api/v1/health | Auto-generated |
| `DATABASE_URL` | PostgreSQL connection string | Auto-generated |
| `WEB_CLIENT_BASE_URL` | Frontend URL | Auto-generated |
| `BETTER_AUTH_URL` | Frontend URL | Auto-generated |
| `BETTER_AUTH_SECRET` | From TF_VAR_ | User-provided |
| AWS/S3 variables | From tfvars | User-provided |
| Microsoft SSO variables | From tfvars | User-provided |
| DocuSeal variables | From tfvars | User-provided |
| Mailgun variables | From tfvars | User-provided |
| Admin account variables | From tfvars | User-provided |

### Frontend App Settings

| Variable | Value | Source |
|----------|-------|--------|
| `NODE_ENV` | `production` | Static |
| `NEXT_PUBLIC_STAGE_ENV` | `production` | Static |
| `NEXT_PUBLIC_API_BASE_URL` | Backend URL + /api/v1/ | Auto-generated |
| `BETTER_AUTH_SECRET` | From TF_VAR_ | User-provided |
| `BETTER_AUTH_URL` | Frontend URL | Auto-generated |

---

## Step 6: Internal Container Networking

See [NETWORKING.md](NETWORKING.md) for detailed information about:
- How frontend communicates with backend
- Database connectivity
- Security configuration
- Troubleshooting tips

### Quick Overview

| Connection | Environment Variable | Example |
|------------|---------------------|---------|
| Frontend → Backend | `NEXT_PUBLIC_API_BASE_URL` | `https://sale-order-backend.azurewebsites.net/api/v1/` |
| Backend → Database | `DATABASE_URL` | Auto-generated |

### CORS Configuration

Add to backend `main.ts`:

```typescript
app.enableCors({
  origin: ['https://sale-order-web.azurewebsites.net'],
  credentials: true,
});
```

---

## Important Notes

### Security

1. **Never commit terraform.tfvars** - It contains sensitive data
2. **Use TF_VAR_ for secrets** - More secure than tfvars
3. **Enable Managed Identity** - Already configured in Terraform for ACR pull

### CORS Configuration

In your backend `main.ts`, add:

```typescript
app.enableCors({
  origin: ['https://sale-order-web.azurewebsites.net'],
  credentials: true,
});
```

---

## Troubleshooting

### View Logs

```bash
# Backend logs
az webapp log tail --name sale-order-backend --resource-group rg-hd-sales

# Frontend logs
az webapp log tail --name sale-order-web --resource-group rg-hd-sales
```

### Restart App Service

```bash
# Backend
az webapp restart --name sale-order-backend --resource-group rg-hd-sales

# Frontend
az webapp restart --name sale-order-web --resource-group rg-hd-sales
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Container not starting | Check startup command and logs |
| Database connection failed | Verify DATABASE_URL and firewall rules |
| Image pull failed | Check ACR permissions and managed identity |
| 502 Bad Gateway | Check health check path and app startup |

---

## Cost Estimation

| Resource | SKU | Estimated Cost (monthly) |
|----------|-----|-------------------------|
| App Service Plan | S1 (1x shared) | ~$73/month |
| PostgreSQL Flexible | B_Standard_B1ms | ~$30/month |
| Application Insights | Pay-as-you-go | ~$10/month |
| Log Analytics | PerGB2018 | ~$10/month |
| **Total** | | **~$123/month** |

**Note:** Single shared App Service Plan for both frontend and backend for cost optimization (~50% savings).

---

## Cleanup

To delete all resources:

```bash
terraform destroy
```

---

## Support

For issues or questions, contact the engineering team.

---

**Document Version:** 2.0  
**Last Updated:** April 2026  
**Author:** Engineering Team