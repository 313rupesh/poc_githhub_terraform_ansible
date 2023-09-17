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

    metadata = {
    "ssh-keys" = <<EOT
      ansible:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgx9mknOH6XeYdrHw2aZkub8jcApKAG6UsZMCqNv+bj ansible
      EOT
    }

  provisioner "remote-exec" {
  inline =["echo 'Wait untill SSH is ready rupesh'"]
  connection {
    type     = "ssh"
    user     = local.ssh_user
    port     = 22
    password = "${file("${local.private_key_path}")}"
    #host     = self.public_ip
    host    = google_compute_instance.my-first-vm.network_interface.0.access_config.0.nat_ip
  }

}

  provisioner "local-exec" {
    #command = "ansible-playbook -i ${var.nginx_ip}, -i --private-key ${local.private_key_path} nginx.yaml"
    command = "ansible-playbook -i var.nginx_ip, -i --private-key ${local.private_key_path} nginx.yaml"
  }
}

output "nginx_ip" {
  value = google_compute_instance.my-first-vm.network_interface.0.access_config.0.nat_ip
}

variable "credentials_file" {
  type        = string
  description = "credentials"
  default     = "sinuous-mind-384104-c8d17b9d3f16.json"
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
  ssh_user      = "ansible"
  private_key_path = "./certificate"
  instance_labels = {
    env = "dev"
    app = "web"
  }
}






