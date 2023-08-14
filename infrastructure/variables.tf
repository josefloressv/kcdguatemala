# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "azs_available" {
  description = "AWS Availability Zones"
  type = list(string)
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "kcdguatemala"
}
