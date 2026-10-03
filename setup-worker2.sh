#!/bin/bash
# ==============================
# RKE2 Worker Node Setup Script
# ==============================
set -euo pipefail

MASTER_IP="$1"
TOKEN="$2"

if [ -z "$MASTER_IP" ] || [ -z "$TOKEN" ]; then
  echo "Usage: sudo bash setup-worker.sh <MASTER_IP> <NODE_TOKEN>"
  exit 1
fi

echo "Updating system..."
apt-get update -y && apt-get upgrade -y

echo "Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab || true

echo "Installing dependencies..."
apt-get install -y curl wget apt-transport-https software-properties-common

echo "Installing containerd..."
apt-get install -y containerd

echo "Configuring containerd..."
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo "Enabling required kernel modules and sysctl parameters..."
modprobe overlay || true
modprobe br_netfilter || true

cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

echo "Installing RKE2 agent..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

echo "Creating RKE2 agent config..."
mkdir -p /etc/rancher/rke2

cat <<EOF >/etc/rancher/rke2/config.yaml
server: https://${MASTER_IP}:9345
token: "${TOKEN}"
tls-san:
  - ${MASTER_IP}
EOF

echo "Enabling and starting RKE2 agent..."
systemctl enable rke2-agent
systemctl start rke2-agent

echo "Waiting for worker node to join the cluster..."
sleep 20

# Optional: enable kubectl for debugging on worker
RKE2_KUBECTL="/var/lib/rancher/rke2/bin/kubectl"
if [ -x "$RKE2_KUBECTL" ]; then
  ln -sf "$RKE2_KUBECTL" /usr/local/bin/kubectl
fi

echo "Checking node status..."
echo "Run this on master:"
echo "  kubectl get nodes -o wide"

echo "Worker node setup completed successfully."
