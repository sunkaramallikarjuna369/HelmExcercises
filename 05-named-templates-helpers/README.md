# Exercise 05: Named Templates and Helpers

## Concept Overview

This exercise demonstrates named templates (also called template helpers) which are reusable template snippets that reduce duplication and improve maintainability. Named templates are defined once in a special file called _helpers.tpl and can be included in any template within the chart. This pattern is fundamental to professional Helm charts and is used extensively in charts published to Artifact Hub.

Named templates follow Kubernetes labeling conventions and provide consistent naming, labeling, and selector patterns across all resources. By centralizing common logic in helpers, you ensure consistency and make charts easier to maintain. When you need to change a label or naming pattern, you only update the helper function rather than every template file.

## Learning Objectives

After completing this exercise, you will understand the purpose and structure of _helpers.tpl files. You'll learn how to define named templates using the define directive. You'll practice including named templates with include and template directives. You'll understand the difference between include and template. You'll master common helper patterns for names, labels, and selectors. You'll also learn how to pass context to named templates.

## Chart Structure

The helperapp chart demonstrates standard helper patterns:

```
helperapp/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl      # Named template definitions
    ├── deployment.yaml
    ├── service.yaml
    └── configmap.yaml
```

The _helpers.tpl file contains all named template definitions. The underscore prefix tells Helm not to render this file as a Kubernetes manifest. Other templates use include to invoke these helpers.

## Common Helper Patterns

**Name Helpers**: helperapp.name returns the chart name, helperapp.fullname returns a fully qualified name combining release and chart names.

**Label Helpers**: helperapp.labels returns standard labels including chart version and app version, helperapp.selectorLabels returns labels used for pod selectors.

**Chart Helper**: helperapp.chart returns the chart name and version formatted for labels.

**Image Helper**: helperapp.image constructs the full image reference with tag.

**Resource Helpers**: Helpers can generate entire YAML blocks like resource limits or annotations.

## Include vs Template

The include function renders a named template and returns the result as a string, which can be piped to other functions like nindent. The template action renders a named template directly but cannot be used in pipelines. Always prefer include over template for flexibility.

## Step-by-Step Instructions

### Step 1: Examine the Helpers File

Navigate to the exercise directory and examine the _helpers.tpl file:

```bash
cd 05-named-templates-helpers
cat helperapp/templates/_helpers.tpl
```

Notice the define blocks that create named templates. Each helper has a descriptive name prefixed with the chart name to avoid conflicts. The helpers use template functions and logic to generate consistent output.

### Step 2: Examine Helper Usage

Look at how templates use the helpers:

```bash
cat helperapp/templates/deployment.yaml
cat helperapp/templates/service.yaml
```

Notice the include statements that invoke helpers. The include function is followed by the helper name and a dot (.) to pass the current context. The nindent function properly indents the output.

### Step 3: Render Templates to See Helper Output

Render the templates to see what the helpers generate:

```bash
helm template my-release helperapp/
```

Examine the labels section in each resource. Notice the consistent labels across all resources: helm.sh/chart, app.kubernetes.io/name, app.kubernetes.io/instance, app.kubernetes.io/version, and app.kubernetes.io/managed-by. The selector labels are a subset used for pod selection.

### Step 4: Test Name Helpers

The fullname helper creates a name combining the release and chart names. Test with different release names:

```bash
helm template short-name helperapp/ | grep "name: short-name"
helm template very-long-release-name-that-exceeds-limits helperapp/ | grep "name:"
```

Notice how the fullname helper truncates names to 63 characters (Kubernetes limit) and removes trailing hyphens.

### Step 5: Test Name Override

The helpers support name overrides for flexibility:

```bash
helm template my-release helperapp/ --set nameOverride="custom" | grep "app.kubernetes.io/name"
helm template my-release helperapp/ --set fullnameOverride="totally-custom" | grep "name:"
```

The nameOverride changes the app name component, while fullnameOverride replaces the entire name. This is useful when integrating with existing infrastructure.

### Step 6: Examine Label Consistency

Check that selector labels match between deployment and service:

```bash
helm template my-release helperapp/ | grep -A 5 "selector:"
```

The deployment's selector and the service's selector both use the same labels generated by helperapp.selectorLabels. This consistency is critical for services to route traffic correctly.

### Step 7: Test Common Labels

Add common labels and see them propagated:

```bash
helm template my-release helperapp/ \
  --set commonLabels.team="backend" \
  --set commonLabels.owner="john" | grep -A 10 "labels:"
```

The helperapp.labels helper includes common labels, so they appear on all resources. This pattern enables organization-wide labeling standards.

### Step 8: Examine the Image Helper

The image helper constructs the full image reference:

```bash
helm template my-release helperapp/ | grep "image:"
helm template my-release helperapp/ --set image.tag="2.0" | grep "image:"
helm template my-release helperapp/ --set image.tag="" | grep "image:"
```

When no tag is specified, the helper defaults to .Chart.AppVersion. This pattern keeps image versions synchronized with chart versions.

### Step 9: Test the Annotations Helper

The annotations helper includes pod annotations:

```bash
helm template my-release helperapp/ | grep -A 5 "annotations:"
```

The prometheus annotations appear on the pod template. Modify them:

```bash
helm template my-release helperapp/ \
  --set podAnnotations."custom\.io/annotation"="value" | grep -A 5 "annotations:"
```

### Step 10: Install and Verify

Create a namespace and install the chart:

```bash
kubectl create namespace helper-demo
helm install helper-demo helperapp/ -n helper-demo
```

Verify the resources have consistent labels:

```bash
kubectl get all -n helper-demo --show-labels
```

All resources should have the standard Kubernetes labels generated by the helpers.

### Step 11: Verify Service Selector

Check that the service correctly selects pods:

```bash
kubectl describe service helper-demo-helperapp -n helper-demo
```

The selector should match the pod labels. Test connectivity:

```bash
kubectl get endpoints helper-demo-helperapp -n helper-demo
```

The endpoints should list the pod IPs, confirming the selector works correctly.

### Step 12: Examine ConfigMap Helper Output

Check the ConfigMap to see helper output stored as data:

```bash
kubectl get configmap helper-demo-helperapp-config -n helper-demo -o yaml
```

The app.conf shows the output of various helpers, demonstrating how helpers can be used anywhere in templates.

## Expected Output

When you render the templates, you should see consistent labels across all resources including helm.sh/chart, app.kubernetes.io/name, app.kubernetes.io/instance, app.kubernetes.io/version, and app.kubernetes.io/managed-by. The selector labels should be a subset of the full labels. Resource names should be properly truncated and formatted.

## Key Concepts Demonstrated

**DRY Principle**: Named templates eliminate duplication by centralizing common logic.

**Consistency**: Helpers ensure consistent naming and labeling across all resources.

**Maintainability**: Changes to naming or labeling patterns require updates in only one place.

**Kubernetes Conventions**: Helpers implement standard Kubernetes label schemas.

**Context Passing**: The dot (.) passes the current context to named templates.

**Include vs Template**: Include allows piping output to functions like nindent for proper formatting.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall helper-demo -n helper-demo
kubectl delete namespace helper-demo
```

## Common Issues

**Missing context**: Always pass context with a dot: `{{ include "helper.name" . }}`. Without the dot, helpers can't access values.

**Indentation errors**: Use nindent to properly indent helper output. The number specifies indentation level.

**Name conflicts**: Prefix helper names with chart name to avoid conflicts with subcharts or library charts.

**Selector mismatch**: Ensure selector labels are a subset of pod labels and remain stable across upgrades.

## Next Steps

Proceed to exercise 06-services-and-ingress to learn how to expose applications using Kubernetes Services and Ingress resources, including setting up an ingress controller on Docker Desktop.
