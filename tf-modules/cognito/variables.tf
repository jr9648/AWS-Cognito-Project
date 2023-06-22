# Define variables
variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  default     = "my-user-pool"
}

variable "admin_group_name" {
  description = "Name of the Cognito admin user group"
  default     = "AdminUser"
}

variable "standard_group_name" {
  description = "Name of the Cognito standard user group"
  default     = "StandardUser"
}