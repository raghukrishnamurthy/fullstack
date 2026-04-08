terraform {
  required_version = ">= 1.3.0"
}

variable "name_prefix" {
  type = string
}

locals {
  payload = {
    name_prefix    = var.name_prefix
    producer       = "terraform"
    sample_profile = "${var.name_prefix}-Terraform-Profile"
  }
}

output "phase_a_status" {
  value = "ready"
}

output "phase_a_payload_json" {
  value = jsonencode(local.payload)
}

output "phase_a_summary_json" {
  value = jsonencode({
    phase   = "phase_a_producer_terraform"
    status  = "ready"
    payload = local.payload
  })
}
