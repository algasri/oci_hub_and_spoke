/**
 * # Terraform and Provider Versions
 * 
 * This file defines the versions of Terraform and the providers used.
 */

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.80.0"
    }
    
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
    
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}