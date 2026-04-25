# KubeKitchen GitOps Repository

This repository contains the **Helm umbrella chart** for the KubeKitchen cloud kitchen platform, managed by **ArgoCD**.

## Repository Structure

```
gitops-kubekitchen/
├── argocd/
│   ├── application-dev.yaml       # ArgoCD Application for dev namespace
│   └── application-prod.yaml      # ArgoCD Application for prod namespace
│
└── kubekitchen-helm/              # Umbrella Helm chart
    ├── Chart.yaml                 # Umbrella chart definition + dependencies
    ├── values.yaml                # Global defaults (all environments)
    ├── values-dev.yaml            # Dev environment overrides
    ├── values-prod.yaml           # Prod environment overrides
    ├── templates/
    │   ├── serviceaccount.yaml    # Shared ServiceAccount (kubekitchen-sa)
    │   └── secret.yaml            # kubekitchen-secrets (see ⚠️ below)
    └── charts/
        ├── auth-service/          # Auth microservice chart
        ├── restaurant-service/    # Restaurant microservice chart
        ├── menu-service/          # Menu microservice chart
        ├── order-service/         # Order microservice chart
        ├── frontend/              # Frontend web app chart
        ├── mongodb/               # MongoDB StatefulSets (4 instances)
        └── seeder/                # DB seeder Job (post-install hook)
```

## ArgoCD Sync Waves

Resources deploy in this order via ArgoCD sync waves:

| Wave | Resource |
|------|----------|
| -1   | Namespace, ServiceAccount, Secret |
| 0    | PersistentVolumeClaims |
| 1    | MongoDB StatefulSets |
| 2    | Backend microservices (auth, restaurant, menu, order) |
| 3    | Frontend |
| 5    | Seeder Job (post-install hook) |

## ⚠️ Secret Management

The `templates/secret.yaml` uses values from `values.yaml` directly. **This is only safe for development.**

**For production**, use one of:
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [External Secrets Operator](https://external-secrets.io/) with AWS SSM / GCP SM / HashiCorp Vault
- [ArgoCD Vault Plugin](https://argocd-vault-plugin.readthedocs.io/)

## ArgoCD Setup

### 1. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Register Your GitOps Repo (Private)

```bash
argocd repo add https://github.com/YOUR_USERNAME/gitops-kubekitchen.git \
  --username YOUR_USERNAME \
  --password YOUR_PAT_TOKEN
```

### 3. Apply the Application Manifests

```bash
# Dev environment
kubectl apply -f argocd/application-dev.yaml

# Prod environment
kubectl apply -f argocd/application-prod.yaml
```

### 4. Update the repoURL

Edit `argocd/application-dev.yaml` and `argocd/application-prod.yaml`:
```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/gitops-kubekitchen.git  # ← Change this
```

## Manual Helm Commands (for testing)

```bash
# Lint the umbrella chart
helm lint kubekitchen-helm/

# Dry-run to see rendered templates
helm template kubekitchen kubekitchen-helm/ \
  -f kubekitchen-helm/values.yaml \
  -f kubekitchen-helm/values-dev.yaml \
  --namespace kubekitchen-dev

# Install dev (without ArgoCD)
helm upgrade --install kubekitchen kubekitchen-helm/ \
  -f kubekitchen-helm/values.yaml \
  -f kubekitchen-helm/values-dev.yaml \
  --namespace kubekitchen-dev \
  --create-namespace
```

## Microservices

| Service | Port | MongoDB | Image |
|---------|------|---------|-------|
| auth-service | 4001 | mongodb-auth | secretpower/kubekitchen-auth-service |
| restaurant-service | 4002 | mongodb-restaurant | secretpower/kubekitchen-restaurant-service |
| menu-service | 4003 | mongodb-menu | secretpower/kubekitchen-menu-service |
| order-service | 4004 | mongodb-order | secretpower/kubekitchen-order-service |
| frontend | 8080 | — | secretpower/kubekitchen-frontend |
