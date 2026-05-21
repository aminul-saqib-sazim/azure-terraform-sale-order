# Module Layout

Reusable modules live under `modules/<cloud>/<module-name>`.

Examples:

- `modules/azure/app-service`
- `modules/azure/database`
- `modules/digitalocean/<module-name>`

When AWS, DigitalOcean, or GCP support is added, follow the same pattern instead of mixing providers inside one module tree.
