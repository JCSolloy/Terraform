resource "google_compute_image" "nested_ubuntu_jammy" {
  name = "nested-ubuntu-jammy"
  project = "ubuntu-os-cloud"
  family = "ubuntu-2204-lts"
  licenses = ["https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"]
}
resource "google_compute_instance" "eve" {
  name         = "eve"
  machine_type = "n2-standard-8"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = google_compute_image.nested_ubuntu_jammy.self_link
      size = 100
      type = "pd-ssd"
    }
  }

  network_interface {
    network = google_compute_network.eve-network.self_link
    subnetwork = google_compute_subnetwork.eve-subnetwork.self_link
    access_config {
    }
  }

}

resource "google_compute_network" "eve-network" {
  name = "eve-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "eve-subnetwork" {
  name          = "eve-subnetwork"
  ip_cidr_range = "10.20.0.0/16"
  region = "us-central1"
  network = google_compute_network.eve-network.id
  
}

resource "google_compute_firewall" "eve-firewall" {
  name = "eve-firewall"
  network = google_compute_network.eve-network.id
  allow {
    protocol = "tcp"
    ports = ["22", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  
}

