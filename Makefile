include *.mk
include .envrc

cluster?=vespa

## install vespa cli, create k3d cluster, and deploy
install: cli k3d deploy

## install vespa cli
cli:
	hash vespa || tools/install-vespa-cli.sh

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
	kubectl rollout status --watch --timeout=7m statefulset/vespa-configserver
	curl -sS http://localhost:19071/state/v1/health | jq -r .status.code

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
	kubectl rollout status --watch --timeout=7m statefulset/vespa-content
	kubectl rollout status --watch --timeout=7m statefulset/vespa-feed-container
	kubectl rollout status --watch --timeout=7m statefulset/vespa-query-container

## deploy app
deploy-app:
# deploy and wait for app to converge, ie: start feed, query and content services
	vespa deploy apps/album-recommendation -w 120
	make ping

## ping
ping:
	tools/port-forward-exec.sh pod/vespa-content-0 19107 curl -sS http://localhost:19107/state/v1/health | jq -r .status.code
	curl -sS http://localhost:8080/state/v1/health | jq -r .status.code
	curl -sS http://localhost:8081/state/v1/health | jq -r .status.code

## feed data
feed:
	vespa feed apps/album-recommendation/ext/documents.jsonl -C feed | tee /dev/stderr | jq -e '."http.response.code.counts"."200" == 5'

## query
query:
	curl -sS --data-urlencode 'yql=select * from sources * where true' http://localhost:8080/search/

## reindex
reindex:
	curl -sS -XPOST http://localhost:19071/application/v2/tenant/default/application/default/environment/default/region/default/instance/default/reindex
	@printf "\n\nReindex is pending application redeployment see https://docs.vespa.ai/en/operations/reindexing.html\n"

## reindexing status
reindexing:
	curl -sS http://localhost:19071/application/v2/tenant/default/application/default/environment/default/region/default/instance/default/reindexing


## show kube logs
logs:
	kubectl logs -l "app.kubernetes.io/name=vespa" -f --tail=-1
