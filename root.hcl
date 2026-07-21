locals {
  account     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
  namespace   = join("-", [local.account.name, local.region.name, local.environment.name])
  tags        = merge(local.account.tags, local.region.tags, local.environment.tags)
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region              = "${local.region.name}"
  allowed_account_ids = ["${local.account.id}"]
}
EOF
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "tf-state-${local.namespace}"
    key            = "${path_relative_to_include()}/tf.tfstate"
    region         = local.region.name
    encrypt        = true
    use_lockfile   = true
    s3_bucket_tags = local.tags
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

catalog {
  urls = [
    "git::git@github.com:monetis-io/infrastructure-catalog",
  ]
}
