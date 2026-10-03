
#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

exec &> >(tee -a /var/log/rke2-bootstrap.log)
echo "=== RKE2 Worker Bootstrap started at $(date -u) ==="

echo "Installing dependencies..."
apt-get update -y
apt-get install -y curl ca-certificates

echo "Configuring system for Kubernetes..."
modprobe br_netfilter || true
cat > /etc/modules-load.d/rke2.conf <<MOD
br_netfilter
overlay
MOD
modprobe overlay || true

# Idempotent sysctl
grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf 2>/dev/null || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
grep -q '^net.bridge.bridge-nf-call-iptables=1' /etc/sysctl.conf 2>/dev/null || echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
sysctl -p

echo "Installing RKE2 agent..."
if ! command -v rke2 >/dev/null 2>&1; then
  for i in $(seq 1 5); do
    echo "RKE2 agent install attempt $i/5..."
    if curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -; then
      echo "RKE2 agent install succeeded on attempt $i"
      break
    fi
    if [ "$i" -eq 5 ]; then
      echo "ERROR: RKE2 agent install failed after 5 attempts"
      exit 1
    fi
    sleep 10
  done
fi

mkdir -p /etc/rancher/rke2/

echo "Writing RKE2 config..."
cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://${MASTER_PRIVATE_IP}:9345
token: ${NODE_TOKEN}
EOF

mkdir -p /etc/systemd/system/rke2-agent.service.d
cat > /etc/systemd/system/rke2-agent.service.d/override.conf <<OVERRIDE
[Service]
TimeoutStartSec=600
OVERRIDE
systemctl daemon-reload

systemctl enable rke2-agent

echo "Starting RKE2 agent (may take several minutes)..."
systemctl start rke2-agent
echo "RKE2 agent is active ✔"

echo "=== Worker bootstrap complete ✔ at $(date -u) ==="