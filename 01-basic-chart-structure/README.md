# Exercise 01: Basic Chart Structure

## Concept Overview

This exercise introduces the fundamental structure of a Helm chart and the basic commands for managing Helm releases. A Helm chart is a collection of files that describe a related set of Kubernetes resources. Understanding the chart structure is essential for creating and maintaining charts in enterprise environments.

Every Helm chart contains a Chart.yaml file that defines metadata about the chart, a values.yaml file that provides default configuration values, and a templates directory containing Kubernetes manifest templates. When you install a chart, Helm processes these templates by substituting values and built-in objects to generate valid Kubernetes YAML manifests.

## Learning Objectives

After completing this exercise, you will understand the purpose of Chart.yaml, values.yaml, and the templates directory. You'll learn how to use built-in template objects like .Release, .Chart, and .Values. You'll practice installing, listing, inspecting, and uninstalling Helm releases. You'll also understand how Helm manages release history and namespaces.

## Chart Structure

The myapp chart in this directory demonstrates a minimal but complete Helm chart structure:

```
myapp/
├── Chart.yaml           # Chart metadata
├── values.yaml          # Default configuration values
└── templates/
    ├── deployment.yaml  # Deployment template
    └── service.yaml     # Service template
```

The Chart.yaml file contains metadata including the chart name, version, description, and maintainer information. The version field tracks the chart version while appVersion tracks the application version. These can be incremented independently.

The values.yaml file provides default values that can be overridden during installation. Values are organized hierarchically and accessed in templates using dot notation like .Values.image.repository.

Template files in the templates directory are Kubernetes manifests with Go template syntax. They use double curly braces for template directives and can access built-in objects provided by Helm.

## Step-by-Step Instructions

### Step 1: Examine the Chart Files

Navigate to the exercise directory and examine each file to understand its purpose:

```bash
cd 01-basic-chart-structure
cat myapp/Chart.yaml
cat myapp/values.yaml
cat myapp/templates/deployment.yaml
cat myapp/templates/service.yaml
```

Notice how the Chart.yaml defines metadata, values.yaml provides configuration, and templates use {{ }} syntax to inject values.

### Step 2: Render Templates Without Installing

Use helm template to render the templates locally without installing to the cluster. This is useful for debugging and understanding what Kubernetes manifests will be generated:

```bash
helm template my-release myapp/
```

Examine the output carefully. Notice how {{ .Release.Name }} is replaced with "my-release", {{ .Chart.Name }} with "myapp", and {{ .Values.image.repository }} with "nginx". The toYaml function converts the resources section from values.yaml into properly formatted YAML.

### Step 3: Create a Namespace

Create a dedicated namespace for this exercise to keep resources organized:

```bash
kubectl create namespace helm-basics
```

### Step 4: Install the Chart

Install the chart as a release named "my-first-release" in the helm-basics namespace:

```bash
helm install my-first-release myapp/ -n helm-basics
```

Helm will display a success message with the release name, namespace, status, and any notes. The release name is important because it's used to identify this specific installation of the chart.

### Step 5: List Helm Releases

View all releases in the helm-basics namespace:

```bash
helm list -n helm-basics
```

You'll see your release listed with its name, namespace, revision number (starts at 1), status, chart name, and app version.

### Step 6: Check Kubernetes Resources

Verify that Kubernetes resources were created:

```bash
kubectl get all -n helm-basics
```

You should see a deployment, replicaset, pod, and service all prefixed with "my-first-release-myapp". Helm uses the release name to make resource names unique, allowing multiple installations of the same chart.

### Step 7: Get Release Values

View the values used for this release:

```bash
helm get values my-first-release -n helm-basics
```

This shows only the values you explicitly set during installation. Since we didn't override any values, it shows "null". To see all values including defaults:

```bash
helm get values my-first-release -n helm-basics --all
```

### Step 8: Get Release Manifest

View the actual Kubernetes manifests that were applied to the cluster:

```bash
helm get manifest my-first-release -n helm-basics
```

This shows the rendered templates that Helm sent to Kubernetes. Compare this with the output from helm template earlier.

### Step 9: Get Release History

View the revision history for this release:

```bash
helm history my-first-release -n helm-basics
```

You'll see revision 1 with status "deployed". Each upgrade creates a new revision, which enables rollbacks.

### Step 10: Access the Application

Since the service type is ClusterIP, use port-forward to access the nginx application:

```bash
kubectl port-forward svc/my-first-release-myapp 8080:80 -n helm-basics
```

Open a browser and navigate to http://localhost:8080 to see the nginx welcome page. Press Ctrl+C to stop port forwarding.

### Step 11: Inspect Chart Information

Use helm show commands to display chart information without installing:

```bash
helm show chart myapp/
helm show values myapp/
helm show all myapp/
```

These commands are useful for exploring charts before installation.

### Step 12: Uninstall the Release

Clean up by uninstalling the release:

```bash
helm uninstall my-first-release -n helm-basics
```

Verify resources are removed:

```bash
kubectl get all -n helm-basics
```

The namespace remains but all resources created by the chart are deleted.

### Step 13: View Uninstalled Releases

By default, helm list only shows deployed releases. To see uninstalled releases:

```bash
helm list -n helm-basics --uninstalled
```

Helm keeps release history even after uninstallation, which can be useful for auditing.

## Expected Output

When you install the chart, you should see output similar to:

```
NAME: my-first-release
LAST DEPLOYED: [timestamp]
NAMESPACE: helm-basics
STATUS: deployed
REVISION: 1
```

The kubectl get all command should show one pod running, one deployment, one replicaset, and one service.

## Key Concepts Demonstrated

**Chart Metadata**: Chart.yaml defines the chart identity, version, and metadata used by Helm and chart repositories.

**Default Values**: values.yaml provides sensible defaults that can be overridden per environment or deployment.

**Template Objects**: Built-in objects like .Release, .Chart, and .Values provide context to templates.

**Release Management**: Helm tracks releases with names, namespaces, and revision history.

**Resource Naming**: Using release names in resource names enables multiple installations of the same chart without conflicts.

## Cleanup

Remove the namespace to clean up completely:

```bash
kubectl delete namespace helm-basics
```

## Common Issues

**Error: release already exists**: Use a different release name or uninstall the existing release first.

**Error: namespace not found**: Create the namespace before installing, or omit the -n flag to use the default namespace.

**Port already in use**: Choose a different local port for port-forward, like 8081:80.

## Next Steps

Proceed to exercise 02-values-and-overrides to learn how to customize chart behavior by overriding values during installation and upgrade.
