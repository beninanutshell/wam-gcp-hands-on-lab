locals {
  functions = {
    stop_function  = module.cloud_functions_stop.function_name
    start_function = module.cloud_functions_start.function_name
  }
}

resource "google_storage_bucket" "bucket" {
  name                        = "${var.project_id}-gcf-source"
  location                    = "northamerica-northeast1"
  uniform_bucket_level_access = true
  project                     = var.project_id
}

module "cloud_functions_stop" {
  source  = "GoogleCloudPlatform/cloud-functions/google"
  version = "~> 0.4"

  project_id        = var.project_id
  function_name     = "gcf-gce-stop-bco"
  function_location = var.function_location
  runtime           = "python311"
  entrypoint        = "stop_instance"
  members           = var.members
  storage_source = {
    bucket     = google_storage_bucket.bucket.name
    object     = google_storage_bucket_object.function-source-stop.name
    generation = null
  }

  service_config = {
    max_instance_count    = "1"
    min_instance_count    = "0"
    available_memory      = "256Mi"
    timeout_seconds       = "180"
    service_account_email = module.service_accounts.email
  }
}

module "cloud_functions_start" {
  source  = "GoogleCloudPlatform/cloud-functions/google"
  version = "~> 0.4"

  project_id        = var.project_id
  function_name     = "gcf-gce-start-bco"
  function_location = var.function_location
  runtime           = "python311"
  entrypoint        = "start_instance"
  members           = var.members
  storage_source = {
    bucket     = google_storage_bucket.bucket.name
    object     = google_storage_bucket_object.function-source-start.name
    generation = null
  }

  service_config = {
    max_instance_count    = "1"
    min_instance_count    = "0"
    available_memory      = "256Mi"
    timeout_seconds       = "60"
    service_account_email = module.service_accounts.email
  }

}

module "service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 3.0"

  project_id = var.project_id
  prefix     = "sac"
  names      = ["cft-gce-manager-bco"]
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
    "${var.project_id}=>roles/compute.instanceAdmin.v1",
  ]

}

resource "google_compute_instance" "instance_bco" {

  boot_disk {
    auto_delete = true
    device_name = "gce-lnx-deb-bco"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20230724"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false
  project             = var.project_id

  machine_type = "e2-micro"
  name         = "gce-lnx-deb-bco"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    subnetwork = "projects/dav-training-lnx-34e2/regions/northamerica-northeast1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "564247751872-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server"]
  zone = "northamerica-northeast1-a"
}

resource "google_project_iam_member" "project_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "user:benjamin.coutellier@davidson.group"
}

data "archive_file" "start" {
  type             = "zip"
  output_path      = "./start.zip"
  source_dir       = "../startFunction/"
  output_file_mode = "0644"
}

data "archive_file" "stop" {
  type             = "zip"
  output_path      = "./stop.zip"
  source_dir       = "../stopFunction/"
  output_file_mode = "0644"
}

resource "google_storage_bucket_object" "function-source-start" {
  name   = "start-${data.archive_file.start.output_sha}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.start.output_path
}

resource "google_storage_bucket_object" "function-source-stop" {
  name   = "stop-${data.archive_file.stop.output_sha}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.stop.output_path
}



