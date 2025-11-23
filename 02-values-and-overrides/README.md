# Exercise 02: Values and Overrides

## Concept Overview

This exercise demonstrates how to manage configuration across multiple environments using Helm values and overrides. In enterprise environments, the same application needs to be deployed with different configurations for development, staging, and production. Helm's values system provides a flexible way to parameterize charts without modifying templates.

Values can be overridden in multiple ways: through additional values files using the -f flag, through command-line overrides using --set, or through a combination of both. Helm merges these values with a specific precedence order, allowing you to maintain environment-specific configurations while keeping templates generic and reusable.

## Learning Objectives

After completing this exercise, you will understand how to structure values.yaml for multi-environment deployments. You'll learn the precedence order of value sources and how to use multiple values files. You'll practice using --set for command-line overrides and understand when to use each override method. You'll also learn how to inspect effective values after merging.

## Chart Structure

The webapp chart includes multiple values files for different environments:

```
webapp/
├── Chart.yaml
├── values.yaml          # Default/base values
├── values-dev.yaml      # Development overrides
├── values-prod.yaml     # Production overrides
└── templates/
    ├── deployment.yaml
    └── service.yaml
```

The base values.yaml contains sensible defaults suitable for development. Environment-specific files like values-dev.yaml and values-prod.yaml contain only the values that differ from the base, following the DRY principle. Helm merges these files during installation, with later files taking precedence.

## Value Precedence Order

Helm applies values in this order, with later sources overriding earlier ones:

1. Default values from values.yaml in the chart
2. Values from parent chart if this is a subchart
3. Values files specified with -f flag (in order specified)
4. Individual values specified with --set flags

This precedence allows you to layer configurations effectively. You can maintain common defaults in values.yaml, environment-specific settings in separate files, and one-off overrides using --set for testing or special deployments.

## Step-by-Step Instructions

### Step 1: Examine the Values Files

Navigate to the exercise directory and compare the different values files:

```bash
cd 02-values-and-overrides
cat webapp/values.yaml
cat webapp/values-dev.yaml
cat webapp/values-prod.yaml
```

Notice how values-dev.yaml and values-prod.yaml only specify values that differ from the base. The development environment uses debug logging and fewer resources, while production uses warn-level logging, more replicas, and higher resource limits.

### Step 2: Render Templates with Default Values

See what gets deployed with just the default values:

```bash
helm template my-app webapp/
```

Examine the output and note the environment label, replica count, resource limits, and environment variables. These all come from values.yaml.

### Step 3: Render Templates with Development Values

Now render with development-specific values:

```bash
helm template my-app webapp/ -f webapp/values-dev.yaml
```

Compare this output with the previous one. Notice that debugMode is now "true", logLevel is "debug", and resources have increased. Values from values-dev.yaml merged with and overrode the base values.

### Step 4: Render Templates with Production Values

Render with production values:

```bash
helm template my-app webapp/ -f webapp/values-prod.yaml
```

Observe that replicas increased to 3, resources are much higher, logLevel is "warn", and the service type changed to NodePort. This demonstrates how the same chart adapts to different environments.

### Step 5: Create Namespaces

Create separate namespaces for dev and prod deployments:

```bash
kubectl create namespace dev
kubectl create namespace prod
```

### Step 6: Install Development Release

Install the chart with development values:

```bash
helm install webapp-dev webapp/ -f webapp/values-dev.yaml -n dev
```

Verify the deployment:

```bash
kubectl get all -n dev
kubectl describe deployment webapp-dev-webapp -n dev
```

Check the environment variables in the pod to confirm debug mode is enabled:

```bash
kubectl get pods -n dev
kubectl exec -n dev $(kubectl get pod -n dev -l app=webapp-dev-webapp -o jsonpath='{.items[0].metadata.name}') -- env | grep -E 'ENVIRONMENT|LOG_LEVEL|DEBUG_MODE'
```

### Step 7: Install Production Release

Install the chart with production values in a separate namespace:

```bash
helm install webapp-prod webapp/ -f webapp/values-prod.yaml -n prod
```

Verify the production deployment has 3 replicas:

```bash
kubectl get deployment webapp-prod-webapp -n prod
kubectl get pods -n prod
```

### Step 8: Use Command-Line Overrides

Install another release with command-line overrides:

```bash
helm install webapp-test webapp/ \
  --set replicaCount=2 \
  --set config.logLevel=trace \
  --set environment=testing \
  -n dev
```

This demonstrates using --set for quick overrides without creating a values file. Useful for testing or one-off deployments.

### Step 9: Combine Multiple Values Files

You can specify multiple -f flags to layer configurations:

```bash
helm template webapp-staging webapp/ \
  -f webapp/values-prod.yaml \
  --set replicaCount=2 \
  --set environment=staging
```

This takes production values but reduces replicas and changes the environment label, useful for a staging environment that mirrors production configuration but with fewer resources.

### Step 10: Inspect Effective Values

Check what values are actually being used in a deployed release:

```bash
helm get values webapp-dev -n dev
helm get values webapp-dev -n dev --all
```

The first command shows only overridden values. The second shows all values including defaults, which is useful for debugging configuration issues.

### Step 11: Upgrade with Different Values

Upgrade the development release with different configuration:

```bash
helm upgrade webapp-dev webapp/ \
  -f webapp/values-dev.yaml \
  --set config.maxConnections=200 \
  -n dev
```

Check the revision history:

```bash
helm history webapp-dev -n dev
```

You'll see two revisions. Each upgrade creates a new revision with its own set of values.

### Step 12: Compare Values Between Revisions

Get values from different revisions:

```bash
helm get values webapp-dev -n dev --revision 1
helm get values webapp-dev -n dev --revision 2
```

This shows how configuration changed between revisions, useful for troubleshooting issues after upgrades.

## Expected Output

When you install with development values, you should see 1 replica with debug logging enabled. When you install with production values, you should see 3 replicas with warn-level logging and higher resource limits. The kubectl describe commands should show the environment variables set according to the values files.

## Key Concepts Demonstrated

**Environment-Specific Values**: Separate values files for each environment keep configurations organized and maintainable.

**Value Merging**: Helm intelligently merges values from multiple sources, allowing layered configuration.

**Command-Line Overrides**: The --set flag enables quick overrides without modifying files, useful for CI/CD pipelines.

**Configuration as Code**: All configuration is version-controlled and reproducible, following infrastructure-as-code principles.

**Release Independence**: Multiple releases of the same chart can coexist with different configurations in different namespaces.

## Cleanup

Remove all releases and namespaces:

```bash
helm uninstall webapp-dev -n dev
helm uninstall webapp-test -n dev
helm uninstall webapp-prod -n prod
kubectl delete namespace dev
kubectl delete namespace prod
```

## Common Issues

**Values not taking effect**: Check the precedence order. Later sources override earlier ones. Use helm get values --all to see effective values.

**Syntax errors in values files**: YAML is whitespace-sensitive. Ensure proper indentation and no tabs.

**Nested value overrides**: When using --set with nested values, use dot notation like --set config.logLevel=debug.

**Array overrides**: Arrays are replaced entirely, not merged. Use --set-string for complex array values or use a values file.

## Next Steps

Proceed to exercise 03-template-functions-pipelines to learn about Helm's powerful template functions and how to use pipelines for data transformation.
