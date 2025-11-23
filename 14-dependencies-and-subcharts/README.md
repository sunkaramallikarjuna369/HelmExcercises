# Exercise 14: Dependencies and Subcharts

## Concept Overview

This exercise demonstrates how to use chart dependencies and subcharts to compose complex applications from multiple charts. Dependencies allow you to package related services together and manage them as a single unit. Understanding dependencies is essential for building modular, reusable charts in enterprise environments.

Helm supports two types of dependencies: subcharts stored in the charts/ directory and external dependencies declared in Chart.yaml. Dependencies can be enabled/disabled, configured through parent values, and share global values. This pattern enables microservice architectures where each service has its own chart but can be deployed together.

## Learning Objectives

After completing this exercise, you will understand how to declare dependencies in Chart.yaml. You'll learn how to manage subchart values from the parent chart. You'll practice using global values to share configuration across charts. You'll understand the helm dependency update command. You'll also learn how to enable/disable subcharts conditionally.

## Chart Structure

```
14-dependencies-and-subcharts/
├── parent-chart/
│   ├── Chart.yaml          # Declares redis-subchart as dependency
│   ├── values.yaml         # Parent and subchart values
│   └── templates/
│       └── deployment.yaml
└── redis-subchart/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        └── service.yaml
```

## Dependency Concepts

**Chart.yaml Dependencies**: Declares dependencies with name, version, and repository. Helm downloads and packages dependencies automatically.

**Subchart Values**: Parent chart can override subchart values using the subchart name as a key in values.yaml.

**Global Values**: Values under the global key are available to all charts and subcharts.

**Conditional Dependencies**: Subcharts can be enabled/disabled using the enabled flag or conditions in Chart.yaml.

## Step-by-Step Instructions

### Step 1: Examine the Parent Chart

Navigate to the exercise directory and examine the parent chart:

```bash
cd 14-dependencies-and-subcharts
cat parent-chart/Chart.yaml
cat parent-chart/values.yaml
```

Notice the dependencies section in Chart.yaml declaring redis-subchart. The values.yaml includes a redis-subchart section to configure the subchart and a global section shared by all charts.

### Step 2: Examine the Subchart

Look at the redis subchart:

```bash
cat redis-subchart/Chart.yaml
cat redis-subchart/templates/deployment.yaml
```

The subchart is a complete, standalone chart. Notice how it accesses .Values.global for global values.

### Step 3: Update Dependencies

Before installing, update dependencies to download/link the subchart:

```bash
cd parent-chart
helm dependency update
ls -la charts/
```

This creates a charts/ directory containing the redis-subchart. The dependency is packaged as a .tgz file.

### Step 4: Render Templates

Render the templates to see both parent and subchart resources:

```bash
helm template my-app .
```

Notice resources from both the parent chart and the redis-subchart. The subchart resources are prefixed with the release name and subchart name.

### Step 5: Install the Chart

Create a namespace and install:

```bash
kubectl create namespace dep-demo
helm install dep-demo . -n dep-demo
```

### Step 6: Verify All Resources

Check that resources from both charts were created:

```bash
kubectl get all -n dep-demo
```

You should see deployments and services for both the parent application and Redis.

### Step 7: Test Subchart Configuration

The parent deployment references the Redis service. Check the environment variable:

```bash
kubectl get deployment dep-demo-parent -n dep-demo -o yaml | grep REDIS_HOST
```

It should point to the Redis service created by the subchart.

### Step 8: Override Subchart Values

Upgrade with different subchart configuration:

```bash
helm upgrade dep-demo . \
  --set redis-subchart.replicaCount=2 \
  --set redis-subchart.image.tag="7.2" \
  -n dep-demo
```

Verify the Redis deployment was updated:

```bash
kubectl get deployment dep-demo-redis-subchart -n dep-demo
```

### Step 9: Test Global Values

Check that global values are accessible in both charts:

```bash
kubectl get deployment dep-demo-parent -n dep-demo -o yaml | grep environment
kubectl get deployment dep-demo-redis-subchart -n dep-demo -o yaml | grep environment
```

Both should show the global environment label.

### Step 10: Disable Subchart

Upgrade with the subchart disabled:

```bash
helm upgrade dep-demo . \
  --set redis-subchart.enabled=false \
  -n dep-demo
```

Verify Redis resources are removed:

```bash
kubectl get all -n dep-demo
```

Only the parent resources should remain.

### Step 11: List Dependencies

View chart dependencies:

```bash
helm dependency list
```

This shows all declared dependencies, their versions, and status.

### Step 12: Clean Up Dependency Cache

Remove the charts/ directory to clean up:

```bash
rm -rf charts/
helm dependency update
```

This demonstrates how to refresh dependencies when subcharts are updated.

## Expected Output

When you install the chart, you should see resources from both the parent chart and the redis-subchart. The parent deployment should reference the Redis service. When you disable the subchart, Redis resources should be removed. Global values should be accessible in both charts.

## Key Concepts Demonstrated

**Dependency Declaration**: Chart.yaml dependencies section declares required charts.

**Subchart Configuration**: Parent chart configures subcharts through values.yaml.

**Global Values**: Shared configuration across all charts using the global key.

**Conditional Subcharts**: Enable/disable subcharts using the enabled flag.

**Dependency Management**: helm dependency update downloads and packages dependencies.

**Modular Architecture**: Compose complex applications from reusable chart components.

## Cleanup

```bash
helm uninstall dep-demo -n dep-demo
kubectl delete namespace dep-demo
cd ..
```

## Common Issues

**Dependency not found**: Run helm dependency update before installing.

**Version conflicts**: Ensure subchart versions match the dependency declaration.

**Value overrides not working**: Use the subchart name as the key in values.yaml.

**Global values not accessible**: Ensure you're accessing .Values.global, not just .Values.

## Next Steps

Proceed to exercise 15-umbrella-chart-multiservice to learn how to create umbrella charts that deploy multiple microservices as a single application.
