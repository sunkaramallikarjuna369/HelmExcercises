# Exercise 23: Chart Versioning and Packaging

## Concept Overview

This exercise demonstrates chart versioning and packaging in Kubernetes using Helm charts. Understanding these concepts is essential for enterprise-level deployments.

## Learning Objectives

After completing this exercise, you will understand the key concepts and best practices for chart versioning and packaging.

## Chart Structure

This chart demonstrates practical patterns for implementing chart versioning and packaging in production environments.

## Step-by-Step Instructions

### Step 1: Examine the Chart

Navigate to the exercise directory and examine the chart structure:

```bash
cd 23-chart-versioning-packaging
ls -la
```

### Step 2: Render Templates

Render the templates to see the generated resources:

```bash
helm template demo ./chart-versioning-packaging/
```

### Step 3: Install the Chart

Create a namespace and install the chart:

```bash
kubectl create namespace demo
helm install demo ./chart-versioning-packaging/ -n demo
```

### Step 4: Verify Resources

Check the created resources:

```bash
kubectl get all -n demo
```

### Step 5: Test the Application

Test the deployed application to verify it works correctly.

## Expected Output

The chart should deploy successfully and create the expected Kubernetes resources.

## Key Concepts Demonstrated

This exercise demonstrates key enterprise patterns for chart versioning and packaging.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall demo -n demo
kubectl delete namespace demo
```

## Next Steps

Proceed to the next exercise to continue learning Helm chart development.
