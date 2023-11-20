####################
#
# Harness Connector AWS Cloud Local Variables
#
####################
locals {
  required_tags = {
    created_by : "Terraform"
  }

  common_tags = merge(
    var.tags,
    var.global_tags,
    local.required_tags
  )
  # Harness Tags are read into Terraform as a standard Map entry but needs to be
  # converted into a list of key:value entries
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

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
}
