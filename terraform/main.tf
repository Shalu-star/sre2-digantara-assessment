provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH from anywhere"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For testing; ideally use your IP
  }

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sre_vm" {
  ami           = "ami-0e35ddab05955cf57"  # Ubuntu 22.04 LTS in ap-south-1
  instance_type = "t2.micro"
  key_name      = "sre2-key"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "sre2-digantara-asses-vm"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io docker-compose -y",
      "sudo usermod -aG docker ubuntu"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Users/shalu/.ssh/sre2-key.pem")
      host        = self.public_ip
    }
  }
}

output "public_ip" {
  value = aws_instance.sre_vm.public_ip
}
