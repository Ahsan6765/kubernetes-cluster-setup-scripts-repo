#!/bin/bash

# ==============================
# RK2 Worker Node Setup Script
# ==============================

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <MASTER_IP> <NODE_TOKEN>"
  exit 1
fi

MASTER_IP=$1
NODE_TOKEN=$2

echo "Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Installing dependencies..."
sudo apt-get install -y curl wget apt-transport-https software-properties-common

echo "Installing containerd..."
sudo apt-get install -y containerd

echo "Configuring containerd..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "Enabling required kernel modules and sysctl parameters..."
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "Installing RKE2 agent..."
curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_TYPE="agent" sh -

echo "Configuring RKE2 agent to join cluster..."
sudo mkdir -p /etc/rancher/rke2
cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml
server: https://$MASTER_IP:9345
token: $NODE_TOKEN
EOF

echo "Enabling and starting RKE2 agent..."
sudo systemctl enable rke2-agent
sudo systemctl start rke2-agent

echo "Worker node setup completed successfully."
