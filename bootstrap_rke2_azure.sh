#!/bin/bash

set -e

PROJECT_NAME="rke2-azure-cluster"

echo "🚀 Creating project structure for: $PROJECT_NAME"

# Root directory
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo "📁 Creating environment folders..."
mkdir -p environments/dev
mkdir -p environments/test

echo "📁 Creating modules..."

# Core modules
MODULES=(
  "resource_group"
  "network"
  "nsg"
  "public_ip"
  "nic"
  "master"
  "worker"
  "storage"
)

for module in "${MODULES[@]}"; do
  mkdir -p modules/$module
  touch modules/$module/main.tf
  touch modules/$module/variables.tf
  touch modules/$module/outputs.tf
done

echo "📁 Creating scripts directory..."
mkdir -p scripts

touch scripts/master.sh
touch scripts/worker.sh

echo "📁 Creating root Terraform files..."

touch providers.tf
touch versions.tf
touch backend.tf
touch main.tf
touch variables.tf
touch outputs.tf

echo "📁 Creating tfvars files..."

touch environments/dev/terraform.tfvars
touch environments/test/terraform.tfvars

echo "📁 Setting execution permission for scripts..."
chmod +x scripts/master.sh
chmod +x scripts/worker.sh

echo "✅ Project structure created successfully!"
echo "📂 Location: $(pwd)"

echo ""
echo "Next steps:"
echo "1. Open project in VS Code"
echo "2. Start implementing Terraform modules"
echo "3. Add Azure backend config in backend.tf"