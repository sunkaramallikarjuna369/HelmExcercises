# Exercise 04: Control Structures

## Concept Overview

This exercise demonstrates control structures in Helm templates, including conditional logic with if/else statements, loops with range, and scope management with with. Control structures enable you to create dynamic templates that adapt to different configurations, conditionally include or exclude resources, and iterate over collections to generate repetitive structures.

Control structures in Helm use the same double-curly-brace syntax as other template directives but with a dash (-) to control whitespace. Understanding whitespace control is crucial for generating clean, properly formatted YAML. The if statement evaluates conditions and includes template sections based on boolean values, while range iterates over lists and maps to generate repeated structures.

## Learning Objectives

After completing this exercise, you will understand how to use if/else/else if for conditional logic. You'll learn to use range for iterating over lists and maps. You'll master the with statement for changing scope and simplifying nested value access. You'll understand whitespace control with the dash (-) modifier. You'll also learn how to conditionally create entire resources based on feature flags.

## Chart Structure

The condapp chart demonstrates various control structures:

```
condapp/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── pvc.yaml
    └── configmap.yaml
```

The templates showcase if/else for feature flags, range for iterating over collections, with for scope management, and conditional resource creation. The ingress and PVC are only created when enabled in values.

## Control Structure Syntax

**If Statement**: `{{- if .Values.enabled }} ... {{- end }}` conditionally includes template content.

**If/Else**: `{{- if .Values.enabled }} ... {{- else }} ... {{- end }}` provides alternative content.

**Range**: `{{- range .Values.items }} ... {{- end }}` iterates over lists or maps.

**With**: `{{- with .Values.config }} ... {{- end }}` changes the scope to the specified value.

**Whitespace Control**: The dash (-) after {{ or before }} removes whitespace. Use `{{-` to trim left whitespace and `-}}` to trim right whitespace.

## Step-by-Step Instructions

### Step 1: Examine Conditional Logic

Navigate to the exercise directory and examine the deployment template:

```bash
cd 04-control-structures
cat condapp/templates/deployment.yaml
```

Notice the if statements that conditionally add annotations, ports, environment variables, and volume mounts based on values. The monitoring section is only included when monitoring.enabled is true. Feature flags control which environment variables are set.

### Step 2: Examine Conditional Resource Creation

Look at the service and ingress templates:

```bash
cat condapp/templates/service.yaml
cat condapp/templates/ingress.yaml
```

The entire service is wrapped in an if statement checking service.enabled. The ingress is only created when ingress.enabled is true. This pattern allows users to disable entire resources without modifying templates.

### Step 3: Examine Range Loops

Look at the ingress and configmap templates:

```bash
cat condapp/templates/ingress.yaml
cat condapp/templates/configmap.yaml
```

The ingress uses range to iterate over hosts and paths, generating rules for each. The configmap uses range to iterate over features, metrics, and environments. Notice how $ is used to access the root context inside range loops.

### Step 4: Render with Default Values

Render the templates with default values:

```bash
helm template my-app condapp/
```

Notice that the service is created (service.enabled is true), but the ingress and PVC are not (both disabled by default). The deployment includes monitoring annotations and ports. The configmap shows only enabled features.

### Step 5: Enable Ingress

Render with ingress enabled:

```bash
helm template my-app condapp/ --set ingress.enabled=true
```

Now the ingress resource appears in the output. Examine the rules section to see how range generated multiple host and path entries.

### Step 6: Enable Persistence

Render with persistence enabled:

```bash
helm template my-app condapp/ --set persistence.enabled=true
```

The PVC resource now appears, and the deployment includes volume and volumeMount sections. This demonstrates how a single flag can affect multiple template sections.

### Step 7: Test Feature Flags

Enable different features and observe the environment variables:

```bash
helm template my-app condapp/ \
  --set features.caching=true \
  --set features.tracing=true | grep -A 20 "env:"
```

Additional environment variables appear for caching and tracing. Feature flags provide a clean way to enable optional functionality.

### Step 8: Disable Monitoring

Render without monitoring:

```bash
helm template my-app condapp/ --set monitoring.enabled=false
```

The monitoring annotations, metrics port, and monitoring.conf in the configmap are all removed. This shows how a single flag can affect multiple resources.

### Step 9: Test Range with Different Data

Modify the metrics list:

```bash
helm template my-app condapp/ \
  --set monitoring.metrics[0].name=cpu \
  --set monitoring.metrics[0].threshold=90 \
  --set monitoring.metrics[1].name=disk \
  --set monitoring.metrics[1].threshold=85 | grep -A 10 "monitoring.conf"
```

The range loop generates entries for each metric in the list.

### Step 10: Install and Test Conditional Resources

Create a namespace and install with various configurations:

```bash
kubectl create namespace cond-demo
helm install cond-demo condapp/ -n cond-demo
```

Verify which resources were created:

```bash
kubectl get all,ingress,pvc -n cond-demo
```

You should see deployment, service, and configmap, but no ingress or PVC since they're disabled by default.

### Step 11: Upgrade to Enable Features

Upgrade to enable ingress and persistence:

```bash
helm upgrade cond-demo condapp/ \
  --set ingress.enabled=true \
  --set persistence.enabled=true \
  -n cond-demo
```

Check resources again:

```bash
kubectl get all,ingress,pvc -n cond-demo
```

The ingress and PVC now exist. Note that the deployment was updated to include the volume mount.

### Step 12: Test Range with Maps

Examine how range works with maps in the configmap:

```bash
kubectl get configmap cond-demo-condapp-config -n cond-demo -o yaml
```

The features.conf section shows only enabled features, demonstrating range with conditional logic inside the loop.

## Expected Output

When you render with default values, you should see deployment, service, and configmap resources. The ingress and PVC should not appear. When you enable ingress and persistence, those resources should appear in the output. The deployment should adapt to include monitoring ports and persistence volumes based on the enabled flags.

## Key Concepts Demonstrated

**Feature Flags**: Boolean values control optional functionality without template modifications.

**Conditional Resources**: Entire resources can be conditionally created based on values.

**Range Loops**: Iterate over lists and maps to generate repetitive structures.

**Scope Management**: Use $ to access root context inside range and with blocks.

**Whitespace Control**: The dash modifier keeps generated YAML clean and properly formatted.

**If/Else Logic**: Provide alternative configurations based on conditions.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall cond-demo -n cond-demo
kubectl delete namespace cond-demo
```

## Common Issues

**Whitespace errors**: Missing or extra whitespace can break YAML syntax. Use the dash modifier carefully.

**Scope issues in range**: Inside range, . refers to the current item. Use $ to access root context.

**Empty resources**: If all content in a resource is conditional and nothing is enabled, you might generate an empty resource. Wrap the entire resource in an if statement.

**Boolean evaluation**: Empty strings, zero, false, and nil are all falsy. Use explicit comparisons when needed.

## Next Steps

Proceed to exercise 05-named-templates-helpers to learn how to create reusable template snippets and helper functions that reduce duplication across templates.
