variable "project_name" {
    description = "The name of the GKE cluster"
    type        = string
    default = "wondr-desktop-cluster"
}

variable "project" {
    description = "The GCP project ID"
    type       = string
    default    = "primeval-rune-467212-t9"
}

variable "region" {
    description = "The GCP region"
    type        = string
    default     = "asia-southeast1"
}

variable "zone" {
    description = "The GCP zone"
    type        = string
    default     = "asia-southeast1-a"
}

variable "k8s_version" {
    description = "Kubernetes version for the GKE cluster"
    type        = string
    default     = "1.31.6-gke.1000"
}

variable "subnet_cidr" {
  description = "The IP CIDR range for the main subnet."
  type        = string
  default     = "10.0.0.0/19"
}