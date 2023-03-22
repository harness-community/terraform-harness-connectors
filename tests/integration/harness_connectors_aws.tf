module "aws_connector_1" {
  source = "../../../modules/aws/cloud"
  identifier = "hello"
  name="hello"

  credentials = {
    type="manual"
    access_key="access_key"
    secret_key_ref="secret_key_ref"
    delegate_selectors=["delegate1","delegate2"]
  }

  cross_account_access = {
    role_arn = "role_arn"
  }
  
}

module "aws_connector_2" {
  source = "../../../modules/aws/cloud"
  identifier = "hello2"
  name="hello2"

  credentials = {
    type="irsa"
    delegate_selectors=["delegate1","delegate2"]
  }

  cross_account_access = {
    role_arn = "role_arn"
  }
  
}