# Wondr Desktop (Sandbox) Deploy to GKE

## Langkah

**Langkah 0** : Buat Cluster GKE menggunakan Terraform

```bash
terraform init
terraform plan -out tfplan
terraform apply -auto-approve tfplan
```

**Langkah 1** : Build & Push Docker Image

```bash
# lakukan di root (.) 
    # .
    # ├── backend-secure-onboarding-system
    # └── frontend-secure-onboarding-system

# frontend
docker build -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest ./frontend-secure-onboarding-system
docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest

# backend
docker build -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest ./backend-secure-onboarding-system
docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest
```
