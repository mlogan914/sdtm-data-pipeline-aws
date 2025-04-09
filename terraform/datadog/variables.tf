# ================================================================
# Datadog Module - Variables
# 
# This file defines input variables for the Datadog module.
# ================================================================

variable "aws_account_id" {
    type = string
}

variable "datadog_api_key" {
    type = string
}

variable "datadog_app_key" {
    type = string
}

variable "datadog_forwarder_arn" {
    type = string
}