# Exercise 15: Umbrella Chart for Multi-Service Application

## Concept Overview

This exercise demonstrates how to create an umbrella chart that deploys a complete multi-service application. An umbrella chart is a parent chart that contains only dependencies and no templates of its own. This pattern is common in enterprise environments where multiple microservices need to be deployed together as a single application.

Umbrella charts provide a single point of configuration for complex applications. They enable teams to deploy entire application stacks with one command while maintaining separate charts for each service. This approach supports independent service development while simplifying deployment and configuration management.

## Learning Objectives

After completing this exercise, you will understand how to create umbrella charts with multiple service dependencies. You'll learn how to configure inter-service communication. You'll practice using global values to share configuration across all services. You'll understand conditional service deployment. You'll also learn how to manage multi-tier applications with frontend, backend, and database services.

## Chart Structure

```
15-umbrella-chart-multiservice/
├── umbrella/
│   ├── Chart.yaml          # Declares all service dependencies
│   └── values.yaml         # Configuration for all services
├── frontend/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       └── service.yaml
├── backend/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       └── service.yaml
└── database/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        └── service.yaml
```

## Umbrella Chart Concepts

**No Templates**: Umbrella charts typically have no templates directory, only dependencies.

**Centralized Configuration**: All service configuration is managed through the umbrella chart's values.yaml.

**Service Communication**: Services reference each other using Kubernetes DNS names.

**Conditional Deployment**: Individual services can be enabled/disabled using conditions.

**Global Values**: Shared configuration like environment and domain are set globally.

## Step-by-Step Instructions

### Step 1: Examine the Umbrella Chart

Navigate to the exercise directory and examine the umbrella chart:

```bash
cd 15-umbrella-chart-multiservice
cat umbrella/Chart.yaml
cat umbrella/values.yaml
```

Notice that Chart.yaml declares three dependencies: frontend, backend, and database. Each has a condition allowing it to be enabled/disabled. The values.yaml contains configuration for all three services plus global values.

### Step 2: Examine Service Charts

Look at each service chart:

```bash
cat frontend/templates/deployment.yaml
cat backend/templates/deployment.yaml
cat database/templates/deployment.yaml
```

Notice how services reference each other. The frontend references the backend service URL, and the backend references the database connection string. These use Kubernetes service DNS names.

### Step 3: Update Dependencies

Update dependencies to package all service charts:

```bash
cd umbrella
helm dependency update
ls -la charts/
```

This creates a charts/ directory with all three service charts packaged as .tgz files.

### Step 4: Render the Complete Application

Render templates to see all services:

```bash
helm template myapp .
```

You should see deployments and services for frontend, backend, and database. Notice how the release name is used consistently across all services.

### Step 5: Install the Complete Stack

Create a namespace and install the umbrella chart:

```bash
kubectl create namespace umbrella-demo
helm install myapp . -n umbrella-demo
```

This single command deploys the entire application stack.

### Step 6: Verify All Services

Check that all services are running:

```bash
kubectl get all -n umbrella-demo
```

You should see deployments, pods, and services for frontend (2 replicas), backend (3 replicas), and database (1 replica).

### Step 7: Test Service Communication

Check that services can communicate. Verify the frontend knows about the backend:

```bash
kubectl get deployment myapp-frontend -n umbrella-demo -o yaml | grep BACKEND_URL
```

Verify the backend knows about the database:

```bash
kubectl get deployment myapp-backend -n umbrella-demo -o yaml | grep DATABASE_URL
```

### Step 8: Test Global Values

Check that global values are propagated to all services:

```bash
kubectl get deployment myapp-frontend -n umbrella-demo -o yaml | grep environment
kubectl get deployment myapp-backend -n umbrella-demo -o yaml | grep environment
kubectl get deployment myapp-database -n umbrella-demo -o yaml | grep environment
```

All should show "production" from the global.environment value.

### Step 9: Scale Individual Services

Upgrade to scale the backend independently:

```bash
helm upgrade myapp . \
  --set backend.replicaCount=5 \
  -n umbrella-demo
```

Verify only the backend scaled:

```bash
kubectl get deployments -n umbrella-demo
```

### Step 10: Disable a Service

Upgrade with the database disabled:

```bash
helm upgrade myapp . \
  --set database.enabled=false \
  -n umbrella-demo
```

Verify the database resources are removed:

```bash
kubectl get all -n umbrella-demo
```

Only frontend and backend should remain.

### Step 11: Deploy to Different Environment

Upgrade with staging environment configuration:

```bash
helm upgrade myapp . \
  --set global.environment=staging \
  --set frontend.replicaCount=1 \
  --set backend.replicaCount=2 \
  --set database.enabled=true \
  -n umbrella-demo
```

This demonstrates how the same umbrella chart can deploy to different environments with different configurations.

### Step 12: View Dependency Tree

List all dependencies:

```bash
helm dependency list
```

This shows the complete dependency tree for the umbrella chart.

## Expected Output

When you install the umbrella chart, you should see resources for all three services created. Services should reference each other using Kubernetes DNS names. Global values should be accessible in all service deployments. You should be able to enable/disable individual services and scale them independently.

## Key Concepts Demonstrated

**Umbrella Pattern**: Single chart that deploys multiple services as dependencies.

**Centralized Configuration**: All service configuration managed from one values.yaml.

**Service Discovery**: Services communicate using Kubernetes DNS names.

**Conditional Deployment**: Individual services can be enabled/disabled.

**Independent Scaling**: Each service can be scaled independently.

**Global Configuration**: Shared values propagated to all services.

**Multi-Tier Architecture**: Frontend, backend, and database tiers working together.

## Cleanup

```bash
helm uninstall myapp -n umbrella-demo
kubectl delete namespace umbrella-demo
cd ..
```

## Common Issues

**Service communication fails**: Ensure service names match the DNS names used in environment variables.

**Dependencies not found**: Run helm dependency update before installing.

**Values not propagating**: Check that subchart names in values.yaml match the dependency names in Chart.yaml.

**Circular dependencies**: Avoid having services depend on each other in Chart.yaml dependencies.

## Best Practices

**Separate Concerns**: Keep each service in its own chart for independent development.

**Use Global Values**: Share common configuration like environment and domain globally.

**Document Dependencies**: Clearly document which services depend on which others.

**Version Management**: Use semantic versioning for all service charts.

**Testing**: Test each service chart independently before integrating into umbrella chart.

## Next Steps

Proceed to exercise 16-hooks-lifecycle to learn how to use Helm hooks for managing application lifecycle events like pre-install, post-install, and pre-upgrade operations.
