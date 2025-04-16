/**
 * # OCI NextGen Firewall Module
 * 
 * This module creates and configures the OCI Native NextGen Firewall.
 */

# Create the NextGen firewall
resource "oci_network_firewall_network_firewall" "firewall" {
  compartment_id = var.compartment_id
  display_name   = "${var.prefix}-firewall"
  subnet_id      = var.subnet_id
  
  network_firewall_policy_id = oci_network_firewall_network_firewall_policy.firewall_policy.id
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# Create firewall policy
resource "oci_network_firewall_network_firewall_policy" "firewall_policy" {
  compartment_id = var.compartment_id
  display_name   = "${var.prefix}-firewall-policy"
  
  # Define application group for HTTP and HTTPS
  application_lists {
    application_list_name = "web_apps"
    applications {
      type = "SERVICE"
      name = "HTTP"
    }
    applications {
      type = "SERVICE"
      name = "HTTPS"
    }
  }
  
  # Define application group for SSH
  application_lists {
    application_list_name = "ssh_app"
    applications {
      type = "SERVICE"
      name = "SSH"
    }
  }
  
  # Define application group for database
  application_lists {
    application_list_name = "db_apps"
    applications {
      type = "SERVICE"
      name = "ORACLE_DB"
    }
  }
  
  # Define URL pattern for allowed websites
  url_lists {
    url_list_name = "allowed_urls"
    url_patterns = [
      "*.oracle.com",
      "*.oraclecloud.com"
    ]
  }
  
  # Define IP address list for trusted sources
  ip_address_lists {
    ip_address_list_name = "trusted_sources"
    ip_addresses = [
      "0.0.0.0/0"  # For demo - in production, this should be restricted
    ]
  }
  
  # Define security rules
  security_rules {
    name        = "allow_web_traffic"
    description = "Allow inbound web traffic"
    action      = "ALLOW"
    
    condition {
      applications = ["web_apps"]
      destinations = ["10.0.0.0/8"]
      sources      = ["trusted_sources"]
    }
  }
  
  security_rules {
    name        = "allow_ssh_traffic"
    description = "Allow SSH to management subnet"
    action      = "ALLOW"
    
    condition {
      applications = ["ssh_app"]
      destinations = ["10.0.0.0/8"]
      sources      = ["trusted_sources"]
    }
  }
  
  security_rules {
    name        = "allow_db_traffic"
    description = "Allow database traffic within VCN"
    action      = "ALLOW"
    
    condition {
      applications = ["db_apps"]
      destinations = ["10.0.0.0/8"]
      sources      = ["10.0.0.0/8"]
    }
  }
  
  security_rules {
    name        = "default_deny"
    description = "Deny all other traffic"
    action      = "DROP"
    
    condition {
      sources      = ["0.0.0.0/0"]
      destinations = ["0.0.0.0/0"]
    }
  }
  
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}