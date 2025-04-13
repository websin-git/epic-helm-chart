# EpicRM Helm Chart

This Helm chart deploys the **EpicRM backend API**, optionally including a PostgreSQL database.

## Overview

- Deploys the **FastAPI-based backend** container.
- Optionally deploys a **PostgreSQL database** (or connects to an external one).
- Includes **Ingress** configuration for Traefik with Let's Encrypt TLS.
- Requires two pre-created **Kubernetes Secrets** for configuration.

## Structure

| Component      | Description                                                 |
|----------------|-------------------------------------------------------------|
| `api`          | The core FastAPI application container                      |
| `postgresql`   | Optional database deployment (can be disabled)              |
| `service`      | Internal Kubernetes service exposing the API                |
| `ingress`      | Public routing via subdomain with TLS support               |

## Configuration Options

You can customize the following values via `values.yaml` before deploying:

```yaml
api:
  image.repository: <Container image>        # Change if using a custom image
  image.tag: <Image tag>                     # e.g. 'latest' or '0.1.2'
  envFromSecret: epic-api-secret             # Kubernetes secret with environment variables for the app

  health:
    livenessProbe:                           # Optional liveness check config
    readinessProbe:                          # Optional readiness check config

postgresql:
  enabled: true                              # Set to false to use external database
  auth.existingSecret: epic-db-secret        # Secret containing DB credentials

service:
  type: ClusterIP                            # Normally not changed
  port: 8000                                 # Port exposed within the cluster

ingress:
  enabled: true
  className: traefik
  host: api.example.com                      # Domain for public access
  tlsSecret: epic-api-tls                    # TLS certificate secret name
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
```

## Required Kubernetes Secrets

Create the following secrets before deploying the chart.

### 1. API Secret (`api.envFromSecret`)

This secret holds all environment variables required by the FastAPI application:

```bash
kubectl create secret generic epic-api-secret \
  --from-literal=MODE=production \
  --from-literal=DB_HOST=epicrm-postgres \
  --from-literal=DB_NAME=epicrm \
  --from-literal=DB_USER=epicuser \
  --from-literal=DB_PASS=changeme \
  -n <namespace>
```

### 2. Database Secret (`postgresql.auth.existingSecret`)

This secret provides the credentials for the PostgreSQL database (whether internal or external):

```bash
kubectl create secret generic epic-db-secret \
  --from-literal=db-name=epicrm \
  --from-literal=db-user=epicuser \
  --from-literal=password=changeme \
  -n <namespace>
```

## Deployment

Use the following command to deploy the chart:

```bash
helm upgrade --install epicrm epicrm/ \
  --namespace epicrm-<customer> \
  --values values.yaml \
  --version 0.1.0
```

## Notes

- **Resource names are static** to ensure simplicity and consistent deployments.
- If the deployment fails, check if all required secrets exist and are correctly named in the given namespace.
