✅ 1. Check Node Status

kubectl get nodes -o wide
kubectl describe node kmaster
kubectl describe node kworker1

✅ 2. Check API Server / Scheduler / Controller Manager

kubectl get componentstatuses

✅ 3. Check All System Pods (Kube-system)
kubectl get pods -n kube-system -o wide


✅ 4. Check Calico CNI Health
kubectl get pods -n calico-system -o wide
kubectl describe pod -n calico-system <calico-pod-name>

Check CNI IPs:
ip a

✅ 5. Check Kubernetes Services
kubectl get svc -A


✅ 6. Verify Pod-to-Pod Connectivity
kubectl run testbox --image=busybox -it -- sh

Inside pod:

ping google.com
ping <another-pod-ip>

✅ 7. Check API Server Reachability From Worker
On worker node:
curl -k https://10.0.1.5:6443/healthz


✅ 8. Check Kubelet Health

systemctl status kubelet
journalctl -u kubelet -f


✅ 9. Check Containerd Runtime
systemctl status containerd
journalctl -u containerd -f


✅ 10. Check Cluster Info Summary
kubectl cluster-info

🛡️ Bonus: Real-time Monitoring Loop
watch -n 2 kubectl get nodes -o wide
