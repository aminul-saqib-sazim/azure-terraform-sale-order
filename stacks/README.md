# Stack Layout

Deployable roots live under `stacks/<cloud>/<application>/<environment>`.

Current convention:

- `stacks/azure/...` for Azure roots
- `stacks/aws/...` for future AWS roots
- `stacks/gcp/...` for future GCP roots

This keeps provider-specific entrypoints separate while allowing the same application to exist across clouds without mixing provider concerns in one directory.
