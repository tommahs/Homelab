# Observability platform Base Grafana

## Overview
This repository contains the base configuration and controllers for monitoring Grafana in a distributed system. It provides a centralized monitoring solution for multiple Grafana instances, allowing for easy management and visualization of metrics and logs.

## Requirements
Grafana 10.2.0 or later
Kubernetes 1.32 or later
S3 objectstore with a user and user having access to buckets:
* mimir
* mimir-blocks
* loki
* tempo
* grafana
File storage PV's:
* 1x grafana-storage StorageClass on 192.168.122.1


## Distributed System Architecture
The implementation uses a distributed architecture to ensure high availability and scalability. The components are deployed on a Kubernetes cluster, which provides a scalable and fault-tolerant infrastructure.

The architecture consists of the following layers:
**Data ingestion**: Loki, Mimir and Tempo accept log, metric and tracing data respectively from various sources.
**Data storage**: Mimir stores metrics data, while Loki stores log data and Tempo stores traces in remote S3-compatible storage.
**Data visualization**: Grafana provides a visualization platform for this metric, logging and tracing data.
**Access**: Traefik functions as ingress controller, Cilium as CNI and CertManager to provide a valid LetsEncrypt https certificate

### Components
- **Grafana**: Grafana is deployed as a replicaset with a single replica. The Grafana configuration is stored in a ConfigMap, which is mounted as a volume in the Grafana container. A Traefik ingressRoute is made available with middleware enforcing https and  a LetsEncrypt certificate through CertManager's ClusterIssuer. Persistent Storage for Grafana data like dashboards is not yet available ( https://github.com/tommahs/Homelab/issues/7).
- **Loki**: Loki is deployed in distributed mode with multiple replicas to ensure high availability wherever logical for this small setup. The Loki configuration is stored in a ConfigMap, which is mounted as a volume in each Loki container after being templated by the initContainer. A Traefik ingressRoute is made available with middleware enforcing https and  a LetsEncrypt certificate through CertManager's ClusterIssuer.
- **Mimir**: Mimir is deployed in distributed mode with multiple replicas to ensure high availability wherever logical for this small setup. The Mimir configuration is stored in a ConfigMap, which is mounted as a volume in each Mimir container after templating the variables into it. A Traefik ingressRoute is made available with middleware enforcing https and  a LetsEncrypt certificate through CertManager's ClusterIssuer.
- **Tempo**: Tempo is deployed in distributed mode with multiple replicas to ensure high availability wherever logical for this small setup. The Mimir configuration is stored in a ConfigMap, which is mounted as a volume in each Tempo container after templating the variables into it. A Traefik ingressRoute is made available with middleware enforcing https and  a LetsEncrypt certificate through CertManager's ClusterIssuer.
- **Remote S3**: A S3-compatible object store like S3 or Ceph for storing data
- **Remote NFS**: A NFS share needs to be provided for grafana for persistence
- **Traefik Ingress**: Traffic to grafana, loki, mimir and tempo is handled by the ingress controller Traefik
- **CertManager**: Certificates for grafana, loki, mimir and tempo are handled by Certmanager

## Configuration
The configuration for the components can be found in each components directory except for the **Access** components. These are merged into the grafanalabs component's directory. Configuration happens once when starting the Pod as the ConfigMap needs to be templated.
The implementation can be found here:
```
monitoring/controllers/base/grafana/kustomization.yaml: Configures all components deployment.
monitoring/controllers/base/grafana/kustomization.yaml: Configures the Grafana deployment.
monitoring/controllers/base/grafana/loki/kustomization.yaml: Configures the Loki deployment.
monitoring/controllers/base/grafana/mimir/kustomization.yaml: Configures the Mimir deployment.
monitoring/controllers/base/grafana/tempo/kustomization.yaml: Configures the Tempo deployment.
```

## Deployment
Copy the secter.yaml_template files in each component's directory to "secret.yaml" in the same folder and add your secrets to the secret.yaml. This needs to be done for the folders ./common, ./grafana, ./loki, ./mimir and ./tempo

Afterwards, the configuration can be applied with: 
```bash
kubectl apply -k .
```

This will deploy the Grafana, loki, mimir and tempo instances as well as the ingress routes to traefik and certificates to cert manager, to the Kubernetes cluster.

## Usage
The current configuration does not insert any data.

## Troubleshooting
For troubleshooting, please refer to the logs of the individual components. The logs can be accessed using the following command:
```bash

kubectl logs -n observability <component-name> 
```
Replace <component-name> with the name of the component, such as pod/grafana-RANDOMHASH as shown in:
```bash
kubectl get all -n observability
```

## Future Enhancements
The implementation is designed to be scalable and highly available. Future enhancements include:

- Integrating with other monitoring and logging tools.
- Providing additional visualization capabilities.
- Improving performance and scalability.
