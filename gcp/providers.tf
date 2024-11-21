terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  region      = "us-central1"
  credentials = file("~/.gcp/credentials.json")
  project     = "firm-retina-442423-p6"
}