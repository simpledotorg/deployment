data "aws_availability_zones" "all" {}

output "ec2_sidekiq_server_id" {
	value = ( length(aws_instance.ec2_sidekiq_server) != 0 ? aws_instance.ec2_sidekiq_server[0].id : null)
}
