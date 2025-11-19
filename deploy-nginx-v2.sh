#!/bin/bash

# --- Configuration Variables ---
SERVICE_NAME="nginx-gcs-service"
REGION="australia-southeast1" # Choose your desired region
PROJECT_ID="tl-sandbox-370622" # Replace with your Project ID
BUCKET_NAME="pages-gcs-bucket" # Replace with your GCS Bucket Name
NGINX_IMAGE="nginx:latest" # Official Nginx image from Docker Hub
# -------------------------------

echo "Configuring gcloud defaults..."
gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION

echo "Deploying Cloud Run service $SERVICE_NAME with GCS volume mounts..."

gcloud run deploy $SERVICE_NAME \
  --image $NGINX_IMAGE \
  --execution-environment gen2 \
  --port 80 \
  --add-volume=name=nginx-conf,type=cloud-storage,bucket=$BUCKET_NAME,mount-options="only-dir=config/nginx/conf.d" \
  --add-volume-mount=volume=nginx-conf,mount-path=/etc/nginx/conf.d \
  --add-volume=name=nginx-sites,type=cloud-storage,bucket=$BUCKET_NAME,mount-options="only-dir=sites" \
  --add-volume-mount=volume=nginx-sites,mount-path=/usr/share/nginx/html \
  --allow-unauthenticated

  echo "Deployment initiated. Check the Cloud Run console for status."