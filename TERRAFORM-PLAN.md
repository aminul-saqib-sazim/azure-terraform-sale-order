# Terraform Plan Explanation

This document explains what resources will be created when `terraform apply` is executed.

## Summary

```
Plan: 18 to add, 0 to change, 0 to destroy.
```

18 Azure resources will be created for the Sale Order application.

---

## Resource Breakdown

### 1. Shared App Service Plan

```
Resource: azurerm_service_plan.shared
Name: sale-order-prod-sp
SKU: S1
Location: canadacentral
```

**Purpose**: Single shared Linux App Service plan for both backend and frontend.
- **Cost**: ~$73/month (vs ~$146/month if using 2 separate plans)
- **OS**: Linux
- **SKU**: S1 (1 vCore, 1.75 GB RAM)

---

### 2. Backend App Service

```
Resource: azurerm_linux_web_app (module.app_service_backend)
Name: sales-order-backend
Location: canadacentral
Health Check: /api/v1/health
```

**Purpose**: NestJS backend application

**Configuration**:

| Setting | Value |
|---------|-------|
| Always On | Enabled |
| HTTP/2 | Enabled |
| TLS Version | 1.2 |
| Health Check Path | `/api/v1/health` |
| Health Check Eviction | 2 minutes |
| Container Image | `salescontractapp.azurecr.io/sale-order-backend:latest` |
| Container Registry | `https://salescontractapp.azurecr.io` |

**Identity**: SystemAssigned (managed identity for ACR pull)

---

### 3. Backend Deployment Slot

```
Resource: azurerm_linux_web_app_slot (module.app_service_backend)
Name: production
```

**Purpose**: Production slot for the backend (allows blue-green deployments)
- Same configuration as main app
- Uses the same container image
- Has its own managed identity

---

### 4. Frontend App Service

```
Resource: azurerm_linux_web_app (module.app_service_frontend)
Name: sales-order-web
Location: canadacentral
Health Check: /
```

**Purpose**: Next.js frontend application

**Configuration**:

| Setting | Value |
|---------|-------|
| Always On | Enabled |
| HTTP/2 | Enabled |
| TLS Version | 1.2 |
| Health Check Path | `/` |
| Container Image | `salescontractapp.azurecr.io/sale-order-web:latest` |
| Container Registry | `https://salescontractapp.azurecr.io` |

**Identity**: SystemAssigned

---

### 5. Frontend Deployment Slot

```
Resource: azurerm_linux_web_app_slot (module.app_service_frontend)
Name: production
```

**Purpose**: Production slot for the frontend

---

### 6. ACR Pull Role Assignments

```
Resources: azurerm_role_assignment (4 total)
- Backend Main App → AcrPull
- Backend Slot → AcrPull
- Frontend Main App → AcrPull
- Frontend Slot → AcrPull
Scope: /subscriptions/.../rg-hd-sales/.../salescontractapp
```

**Purpose**: Grants both apps permission to pull images from the existing ACR without storing credentials.

---

### 7. PostgreSQL Flexible Server

```
Resource: azurerm_postgresql_flexible_server (module.database)
Name: sale-order-prod-db
SKU: B_Standard_B1ms
Version: 16
Storage: 32 GB
Location: canadacentral
```

**Configuration**:

| Setting | Value |
|---------|-------|
| SKU | B_Standard_B1ms (1 vCore, 2GB) |
| PostgreSQL Version | 16 |
| Storage | 32 GB |
| Auto Grow | Disabled |
| Backup Retention | 14 days |
| Geo-redundant Backup | Disabled |
| Public Network Access | Enabled |

**Cost**: ~$35/month (Basic tier)

---

### 8. PostgreSQL Database

```
Resource: azurerm_postgresql_flexible_server_database
Name: sale_order_db
Charset: UTF8
Collation: en_US.utf8
```

**Purpose**: Main application database

---

### 9. PostgreSQL Firewall Rules

```
Resource: azurerm_postgresql_flexible_server_firewall_rule
- AllowAzureServices: 0.0.0.0 → 0.0.0.0
- AllowClientIP: 0.0.0.0 → 0.0.0.0
```

**Purpose**:
- **AllowAzureServices**: Allows Azure services to connect to the database
- **AllowClientIP**: Allows your local machine to connect (for development)

> **Security Note**: In production, you should restrict `AllowClientIP` to your specific IP address.

---

### 10. Key Vault

```
Resource: azurerm_key_vault
Name: sale-order-prod-kv
SKU: standard
Location: canadacentral
Tenant: f480eed2-167f-4661-a2ee-ce2d5a29ecf4
```

**Purpose**: Secure storage for secrets

---

### 11. Key Vault Secrets

| Secret Name | Purpose |
|-------------|---------|
| `db-password` | PostgreSQL admin password |
| `better-auth-secret` | Better Auth authentication secret |

Both secrets are stored securely and can be referenced by App Service.

---

### 12. Application Insights

```
Resource: azurerm_application_insights
Name: sale-order-prod-ai
Location: canadacentral
Application Type: web
Retention: 30 days
```

**Purpose**: Application Performance Monitoring (APM)
- Tracks exceptions, dependencies, requests
- Provides metrics and alerts
- Integrates with Log Analytics

---

### 13. Log Analytics Workspace

```
Resource: azurerm_log_analytics_workspace
Name: sale-order-prod-law
Location: canadacentral
SKU: PerGB2018
Retention: 30 days
```

**Purpose**: Centralized log storage for:
- App Service logs
- Application Insights data
- Diagnostic logs

---

## Outputs

After apply, these values will be available:

| Output | Description |
|--------|-------------|
| `backend_app_url` | Backend URL (e.g., `https://sales-order-backend.azurewebsites.net`) |
| `frontend_app_url` | Frontend URL (e.g., `https://sales-order-web.azurewebsites.net`) |
| `db_fqdn` | Database hostname |
| `db_connection_string` | Full connection string (sensitive) |
| `key_vault_name` | Key Vault name |
| `application_insights_instrumentation_key` | AI instrumentation key (sensitive) |
| `acr_login_server` | ACR login server |
| `app_service_plan_name` | Shared service plan name |

---

## Cost Estimation

| Resource | Monthly Cost (CAD) |
|----------|-------------------|
| App Service Plan (S1) | ~$73 |
| PostgreSQL Flexible Server (B1ms) | ~$35 |
| Application Insights | ~$5-10 |
| Log Analytics | ~$5-10 |
| Key Vault | Free |
| **Total** | **~$118-128/month** |

---

## Security Considerations

1. **Firewall Rules**: Currently open to `0.0.0.0` - restrict in production
2. **HTTPS Only**: Not enabled by default - consider enabling
3. **Client Certificates**: Mode set to "Required" - verify app handles this
4. **Public Network Access**: Enabled for PostgreSQL - consider VNet in production

---

## Next Steps After Apply

1. **Build and push Docker images** to ACR
2. **Configure environment variables** in App Service (if not set via Terraform)
3. **Verify health checks** are working
4. **Update DNS** if using custom domain
5. **Enable HTTPS only** for production security

---

## Troubleshooting

If deployment fails:
- Check Application Insights for errors
- Verify container images exist in ACR
- Ensure managed identities have ACR Pull role
- Check health check path returns 200 OK