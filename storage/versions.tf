terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.37.0, < 8.0.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "google" {
  credentials = file("./credentials.json")
}