gcloud run deploy gcs-proxy \
  --image gcr.io/tl-sandbox-370622/nginx-gcs-proxy \
  --platform managed \
  --region australia-southeast1 \
  --allow-unauthenticated
