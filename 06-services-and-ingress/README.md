# Exercise 06: Services and Ingress

## Concept Overview

This exercise demonstrates how to expose applications using Kubernetes Services and Ingress resources on Docker Desktop. Services provide stable networking endpoints for pods, while Ingress manages external HTTP/HTTPS access with routing rules. Understanding these resources is essential for making applications accessible in enterprise environments.

Kubernetes offers several Service types: ClusterIP for internal cluster access, NodePort for access via node IP and port, and LoadBalancer for cloud load balancers. On Docker Desktop, LoadBalancer services remain pending since there's no external load balancer, so we use NodePort or Ingress instead. Ingress provides more sophisticated routing with host-based and path-based rules, SSL termination, and other HTTP features.

## Learning Objectives

After completing this exercise, you will understand different Service types and their use cases. You'll learn how to install and configure an ingress controller on Docker Desktop. You'll practice creating Ingress resources with host-based and path-based routing. You'll understand how to access applications using ClusterIP with port-forward, NodePort with localhost, and Ingress with host file entries. You'll also learn ingress annotations for advanced routing.

## Chart Structure

The webservice chart demonstrates various service types and ingress configuration:

```
webservice/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── service-clusterip.yaml
    ├── service-nodeport.yaml
    └── ingress.yaml
```

The chart creates both ClusterIP and NodePort services to demonstrate different access patterns. The Ingress resource shows host-based and path-based routing.

## Service Types

**ClusterIP**: Default type, provides internal cluster IP accessible only within the cluster. Use for internal services or with kubectl port-forward for testing.

**NodePort**: Exposes service on each node's IP at a static port (30000-32767 range). On Docker Desktop, accessible via localhost:nodePort.

**LoadBalancer**: Provisions external load balancer in cloud environments. On Docker Desktop, remains in Pending state. Not used in this exercise.

## Step-by-Step Instructions

### Step 1: Install Ingress Controller

Docker Desktop doesn't include an ingress controller by default. Install nginx-ingress using Helm:

```bash
cd 06-services-and-ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --set controller.service.nodePorts.https=30443
```

Wait for the ingress controller to be ready:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

### Step 2: Verify Ingress Controller

Check that the ingress controller is running:

```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

The controller pod should be running, and the service should be NodePort type with ports 30080 and 30443.

### Step 3: Examine the Chart

Look at the different service templates:

```bash
cat webservice/templates/service-clusterip.yaml
cat webservice/templates/service-nodeport.yaml
cat webservice/templates/ingress.yaml
```

Notice how ClusterIP provides internal access, NodePort adds a nodePort field, and Ingress defines routing rules with hosts and paths.

### Step 4: Install the Chart

Create a namespace and install the chart:

```bash
kubectl create namespace web-demo
helm install web-demo webservice/ -n web-demo
```

### Step 5: Verify Resources

Check all created resources:

```bash
kubectl get all,ingress -n web-demo
```

You should see deployment, two services (ClusterIP and NodePort), and an ingress resource.

### Step 6: Test ClusterIP Service with Port-Forward

Access the application via ClusterIP using port-forward:

```bash
kubectl port-forward svc/web-demo-webservice-clusterip 8080:80 -n web-demo
```

Open a browser to http://localhost:8080 to see the nginx welcome page. Press Ctrl+C to stop port forwarding. This method works for any service type and is useful for testing.

### Step 7: Test NodePort Service

Access the application via NodePort using localhost:

```bash
curl http://localhost:30080
```

Or open a browser to http://localhost:30080. NodePort services are accessible on Docker Desktop via localhost and the specified nodePort. This works without port-forward.

### Step 8: Configure Hosts File for Ingress

The ingress uses hostnames myapp.local and api.myapp.local. Add these to your hosts file. On Windows, edit C:\Windows\System32\drivers\etc\hosts as Administrator and add:

```
127.0.0.1 myapp.local
127.0.0.1 api.myapp.local
```

Save the file. On Linux/Mac, edit /etc/hosts with sudo.

### Step 9: Test Ingress with Host-Based Routing

Access the application via ingress using the configured hostnames:

```bash
curl http://myapp.local:30080
curl http://api.myapp.local:30080/api
```

Or open a browser to http://myapp.local:30080. The ingress controller routes requests based on the Host header. Note we use port 30080 because the ingress controller service is NodePort type.

### Step 10: Examine Ingress Details

Get detailed information about the ingress:

```bash
kubectl describe ingress web-demo-webservice -n web-demo
```

Notice the rules section showing host-based routing and the backend service. The ingress controller watches for Ingress resources and configures routing automatically.

### Step 11: Test Path-Based Routing

The ingress defines different paths for different hosts. Test the /api path:

```bash
curl http://api.myapp.local:30080/api
```

The ingress routes this to the same backend service, but in production you might route different paths to different services.

### Step 12: Modify Ingress Configuration

Upgrade the chart to add another host:

```bash
helm upgrade web-demo webservice/ \
  --set ingress.hosts[2].host=admin.myapp.local \
  --set ingress.hosts[2].paths[0].path=/ \
  --set ingress.hosts[2].paths[0].pathType=Prefix \
  -n web-demo
```

Add admin.myapp.local to your hosts file, then test:

```bash
curl http://admin.myapp.local:30080
```

### Step 13: Test Service Discovery

Services provide DNS names within the cluster. Create a test pod:

```bash
kubectl run test-pod --image=busybox --rm -it --restart=Never -n web-demo -- sh
```

Inside the pod, test service DNS:

```
wget -O- http://web-demo-webservice-clusterip
exit
```

The service is accessible via its name within the namespace. For cross-namespace access, use the full DNS name: service-name.namespace.svc.cluster.local.

## Expected Output

When you access the application via port-forward, NodePort, or Ingress, you should see the nginx welcome page. The ingress should route requests based on the Host header. The kubectl describe ingress command should show the configured rules and backend service.

## Key Concepts Demonstrated

**Service Types**: ClusterIP for internal access, NodePort for external access on Docker Desktop.

**Port Forwarding**: kubectl port-forward provides temporary access to any service for testing.

**NodePort Access**: On Docker Desktop, NodePort services are accessible via localhost.

**Ingress Controller**: Separate component that implements Ingress resources, must be installed explicitly.

**Host-Based Routing**: Ingress routes requests based on HTTP Host header.

**Path-Based Routing**: Ingress can route different paths to different services.

**Service Discovery**: Services provide stable DNS names for pod-to-pod communication.

## Cleanup

Remove the release and namespace:

```bash
helm uninstall web-demo -n web-demo
kubectl delete namespace web-demo
```

Optionally remove the ingress controller:

```bash
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

Remove the hosts file entries you added.

## Common Issues

**Ingress not working**: Ensure the ingress controller is installed and running. Check controller logs with kubectl logs.

**Host not found**: Verify hosts file entries and that you're using the correct port (30080 for the ingress controller NodePort).

**NodePort not accessible**: On Docker Desktop, use localhost, not the node IP. Ensure the port is in the valid range (30000-32767).

**Service selector mismatch**: Ensure service selector labels match pod labels exactly.

## Next Steps

Proceed to exercise 07-configmaps-and-secrets to learn how to manage application configuration and sensitive data using ConfigMaps and Secrets.
