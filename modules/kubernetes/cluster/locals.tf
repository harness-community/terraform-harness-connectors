####################
#
# Harness Connector Azure Cloud Local Variables
#
####################
locals {
  required_tags = [
    "created_by:Terraform"
  ]
  # Harness Tags are read into Terraform as a standard Map entry but needs to be
  # converted into a list of key:value entries
  global_tags = [for k, v in var.global_tags : "${k}:${v}"]
  # Harness Tags are read into Terraform as a standard Map entry but needs to be
  # converted into a list of key:value entries
  tags = [for k, v in var.tags : "${k}:${v}"]

  common_tags = flatten([
    local.tags,
    local.global_tags,
    local.required_tags
  ])

  auto_identifier = (
        replace(
          replace(
            var.name,
            " ",
            "_"
          ),
          "-",
          "_"
        )
  )

  fmt_identifier = (
    var.identifier == null
    ?
    (
      var.case_sensitive
      ?
      local.auto_identifier
      :
      lower(local.auto_identifier)
    )
    :
    var.identifier
  )

  # Create a currated list of valid credential choices based on the provided
  # variables.  This will create a list that we can leverage to ensure that
  # only one model is provided and chosen by the call to this module.
  validate_credential_checks = compact(flatten([
    (length(keys(var.delegate_credentials)) > 0 ? "delegate" : ""),
    (length(keys(var.service_account_credentials)) > 0 ? "service_account" : ""),
    (length(keys(var.username_credentials)) > 0 ? "username" : ""),
    (length(keys(var.certificate_credentials)) > 0 ? "certificate" : ""),
    (length(keys(var.openid_connect_credentials)) > 0 ? "openid_connect" : "")
  ]))

  # Finally, we need to handle the situation where no credential model is chosen
  # and accurately configure this to leverage our default choice of delegate
  validate_credential_models = compact(flatten([
    length(local.validate_credential_checks) == 0 ? ["delegate"] : local.validate_credential_checks
  ]))
}
