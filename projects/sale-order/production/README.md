# Azure Deployment Guide for Sale Order Application

## Overview

This guide provides step-by-step instructions to deploy the Sale Order full-stack application to Azure App Service.

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

Open `terraform.tfvars` and update the values as needed:

```hcl
# General
resource_group_name = "rg-hd-sales"
location             = "canadacentral"

# Azure Container Registry (existing)
acr_name = "salescontractapp"

# App Service Plan
app_service_plan_sku = "S1"

# App Service names
backend_app_name  = "sale-order-backend"
frontend_app_name = "sale-order-web"

# Database
db_sku_name       = "B_Standard_B1ms"
db_storage_mb     = 32768
db_admin_username = "saleadmin"
db_name           = "sale_order_db"
```

### 2.3 Set Sensitive Variables

Set the sensitive environment variables before running Terraform:

```bash
# Database admin password
export TF_VAR_db_admin_password="YourSecurePassword123!"

# Better Auth secret (generate with: openssl rand -hex 32)
export TF_VAR_better_auth_secret="your-generated-secret-here"
```

---

## Step 3: Deploy Infrastructure

### 3.1 Initialize Terraform

```bash
cd projects/sale-order/production
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
- 2 App Service Plans (Backend & Frontend)
- 2 Linux Web Apps with staging slots
- PostgreSQL Flexible Server
- Key Vault
- Application Insights
- Log Analytics Workspace

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

---

## Step 5: Configure App Service

> **Note:** Container configuration (image, registry URL) is now handled automatically by Terraform. The steps below are only needed if you need to update the container manually or for troubleshooting.

### 5.1 Set Container Image (Optional - Automatic via Terraform)

**Backend:**
```bash
az webapp config container set \
  --name sale-order-backend \
  --resource-group rg-hd-sales \
  --container-image-name salescontractapp.azurecr.io/sale-order-backend:latest \
  --container-registry-url https://salescontractapp.azurecr.io
```

**Frontend:**
```bash
az webapp config container set \
  --name sale-order-web \
  --resource-group rg-hd-sales \
  --container-image-name salescontractapp.azurecr.io/sale-order-web:latest \
  --container-registry-url https://salescontractapp.azurecr.io
```

> **Important:** The Terraform deployment already configures the container image and ACR registry automatically. Only run these commands if you need to manually update the container image or troubleshoot deployment issues.

### 5.2 Configure Environment Variables

#### Backend App Service Variables

| Variable | Value | Sensitive |
|----------|-------|-----------|
| `NODE_ENV` | `production` | No |
| `STAGE_ENV` | `production` | No |
| `DATABASE_URL` | From Terraform output | Yes |
| `BETTER_AUTH_SECRET` | Generated secret | Yes |
| `BETTER_AUTH_URL` | `https://sale-order-web.azurewebsites.net` | No |
| `AWS_ACCESS_KEY_ID` | Your AWS access key | Yes |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | Yes |
| `AWS_REGION` | `ca-central-1` | No |
| `AWS_S3_BUCKET` | Your S3 bucket name | No |
| `AWS_S3_ENDPOINT` | `https://s3.ca-central-1.amazonaws.com` | No |
| `MICROSOFT_CLIENT_ID` | Azure AD app client ID | Yes |
| `MICROSOFT_CLIENT_SECRET` | Azure AD app secret | Yes |
| `MICROSOFT_TENANT_ID` | Azure AD tenant ID | Yes |
| `DOCUSEAL_API_KEY` | DocuSeal API key | Yes |
| `DOCUSEAL_WEBHOOK_SECRET` | Webhook secret | Yes |
| `MAILGUN_API_KEY` | Mailgun API key | Yes |
| `MAILGUN_DOMAIN` | Mailgun domain | No |
| `SEND_FROM_EMAIL` | Sender email | No |
| `API_HEALTH_URL` | `https://sale-order-backend.azurewebsites.net/api/v1/health` | No |

**Set Backend Variables:**
```bash
az webapp config appsettings set \
  --name sale-order-backend \
  --resource-group rg-hd-sales \
  --settings \
    NODE_ENV=production \
    STAGE_ENV=production \
    BETTER_AUTH_SECRET="your-secret" \
    BETTER_AUTH_URL="https://sale-order-web.azurewebsites.net" \
    AWS_REGION="ca-central-1" \
    AWS_S3_BUCKET="your-bucket" \
    AWS_S3_ENDPOINT="https://s3.ca-central-1.amazonaws.com"
```

#### Frontend App Service Variables

| Variable | Value | Sensitive |
|----------|-------|-----------|
| `NODE_ENV` | `production` | No |
| `NEXT_PUBLIC_STAGE_ENV` | `production` | No |
| `NEXT_PUBLIC_API_BASE_URL` | `https://sale-order-backend.azurewebsites.net/api/v1/` | No |
| `BETTER_AUTH_SECRET` | Same as backend | Yes |
| `BETTER_AUTH_URL` | `https://sale-order-web.azurewebsites.net` | No |

**Set Frontend Variables:**
```bash
az webapp config appsettings set \
  --name sale-order-web \
  --resource-group rg-hd-sales \
  --settings \
    NODE_ENV=production \
    NEXT_PUBLIC_STAGE_ENV=production \
    NEXT_PUBLIC_API_BASE_URL="https://sale-order-backend.azurewebsites.net/api/v1/" \
    BETTER_AUTH_SECRET="your-secret" \
    BETTER_AUTH_URL="https://sale-order-web.azurewebsites.net"
```

### 5.3 Configure Startup Command

**Backend:**
```bash
az webapp config set \
  --name sale-order-backend \
  --resource-group rg-hd-sales \
  --startup-command "yarn start:prod"
```

**Frontend:**
```bash
az webapp config set \
  --name sale-order-web \
  --resource-group rg-hd-sales \
  --startup-command "yarn start"
```

### 5.4 Enable Health Check

```bash
az webapp config set \
  --name sale-order-backend \
  --resource-group rg-hd-sales \
  --health-check-path "/api/v1/health"
```

---

## Step 6: Verify Deployment

### 6.1 Check Backend Health

```bash
curl https://sale-order-backend.azurewebsites.net/api/v1/health
```

Expected response: `OK`

### 6.2 Check Frontend

```bash
curl https://sale-order-web.azurewebsites.net
```

Expected: Next.js application loads

---

## Step 7: Internal Container Networking

See [NETWORKING.md](NETWORKING.md) for detailed information about:
- How frontend communicates with backend
- Database connectivity
- Security configuration
- Troubleshooting tips

### Quick Overview

| Connection | Environment Variable | Example |
|------------|---------------------|---------|
| Frontend → Backend | `NEXT_PUBLIC_API_BASE_URL` | `https://sale-order-backend.azurewebsites.net/api/v1/` |
| Backend → Database | `DATABASE_URL` | From Terraform output |

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
2. **Use Azure Key Vault** - Store secrets in KV for production
3. **Enable Managed Identity** - Already configured in Terraform for ACR pull
4. **CORS** - Update backend CORS to allow frontend domain

### CORS Configuration

In your backend `main.ts`, add:

```typescript
app.enableCors({
  origin: ['https://sale-order-web.azurewebsites.net'],
  credentials: true,
});
```

### Database Connection

The database connection string from Terraform output follows this format:
```
postgresql://username:password@hostname:5432/database?sslmode=require
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

**Document Version:** 1.0  
**Last Updated:** April 2026  
**Author:** Engineering Team
