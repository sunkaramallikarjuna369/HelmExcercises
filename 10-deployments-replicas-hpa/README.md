# Exercise 10: Deployments, Replicas, and HPA

## Concept Overview

This exercise demonstrates scaling applications with replicas and horizontal pod autoscaling in Kubernetes using Helm charts. Understanding these concepts is essential for enterprise-level deployments.

## Learning Objectives

After completing this exercise, you will understand the key concepts and best practices for scaling applications with replicas and horizontal pod autoscaling.

## Chart Structure

This chart demonstrates practical patterns for implementing scaling applications with replicas and horizontal pod autoscaling in production environments.

## Step-by-Step Instructions

### Step 1: Examine the Chart

Navigate to the exercise directory and examine the chart structure:

```bash
cd 10-deployments-replicas-hpa
ls -la
```

### Step 2: Render Templates

Render the templates to see the generated resources:

```bash
helm template demo ./deployments-replicas-hpa/
```

### Step 3: Install the Chart

Create a namespace and install the chart:

```bash
kubectl create namespace demo
helm install demo ./deployments-replicas-hpa/ -n demo
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

This exercise demonstrates key enterprise patterns for scaling applications with replicas and horizontal pod autoscaling.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall demo -n demo
kubectl delete namespace demo
```

## Next Steps

Proceed to the next exercise to continue learning Helm chart development.
