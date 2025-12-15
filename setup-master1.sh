#!/bin/bash

# ==============================
# RK2 Master Node Setup Script
# ==============================

set -e

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

echo "Installing RKE2 server..."
curl -sfL https://get.rke2.io | sudo sh -

echo "Enabling and starting RKE2 server..."
sudo systemctl enable rke2-server
sudo systemctl start rke2-server

echo "Waiting for RKE2 to be ready..."
sleep 60

echo "Exporting kubeconfig..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/rke2/rke2.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Master setup complete. Retrieve token for worker node:"
sudo cat /var/lib/rancher/rke2/server/node-token

echo "Applying Calico CNI..."
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml

echo "Master node setup completed successfully."
