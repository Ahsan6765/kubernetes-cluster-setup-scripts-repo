#!/bin/bash
# ==============================
# Robust RKE2 Master Node Setup Script
# ==============================
set -euo pipefail

MASTER_WAIT_TIMEOUT=300   # seconds to wait for API server
SLEEP_INTERVAL=5

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

echo "Installing RKE2 server..."
curl -sfL https://get.rke2.io | sh -

echo "Enabling and starting RKE2 server..."
systemctl enable rke2-server
systemctl start rke2-server

# Wait for node-token to appear (server boot)
echo "Waiting for RKE2 to generate node-token..."
token_file="/var/lib/rancher/rke2/server/node-token"
i=0
while [ ! -f "$token_file" ] && [ $i -lt 60 ]; do
  sleep 2
  i=$((i+1))
done
if [ ! -f "$token_file" ]; then
  echo "Warning: node-token not found after wait. Continuing anyway..."
fi

# Export kubeconfig for the current user (supports running as root or non-root)
KUBECONFIG_PATH="${HOME:-/root}/.kube/config"
mkdir -p "$(dirname "$KUBECONFIG_PATH")"
cp -f /etc/rancher/rke2/rke2.yaml "$KUBECONFIG_PATH"
chown "$(id -u):$(id -g)" "$KUBECONFIG_PATH" || true
export KUBECONFIG="$KUBECONFIG_PATH"

# Ensure kubectl exists. Prefer RKE2-provided kubectl, otherwise symlink it.
if command -v kubectl >/dev/null 2>&1; then
  echo "kubectl already on PATH."
else
  RKE2_KUBECTL="/var/lib/rancher/rke2/bin/kubectl"
  if [ -x "$RKE2_KUBECTL" ]; then
    echo "Found RKE2 kubectl at $RKE2_KUBECTL — linking to /usr/local/bin/kubectl"
    ln -sf "$RKE2_KUBECTL" /usr/local/bin/kubectl
  else
    echo "No kubectl found. Fetching kubectl client (stable)..."
    # Get latest stable version string
    K8S_VER="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
    curl -LO "https://dl.k8s.io/release/${K8S_VER}/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
  fi
fi

# Wait for API server to respond via kubectl
echo "Waiting for Kubernetes API server to be ready (timeout ${MASTER_WAIT_TIMEOUT}s)..."
elapsed=0
until kubectl get nodes >/dev/null 2>&1; do
  sleep "$SLEEP_INTERVAL"
  elapsed=$((elapsed + SLEEP_INTERVAL))
  if [ $elapsed -ge $MASTER_WAIT_TIMEOUT ]; then
    echo "ERROR: timed out waiting for API server (after ${MASTER_WAIT_TIMEOUT}s)."
    echo "journalctl -u rke2-server -n 200 --no-pager"
    exit 1
  fi
done
echo "Kubernetes API is reachable."

echo "Master setup complete. Worker token (for joining nodes):"
cat "$token_file" || true

echo "Applying Calico CNI manifest..."
# Use the recommended Calico manifest URL (this one should work offline if you adjust)
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml

echo "Verify pods in kube-system:"
kubectl -n kube-system get pods

echo "Master node setup completed successfully."
