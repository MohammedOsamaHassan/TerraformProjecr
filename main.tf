provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  token      = var.token
}

module "network" {
  source             = "./modules/network"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

module "security" {
  source     = "./modules/security"
  vpc_id     = module.network.vpc_id
}

module "compute" {
  source            = "./modules/compute"
  ami               = "ami-084568db4383264d4"  
  instance_type     = "t2.micro"
  key_name          = var.key_name
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.security.ec2_sg
}

module "database" {
  source             = "./modules/database"
  db_name            = "wordpress"
  username           = "root"
  password           = var.db_password
  security_group_id  = module.security.rds_sg
  db_subnet_group    = module.network.db_subnet_group
  public_subnet_id   = module.network.public_subnet_id
  private_subnet_id  = module.network.private_subnet_id
  vpc_id             = module.network.vpc_id
  subnet_ids         = [module.network.private_subnet_id]
}