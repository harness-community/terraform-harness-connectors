####################
#
# Harness Connectors Kubernetes Validations
#
####################
locals {
  connectors_kubernetes_outputs = flatten([
    {
      connector_kubernetes_cluster_minimal                = module.connector_kubernetes_cluster_minimal.details
      connector_kubernetes_cluster_delegate_auth          = module.connector_kubernetes_cluster_delegate_auth.details
      connector_kubernetes_cluster_service_account        = module.connector_kubernetes_cluster_service_account.details
      connector_kubernetes_cluster_username               = module.connector_kubernetes_cluster_username.details
      connector_kubernetes_cluster_username_secret        = module.connector_kubernetes_cluster_username_secret.details
      connector_kubernetes_cluster_certificate            = module.connector_kubernetes_cluster_certificate.details
      connector_kubernetes_cluster_certificate_ca_cert    = module.connector_kubernetes_cluster_certificate_ca_cert.details
      connector_kubernetes_cluster_certificate_passphrase = module.connector_kubernetes_cluster_certificate_passphrase.details
      connector_kubernetes_cluster_openid_connect         = module.connector_kubernetes_cluster_openid_connect.details
    }
  ])
}

module "connector_kubernetes_cluster_minimal" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-minimal"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  global_tags        = local.common_tags

}

module "connector_kubernetes_cluster_delegate_auth" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-delegate-auth"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  delegate_credentials = {
    delegates = ["k8s"]
  }
  global_tags = local.common_tags

}

module "connector_kubernetes_cluster_service_account" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-service-account"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  service_account_credentials = {
    master_url  = "https://k8s.url"
    secret_name = local.test_secret_name
  }
  global_tags = local.common_tags

}

module "connector_kubernetes_cluster_username" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-username"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  username_credentials = {
    master_url  = "https://k8s.url"
    username    = "master"
    secret_name = local.test_secret_name
  }
  global_tags = local.common_tags

}

module "connector_kubernetes_cluster_username_secret" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-username-secret"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  username_credentials = {
    master_url     = "https://k8s.url"
    username       = local.test_secret_name
    is_user_secret = true
    secret_name    = local.test_secret_name
  }
  global_tags = local.common_tags

}

module "connector_kubernetes_cluster_certificate" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-certificate"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  certificate_credentials = {
    master_url           = "https://k8s.url"
    certificate          = local.test_secret_name
    client_key_algorithm = "rsa"
    client_key           = local.test_secret_name
  }
  global_tags = local.common_tags

}

module "connector_kubernetes_cluster_certificate_ca_cert" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-certificate-ca-cert"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  certificate_credentials = {
    master_url           = "https://k8s.url"
    certificate          = local.test_secret_name
    client_key_algorithm = "rsa"
    client_key           = local.test_secret_name
    ca_cert              = local.test_secret_name
  }
  global_tags = local.common_tags

}

module "connector_kubernetes_cluster_certificate_passphrase" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-certificate-passphrase"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  certificate_credentials = {
    master_url           = "https://k8s.url"
    certificate          = local.test_secret_name
    client_key_algorithm = "rsa"
    client_key           = local.test_secret_name
    passphrase           = local.test_secret_name
  }
  global_tags = local.common_tags

}


module "connector_kubernetes_cluster_openid_connect" {
  depends_on = [
    time_sleep.load_dependencies
  ]

  source = "../../modules/kubernetes/cluster"

  name               = "test-kubernetes-cluster-openid-connect"
  organization_id    = local.organization_id
  project_id         = local.project_id
  delegate_selectors = ["account"]
  openid_connect_credentials = {
    master_url  = "https://k8s.url"
    issuer_url  = "https://k8s.url"
    client_id   = local.test_secret_name
    password    = local.test_secret_name
    username    = "main"
    secret_name = local.test_secret_name
    scopes      = ["all"]
  }
  global_tags = local.common_tags

}
