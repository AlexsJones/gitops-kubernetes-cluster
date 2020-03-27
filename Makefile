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
	kubectl create secret tls argocd-tls --key keys/argocd.key --cert keys/argocd.cert -n argocd || true
	#https://github.com/argoproj/argo-cd/blob/master/docs/faq.md
	echo "Manually patch argo-server commands to --insecure"

install-grafana-ingress:
	kubectl create -f resources/grafana-ingress.yaml -n monitoring
	kubectl create secret tls grafana-tls --key keys/grafana.key --cert keys/grafana.cert -n monitoring
