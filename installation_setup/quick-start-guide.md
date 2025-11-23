# Quick Start Guide

This is a condensed version of the installation guide for experienced users. For detailed instructions, see [README.md](README.md).

## Prerequisites

- Windows 10/11 (64-bit)
- 4 GB RAM minimum (8 GB recommended)
- 20 GB free disk space
- Administrator access

## Installation Steps

### 1. Install Docker Desktop

```powershell
# Download from https://www.docker.com/products/docker-desktop
# Run installer as administrator
# Enable WSL 2 when prompted
# Restart computer
```

Verify:
```powershell
docker --version
docker run hello-world
```

### 2. Enable Kubernetes

1. Docker Desktop → Settings → Kubernetes
2. Check "Enable Kubernetes"
3. Click "Apply & Restart"
4. Wait 3-5 minutes for installation

Verify:
```powershell
kubectl version --client
kubectl cluster-info
kubectl get nodes
kubectl config use-context docker-desktop
```

### 3. Install Helm

**Option A: Using Chocolatey**
```powershell
# Install Chocolatey (if needed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Helm
choco install kubernetes-helm
```

**Option B: Manual Installation**
1. Download from https://github.com/helm/helm/releases
2. Extract to C:\helm
3. Add to PATH environment variable

Verify:
```powershell
helm version
```

### 4. Test Complete Setup

```powershell
# Create test namespace
kubectl create namespace test-setup

# Install test application
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install test-nginx bitnami/nginx -n test-setup

# Verify
helm list -n test-setup
kubectl get all -n test-setup

# Access application
kubectl port-forward svc/test-nginx 8080:80 -n test-setup
# Open browser to http://localhost:8080

# Clean up
helm uninstall test-nginx -n test-setup
kubectl delete namespace test-setup
```

### 5. Clone Exercises Repository

```powershell
cd $HOME\Documents
git clone https://github.com/sunkaramallikarjuna369/HelmExcercises.git
cd HelmExcercises
git checkout devin/1763912892-helm-exercises
```

### 6. Start First Exercise

```powershell
cd 01-basic-chart-structure
type README.md
```

## Quick Verification Commands

```powershell
# Check Docker
docker --version
docker ps

# Check Kubernetes
kubectl version --client
kubectl get nodes
kubectl config current-context

# Check Helm
helm version
helm list --all-namespaces

# Check context
kubectl config use-context docker-desktop
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Docker won't start | Enable virtualization in BIOS, restart computer |
| Kubernetes won't start | Reset Kubernetes in Docker Desktop settings |
| kubectl not found | Restart PowerShell, check Docker Desktop is running |
| helm not found | Add helm to PATH, restart PowerShell |
| Port already in use | Use different port: `kubectl port-forward svc/name 8081:80` |

## Resource Recommendations

Adjust in Docker Desktop Settings → Resources:
- **CPUs**: 2-4
- **Memory**: 4-8 GB
- **Disk**: 20+ GB

## Ready to Start?

✅ Docker Desktop running  
✅ Kubernetes enabled and running  
✅ kubectl working  
✅ Helm installed  
✅ Repository cloned  

Start with Exercise 01!

For detailed instructions and troubleshooting, see [README.md](README.md).
