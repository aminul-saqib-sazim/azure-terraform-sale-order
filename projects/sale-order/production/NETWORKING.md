# Internal Container Networking Guide

## Overview

This document explains how the frontend and backend containers communicate in the Azure App Service deployment, along with database connectivity and security considerations.

---

## Current Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Azure App Service (Public Endpoints)             │
│                                                                      │
│  ┌──────────────────────┐         ┌──────────────────────┐        │
│  │   sale-order-web    │         │  sale-order-backend   │        │
│  │   (Frontend)       │         │   (Backend API)       │        │
│  │                    │         │                      │        │
│  │   Port: 443 (HTTPS)│◄────────►│  Port: 443 (HTTPS)    │        │
│  │                    │   API   │                      │        │
│  └──────────────────────┘         └──────────┬───────────┘        │
│               │                                  │                  │
│               │                                  │                  │
│               │        NEXT_PUBLIC_API_BASE_URL │                  │
│               │          (environment variable)    │                  │
│               ▼                                  ▼                  │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              Public Internet (HTTPS)                       │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
         │
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│              Azure PostgreSQL Flexible Server                    │
│                                                              │
│  • Public endpoint enabled                                     │
│  • Firewall rules for Azure services and client IP           │
│  • Connection: DATABASE_URL from Terraform output             │
│                                                              │
│  Connection string format:                                     │
│  postgresql://user:pass@host:5432/db?sslmode=require            │
└────────────────────────────────────────────────────────────────┘
```

---

## How Frontend Connects to Backend

### Environment Variable Configuration

The frontend connects to the backend using the `NEXT_PUBLIC_API_BASE_URL` environment variable:

```bash
# Frontend App Service Environment Variable
NEXT_PUBLIC_API_BASE_URL=https://sale-order-backend.azurewebsites.net/api/v1/
```

### API Call Flow

1. **Frontend** (sale-order-web.azurewebsites.net)
   - Makes API calls to `NEXT_PUBLIC_API_BASE_URL`
   - Example: `GET https://sale-order-backend.azurewebsites.net/api/v1/sale-orders`

2. **Backend** (sale-order-backend.azurewebsites.net)
   - Receives the request
   - Processes business logic
   - Connects to PostgreSQL database
   - Returns JSON response

### CORS Configuration

The backend must allow the frontend domain for API calls. Add to backend `main.ts`:

```typescript
app.enableCors({
  origin: ['https://sale-order-web.azurewebsites.net'],
  credentials: true,
});
```

---

## How Backend Connects to Database

### Database Connection String

The backend uses `DATABASE_URL` environment variable:

```
postgresql://saleadmin:password@sale-order-prod-db.postgres.database.azure.com:5432/sale_order_db?sslmode=require
```

### Configuration in Terraform

The database connection string is output from Terraform after deployment:

```bash
terraform output db_connection_string
```

### Setting as Environment Variable

```bash
# Set in App Service
az webapp config appsettings set \
  --name sale-order-backend \
  --resource-group rg-hd-sales \
  --settings DATABASE_URL="postgresql://..."
```

---

## Communication Flow Diagram

```
┌─────────────┐     HTTPS      ┌─────────────┐     DATABASE_URL    ┌─────────────┐
│  Frontend   │ ────────────► │   Backend   │ ──────────────────►  │ PostgreSQL  │
│  (Next.js)  │    API Call   │   (NestJS)  │    SQL Queries       │  Database  │
└─────────────┘               └─────────────┘                      └─────────────┘

1. User visits https://sale-order-web.azurewebsites.net
2. Frontend loads Next.js application
3. User action triggers API call to backend
4. Frontend → Backend: GET /api/v1/sale-orders
5. Backend validates request
6. Backend → Database: SELECT * FROM sale_orders
7. Database returns data
8. Backend → Frontend: JSON response
9. Frontend displays data to user
```

---

## Security Considerations

### Current Setup (Public Endpoints)

| Component | Security | Notes |
|-----------|----------|-------|
| Frontend URL | HTTPS only | TLS/SSL enabled |
| Backend URL | HTTPS only | TLS/SSL enabled |
| Database | Firewall rules | Azure services + client IP allowed |
| API Authentication | Better Auth | Token-based authentication |
| OAuth | Microsoft SSO | Azure AD authentication |

### Recommended Security Practices

1. **Use HTTPS only** - All traffic is encrypted
2. **Keep secrets in Key Vault** - Don't hardcode credentials
3. **Enable CORS** - Restrict allowed origins
4. **Use Managed Identities** - For ACR pull (already configured)
5. **Rotate secrets periodically** - Database password, auth secrets

---

## Future Enhancements (Out of Scope)

### Private Networking (Planned for Future)

When you're ready for enhanced security:

1. **VNet Integration**
   - Connect App Service to Azure Virtual Network
   - Enable private networking between components

2. **Private Endpoints**
   - Access PostgreSQL via private endpoints
   - No public internet access to database

3. **Azure Front Door / CDN**
   - Add CDN for static assets
   - Custom domain with SSL

4. **Web Application Firewall (WAF)**
   - Protect against common web attacks
   - Rate limiting

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| CORS error | Add frontend URL to backend CORS configuration |
| Database connection failed | Check DATABASE_URL format and firewall rules |
| 502 Bad Gateway | Check backend is running and health check passes |
| Image pull failed | Verify ACR permissions and managed identity |

### Check Connectivity

```bash
# Test backend health
curl https://sale-order-backend.azurewebsites.net/api/v1/health

# Test frontend
curl https://sale-order-web.azurewebsites.net

# View logs
az webapp log tail --name sale-order-backend --resource-group rg-hd-sales
```

---

## Related Documentation

- [Deployment Guide](../production/README.md)
- [Azure Migration Plan](../../azure-migration-plan.md)

---

**Last Updated:** April 2026  
**Version:** 1.0