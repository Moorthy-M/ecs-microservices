output "service_sgs" {
  value = { for service in module.services : service.service_name => service.service_sg_id }
}