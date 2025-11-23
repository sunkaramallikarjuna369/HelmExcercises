# Installation Verification Checklist

Use this checklist to verify your environment is correctly set up before starting the Helm exercises.

## Pre-Installation Checklist

Before installing, verify your system meets these requirements:

- [ ] Windows 10 64-bit Pro, Enterprise, or Education (Build 19041+) OR Windows 11
- [ ] At least 4 GB RAM available (8 GB recommended)
- [ ] At least 20 GB free disk space
- [ ] Administrator access to install software
- [ ] Virtualization enabled in BIOS (Intel VT-x or AMD-V)
- [ ] Internet connection available

## Docker Desktop Installation Checklist

- [ ] Docker Desktop downloaded from official website
- [ ] Docker Desktop installed as administrator
- [ ] WSL 2 enabled (if prompted)
- [ ] Computer restarted after installation
- [ ] Docker Desktop started and running (whale icon in system tray)
- [ ] Docker Subscription Service Agreement accepted

### Docker Verification Commands

Run these commands in PowerShell and verify the output:

```powershell
# Check Docker version
docker --version
```
Expected: `Docker version 24.0.x` or higher

```powershell
# Test Docker is working
docker run hello-world
```
Expected: "Hello from Docker!" message

```powershell
# Check Docker is running
docker ps
```
Expected: List of containers (may be empty)

- [ ] All Docker verification commands successful

## Kubernetes Installation Checklist

- [ ] Docker Desktop Settings opened
- [ ] Kubernetes section accessed
- [ ] "Enable Kubernetes" checkbox checked
- [ ] "Apply & Restart" clicked
- [ ] Kubernetes installation completed (3-5 minutes)
- [ ] Green "Kubernetes is running" indicator visible in Docker Desktop

### Kubernetes Verification Commands

Run these commands in PowerShell and verify the output:

```powershell
# Check kubectl version
kubectl version --client
```
Expected: Client version information displayed

```powershell
# Check cluster info
kubectl cluster-info
```
Expected: Kubernetes control plane URL displayed

```powershell
# Check nodes
kubectl get nodes
```
Expected: One node named "docker-desktop" with STATUS "Ready"

```powershell
# Check current context
kubectl config current-context
```
Expected: `docker-desktop`

```powershell
# Set context (if needed)
kubectl config use-context docker-desktop
```
Expected: Switched to context "docker-desktop"

```powershell
# List all namespaces
kubectl get namespaces
```
Expected: List including default, kube-system, kube-public, kube-node-lease

- [ ] All Kubernetes verification commands successful

## Helm Installation Checklist

Choose one installation method:

### Method A: Chocolatey
- [ ] Chocolatey installed
- [ ] PowerShell opened as Administrator
- [ ] `choco install kubernetes-helm` executed
- [ ] Installation confirmed with "Y"
- [ ] PowerShell restarted

### Method B: Manual
- [ ] Helm downloaded from GitHub releases
- [ ] Helm extracted to folder (e.g., C:\helm)
- [ ] Helm folder added to PATH environment variable
- [ ] PowerShell restarted

### Helm Verification Commands

Run these commands in PowerShell and verify the output:

```powershell
# Check Helm version
helm version
```
Expected: `version.BuildInfo{Version:"v3.x.x"...}`

```powershell
# Add a repository
helm repo add stable https://charts.helm.sh/stable
```
Expected: "stable" has been added to your repositories

```powershell
# Update repositories
helm repo update
```
Expected: Successfully got an update from the "stable" chart repository

```powershell
# Search for charts
helm search repo stable | Select-Object -First 5
```
Expected: List of available charts

- [ ] All Helm verification commands successful

## Complete Setup Verification

### End-to-End Test

Run this complete test to verify everything works together:

```powershell
# 1. Create test namespace
kubectl create namespace verify-setup
```
Expected: namespace/verify-setup created

```powershell
# 2. Add bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
Expected: Repository added and updated

```powershell
# 3. Install nginx chart
helm install verify-nginx bitnami/nginx --namespace verify-setup
```
Expected: Release "verify-nginx" deployed

```powershell
# 4. Check release
helm list -n verify-setup
```
Expected: verify-nginx listed with STATUS "deployed"

```powershell
# 5. Check resources
kubectl get all -n verify-setup
```
Expected: deployment, replicaset, pod, and service listed

```powershell
# 6. Wait for pod to be ready (may take 30-60 seconds)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=nginx -n verify-setup --timeout=120s
```
Expected: pod/verify-nginx-xxx condition met

```powershell
# 7. Test port forwarding (run in background or separate terminal)
kubectl port-forward svc/verify-nginx 8080:80 -n verify-setup
```
Expected: Forwarding from 127.0.0.1:8080 -> 80

- [ ] Open browser to http://localhost:8080
- [ ] Nginx welcome page displayed

```powershell
# 8. Clean up (press Ctrl+C to stop port-forward first)
helm uninstall verify-nginx -n verify-setup
kubectl delete namespace verify-setup
```
Expected: Release uninstalled, namespace deleted

- [ ] Complete end-to-end test successful

## Git Installation Checklist

- [ ] Git downloaded from https://git-scm.com/download/win
- [ ] Git installed with default settings
- [ ] PowerShell restarted

### Git Verification Commands

```powershell
# Check Git version
git --version
```
Expected: `git version 2.x.x`

- [ ] Git verification successful

## Repository Clone Checklist

```powershell
# Navigate to desired directory
cd $HOME\Documents

# Clone repository
git clone https://github.com/sunkaramallikarjuna369/HelmExcercises.git

# Navigate into repository
cd HelmExcercises

# Checkout exercises branch
git checkout devin/1763912892-helm-exercises

# List contents
dir
```

- [ ] Repository cloned successfully
- [ ] Branch checked out successfully
- [ ] 28 exercise directories visible
- [ ] installation_setup directory visible

## Resource Configuration Checklist

Recommended Docker Desktop resource settings:

- [ ] Docker Desktop Settings opened
- [ ] Resources section accessed
- [ ] CPUs set to 2 or more (4 recommended)
- [ ] Memory set to 4 GB or more (8 GB recommended)
- [ ] Disk image size has 20+ GB available
- [ ] "Apply & Restart" clicked if changes made

## Final Verification

Before starting exercises, confirm:

- [ ] Docker Desktop is running (whale icon in system tray)
- [ ] Kubernetes is running (green indicator in Docker Desktop)
- [ ] kubectl commands work without errors
- [ ] helm commands work without errors
- [ ] End-to-end test completed successfully
- [ ] Repository cloned and accessible
- [ ] PowerShell or preferred terminal ready to use

## Troubleshooting Reference

If any checks fail, refer to:

1. **Detailed Installation Guide**: [README.md](README.md) - Complete step-by-step instructions
2. **Quick Start Guide**: [quick-start-guide.md](quick-start-guide.md) - Condensed installation steps
3. **Docker Desktop Documentation**: https://docs.docker.com/desktop/
4. **Kubernetes Documentation**: https://kubernetes.io/docs/
5. **Helm Documentation**: https://helm.sh/docs/

## Common Issues Quick Reference

| Failed Check | Likely Issue | Quick Fix |
|--------------|--------------|-----------|
| Docker version | Docker not installed | Install Docker Desktop |
| Docker ps | Docker not running | Start Docker Desktop |
| kubectl version | Kubernetes not enabled | Enable in Docker Desktop Settings |
| kubectl get nodes | Kubernetes not ready | Wait 5 minutes, restart Docker Desktop |
| helm version | Helm not installed | Install Helm via Chocolatey or manually |
| helm commands | Helm not in PATH | Add to PATH, restart PowerShell |
| Port forward fails | Port in use | Use different port (8081, 8082, etc.) |
| Pod pending | Insufficient resources | Increase Docker Desktop memory |
| Image pull error | Network issue | Check internet, wait and retry |

## Ready to Start?

If all checks are complete and successful, you're ready to begin the exercises!

### Next Steps:

1. Navigate to first exercise:
   ```powershell
   cd 01-basic-chart-structure
   ```

2. Read the exercise README:
   ```powershell
   type README.md
   ```

3. Follow the step-by-step instructions in each exercise

4. Work through exercises in order for best learning experience

## Need Help?

If you encounter issues:

1. Review the troubleshooting section in [README.md](README.md)
2. Check Docker Desktop logs (Settings → Troubleshoot → View logs)
3. Restart Docker Desktop
4. Restart your computer
5. Consult official documentation links above

Good luck with your Helm learning journey!
