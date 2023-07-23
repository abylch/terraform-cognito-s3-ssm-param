resource "aws_ssm_parameter" "hello_param" {
  name        = "/res/hello"
  description = "Parameter to store the word 'hello'..."
  type        = "String"
  value       = "hello"
}