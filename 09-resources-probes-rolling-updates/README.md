# Exercise 09: Resources, Probes, and Rolling Updates

## Concept Overview

This exercise demonstrates resource management, health checks, and deployment strategies in Kubernetes using Helm charts. Understanding these concepts is essential for enterprise-level deployments.

## Learning Objectives

After completing this exercise, you will understand the key concepts and best practices for resource management, health checks, and deployment strategies.

## Chart Structure

This chart demonstrates practical patterns for implementing resource management, health checks, and deployment strategies in production environments.

## Step-by-Step Instructions

### Step 1: Examine the Chart

Navigate to the exercise directory and examine the chart structure:

```bash
cd 09-resources-probes-rolling-updates
ls -la
```

### Step 2: Render Templates

Render the templates to see the generated resources:

```bash
helm template demo ./resources-probes-rolling-updates/
```

### Step 3: Install the Chart

Create a namespace and install the chart:

```bash
kubectl create namespace demo
helm install demo ./resources-probes-rolling-updates/ -n demo
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

This exercise demonstrates key enterprise patterns for resource management, health checks, and deployment strategies.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall demo -n demo
kubectl delete namespace demo
```

## Next Steps

Proceed to the next exercise to continue learning Helm chart development.
