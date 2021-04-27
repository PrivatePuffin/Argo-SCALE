# GitOps Argo CD
This Repo is a showcase/template on how to setup ArgoCD on TrueNAS SCALE

## Getting started

Installing a basic setup of ArgoCD on SCALE is rather easy!

- Adapt the default config to your liking:

Be sure that all references to github repo's, domainname, dataset and pool are set correctly.
Our bootstrap script will also create our a seperate storageClass called `argo-storage-class-zfs` for argo-apps to prevent interferance from SCALE App storage.

- Run `bash ./bootstrap.sh`

*This should create:*

- an ArgoCD instance with a random admin password (displayed after running the script)
- A traefik instance
- ArgoCD ingress with a self-signed certificate at the domain specified by your
- Traefik ingress with a self-signed certificate at the domain specified by your

With this out of the way, you should be able to use the ArgoCD webinterface and CLI from another PC on the network.

As long as you consume the storageClass called `argo-storage-class-zfs` and don't use namespaces which start with "ix", there shouldn't be any interferance with SCALE Apps.