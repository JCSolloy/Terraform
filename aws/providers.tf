terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
    region                  = "us-west-2"
    shared_credentials_files = ["~/.aws/credentials"]
    profile = "vscode"
<<<<<<< HEAD
}
=======
}
>>>>>>> f2571c5 (Test)
