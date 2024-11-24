output "dev_ip" {
  value = aws_instance.mtc_instance.public_ip
}