include *.mk
include .envrc

cluster?=vespa

## install vespa cli, create k3d cluster, and deploy
install: cli k3d deploy

## install vespa cli
cli:
	hash vespa || brew install vespa-cli

## create k3d cluster
k3d:
# 2 agents to double total allocatable memory
	k3d cluster create $(cluster) \
		-p 19071:19071@loadbalancer -p 8080:8080@loadbalancer -p 8081:8081@loadbalancer \
		--agents 2 --wait
	@k3d kubeconfig write $(cluster) > /dev/null
	@echo -e "\nTo use your cluster set:\n"
	@echo "export KUBECONFIG=$(KUBECONFIG)"

## deploy vespa to kubes
deploy: deploy-configserver deploy-vespa

deploy-configserver:
	@echo "Deploy config servers"
	kubectl apply -f infra/ingress/lb-configserver.yaml
	kubectl apply -f infra/configmap.yml -f infra/headless.yml -f infra/configserver.yml
	kubectl wait --for=condition=ready pod vespa-configserver-0 --timeout=5m
	curl -s http://localhost:19071/state/v1/health | jq -r .status.code

deploy-vespa:
	@echo "Deploy admin node, feed container cluster, query container cluster and content node pods"
	kubectl apply \
		-f infra/service-feed.yml \
		-f infra/service-query.yml \
		-f infra/admin.yml \
		-f infra/feed-container.yml \
		-f infra/query-container.yml \
		-f infra/content.yml
	kubectl apply -f infra/ingress/lb-query.yaml -f infra/ingress/lb-feed.yaml
	kubectl wait --for=condition=ready pod vespa-content-0 --timeout=7m
	kubectl wait --for=condition=ready pod vespa-feed-container-0 --timeout=7m
	kubectl wait --for=condition=ready pod vespa-query-container-0 --timeout=7m

## deploy app
deploy-app:
	vespa deploy apps/album-recommendation/package
# TODO - wait until deployment complete
	make ping

## ping
ping:
	tools/port-forward-exec.sh pod/vespa-content-0 19107 curl -s http://localhost:19107/state/v1/health | jq -r .status.code
	curl -s http://localhost:8080/state/v1/health | jq -r .status.code
	curl -s http://localhost:8081/state/v1/health | jq -r .status.code

## feed data
feed:
	vespa feed apps/album-recommendation/ext/documents.jsonl -t http://localhost:8081

## query
query:
	curl -s --data-urlencode 'yql=select * from sources * where true' http://localhost:8080/search/

## show kube logs
logs:
	kubectl logs -l "app.kubernetes.io/name=vespa" -f --tail=-1
