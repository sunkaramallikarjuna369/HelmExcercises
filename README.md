# Helm Charts Enterprise Practice Exercises

This repository contains comprehensive Helm chart exercises designed to prepare you for enterprise-level Kubernetes deployments. Each exercise is self-contained in its own directory with a detailed README, sample chart, and step-by-step instructions for practicing on Docker Desktop.

## Prerequisites

Before starting these exercises, ensure you have the following installed and configured on your Windows machine:

### Required Software

**Docker Desktop** must be installed with Kubernetes enabled. To enable Kubernetes in Docker Desktop, open Docker Desktop settings, navigate to the Kubernetes section, check "Enable Kubernetes", and click "Apply & Restart". Wait for the Kubernetes cluster to start (you'll see a green indicator in Docker Desktop).

**kubectl** command-line tool should be available. Docker Desktop includes kubectl automatically. Verify installation by running `kubectl version --client` in your terminal.

**Helm 3** must be installed. Download from https://helm.sh/docs/intro/install/ or use a package manager like Chocolatey (`choco install kubernetes-helm`). Verify with `helm version`.

### Verify Your Setup

Open PowerShell, Command Prompt, or Git Bash and run these commands to verify your environment is ready:

```bash
kubectl config use-context docker-desktop
kubectl cluster-info
kubectl get nodes
helm version
```

You should see your Docker Desktop Kubernetes cluster running with one node in Ready status.

## Important Notes for Docker Desktop

Docker Desktop provides a single-node Kubernetes cluster that differs from cloud environments in several ways. LoadBalancer services will remain in "Pending" state since there's no external load balancer. Use NodePort services or `kubectl port-forward` to access applications instead. For ingress functionality, you'll install an ingress controller (nginx-ingress) in one of the early exercises.

Storage classes use the local filesystem, so PersistentVolumes are stored on your machine. This works well for practice but behaves differently than cloud storage. The cluster runs with full admin privileges, making it perfect for learning RBAC and security concepts without cloud account costs.

## Exercise Structure

Each exercise directory contains a complete Helm chart with templates, values files, and a detailed README. The README explains the concept, provides the exact commands to run, and describes what to observe. Exercises are numbered to suggest a learning progression, but you can jump to specific topics if you already understand the prerequisites.

## Exercise Categories

### Fundamentals (01-05)

These exercises cover the core building blocks of Helm charts. You'll learn chart structure, templating syntax, values management, and how to create reusable template helpers. Start here if you're new to Helm.

- **01-basic-chart-structure**: Understanding Chart.yaml, values.yaml, templates, and basic Helm commands
- **02-values-and-overrides**: Managing configuration with values files and command-line overrides
- **03-template-functions-pipelines**: Using built-in functions, pipelines, and template objects
- **04-control-structures**: Conditional logic and loops in templates
- **05-named-templates-helpers**: Creating reusable template snippets and helpers

### Kubernetes Resources (06-13)

These exercises show how to deploy various Kubernetes resources using Helm, with focus on configuration patterns and best practices for production deployments.

- **06-services-and-ingress**: Exposing applications with Services and Ingress resources
- **07-configmaps-and-secrets**: Managing application configuration and sensitive data
- **08-rbac-and-serviceaccounts**: Implementing role-based access control
- **09-resources-probes-rolling-updates**: Resource limits, health checks, and deployment strategies
- **10-deployments-replicas-hpa**: Scaling applications with replicas and autoscaling
- **11-statefulsets-and-persistence**: Deploying stateful applications with persistent storage
- **12-init-containers-sidecars**: Using init containers and sidecar patterns
- **13-scheduling-disruption-network**: Advanced scheduling, disruption budgets, and network policies

### Composition (14-15)

Learn how to compose complex applications from multiple charts and manage dependencies between services.

- **14-dependencies-and-subcharts**: Using chart dependencies and managing subcharts
- **15-umbrella-chart-multiservice**: Creating umbrella charts for multi-service applications

### Lifecycle Management (16-18)

Master the operational aspects of Helm releases including hooks, upgrades, rollbacks, and multi-environment deployments.

- **16-hooks-lifecycle**: Using Helm hooks for lifecycle management
- **17-upgrades-rollbacks-atomic**: Safely upgrading and rolling back releases
- **18-multi-environment-configs**: Managing multiple environments with the same chart

### Quality and Testing (19-20)

Ensure chart quality through linting, testing, and validation before deployment.

- **19-linting-and-testing**: Validating charts with helm lint and testing tools
- **20-values-schema-validation**: Enforcing value constraints with JSON schemas

### Security (21-22)

Implement security best practices for Helm charts and Kubernetes deployments.

- **21-secrets-management**: Secure patterns for managing secrets in Helm
- **22-pod-security-settings**: Configuring pod and container security contexts

### Packaging and Distribution (23-25)

Learn how to package, version, and distribute your charts through repositories and registries.

- **23-chart-versioning-packaging**: Versioning and packaging charts for distribution
- **24-helm-repo-oci-registry**: Hosting charts in Helm repositories and OCI registries
- **25-helm-plugins**: Extending Helm with plugins for enhanced workflows

### Advanced Patterns (26-28)

Explore advanced Helm features and enterprise best practices for production-grade charts.

- **26-capabilities-conditional-resources**: Adapting charts to different Kubernetes versions
- **27-lookup-function**: Dynamically querying existing cluster resources
- **28-best-practices-conventions**: Enterprise patterns and chart conventions

## How to Use These Exercises

Navigate to each exercise directory and read its README file. Each README follows a consistent structure: concept explanation, learning objectives, the chart structure, step-by-step instructions with exact commands, expected output, and cleanup instructions.

Work through exercises in order if you're learning Helm from scratch. Each exercise builds on concepts from previous ones. If you're already familiar with basic Helm usage, jump directly to topics you want to practice.

Always clean up resources after each exercise using the provided cleanup commands. This prevents resource conflicts and keeps your Docker Desktop cluster clean. Use `helm list --all-namespaces` to see all releases and `kubectl get all --all-namespaces` to check for remaining resources.

## Common Commands Reference

Here are the most frequently used commands throughout these exercises:

```bash
# Check current context
kubectl config current-context

# Create a namespace
kubectl create namespace <namespace-name>

# Install a chart
helm install <release-name> ./<chart-directory> -n <namespace>

# Install with custom values
helm install <release-name> ./<chart-directory> -f custom-values.yaml -n <namespace>

# List releases
helm list -n <namespace>
helm list --all-namespaces

# Get release details
helm get values <release-name> -n <namespace>
helm get manifest <release-name> -n <namespace>

# Upgrade a release
helm upgrade <release-name> ./<chart-directory> -n <namespace>

# Rollback a release
helm rollback <release-name> <revision> -n <namespace>

# Uninstall a release
helm uninstall <release-name> -n <namespace>

# Template rendering (dry-run)
helm template <release-name> ./<chart-directory>

# Lint a chart
helm lint ./<chart-directory>

# Check Kubernetes resources
kubectl get all -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>

# Port forwarding
kubectl port-forward svc/<service-name> <local-port>:<service-port> -n <namespace>
```

## Troubleshooting

If you encounter issues during exercises, here are common solutions:

**Helm command not found**: Ensure Helm is installed and added to your PATH. Restart your terminal after installation.

**kubectl cannot connect to cluster**: Verify Docker Desktop Kubernetes is running (green indicator in Docker Desktop). Run `kubectl config use-context docker-desktop` to switch to the correct context.

**Pods stuck in Pending state**: Check pod events with `kubectl describe pod <pod-name>`. Common causes include insufficient resources or missing PersistentVolumes. Docker Desktop has resource limits set in Docker Desktop settings.

**ImagePullBackOff errors**: The image name might be incorrect, or you need to pull the image first. Docker Desktop can pull public images from Docker Hub automatically, but private images require authentication.

**Port already in use**: Another application or previous exercise might be using the port. Use `kubectl port-forward` with a different local port, or clean up previous resources.

**Helm release already exists**: Uninstall the previous release with `helm uninstall <release-name> -n <namespace>` or use a different release name.

## Additional Resources

- Official Helm Documentation: https://helm.sh/docs/
- Kubernetes Documentation: https://kubernetes.io/docs/
- Helm Chart Best Practices: https://helm.sh/docs/chart_best_practices/
- Artifact Hub (public charts): https://artifacthub.io/

## Contributing

This repository is for personal practice and learning. Feel free to modify exercises, add your own variations, or extend charts with additional features as you learn.

## Getting Help

If you encounter issues specific to Docker Desktop or Windows, consult the Docker Desktop documentation. For Helm-specific questions, the official Helm documentation and community Slack channel are excellent resources.

Happy learning! Work through these exercises at your own pace, experiment with modifications, and don't hesitate to break things - that's how you learn best in a local environment.
