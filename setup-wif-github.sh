#!/bin/bash

# === CONFIGURATION ===
PROJECT_ID="tl-sandbox-370622"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
POOL_ID="github-pool"
PROVIDER_ID="github-provider"
SERVICE_ACCOUNT_NAME="github-deployer"
REPO="kevin-tang-tl/test-pages-migration"  # Format: org/repo

# === ENABLE REQUIRED APIS ===
gcloud services enable iamcredentials.googleapis.com iam.googleapis.com sts.googleapis.com

# === CREATE WORKLOAD IDENTITY POOL ===
gcloud iam workload-identity-pools create $POOL_ID \
  --project=$PROJECT_ID \
  --location="global" \
  --display-name="GitHub Actions Pool"

# === CREATE OIDC PROVIDER ===
gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID \
  --project=$PROJECT_ID \
  --location="global" \
  --workload-identity-pool=$POOL_ID \
  --display-name="GitHub OIDC Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.aud=assertion.aud,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="attribute.repository == '$REPO'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# === CREATE SERVICE ACCOUNT ===
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --project=$PROJECT_ID \
  --display-name="GitHub Actions Deployer"

# === ALLOW GITHUB TO IMPERSONATE SERVICE ACCOUNT ===
gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --project=$PROJECT_ID \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/attribute.repository/$REPO"

# === GRANT GCS PERMISSIONS ===
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"

echo "✅ Workload Identity Federation setup complete."
echo "🔑 Use the following in your GitHub Actions workflow:"
echo ""
echo "workload_identity_provider: 'projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID'"
echo "service_account: '$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com'"
