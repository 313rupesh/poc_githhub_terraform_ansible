terraform {
  backend "gcs" {
    bucket = "sinuous-mind-384104"  # create gs://tf-states-demo
    prefix = "terraform/state" # create folders "terraform/state" --> gs://tf-states-demo/terraform/state/
    ######## On run "Terraform init", TF will put default state at gs://tf-states-demo/terraform/state/default.tfstate 
    #credentials = "zinc-arc-396916-9d8a70ea2239.json"   # this is needed if you run from local TF CLI
  }
}
provider "google" {
  project     = "sinuous-mind-384104"
  # credentials = file(var.credentials_file)  # this is needed if you run from local TF CLI
  region      = var.region
  zone        = "us-west4-a" //us-centra1-c
}

resource "google_compute_instance" "my-first-vm" {
  name         = local.instance_name
  machine_type = local.machine_type
  boot_disk {
    initialize_params {
      image = local.image
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}

variable "credentials_file" {
  type        = string
  description = "credentials"
  default     = "sinuous-mind-384104-25030839f4b3.json"
}
variable "region" {
  type        = string
  description = "region11"
  default     = "us-west4"
}
locals {
  instance_name = "my-first-vm12"
  instance_zone = "us-central1-a"
  machine_type  = "e2-medium"
  image         = "ubuntu-os-cloud/ubuntu-2004-lts"
  instance_labels = {
    env = "dev"
    app = "web"
  }
}






