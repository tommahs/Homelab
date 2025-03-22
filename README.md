# 🏠 Homelab

## Introduction
This repository showcases my personal homelab setup, built for high availability, automation, and scalability. The homelab serves as both a learning environment and a space for experimentation and fun.

My setup consists of a single physical machine hosting multiple Arch Linux virtual machines (VMs), provisioned using Terraform. These VMs form the foundation of my Kubernetes (k8s) cluster, which powers various applications and services. While this repository contains configurations for services running within the Kubernetes cluster, configurations for system-level services on the physical machine (such as NFS) are not included.

Managing my own infrastructure provides valuable hands-on experience, making me responsible for the entire application lifecycle—from deployment and maintenance to security, scalability, and backup strategies.

## Infrastructure
### Virtualization & Provisioning
- **Hypervisor:** Single physical machine running multiple Arch Linux VMs
- **Provisioning:** Terraform
- **Networking:** nftables
- **Storage:** NFS for persistent volumes (planned migration to Longhorn)
- **Secret Management:** External source (planned migration to Vault)

### Kubernetes Cluster
- **Control Plane:** Multiple k8s master nodes
- **Worker Nodes:** Multiple k8s worker nodes to handle load
- **Networking:** Cilium (CNI)
- **Ingress Controller:** Traefik
- **Certificate Management:** cert-manager
- **Storage:** Persistent Volumes (NFS, future migration to Longhorn)
- **Secrets:** External storage (future migration to HashiCorp Vault)

## 🚀 Installed Apps & Tools
The following services are deployed on top of Kubernetes:
- **Vaultwarden:** Secure password management
- **PathfinderWiki:** MediaWiki-based wiki  (nginx, php-fpm, MariaDB)
- **Ollama & OpenWebUI:** AI-related services for local LLM hosting and interaction
- **n8n:** Workflow automation tool, primarily used for AI workload orchestration

### Backup Strategy
- All critical services are backed up to dedicated NFS Persistent Volumes (PVs)

## Future Enhancements

**Object Store:** Deploying a Ceph cluster on VMs to provide distributed object storage, improving scalability and redundancy.

**Monitoring:** Implementing Grafana, Loki, and Mimir for centralized monitoring, logging, and metrics collection.

**Storage Improvements:** Transitioning from NFS-based persistent volumes to Longhorn for better resilience and dynamic volume provisioning.

**Secret Management:** Integrating HashiCorp Vault to centralize and securely manage application secrets.

**Automation Enhancements:** Expanding n8n workflows to streamline automation tasks, reducing manual intervention and improving efficiency.

**Redis Cluster:** Deploying a Redis cluster for high-availability caching and improved performance of applications.

**MariaDB Galera Cluster:** Implementing a MariaDB Galera Cluster for synchronous multi-master database replication, ensuring fault tolerance and high availability.

**PostgreSQL High Availability:** Setting up a highly available PostgreSQL cluster with replication and failover mechanisms for improved database resilience.

## Repository Structure
```
/
├── terraform/       # Infrastructure as Code for VM provisioning
│   ├── k8s/         # Kubernetes-related infrastructure
│   └── ceph/        # Ceph deployment configurations
├── apps/            # Kubernetes manifests and configurations for apps running on top of infrastructure
├── monitoring/      # Kubernetes manifests and configurations for monitoring
└── infrastructure/  # Kubernetes manifests and configurations for k8s infra components
```

## Contact
For any inquiries, discussions, or collaboration, feel free to reach out!

