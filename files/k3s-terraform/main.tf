terraform {
  required_version = ">= 1.3.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "null" {}

resource "null_resource" "install_k3s_wsl" {

  # Install k3s
  provisioner "local-exec" {
    when    = create
    command = <<EOT
echo "Updating packages..."
sudo apt-get update -y || true

echo "Installing dependencies..."
sudo apt-get install -y curl ca-certificates iptables

echo "Disabling swap (required by Kubernetes)..."
sudo swapoff -a || true

echo "Installing latest stable k3s..."
curl -sfL https://get.k3s.io | sudo sh -

echo "Verifying k3s installation..."
sudo k3s kubectl get nodes
EOT
  }

  # Uninstall k3s on destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
echo "Uninstalling k3s..."
sudo /usr/local/bin/k3s-uninstall.sh || true
EOT
  }
}

