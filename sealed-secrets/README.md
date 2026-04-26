# Sealed Secrets

This directory contains `SealedSecret` manifests — encrypted Kubernetes secrets safe to store in Git.

## How they work
```
kubeseal encrypts → SealedSecret (Git) → Sealed Secrets Controller decrypts → Secret (cluster)
```

## Files
| File | Namespace | Purpose |
|---|---|---|
| `sealed-secret-dev.yaml` | kubekitchen-dev | Dev secrets (MongoDB URIs, JWT) |
| `sealed-secret-prod.yaml` | kubekitchen-prod | Prod secrets (real credentials) |

## Regenerating secrets

If you need to rotate secrets:
```bash
# Create new plain secret (NEVER commit this file!)
cat <<EOF > /tmp/new-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: kubekitchen-secrets
  namespace: kubekitchen-dev
type: Opaque
stringData:
  JWT_SECRET: "your-new-256bit-secret-here"
  MONGO_AUTH_URI: "mongodb://..."
  # ... other keys
EOF

# Re-seal
kubeseal --format yaml < /tmp/new-secret.yaml > sealed-secret-dev.yaml

# Clean up
rm /tmp/new-secret.yaml

# Commit and push — ArgoCD applies it automatically
git add sealed-secret-dev.yaml
git commit -m "chore: rotate dev secrets"
git push
```

## ⚠️ Important Notes
- SealedSecrets are **cluster-specific** — sealed with THIS cluster's public key
- If you recreate the cluster, you must back up the controller's private key first:
  ```bash
  kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key \
    -o yaml > sealed-secrets-master-key-BACKUP.yaml
  ```
- Store the backup key in a password manager, NOT in Git
