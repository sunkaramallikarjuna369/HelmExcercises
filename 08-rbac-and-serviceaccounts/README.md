# Exercise 08: RBAC and ServiceAccounts

## Concept Overview

This exercise demonstrates Role-Based Access Control (RBAC) and ServiceAccounts in Kubernetes. ServiceAccounts provide identity for pods, while RBAC controls what actions those identities can perform. Understanding RBAC is essential for implementing the principle of least privilege in enterprise environments.

Every pod runs with a ServiceAccount. By default, pods use the "default" ServiceAccount in their namespace, which has minimal permissions. Creating custom ServiceAccounts with specific RBAC permissions allows fine-grained control over what pods can access in the cluster.

## Learning Objectives

After completing this exercise, you will understand ServiceAccounts and their purpose. You'll learn how to create Roles and RoleBindings for namespace-scoped permissions. You'll practice binding ServiceAccounts to Roles. You'll understand the difference between Role/RoleBinding and ClusterRole/ClusterRoleBinding. You'll also learn how to test RBAC permissions from within pods.

## Chart Structure

```
rbacapp/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── serviceaccount.yaml
    ├── role.yaml
    ├── rolebinding.yaml
    └── deployment.yaml
```

## RBAC Components

**ServiceAccount**: Provides identity for pods. Pods authenticate to the API server using the ServiceAccount's token.

**Role**: Defines permissions within a namespace. Specifies which resources and verbs (get, list, create, etc.) are allowed.

**RoleBinding**: Binds a Role to subjects (ServiceAccounts, Users, or Groups) in a namespace.

**ClusterRole/ClusterRoleBinding**: Similar to Role/RoleBinding but cluster-wide scope. Used for cluster-level resources or cross-namespace access.

## Step-by-Step Instructions

### Step 1: Examine RBAC Templates

```bash
cd 08-rbac-and-serviceaccounts
cat rbacapp/templates/serviceaccount.yaml
cat rbacapp/templates/role.yaml
cat rbacapp/templates/rolebinding.yaml
```

The Role defines permissions to get, list, and watch pods and services. The RoleBinding connects the ServiceAccount to the Role.

### Step 2: Install the Chart

```bash
kubectl create namespace rbac-demo
helm install rbac-demo rbacapp/ -n rbac-demo
```

### Step 3: Verify RBAC Resources

```bash
kubectl get serviceaccount,role,rolebinding -n rbac-demo
kubectl describe role rbac-demo-rbacapp -n rbac-demo
kubectl describe rolebinding rbac-demo-rbacapp -n rbac-demo
```

### Step 4: Test ServiceAccount Permissions

Get a shell in the pod:

```bash
kubectl exec -it -n rbac-demo $(kubectl get pod -n rbac-demo -l app=rbac-demo-rbacapp -o jsonpath='{.items[0].metadata.name}') -- sh
```

Inside the pod, install curl:

```bash
apk add --no-cache curl
```

Get the ServiceAccount token:

```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
APISERVER=https://kubernetes.default.svc
```

Test allowed operations (should succeed):

```bash
curl -H "Authorization: Bearer $TOKEN" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt $APISERVER/api/v1/namespaces/rbac-demo/pods
```

Test forbidden operations (should fail):

```bash
curl -H "Authorization: Bearer $TOKEN" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt $APISERVER/api/v1/namespaces/rbac-demo/secrets
exit
```

### Step 5: Modify RBAC Permissions

Add permission to read secrets:

```bash
helm upgrade rbac-demo rbacapp/ \
  --set rbac.rules[2].apiGroups[0]="" \
  --set rbac.rules[2].resources[0]="secrets" \
  --set rbac.rules[2].verbs[0]="get" \
  --set rbac.rules[2].verbs[1]="list" \
  -n rbac-demo
```

Test again from the pod (now should succeed):

```bash
kubectl exec -it -n rbac-demo $(kubectl get pod -n rbac-demo -l app=rbac-demo-rbacapp -o jsonpath='{.items[0].metadata.name}') -- sh
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
APISERVER=https://kubernetes.default.svc
curl -H "Authorization: Bearer $TOKEN" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt $APISERVER/api/v1/namespaces/rbac-demo/secrets
exit
```

## Key Concepts Demonstrated

**Least Privilege**: Grant only the minimum permissions needed.

**ServiceAccount Identity**: Pods authenticate using ServiceAccount tokens.

**Namespace Scoping**: Roles and RoleBindings are namespace-scoped.

**Permission Testing**: Test RBAC from within pods using the Kubernetes API.

## Cleanup

```bash
helm uninstall rbac-demo -n rbac-demo
kubectl delete namespace rbac-demo
```

## Next Steps

Proceed to exercise 09-resources-probes-rolling-updates to learn about resource management, health checks, and deployment strategies.
