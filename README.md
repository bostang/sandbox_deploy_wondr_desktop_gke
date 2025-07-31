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
# Build Frontend dengan argumen -> untuk memastikan environment variable terpasang
# kalau dijadikan secrets di .yaml, ia tidak terbaca
docker build \
  --build-arg VITE_BACKEND_BASE_URL=GANTISAYA \
  --build-arg VITE_VERIFICATOR_BASE_URL=https://verificator-secure-onboarding-system-441501015598.asia-southeast1.run.app \
  --build-arg VITE_FIREBASE_API_KEY=AIzaSyCTXgqBktnmUo8z5VkxMuwBpLkBGZ_syj0 \
  --build-arg VITE_FIREBASE_AUTH_DOMAIN=model-parsec-465503-p3.firebaseapp.com \
  --build-arg VITE_FIREBASE_PROJECT_ID=model-parsec-465503-p3 \
  --build-arg VITE_FIREBASE_STORAGE_BUCKET=model-parsec-465503-p3.firebasestorage.app \
  --build-arg VITE_FIREBASE_MESSAGING_SENDER_ID="371655033224" \
  --build-arg VITE_FIREBASE_APP_ID="1:371655033224:web:0b124bca5fca9b65a67a3d" \
  -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest \
  ./frontend-secure-onboarding-system

docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest

# backend
docker build -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest ./backend-secure-onboarding-system
docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest
```

**Langkah 2** : Apply manifest untuk deployment aplikasi

```bash
# lakukan di folder root (.)

# db
kubectl apply -f ./k8s/db/db-deployment.yaml
kubectl apply -f ./k8s/db/db-secrets.yaml
kubectl apply -f ./k8s/db/db-service.yaml

# be
kubectl apply -f ./k8s/be/be-secrets.yaml
kubectl apply -f ./k8s/be/be-healthcheck.yaml
kubectl apply -f ./k8s/be/be-configmaps.yaml
kubectl apply -f ./k8s/be/be-deployment.yaml
kubectl apply -f ./k8s/be/be-service.yaml

# fe
kubectl apply -f ./k8s/fe/fe-secrets.yaml
kubectl apply -f ./k8s/fe/fe-deployment.yaml
kubectl apply -f ./k8s/fe/fe-service.yaml

# network
kubectl delete -f ./k8s/network/ingress.yaml
kubectl apply -f ./k8s/network/ingress.yaml

kubectl delete -f ./k8s/be/be-deployment.yaml
kubectl rollout restart deployment wondr-desktop-backend-deployment

kubectl describe pods [nama_pods]
```

### Troubleshooting Frontend / Update perubahan kode di environment production

```bash
# lakukan di root (.)
# lakukan modifikasi pada kode sumber

# build & push ulang docker
docker build \
  --build-arg VITE_BACKEND_BASE_URL=GANTISAYA \
  --build-arg VITE_VERIFICATOR_BASE_URL=https://verificator-secure-onboarding-system-441501015598.asia-southeast1.run.app \
  --build-arg VITE_FIREBASE_API_KEY=AIzaSyCTXgqBktnmUo8z5VkxMuwBpLkBGZ_syj0 \
  --build-arg VITE_FIREBASE_AUTH_DOMAIN=model-parsec-465503-p3.firebaseapp.com \
  --build-arg VITE_FIREBASE_PROJECT_ID=model-parsec-465503-p3 \
  --build-arg VITE_FIREBASE_STORAGE_BUCKET=model-parsec-465503-p3.firebasestorage.app \
  --build-arg VITE_FIREBASE_MESSAGING_SENDER_ID="371655033224" \
  --build-arg VITE_FIREBASE_APP_ID="1:371655033224:web:0b124bca5fca9b65a67a3d" \
  -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest \
  ./frontend-secure-onboarding-system

docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-fe:latest

# pindah ke folder /sandbox_deploy_windor_desktop_gke/
# re-apply manifest
kubectl delete -f ./k8s/fe/fe-deployment.yaml
kubectl apply -f ./k8s/fe/fe-deployment.yaml
```

### Troubleshooting Backend / Update perubahan kode di environment production

```bash
# lakukan di root (.)
# lakukan modifikasi pada kode sumber

# build & push ulang docker
docker build -t asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest ./backend-secure-onboarding-system
docker push asia.gcr.io/primeval-rune-467212-t9/wondr-desktop-be:latest

# pindah ke folder /sandbox_deploy_windor_desktop_gke/

# re-apply manifest
kubectl delete -f ./k8s/be/be-configmaps.yaml
kubectl delete -f ./k8s/be/be-deployment.yaml
kubectl delete -f ./k8s/be/be-service.yaml
kubectl delete -f ./k8s/be/be-secrets.yaml

kubectl apply -f ./k8s/be/be-configmaps.yaml
kubectl apply -f ./k8s/be/be-deployment.yaml
kubectl apply -f ./k8s/be/be-service.yaml
kubectl apply -f ./k8s/be/be-secrets.yaml

# catatan : http://http://34.8.228.44 merupakan endpoint dari ingress
```

### Curl Test Verifikator

```bash
curl -X POST \
  https://verificator-secure-onboarding-system-441501015598.asia-southeast1.run.app/api/dukcapil/verify-nik \
  -H 'Content-Type: application/json' \
  -d '{
    "nik": "3175031234567890",
    "namaLengkap": "John Doe",
    "tanggalLahir": "1990-05-15"
  }'
```

## Catatan

1. Urutan path pada ingress berpengaruh. Usahakan taruh yang paling spesifik di atas seperti `/api/auth` lalu yang lebih umum seperti `/` di bawah.
