locals {
  environment = "DevOpsTest"
  brand = "Toufik"

  tags = {
    environment = local.environment
    developer   = "Toufik"
    brand = local.brand
  }
}