🚀 Steps to Deploy Kubernetes Dashboard

1. Deploy the Dashboard:

pply the official manifest provided by the Kubernetes project:


kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
This creates the Dashboard Deployment, Service, and related RBAC resources.

By default, the Dashboard runs in the kubernetes-dashboard namespace.

============================================================================================================
============================================================================================================

2. Create a Service Account
You’ll need a ServiceAccount with cluster-admin privileges to log in:

yamlfile:

apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard


Apply it:

kubectl apply -f admin-user.yaml



============================================================================================================
============================================================================================================

3. Get the Login Token
Retrieve the token for the admin-user:


kubectl -n kubernetes-dashboard create token admin-user

Copy this token — you’ll use it to log in.


============================================================================================================
============================================================================================================


Start a secure proxy:


kubectl proxy
Then open the Dashboard in your browser:


http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/






========================================
========================================

-L 8001:localhost:8001
ssh -i /home/ahsan-malik/Desktop/k3s-Cluster-infra/ssh/id_rsa -L 8001:localhost:8001 azureuser@172.191.159.56
ssh -i "/home/ahsan-malik/Desktop/k3s-Cluster-infra/ssh/id_rsa" azureuser@172.178.30.45
========================================
========================================

Token:

eyJhbGciOiJSUzI1NiIsImtpZCI6ImhqZ09tQ1ctbGduZDdmMDRSOWlIZDJGcE1VYU0zXzk2SUtlcnVtV3JGU00ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzY1NTM2MTAxLCJpYXQiOjE3NjU1MzI1MDEsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNmY4ZmY3MWUtOGZjOS00YjFkLTg5MTEtMjg0Y2EzZTQzNDQ1Iiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiN2Q3NGYxYTUtZWU2Yy00MTk2LWEwNDItNDkyNTZhNWI0ZGViIn19LCJuYmYiOjE3NjU1MzI1MDEsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.kIsSH3jpG9i8PcZJDjB2moqByYb-3_iO2xoGOG7uYY4urAdjLXv8lMk0e6-8nneYHfmCkHHAUf2IsNWhUOdx9g4fn-Rzll3FBY628dpGKxnNk_p7ns86p_Cn_fIAOePthQes1c35EJ9ZOZD9kFEcWotDcC2Ly8QUSVD3Pqe7NWKKXIc7NwllmN1ix3K9KW3Ifu1mO3tzgwSACcc7d6htuip00zW_JCumv5t-Y7g1rYwLNRHjgOAqut2GZDdI2z5v8zd7eCBSHUDCKX6RmW-CMDxeB4bolcYx8xee2dv6RzCAhUOjg1igFtPiRnjnxYRKCqJXlpItZOow-bVsXz8R7Q

https://52.147.200.83:32000
