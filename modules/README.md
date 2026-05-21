# Module Layout

Reusable modules live under `modules/<cloud>/<module-name>`.

Examples:

- `modules/azure/app-service`
- `modules/azure/database`

When AWS or GCP support is added, follow the same pattern instead of mixing providers inside one module tree.
