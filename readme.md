
How to Run
On master:

chmod +x setup-master.sh
./setup-master.sh

After completion, note the node token output at the end.

================================================================================================
================================================================================================
On worker:

chmod +x setup-worker.sh
./setup-worker.sh <MASTER_IP> <NODE_TOKEN>


Replace <MASTER_IP> with your master VM’s private IP and <NODE_TOKEN> with the token you retrieved from master.



aster setup complete. Worker token (for joining nodes):
K1038232f558d15b2e2a9266cd53ae83423f0e56ac1c13c3cdc61c33b4538c527ce::server:47156e5185815f9112fd98eab7151e96

chmod +x setup-worker.sh
./setup-worker.sh 10.0.1.4 K1038232f558d15b2e2a9266cd53ae83423f0e56ac1c13c3cdc61c33b4538c527ce::server:47156e5185815f9112fd98eab7151e96






================================================================================================
================================================================================================


Quick usage & checklist

Copy kubeadm-master.sh to kmaster, kubeadm-worker.sh to worker1.
Make them executable:

sudo chmod +x kubeadm-master.sh 
sudo chmod +x kubeadm-worker.sh 


Run on master:

sudo ./kubeadm-master.sh
sudo ./kubeadm-worker.sh


At the end the script prints a kubeadm join ... full command. Copy that entire line.

On each worker:

sudo ./kubeadm-worker.sh "<paste the full kubeadm join ... command here>"


Verify on master:

kubectl get nodes -o wide
kubectl -n kube-system get pods

================================================================================================
================================================================================================

if you get “token expired” error

Tokens last 24 hours.

If expired → on master run:

sudo kubeadm token create --print-join-command


Then paste the new join command into the worker.


================================================================================================
================================================================================================


kubeadm join 10.0.1.5:6443 --token mb8t98.3lex3ldmeuptleok --discovery-token-ca-cert-hash sha256:b1fce502a02cc0740d051995dba3b3fde1ee49afac2cc5a8c6682e6745f8d01a