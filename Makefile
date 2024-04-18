include *.mk
include .envrc

cluster?=vespa

## install vespa cli, create k3s cluster, and deploy
install: cli k3s deploy

## install vespa cli
cli:
	hash vespa-cli || brew install vespa-cli

## create k3s cluster
k3s:
# 2 agents to double total allocatable memory
	k3d cluster create $(cluster) -p 6379:6379@loadbalancer --agents 2 --wait
	@k3d kubeconfig write $(cluster) > /dev/null
	@echo "Probing until cluster is ready (~60 secs)..."
	@while ! kubectl get crd ingressroutes.traefik.containo.us 2> /dev/null ; do sleep 10 && echo $$((i=i+10)); done
	@echo -e "\nTo use your cluster set:\n"
	@echo "export KUBECONFIG=$(KUBECONFIG)"

## deploy vespa to kubes
deploy: deploy-configserver deploy-vespa

deploy-configserver:
	echo "Deploy config servers"
	kubectl apply -f infra/config/configmap.yml -f infra/config/headless.yml -f infra/config/configserver.yml
	kubectl wait --for=condition=ready pod vespa-configserver-0 --timeout=1m
	tools/port-forward-exec.sh pod/vespa-configserver-0 19071 curl -s http://localhost:19071/state/v1/health | jq -r .status.code

deploy-vespa:
	echo "Deploying admin node, feed container cluster, query container cluster and content node pods"
	kubectl apply \
		-f infra/config/service-feed.yml \
		-f infra/config/service-query.yml \
		-f infra/config/admin.yml \
		-f infra/config/feed-container.yml \
		-f infra/config/query-container.yml \
		-f infra/config/content.yml
	make ping

## deploy app
deploy-app:
	tools/port-forward-exec.sh pod/vespa-configserver-0 19071 vespa deploy infra/app

## feed data
feed-data:
	tools/port-forward-exec.sh svc/vespa-feed 8080 tools/feed-data.sh

## ping
ping:
	tools/port-forward-exec.sh pod/vespa-content-0 19107 curl -s http://localhost:19107/state/v1/health | jq -r .status.code
	tools/port-forward-exec.sh svc/vespa-feed 8080 curl -s http://localhost:8080/state/v1/health | jq -r .status.code
	tools/port-forward-exec.sh svc/vespa-query 8080 curl -s http://localhost:8080/state/v1/health | jq -r .status.code

## query
query:
	tools/port-forward-exec.sh svc/vespa-query 8080 curl --data-urlencode 'yql=select * from sources * where true' http://localhost:8080/search/ 2>/dev/null

## show kube logs
logs:
	kubectl logs -l "app.kubernetes.io/name=vespa" -f --tail=-1
