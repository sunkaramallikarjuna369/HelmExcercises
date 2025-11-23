# Installation and Setup Guide for Helm Charts Practice

This guide provides comprehensive step-by-step instructions for setting up your Windows machine with Docker Desktop, Kubernetes, and Helm to practice all the Helm chart exercises in this repository.

## Overview

To practice Helm charts on your Windows machine, you need three main components:

1. **Docker Desktop** - Provides a local Kubernetes cluster
2. **Kubernetes** - Container orchestration platform (included with Docker Desktop)
3. **Helm** - Kubernetes package manager

This guide will walk you through installing and configuring each component.

## Prerequisites

Before starting, ensure your Windows machine meets these requirements:

- **Operating System**: Windows 10 64-bit Pro, Enterprise, or Education (Build 19041 or higher) OR Windows 11
- **Hardware**: 
  - 4 GB RAM minimum (8 GB recommended)
  - 20 GB free disk space
  - CPU with virtualization support (Intel VT-x or AMD-V)
- **Administrator Access**: You'll need admin rights to install software

## Part 1: Install Docker Desktop

Docker Desktop includes both Docker Engine and a single-node Kubernetes cluster, making it perfect for local development and learning.

### Step 1.1: Download Docker Desktop

1. Open your web browser and go to: https://www.docker.com/products/docker-desktop
2. Click "Download for Windows"
3. Save the installer file (Docker Desktop Installer.exe) to your Downloads folder

### Step 1.2: Install Docker Desktop

1. Locate the downloaded file in your Downloads folder
2. Right-click on "Docker Desktop Installer.exe" and select "Run as administrator"
3. If prompted by User Account Control, click "Yes"
4. The installer will start. Follow these steps:
   - Check "Use WSL 2 instead of Hyper-V" (recommended for better performance)
   - Click "OK" to proceed with installation
   - Wait for the installation to complete (this may take 5-10 minutes)
5. When installation completes, click "Close and restart"
6. Your computer will restart

### Step 1.3: Start Docker Desktop

1. After restart, Docker Desktop should start automatically
2. If not, search for "Docker Desktop" in the Windows Start menu and launch it
3. Accept the Docker Subscription Service Agreement
4. You may be prompted to install WSL 2 Linux kernel update:
   - If prompted, click the link to download the WSL 2 kernel update
   - Install the update and restart Docker Desktop
5. Wait for Docker Desktop to start (you'll see a whale icon in the system tray)
6. When the whale icon stops animating, Docker is running

### Step 1.4: Verify Docker Installation

Open PowerShell (search for "PowerShell" in Start menu) and run:

```powershell
docker --version
```

You should see output like: `Docker version 24.0.x, build xxxxxxx`

Test Docker is working:

```powershell
docker run hello-world
```

You should see a "Hello from Docker!" message.

## Part 2: Enable Kubernetes in Docker Desktop

Docker Desktop includes Kubernetes, but it's disabled by default. Let's enable it.

### Step 2.1: Open Docker Desktop Settings

1. Click the Docker whale icon in your system tray (bottom-right corner)
2. Click the gear icon (⚙️) to open Settings
3. In the left sidebar, click "Kubernetes"

### Step 2.2: Enable Kubernetes

1. Check the box "Enable Kubernetes"
2. Check the box "Show system containers (advanced)" (optional, but helpful for learning)
3. Click "Apply & Restart"
4. A dialog will appear saying "Kubernetes cluster installation". Click "Install"
5. Wait for Kubernetes to install and start (this takes 3-5 minutes)
6. You'll see a green indicator showing "Kubernetes is running" when ready

### Step 2.3: Verify Kubernetes Installation

Open PowerShell and run:

```powershell
kubectl version --client
```

You should see the kubectl version information.

Check cluster status:

```powershell
kubectl cluster-info
```

You should see output showing the Kubernetes control plane is running.

Check nodes:

```powershell
kubectl get nodes
```

You should see one node named "docker-desktop" with status "Ready".

### Step 2.4: Set Docker Desktop as Current Context

Ensure kubectl is configured to use Docker Desktop:

```powershell
kubectl config use-context docker-desktop
```

Verify the current context:

```powershell
kubectl config current-context
```

Should output: `docker-desktop`

## Part 3: Install Helm

Helm is the package manager for Kubernetes. We'll install it using Chocolatey (Windows package manager) or manually.

### Option A: Install Helm Using Chocolatey (Recommended)

#### Step 3A.1: Install Chocolatey (if not already installed)

Open PowerShell as Administrator (right-click PowerShell, select "Run as administrator") and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Wait for installation to complete, then close and reopen PowerShell as Administrator.

#### Step 3A.2: Install Helm with Chocolatey

```powershell
choco install kubernetes-helm
```

Type "Y" when prompted to confirm installation.

### Option B: Install Helm Manually

#### Step 3B.1: Download Helm

1. Go to: https://github.com/helm/helm/releases
2. Download the latest Windows amd64 zip file (e.g., helm-v3.13.0-windows-amd64.zip)
3. Extract the zip file to a folder (e.g., C:\helm)

#### Step 3B.2: Add Helm to PATH

1. Open "Edit the system environment variables" from Start menu
2. Click "Environment Variables"
3. Under "System variables", find and select "Path", then click "Edit"
4. Click "New" and add the path to the helm folder (e.g., C:\helm\windows-amd64)
5. Click "OK" on all dialogs
6. Close and reopen PowerShell for changes to take effect

### Step 3.3: Verify Helm Installation

Open PowerShell and run:

```powershell
helm version
```

You should see output like: `version.BuildInfo{Version:"v3.13.0", ...}`

Test Helm is working:

```powershell
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm search repo stable
```

You should see a list of available charts.

## Part 4: Verify Complete Setup

Let's verify everything is working together by deploying a test application.

### Step 4.1: Create a Test Namespace

```powershell
kubectl create namespace test-setup
```

### Step 4.2: Deploy a Test Application with Helm

```powershell
# Add the bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install nginx
helm install test-nginx bitnami/nginx --namespace test-setup
```

### Step 4.3: Verify Deployment

```powershell
# Check the release
helm list -n test-setup

# Check Kubernetes resources
kubectl get all -n test-setup
```

You should see a deployment, pod, and service for nginx.

### Step 4.4: Access the Test Application

```powershell
kubectl port-forward svc/test-nginx 8080:80 -n test-setup
```

Open your browser to http://localhost:8080 - you should see the nginx welcome page.

Press Ctrl+C in PowerShell to stop port forwarding.

### Step 4.5: Clean Up Test Resources

```powershell
helm uninstall test-nginx -n test-setup
kubectl delete namespace test-setup
```

## Part 5: Configure Your Environment

### Step 5.1: Increase Docker Desktop Resources (Recommended)

For better performance when running multiple exercises:

1. Open Docker Desktop Settings (gear icon)
2. Click "Resources" in the left sidebar
3. Adjust the following:
   - **CPUs**: Set to at least 2 (4 recommended if available)
   - **Memory**: Set to at least 4 GB (8 GB recommended)
   - **Disk image size**: Ensure at least 20 GB available
4. Click "Apply & Restart"

### Step 5.2: Install Git (if not already installed)

You'll need Git to clone the exercises repository.

1. Download Git from: https://git-scm.com/download/win
2. Run the installer with default settings
3. Verify installation:

```powershell
git --version
```

### Step 5.3: Choose Your Terminal

You can use any of these terminals for the exercises:

- **PowerShell** (built into Windows)
- **Command Prompt** (built into Windows)
- **Git Bash** (installed with Git, provides Linux-like commands)
- **Windows Terminal** (recommended, download from Microsoft Store)

All exercises work with any terminal, but Git Bash or Windows Terminal provide the best experience.

## Part 6: Clone the Exercises Repository

Now that everything is set up, clone the Helm exercises repository:

```powershell
# Navigate to your preferred directory (e.g., Documents)
cd $HOME\Documents

# Clone the repository
git clone https://github.com/sunkaramallikarjuna369/HelmExcercises.git

# Navigate into the repository
cd HelmExcercises

# Checkout the branch with all exercises
git checkout devin/1763912892-helm-exercises

# List the exercises
dir
```

You should see 28 numbered exercise directories and this installation_setup folder.

## Part 7: Start Practicing

You're now ready to start practicing! Begin with Exercise 01:

```powershell
cd 01-basic-chart-structure
type README.md
```

Each exercise has a detailed README with:
- Concept overview
- Learning objectives
- Step-by-step instructions
- Expected output
- Troubleshooting tips

Work through the exercises in order for the best learning experience.

## Troubleshooting Common Issues

### Docker Desktop Won't Start

**Issue**: Docker Desktop fails to start or shows errors.

**Solutions**:
1. Ensure virtualization is enabled in BIOS
2. Check Windows features: Enable "Hyper-V" or "Virtual Machine Platform" and "Windows Subsystem for Linux"
3. Restart your computer
4. Reinstall Docker Desktop if issues persist

### Kubernetes Not Starting

**Issue**: Kubernetes stays in "Starting" state or fails to start.

**Solutions**:
1. Reset Kubernetes: Docker Desktop Settings → Kubernetes → Reset Kubernetes Cluster
2. Increase Docker Desktop memory allocation (Settings → Resources)
3. Check Docker Desktop logs: Settings → Troubleshoot → View logs

### kubectl Commands Not Working

**Issue**: kubectl commands return "command not found" or connection errors.

**Solutions**:
1. Verify Docker Desktop is running
2. Ensure Kubernetes is enabled and running (green indicator in Docker Desktop)
3. Set context: `kubectl config use-context docker-desktop`
4. Restart Docker Desktop

### Helm Commands Not Working

**Issue**: helm commands return "command not found".

**Solutions**:
1. Verify Helm is installed: Check if helm.exe exists in your installation directory
2. Ensure Helm is in your PATH environment variable
3. Close and reopen PowerShell after installation
4. Reinstall Helm if necessary

### Port Already in Use

**Issue**: Port forwarding fails with "address already in use".

**Solutions**:
1. Use a different port: `kubectl port-forward svc/service-name 8081:80`
2. Find and close the application using the port
3. Restart your computer if needed

### Pods Stuck in Pending State

**Issue**: Pods remain in "Pending" status.

**Solutions**:
1. Check pod events: `kubectl describe pod <pod-name> -n <namespace>`
2. Increase Docker Desktop resources (CPU/Memory)
3. Check if PersistentVolumes are available (for exercises using storage)

### Image Pull Errors

**Issue**: Pods fail with "ImagePullBackOff" or "ErrImagePull".

**Solutions**:
1. Check internet connection
2. Verify image name is correct
3. Wait a few minutes and check again (sometimes it's a temporary network issue)
4. Check Docker Desktop is logged in (for private images)

## Additional Resources

### Documentation
- Docker Desktop: https://docs.docker.com/desktop/
- Kubernetes: https://kubernetes.io/docs/
- Helm: https://helm.sh/docs/
- kubectl: https://kubernetes.io/docs/reference/kubectl/

### Learning Resources
- Kubernetes Basics: https://kubernetes.io/docs/tutorials/kubernetes-basics/
- Helm Getting Started: https://helm.sh/docs/intro/quickstart/
- Docker Desktop Kubernetes: https://docs.docker.com/desktop/kubernetes/

### Community Support
- Kubernetes Slack: https://slack.k8s.io/
- Helm Slack: https://slack.cncf.io/ (channel: #helm-users)
- Docker Community: https://www.docker.com/community/

## Next Steps

1. Verify all installations are working using the verification steps above
2. Clone the exercises repository
3. Start with Exercise 01: Basic Chart Structure
4. Work through exercises in order
5. Experiment and modify the charts to deepen your understanding

## Summary Checklist

Before starting the exercises, ensure you have:

- ✅ Docker Desktop installed and running
- ✅ Kubernetes enabled in Docker Desktop and running
- ✅ kubectl installed and working
- ✅ Helm installed and working
- ✅ Git installed
- ✅ Exercises repository cloned
- ✅ Test deployment successful

If all items are checked, you're ready to start practicing Helm charts!

## Getting Help

If you encounter issues not covered in this guide:

1. Check the troubleshooting section above
2. Review the specific exercise's README for exercise-specific issues
3. Check Docker Desktop logs (Settings → Troubleshoot → View logs)
4. Search for error messages online
5. Ask in Kubernetes or Helm community forums

Happy learning!
