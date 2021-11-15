NAMESPACE    ?= monitoring

HELM_NS_OPTS ?= --namespace $(NAMESPACE) $(shell $(HELM_INSTALL) && echo --create-namespace)
HELM_OPTIONS ?= -f config.yaml # --reuse-values
HELM_INSTALL ?= false
HELM_UPGRADE ?= $(shell $(HELM_INSTALL) || echo diff) upgrade --install $(shell $(HELM_INSTALL) || echo -C 5)

LB_IP ?= $(shell kubectl -n kube-system get svc traefik  -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
DOMAIN ?= $(LB_IP).nip.io

export DOMAIN

get-lb-ip:
	@echo $(LB_IP)

deploy-prometheus:
	envsubst < config.template.yaml > config.yaml
	helm $(HELM_UPGRADE) prometheus prometheus-community/kube-prometheus-stack $(HELM_NS_OPTS) $(HELM_OPTIONS)
