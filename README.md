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

I have automatically loaded in resources for two ingress objects `grafana-ingress` and `argocd-ingress`
Modify these and the certs below to match your domain.

- Generate certs for grafana & argocd with lets-encrypt
  - keys/grafana.cert
  - keys/grafana.key
  - keys/argocd.key
  - keys/argocd.cert
