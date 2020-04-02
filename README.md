# GitOps-Kubernetes-cluster

A snapshot of a cluster configuation I've used running on Scaleway.
It leverages ArgoCD to pull in a Helm chart that launches additional ArgoCD applications.

![](images/scaleway.png)


## Bootstrap

- `make install-argocd`

![](images/1.png)

The bootstrap process will install the Applications into GitOps as CRD.

![](images/2.png)

![](images/3.png)

### Optional ingress


`make install-cert-manager`

Once installed you can use cert-manager to install certs for grafana/argocd

```
make install-argocd-ingress
make install-grafana-ingress
```
