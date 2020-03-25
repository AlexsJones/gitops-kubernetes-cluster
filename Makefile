.PHONY: install-argocd install-nginx install-cert-manager install-prometheus get-argocd-password get-grafana-password proxy-argocd-ui

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

get-argocd-password:
	kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

get-grafana-password:
	kubectl get secret prometheus-grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 --decode ; echo

install-argocd:
	kubectl create ns argocd
	kubectl create ns argocd-applications
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl create -f resources/grafana-ingress.yaml -n argocd
	kubectl create secret tls argocd-tls --key keys/argocd.key --cert keys/argocd.cert -n argocd
	#https://github.com/argoproj/argo-cd/blob/master/docs/faq.md
	echo "Manually patch argo-server commands to --insecure"

install-nginx:
	helm install nginx  stable/nginx-ingress --set service.type=LoadBalancer --namespace kube-system

install-cert-manager:
	kubectl create namespace cert-manager || true
	kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.0/cert-manager.crds.yaml
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm install cert-manager jetstack/cert-manager --version v0.14.0

install-prometheus:
	kubectl create ns monitoring || true
	helm install prometheus stable/prometheus-operator -n monitoring
	kubectl create -f resources/grafana-ingress.yaml -n monitoring
	kubectl create secret tls grafana-tls --key keys/grafana.key --cert keys/grafana.cert -n monitoring
