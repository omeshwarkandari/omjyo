This document has custom Grafana dashboards created as shown in the pic "Dashborad Pic" for the CPU, Memory, Disk and Network Traffic for a Worker Node-1
of the demo cluster Kubeadm.

instance="172.31.82.223:9100"
172.31.82.223: Internal IP of the Node-1
9100: This is the port for Node Exporter to scrap the metrics

job="kubernetes-service-endpoints"
Kubernetes is using service Cluster IP 
