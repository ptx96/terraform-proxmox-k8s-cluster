terraform {
  cloud {
    organization = "ClastixLabs"

    workspaces {
      tags = ["cke"]
    }
  }
}