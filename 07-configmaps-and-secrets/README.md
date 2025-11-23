# Exercise 07: ConfigMaps and Secrets

## Concept Overview

This exercise demonstrates how to manage application configuration and sensitive data using ConfigMaps and Secrets. ConfigMaps store non-sensitive configuration data as key-value pairs or files, while Secrets store sensitive information like passwords, tokens, and certificates. Understanding these resources is essential for separating configuration from application code and following the twelve-factor app methodology.

ConfigMaps and Secrets can be consumed by pods as environment variables, command-line arguments, or mounted as files. Using checksums of ConfigMaps and Secrets in pod annotations ensures pods are restarted when configuration changes. This pattern is critical for enterprise deployments where configuration updates need to trigger application restarts.

## Learning Objectives

After completing this exercise, you will understand the difference between ConfigMaps and Secrets. You'll learn how to create ConfigMaps and Secrets from values. You'll practice consuming configuration as environment variables using valueFrom. You'll master mounting ConfigMaps and Secrets as volumes. You'll understand using checksums to trigger pod restarts on config changes. You'll also learn best practices for managing secrets in Helm charts.

## Chart Structure

The configapp chart demonstrates various ConfigMap and Secret patterns:

```
configapp/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── configmap.yaml
    ├── configmap-files.yaml
    ├── secret.yaml
    └── secret-files.yaml
```

The chart creates separate ConfigMaps for key-value data and file data. Similarly, it creates separate Secrets for credentials and file-based secrets. The deployment consumes these resources in multiple ways.

## ConfigMaps vs Secrets

**ConfigMaps**: Store non-sensitive configuration data in plain text. Visible to anyone with read access to the namespace. Use for application settings, feature flags, and configuration files.

**Secrets**: Store sensitive data with base64 encoding (not encryption). Kubernetes provides some protection like not writing to disk and limiting access. Use for passwords, API keys, certificates, and tokens. Never commit real secrets to version control.

**StringData vs Data**: Secrets support stringData for plain text input (Helm converts to base64) and data for pre-encoded base64 values. ConfigMaps only use data field.

## Step-by-Step Instructions

### Step 1: Examine ConfigMap Templates

Navigate to the exercise directory and examine the ConfigMap templates:

```bash
cd 07-configmaps-and-secrets
cat configapp/templates/configmap.yaml
cat configapp/templates/configmap-files.yaml
```

The first ConfigMap stores individual key-value pairs from values.yaml. The second ConfigMap stores entire files using range to iterate over configFiles. This separation keeps the templates organized.

### Step 2: Examine Secret Templates

Look at the Secret templates:

```bash
cat configapp/templates/secret.yaml
cat configapp/templates/secret-files.yaml
```

Secrets use stringData for plain text input. The secret-files template demonstrates storing structured data like JSON and certificate files. Note the warning comments about not using these in production.

### Step 3: Examine Deployment Configuration

Look at how the deployment consumes ConfigMaps and Secrets:

```bash
cat configapp/templates/deployment.yaml
```

Environment variables use valueFrom with configMapKeyRef and secretKeyRef. Volumes mount entire ConfigMaps and Secrets as directories. The checksum annotations ensure pods restart when configuration changes.

### Step 4: Render Templates

Render the templates to see the generated resources:

```bash
helm template config-demo configapp/
```

Examine the ConfigMap and Secret data. Notice that Secret stringData values are shown in plain text in the template output but will be base64-encoded when applied to the cluster.

### Step 5: Install the Chart

Create a namespace and install the chart:

```bash
kubectl create namespace config-demo
helm install config-demo configapp/ -n config-demo
```

### Step 6: Verify ConfigMaps

View the created ConfigMaps:

```bash
kubectl get configmaps -n config-demo
kubectl describe configmap config-demo-configapp -n config-demo
kubectl get configmap config-demo-configapp-files -n config-demo -o yaml
```

The ConfigMaps contain the configuration data from values.yaml. The files ConfigMap contains the app.conf and logging.conf files.

### Step 7: Verify Secrets

View the created Secrets:

```bash
kubectl get secrets -n config-demo
kubectl describe secret config-demo-configapp-secret -n config-demo
```

Notice that describe doesn't show the secret values. To view the actual values (base64-encoded):

```bash
kubectl get secret config-demo-configapp-secret -n config-demo -o yaml
```

Decode a secret value:

```bash
kubectl get secret config-demo-configapp-secret -n config-demo -o jsonpath='{.data.database\.password}' | base64 -d
echo
```

### Step 8: Verify Environment Variables

Check that environment variables are set correctly in the pod:

```bash
kubectl get pods -n config-demo
kubectl exec -n config-demo $(kubectl get pod -n config-demo -l app=config-demo-configapp -o jsonpath='{.items[0].metadata.name}') -- env | grep -E 'APP_NAME|LOG_LEVEL|DB_|API_KEY|JWT_SECRET'
```

The environment variables are populated from ConfigMaps and Secrets using valueFrom.

### Step 9: Verify Mounted Files

Check that ConfigMaps and Secrets are mounted as files:

```bash
kubectl exec -n config-demo $(kubectl get pod -n config-demo -l app=config-demo-configapp -o jsonpath='{.items[0].metadata.name}') -- ls -la /etc/config
kubectl exec -n config-demo $(kubectl get pod -n config-demo -l app=config-demo-configapp -o jsonpath='{.items[0].metadata.name}') -- cat /etc/config/app.conf
```

Check secret files:

```bash
kubectl exec -n config-demo $(kubectl get pod -n config-demo -l app=config-demo-configapp -o jsonpath='{.items[0].metadata.name}') -- ls -la /etc/secrets
kubectl exec -n config-demo $(kubectl get pod -n config-demo -l app=config-demo-configapp -o jsonpath='{.items[0].metadata.name}') -- cat /etc/secrets/credentials.json
```

### Step 10: Test Checksum Annotations

View the current checksum annotations:

```bash
kubectl get deployment config-demo-configapp -n config-demo -o yaml | grep checksum
```

These checksums are SHA256 hashes of the ConfigMap and Secret templates. When configuration changes, the checksum changes, triggering a pod restart.

### Step 11: Update Configuration

Upgrade the release with new configuration:

```bash
helm upgrade config-demo configapp/ \
  --set config.logLevel=debug \
  --set config.appName="UpdatedApp" \
  -n config-demo
```

Watch the pods restart:

```bash
kubectl get pods -n config-demo -w
```

Press Ctrl+C after the new pod is running. The checksum changed, triggering a rolling update.

### Step 12: Verify Updated Configuration

Check that the new values are applied:

```bash
kubectl exec -n config-demo $(kubectl get pod -n config-demo -l app=config-demo-configapp -o jsonpath='{.items[0].metadata.name}') -- env | grep -E 'APP_NAME|LOG_LEVEL'
```

The environment variables reflect the updated values.

### Step 13: Update Secret

Update a secret value:

```bash
helm upgrade config-demo configapp/ \
  --set secrets.apiKey="new-api-key-67890" \
  -n config-demo
```

The pods restart due to the changed secret checksum. Verify the new secret:

```bash
kubectl get secret config-demo-configapp-secret -n config-demo -o jsonpath='{.data.api\.key}' | base64 -d
echo
```

## Expected Output

When you view ConfigMaps, you should see plain text configuration data. When you view Secrets, you should see base64-encoded data. Environment variables in pods should match the values from ConfigMaps and Secrets. Mounted files should contain the expected content. When you update configuration, pods should restart automatically due to checksum changes.

## Key Concepts Demonstrated

**Configuration Separation**: ConfigMaps and Secrets separate configuration from application code.

**Multiple Consumption Methods**: Configuration can be consumed as environment variables or mounted files.

**Checksum Pattern**: Using checksums in annotations triggers pod restarts when configuration changes.

**StringData**: Simplifies Secret creation by accepting plain text instead of base64.

**File-Based Configuration**: ConfigMaps and Secrets can store entire configuration files.

**Security Note**: Secrets in Helm charts are not truly secure since they're in version control. Use external secret management for production.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall config-demo -n config-demo
kubectl delete namespace config-demo
```

## Common Issues

**Secrets not updating**: Kubernetes doesn't automatically update environment variables when ConfigMaps or Secrets change. Use checksums to trigger pod restarts.

**Base64 encoding errors**: Use stringData instead of data to avoid manual base64 encoding.

**File permissions**: Mounted secrets have restrictive permissions (0400). This is intentional for security.

**Large ConfigMaps**: ConfigMaps have a 1MB size limit. For larger data, use persistent volumes.

## Security Best Practices

**Never commit real secrets**: The secrets in this exercise are demos only. Never commit production secrets to Git.

**Use external secret management**: For production, use tools like HashiCorp Vault, AWS Secrets Manager, or Sealed Secrets.

**Limit RBAC access**: Restrict who can read Secrets in your cluster.

**Rotate secrets regularly**: Implement secret rotation policies.

**Use separate secrets**: Don't store all secrets in one Secret resource. Separate by application or service.

## Next Steps

Proceed to exercise 08-rbac-and-serviceaccounts to learn how to implement role-based access control and service accounts for pod authentication and authorization.
