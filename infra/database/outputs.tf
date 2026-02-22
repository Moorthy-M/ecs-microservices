output "security_group" {
  value = module.main_db.security_group
}

output "rds_endpoint" {
  value = module.main_db.rds_endpoint
}

output "db_name" {
  value = module.main_db.db_name
}

output "db_secret_arn" {
  value = module.main_db.db_secret_arn
}