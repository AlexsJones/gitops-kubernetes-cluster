.PHONY: install-argocd get-argocd-password get-grafana-password proxy-argocd-ui check-argocd-ready

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

get-argocd-password:
	kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

get-grafana-password:
	kubectl get secret prometheus-grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 --decode ; echo

check-argocd-ready:
	kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s

proxy-argocd-ui:
	kubectl port-forward svc/argocd-server -n argocd 8080:80

install-argocd:
	kubectl create ns argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl apply -f resources/application-bootstrap.yaml -n argocd

install-argocd-ingress:
	kubectl create -f resources/argocd-ingress.yaml -n argocd
	kubectl patch deployment argocd-server --type json -p='[ { "op": "replace", "path":"/spec/template/spec/containers/0/command","value": ["argocd-server","--staticassets","/shared/app","--insecure"] }]' -n argocd

install-grafana-ingress:
	kubectl create -f resources/grafana-ingress.yaml -n monitoring

install-cert-manager:
	helm repo add jetstack https://charts.jetstack.io
	kubectl create namespace cert-manager
	kubectl label namespace cert-manager cert-manager.k8s.io/disable-validation=true
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.14.0/cert-manager.crds.yaml
	helm install cert-manager --namespace cert-manager --version v0.14.0 jetstack/cert-manager
	kubectl apply -f resources/letsencrypt-issuer.yaml
