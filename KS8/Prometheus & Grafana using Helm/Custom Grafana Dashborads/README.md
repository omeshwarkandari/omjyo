This document has custom Grafana dashboards created as shown in the pic "Dashborad Pic" for the CPU, Memory, Disk and Network Traffic for a Worker Node-1
of the demo cluster Kubeadm.

Instance: In Prometheus terms, an endpoint you can scrape is called an instance, usually corresponding to a single process.
e.g. instance="172.31.82.223:9100"
172.31.82.223: Internal IP of the Node-1
9100: This is the port for Node Exporter to scrap the metrics

Job: A collection of instances with the same purpose, a process replicated for scalability or reliability for example, is called a job.
e.g. job="kubernetes-service-endpoints"
In Prometheus the Node Exporter is using Port:9100 with service type:ClusterIP to scrap metrics for the instances.
