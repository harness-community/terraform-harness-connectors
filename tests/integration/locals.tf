locals {
  organization_id  = harness_platform_organization.test.id
  project_id       = harness_platform_project.test.id
  test_secret_name = harness_platform_secret_text.test.id
  fmt_prefix = (
    lower(
      replace(
        replace(
          var.prefix,
          " ",
          "_"
        ),
        "-",
        "_"
      )
    )
  )

  common_tags = merge(
    var.global_tags,
    {
      purpose = "terraform-testing"
    }
  )
}
