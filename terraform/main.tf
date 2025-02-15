module "network" {
  source = "./modules/network"
  # 必要な変数は modules/network/variables.tf でデフォルト値が設定済み
}

module "keypair" {
  source   = "./modules/keypair"
  key_name = var.key_name
}

module "compute" {
  source                  = "./modules/compute"
  vpc_id                  = module.network.vpc_id
  subnet_id               = module.network.public_subnet_a_id
  vpc_cidr                = var.vpc_cidr
  allowed_ssh_cidr        = var.allowed_ssh_cidr
  key_name                = module.keypair.key_name
  keycloak_admin          = var.keycloak_admin
  keycloak_admin_password = var.keycloak_admin_password
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.network.vpc_id
  public_subnet_ids = [
    module.network.public_subnet_a_id,
    module.network.public_subnet_c_id,
  ]
  domain_name = var.domain_name
  instance_id = module.compute.instance_id
}
