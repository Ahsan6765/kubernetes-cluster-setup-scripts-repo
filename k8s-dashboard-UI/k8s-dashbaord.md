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

eyJhbGciOiJSUzI1NiIsImtpZCI6ImV3Zmp6Y0wtR3dwVVhhZEQ5ZDZyVzhqVldHYjZsUVl2NWFPa01DWG9WRWsifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzY1NDU2OTU2LCJpYXQiOjE3NjU0NTMzNTYsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNmUyYjE2MjQtZTkwNS00NGNmLTlkZjQtNzQ2YjIyZDJlNTkzIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiNDZjYzA1NDQtMTc2ZC00Mjk1LWJhMzItM2EwODg4NGU1MzBhIn19LCJuYmYiOjE3NjU0NTMzNTYsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.lcemPdfyACw1SAI1HePgbQO9916lJVchHZWtka88_-HQyRRLQRoiXLAhrMzhGkgatelOaC2t_Vjs72JyyG7Yh8VEgKXg8jgvcP6dPd52YDVkShZJsOdR68lDFBc5MMil_LG6zMP38Bwt8gicmreA4cI9ejVyNDwSvFxmXRBEcBTi9qJGGa2fAVdQysHSBxO2dTOnT2xSDUq0Wx-sgr8ostWJoGj0Ko_8jxcArqAVFCn9chRqoPRHyEtnq_Lm0ae2sk76EFrt6FBQWv7qqaIF9a29xt7A8EcSaA-GHsNXliSpnLNtx-6ed0LluqzT8VB6y0RsJQQMH1ZNdyOs_i_vsQ


https://192.168.110.53:443
