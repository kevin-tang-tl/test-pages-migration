# Project Configuration
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "australia-southeast1"
}

# Storage Configuration
variable "bucket_name" {
  description = "The name of the GCS bucket containing static content"
  type        = string
}

# Service Account Configuration
variable "service_account_id" {
  description = "The ID for the Cloud Run service account"
  type        = string
}

variable "service_account_display_name" {
  description = "Display name for the Cloud Run service account"
  type        = string
  default     = "Cloud Run GCS Static Site Service Account"
}

# Cloud Run Service Configuration
variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "container_image" {
  description = "Docker image for the Cloud Run container"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

# Volume Mounts Configuration
variable "static_content_mount_path" {
  description = "Mount path for static content in the container"
  type        = string
  default     = "/usr/share/nginx/html"
}

variable "config_mount_path" {
  description = "Mount path for nginx config in the container"
  type        = string
  default     = "/etc/nginx/conf.d"
}

variable "static_content_only_dir" {
  description = "Directory within bucket to mount for static content"
  type        = string
  default     = "sites"
}

variable "config_only_dir" {
  description = "Directory within bucket to mount for nginx config"
  type        = string
  default     = "config/nginx/conf.d"
}

variable "execution_environment" {
  description = "Execution environment for Cloud Run"
  type        = string
  default     = "EXECUTION_ENVIRONMENT_GEN2"
}

variable "ingress" {
  description = "Ingress traffic setting for Cloud Run"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

# IAM Configuration
variable "invoker_role" {
  description = "IAM role for public access"
  type        = string
  default     = "roles/run.invoker"
}

variable "public_member" {
  description = "Member for public access"
  type        = string
  default     = "allUsers"
}

variable "company_domain" {
  description = "Company domain for restricting access (e.g., 'yourcompany.com')"
  type        = string
  default     = ""
}