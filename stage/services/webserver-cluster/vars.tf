variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

variable "flask_host" {
  description = "Host for server flask"
  default = "0.0.0.0"
}
