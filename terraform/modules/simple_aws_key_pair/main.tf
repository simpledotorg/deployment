resource "aws_key_pair" "simple_aws_key" {
	key_name   = "simple-server"
	public_key = file("~/.ssh/simple_aws_key.pub")
}

output "simple_aws_key_name" {
	value       = aws_key_pair.simple_aws_key.key_name
	description = "Name of the default key pair"
}
