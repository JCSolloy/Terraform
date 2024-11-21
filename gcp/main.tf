resource "google_compute_instance" "pnetlab" {
  name         = "pnetlab"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-pro-cloud/global/images/ubuntu-pro-1804-bionic-v20241115a"
      size = 100
      type = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.pnetlab-network.self_link
    subnetwork = google_compute_subnetwork.pnetlab-subnetwork.self_link
    access_config {
    }
  }

}

resource "google_compute_network" "pnetlab-network" {
  name = "pnetlab-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "pnetlab-subnetwork" {
  name          = "pnetlab-subnetwork"
  ip_cidr_range = "10.20.0.0/16"
  region = "us-central1"
  network = google_compute_network.pnetlab-network.id
  
}

resource "google_compute_firewall" "pnetlab-firewall" {
  name = "pnetlab-firewall"
  network = google_compute_network.pnetlab-network.id
  allow {
    protocol = "tcp"
    ports = ["22", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  
}

