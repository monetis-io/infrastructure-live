locals {
  name = "production"

  domain_name = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.domain_name

  tags = {
    environment = local.name
  }
}
