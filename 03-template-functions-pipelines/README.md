# Exercise 03: Template Functions and Pipelines

## Concept Overview

This exercise explores Helm's extensive library of template functions and the pipeline syntax for data transformation. Template functions enable you to manipulate strings, format data, perform calculations, and transform values within templates. Understanding these functions is essential for creating flexible, maintainable charts that handle various input formats and generate correct Kubernetes manifests.

Helm provides over 60 built-in functions from the Sprig library plus Helm-specific functions. Functions can be chained using the pipeline operator (|) to perform sequential transformations, similar to Unix pipes. This functional approach keeps templates readable while enabling powerful data manipulation.

## Learning Objectives

After completing this exercise, you will understand common string manipulation functions like upper, lower, quote, and replace. You'll learn data formatting functions including toYaml, toJson, and toString. You'll practice using default values and type conversion functions. You'll master the pipeline syntax for chaining functions. You'll also learn utility functions like sha256sum for generating checksums and include for template composition.

## Chart Structure

The funcapp chart demonstrates various template functions in realistic scenarios:

```
funcapp/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── configmap.yaml
    └── service.yaml
```

The templates showcase string functions, type conversions, data formatting, list operations, and checksum generation. Each template includes comments explaining the functions used.

## Key Template Functions

**String Functions**: upper, lower, quote, trim, replace, trunc, repeat, substr, and many more for string manipulation.

**Default and Coalesce**: default provides fallback values when a value is empty or undefined. Coalesce returns the first non-empty value from a list.

**Type Conversion**: toString, toJson, toYaml, int, float64 convert between types and formats.

**List Functions**: join, split, append, prepend, first, last, rest, initial for list manipulation.

**Encoding**: b64enc, b64dec for base64 encoding, sha256sum for checksums.

**Helm-Specific**: include, required, fail, lookup for advanced template operations.

## Step-by-Step Instructions

### Step 1: Examine Template Functions in Use

Navigate to the exercise directory and examine the deployment template:

```bash
cd 03-template-functions-pipelines
cat funcapp/templates/deployment.yaml
```

Notice the various functions: replace for sanitizing chart version, default for image tag fallback, upper for environment variable names, printf for string formatting, join for list concatenation, toString for type conversion, and sha256sum for config checksums.

### Step 2: Examine the ConfigMap Template

Look at how data formatting functions work:

```bash
cat funcapp/templates/configmap.yaml
```

The ConfigMap demonstrates toJson and toYaml for converting structured data, range for iterating over lists, and quote for ensuring proper YAML string formatting.

### Step 3: Render Templates to See Function Output

Render the templates to see the actual output:

```bash
helm template my-release funcapp/
```

Examine the rendered YAML carefully. Notice how the chart version "0.1.0" appears in labels, the image tag defaults to the appVersion "1.0", the APP_NAME environment variable is uppercased, the DB_CONNECTION string is formatted with printf, and the FEATURES list is joined with commas.

### Step 4: Test Default Function

Render without specifying an image tag:

```bash
helm template my-release funcapp/ --set image.tag=""
```

The image tag defaults to .Chart.AppVersion ("1.0") thanks to the default function. Now override it:

```bash
helm template my-release funcapp/ --set image.tag="2.0"
```

The image tag is now "2.0", demonstrating how default only applies when the value is empty.

### Step 5: Experiment with String Functions

Test various string transformations:

```bash
helm template my-release funcapp/ --set image.repository="NGINX" | grep image:
```

The repository name appears as specified. Now let's see the upper function in action:

```bash
helm template my-release funcapp/ | grep APP_NAME
```

The release name is converted to uppercase in the APP_NAME environment variable.

### Step 6: Test List Functions

Modify the features list and see how join works:

```bash
helm template my-release funcapp/ \
  --set config.features="{api,database,cache,metrics}" | grep FEATURES
```

The features are joined with commas into a single string suitable for an environment variable.

### Step 7: Examine Data Format Conversions

Look at the ConfigMap data to see toJson and toYaml in action:

```bash
helm template my-release funcapp/ | grep -A 20 "kind: ConfigMap"
```

The labels appear in both JSON and YAML formats in different keys, demonstrating format conversion functions.

### Step 8: Test Checksum Annotation

The deployment includes a checksum annotation that changes when the ConfigMap changes. Install the chart:

```bash
kubectl create namespace func-demo
helm install func-demo funcapp/ -n func-demo
```

Note the checksum annotation on the pod:

```bash
kubectl get deployment func-demo-funcapp -n func-demo -o yaml | grep checksum
```

### Step 9: Modify ConfigMap and Upgrade

Change a configuration value:

```bash
helm upgrade func-demo funcapp/ \
  --set config.settings.timeout=60 \
  -n func-demo
```

Check the checksum annotation again:

```bash
kubectl get deployment func-demo-funcapp -n func-demo -o yaml | grep checksum
```

The checksum changed, which triggers a pod restart. This pattern ensures pods are restarted when configuration changes.

### Step 10: Test Type Conversion Functions

Examine how toString converts the timeout value:

```bash
helm template my-release funcapp/ --set config.settings.timeout=120 | grep "name: TIMEOUT" -A 1
```

The integer value is converted to a string for the environment variable.

### Step 11: Test Printf Function

The printf function formats the database connection string. Test with different values:

```bash
helm template my-release funcapp/ \
  --set config.database.host="postgres.prod.local" \
  --set config.database.port=5433 \
  --set config.database.name="production" | grep DB_CONNECTION
```

The connection string is properly formatted as "postgres.prod.local:5433/production".

### Step 12: Explore Range Function

The range function iterates over the features list. Add more features:

```bash
helm template my-release funcapp/ \
  --set config.features="{auth,logging,monitoring,tracing,metrics}" \
  | grep -A 10 "# Features"
```

Each feature appears as a separate list item in the YAML configuration.

## Expected Output

When you render the templates, you should see the chart version with "+" replaced by "_" in labels, the image tag defaulting to "1.0" when not specified, the release name uppercased in APP_NAME, the database connection formatted as a connection string, features joined with commas, and a checksum annotation on the deployment.

## Key Concepts Demonstrated

**Function Chaining**: The pipeline operator enables readable sequential transformations like .Chart.Version | replace "+" "_".

**Safe Defaults**: The default function prevents errors when optional values are not provided.

**Type Safety**: Explicit type conversion with toString, int, and float64 ensures correct YAML types.

**Data Formatting**: toYaml and toJson convert structured data for different consumers.

**Config Checksums**: Using sha256sum with include triggers pod restarts when configuration changes.

**String Formatting**: printf and similar functions create formatted strings from multiple values.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall func-demo -n func-demo
kubectl delete namespace func-demo
```

## Common Issues

**Function not found**: Ensure you're using Helm 3 and check the function name spelling. Refer to the Sprig documentation for available functions.

**Type mismatch errors**: Use explicit type conversion functions like toString or int when mixing types.

**Pipeline syntax errors**: Ensure proper spacing around the pipe operator and function arguments.

**Quote issues**: Use quote function for string values that might contain special characters or spaces.

## Next Steps

Proceed to exercise 04-control-structures to learn how to use conditional logic and loops to create dynamic templates that adapt to different configurations.
