db_identifier         = "RDS"
db_engine             = "mysql"
db_engine_version     = "8.0.44"
db_allocatted_storage = 20
db_storage_type       = "gp2"
db_instance_class     = "db.t3.micro"
db_name               = "ecs_db"
db_username           = "admin"

db_multi_az                = false
db_deletion_protection     = false
db_skip_final_snapshot     = true
db_backup_retention_period = 1
