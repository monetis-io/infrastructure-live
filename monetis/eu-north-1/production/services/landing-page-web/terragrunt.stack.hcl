locals {
  name = "landing-page-web"
}

unit "s3_bucket" {
  source = "git::https://github.com/monetis-io/infrastructure-catalog.git//units/s3-bucket?ref=@units/s3-bucket@1.1.5"
  path   = "s3-bucket"

  no_dot_terragrunt_stack = true

  values = {
    name = local.name
  }
}

unit "cloudfront_distribution" {
  source = "git::https://github.com/monetis-io/infrastructure-catalog.git//units/cloudfront-distribution?ref=@units/cloudfront-distribution@1.1.3"
  path   = "cloudfront-distribution"

  no_dot_terragrunt_stack = true

  autoinclude {
    dependency "s3_bucket" {
      config_path = unit.s3_bucket.path

      mock_outputs = {
        id                   = "mock"
        arn                  = "mock",
        regional_domain_name = "mock"
      }
    }

    inputs = {
      origins = {
        S3 = [{
          id          = dependency.s3_bucket.outputs.id
          bucket_arn  = dependency.s3_bucket.outputs.arn
          domain_name = dependency.s3_bucket.outputs.regional_domain_name
        }]
      }

      cache_behaviors = [
        {
          path             = "/assets/*",
          type             = "S3",
          target_origin_id = dependency.s3_bucket.outputs.id,
          cache_policy     = "CachingOptimized",
          purpose          = "static-assets"
        },
        {
          path             = "/build/*",
          type             = "S3",
          target_origin_id = dependency.s3_bucket.outputs.id,
          cache_policy     = "CachingOptimized",
          purpose          = "static-assets"
        },
        {
          type             = "S3",
          target_origin_id = dependency.s3_bucket.outputs.id,
          cache_policy     = "CachingDisabled",
          purpose          = "spa"
        },
      ]
    }
  }

  values = {
    name = local.name

    custom_error_response = [
      {
        error_code         = 404,
        response_code      = 200,
        response_page_path = "/redirect.html"
      },
      { error_code         = 403,
        response_code      = 200,
        response_page_path = "/redirect.html"
      },
    ]
  }
}
