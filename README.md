# vespa demo

vespa HA running in a local kubernetes cluster.

## Getting started

Prerequisites:

- [k3d](https://k3d.io/) (for creating a local kubernetes cluster)
- kubectl
- macOS: brew

Install vespsa cli, create k3d cluster and deploy vespa:

```
make install
```

Deploy album recommendation app and feed data:

```
make deploy-app feed
```

## Usage

Basic query:

```
make query
```

Endpoints:

- TODO

## Failover

TODO

## Resources

Config server:

- configmap/vespa-config
- service/vespa-internal
- statefulset.apps/vespa-configserver

Vespa:

- service/vespa-feed
- service/vespa-query
- statefulset.apps/vespa-admin
- statefulset.apps/vespa-feed-container
- statefulset.apps/vespa-query-container
- statefulset.apps/vespa-content

The configserver and vespa-content statefulsets have volume claims.

<img src="https://raw.githubusercontent.com/vespa-engine/sample-apps/master/examples/operations/multinode-HA/img/multinode-HA.svg" width="50%" height="50%"/>

## Architecture

See [Vespa Overview](https://docs.vespa.ai/en/overview.html)

### Admin services

#### Config servers

[Vespa Configuration Servers](https://docs.vespa.ai/en/operations-selfhosted/configuration-server.html) host the endpoint where application packages are deployed and serve generated configuration to all services. Without Config Servers, Vespa cannot be configured, and services cannot run. The config servers hold the node configuration which determines [which services will run on which nodes](https://docs.vespa.ai/en/operations-selfhosted/config-sentinel.html#:~:text=config%2Dsentinel%20starts%20the%20services%20given%20in%20the%20node%20configuration).

They use [embedded Apache Zookeeper](https://docs.vespa.ai/en/operations-selfhosted/configuration-server.html#zookeeper) for data storage. Config Servers must be started first before other Vespa nodes, as the other nodes depend on Config Servers at startup.

#### Cluster controllers

Maintains the [state of the nodes in the content cluster](https://docs.vespa.ai/en/content/content-nodes.html#cluster-controller) in order to provide elasticity and failure detection. The [cluster state](https://docs.vespa.ai/en/content/content-nodes.html#cluster-state) is generating by polling nodes for their unit state (eg: up, down, or stopping) and merging that with and user-provided state that marks nodes as up, down, under maintenance or retired.

#### Admin server

The default admin node. This [isn't its own process](https://github.com/vespa-engine/vespa/issues/9681#issuecomment-501181755), just the default node for various administrative services like log server, configuration server (configserver), and slobrok unless you [specify otherwise in your configuration](https://docs.vespa.ai/en/reference/services-admin.html#:~:text=version%20of%20Vespa-,adminserver,will%20run%20on%20this%20node.).

#### Service location brokers (slobrok)

Clients and the cluster controller use a slobrok to locate services.

### Container cluster

Stateless Java services that receive and process incoming data (feed) and/or queries from clients, before passing them to the content cluster. Can be configured as a single cluster for all types of requests, or as multiple clusters.

A container service is an hosting environment for [components](https://docs.vespa.ai/en/jdisc/container-components.html) of [different types](https://docs.vespa.ai/en/reference/component-reference.html#component-types).

Includes the following for documents:

- [Document API](https://docs.vespa.ai/en/api.html#document-api)
- [Document processing](https://docs.vespa.ai/en/document-processing.html)

And the following for querying:

- [Searcher](https://docs.vespa.ai/en/reference/services-search.html) for the [query endpoint](https://docs.vespa.ai/en/query-api.html)
- [Huggingface Embbedder](https://docs.vespa.ai/en/embedding.html#huggingface-embedder) to run ONNX embedding models
- [LLM Clients](https://docs.vespa.ai/en/llms-in-vespa.html#setting-up-llm-clients-in-services.xml)

### Content cluster

Responsible for storing data and execute queries and inferences over the data. Distributors automatically rebalance documents to maintain a balanced distribution at the configured redundancy level, including when nodes fail. See [Content Cluster Elasticity](https://docs.vespa.ai/en/elasticity.html).

## Application packages

- maps services to nodes in [services.xml](https://docs.vespa.ai/en/tutorials/news-2-basic-feeding-and-query.html#services-specification)
- defines aliases for nodes in [hosts.xml](https://docs.vespa.ai/en/reference/hosts.html#)
- defines document [schemas](https://docs.vespa.ai/en/schemas.html)
- contains machine-learned models and Java components

The application package is deployed to any node in the config cluster.

See

- [Application Packages](https://docs.vespa.ai/en/application-packages.html)
- [Application Package Reference](https://docs.vespa.ai/en/reference/application-packages-reference.html#deploy)

## Consistency

AP see [Vespa Consistency Model](https://docs.vespa.ai/en/content/consistency.html)

> Vespa has support for conditional writes for individual documents through test-and-set operations. Multi-document transactions are not supported.
>
> After a successful response, changes to the search indexes are immediately visible by default.

## References

- [vespa cli](https://docs.vespa.ai/en/vespa-cli.html) see also [its source code](https://github.com/vespa-engine/vespa/tree/master/client/go)
- [Multinode systems](https://docs.vespa.ai/en/operations-selfhosted/multinode-systems.html)
- [Using Kubernetes with Vespa](https://docs.vespa.ai/en/operations-selfhosted/using-kubernetes-with-vespa.html)
- [Multinode-HA sample application (GKE)](https://github.com/vespa-engine/sample-apps/blob/master/examples/operations/multinode-HA/gke/README.md)
- [Models hot swap](https://docs.vespa.ai/en/tutorials/models-hot-swap.html)
- [Convergence](https://github.com/vespa-engine/vespa/issues/29861)
- [Batch delete](https://docs.vespa.ai/en/operations/batch-delete.html)
- [Modifying schemas](https://docs.vespa.ai/en/reference/schema-reference.html#modifying-schemas)

## Troubleshooting

See [Troubleshooting](docs/troubleshooting.md).

## TODO

- Add basic auth
