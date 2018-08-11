provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
    ami = "ami-3548444c" # centos 7
    instance_type = "t2.micro"
}
