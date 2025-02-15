module "network" {
  source = "./modules/network"
}

module "compute" {
  source   = "./modules/compute"
  vpc_id   = module.network.vpc_id
  subnet_id = module.network.subnet_id
  vpc_cidr = var.vpc_cidr
  allowed_ssh_cidr = var.allowed_ssh_cidr
  key_name = var.key_name
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.network.vpc_id
  subnet_id = module.network.subnet_id
  domain_name = var.domain_name
  manual_validation_fqdns = var.manual_validation_fqdns
  instance_id = module.compute.instance_id
}
