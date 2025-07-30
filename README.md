# Wondr Desktop (Sandbox) Deploy to GKE

## Langkah

**Langkah 0** : Buat Cluster GKE menggunakan Terraform

```bash
# lakukan di folder tf (/tf/.) 
terraform init
terraform plan -out tfplan
terraform apply -auto-approve tfplan
```

**Langkah 0.5** : atur cluster di cloud terminal menjadi cluster saat ini

```bash
# lihat konteks saat ini
kubectl config current-context --project primeval-rune-467212-t9

# ubah konteks kubectl menjadi berinteraksi dgn cluster kita
gcloud container clusters get-credentials wondr-desktop-cluster --zone asia-southeast1-a --project primeval-rune-467212-t9
```

**Langkah 1** : Build & Push Docker Image

```bash
# lakukan di root (.) 
    # .
    # ├── backend-secure-onboarding-system
    # └── frontend-secure-onboarding-system

# frontend
# PASTIKAN BAHWA JSON FILE FIREBASE SUDAH ADA DI FE DAN BE!

docker build -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest ./frontend-secure-onboarding-system
docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest

# backend
docker build -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest ./backend-secure-onboarding-system
docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest
```

**Langkah 2** : Apply manifest untuk deployment aplikasi

```bash
# lakukan di folder root (.)

# buat namespace
# kubectl apply -f k8s/namespaces.yaml

# db
kubectl apply -f ./k8s/db/db-deployment.yaml
kubectl apply -f ./k8s/db/db-secrets.yaml
kubectl apply -f ./k8s/db/db-service.yaml

# be
kubectl apply -f ./k8s/be/be-deployment.yaml
kubectl apply -f ./k8s/be/be-secrets.yaml
kubectl apply -f ./k8s/be/be-service.yaml
kubectl apply -f ./k8s/be/be-healthcheck.yaml
kubectl apply -f ./k8s/be/be-configmaps.yaml

# fe
kubectl apply -f ./k8s/fe/fe-deployment.yaml
kubectl apply -f ./k8s/fe/fe-service.yaml

# network
kubectl apply -f ./k8s/network/ingress.yaml
# kubectl apply -f k8s/network/be-db.yaml
# kubectl apply -f k8s/network/ingress-to-be.yaml

```
