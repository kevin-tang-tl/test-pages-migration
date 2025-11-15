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

gcloud run services replace nginx-service.yaml --platform managed --region $REGION

echo "Deployment initiated. Check the Cloud Run console for status."
