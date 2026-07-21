locals {
  id   = get_env("AWS_ACCOUNT_ID")
  name = "monetis"

  domain_name = "monetis.io"

  tags = {
    project = local.name
    user    = "terragrunt@${local.name}"
  }
}
