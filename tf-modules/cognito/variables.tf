module "api-gateway" {
  source = "../api-gateway"
}

variable "api-arn" {
    default = module.api-gateway.api_arn
}
