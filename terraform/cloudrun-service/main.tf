# Use the google provider for GCS volume mount feature
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.11.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the GCS bucket
resource "google_storage_bucket" "static_site_bucket" {
  name     = var.bucket_name
  location = var.region
  force_destroy = false
  project = var.project_id
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
  labels = {
    env = "non-prod"
    app = "gcs-pages-app"
    trustlevel = "low"       
    integrity = "accurate"
    confidentiality = "internal"               
  }                         
}

# Upload the nginx config file to the bucket
resource "google_storage_bucket_object" "nginx_config" {
  name   = "${var.config_only_dir}/default.conf"
  bucket = google_storage_bucket.static_site_bucket.name
  source = "default.conf"
}

# Upload the index.html to the sites folder
resource "google_storage_bucket_object" "sites_index" {
  name   = "sites/index.html"
  bucket = google_storage_bucket.static_site_bucket.name
  source = "index.html"
}

# Define the service account for the Cloud Run service
resource "google_service_account" "cloudrun_gcs_sa" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

# Grant minimal permissions to the service account to read objects from the bucket
resource "google_storage_bucket_iam_binding" "bucket_iam_viewer" {
  bucket = google_storage_bucket.static_site_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.cloudrun_gcs_sa.email}",
  ]
}

# Grant permissions for the service account to be used by Cloud Run
resource "google_project_iam_member" "cloud_run_service_agent" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudrun_gcs_sa.email}"
}

# Define the Cloud Run service using the google provider
resource "google_cloud_run_v2_service" "static_site_service" {
  provider = google
  name     = var.service_name
  location = var.region

  template {
    service_account = google_service_account.cloudrun_gcs_sa.email
    execution_environment = var.execution_environment

    containers {
      image = var.container_image
      
      ports {
        container_port = var.container_port
      }

      # Mount the GCS bucket subdirectory for the nginx config file
      volume_mounts {
        name = "nginx-conf"
        # Mount to the conf.d directory to pick up the custom config
        mount_path = var.config_mount_path
      }

      # Mount the GCS bucket subdirectory for static content
      volume_mounts {
        name = "nginx-sites"
        mount_path = var.static_content_mount_path # Default nginx static content path
      }
    }

    volumes {
      name = "nginx-conf"
      gcs {
        bucket = google_storage_bucket.static_site_bucket.name
        # read_only   = true
        # Mount only the 'config/nginx/conf.d' directory
        mount_options = ["only-dir=${var.config_only_dir}"] 
      }
    }

    # Define the GCS volumes
    volumes {
      name = "nginx-sites"
      gcs {
        bucket = google_storage_bucket.static_site_bucket.name
        # read_only   = true
        # Removed only-dir to mount entire bucket
        # Mount only the 'sites' directory within the bucket
        mount_options = ["only-dir=${var.static_content_only_dir}"] 
      }
    }
  }

  ingress      = var.ingress
  deletion_protection = false
}

resource "google_cloud_run_v2_service_iam_member" "public_access_invoker" {
  location = google_cloud_run_v2_service.static_site_service.location
  name     = google_cloud_run_v2_service.static_site_service.name
  role     = var.invoker_role
  member   = var.public_member
}

# Output the service URL
output "service_url" {
  value = google_cloud_run_v2_service.static_site_service.uri
}
