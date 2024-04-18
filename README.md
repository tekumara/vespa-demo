# vespa demo

vespa HA running in a local kubernetes cluster.

## Getting started

Prerequisites:

- [k3d](https://k3d.io/) (for creating a local kubernetes cluster)
- kubectl
- brew

Install vespsa cli, create k3d cluster and deploy vespa:

```
make install
```

Deploy album recommendation app and feed data:

```
make deploy-app feed-data
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

## Application packages

See [Application Package Reference](https://docs.vespa.ai/en/reference/application-packages-reference.html#deploy).

## References

- [vespa cli](https://docs.vespa.ai/en/vespa-cli.html) see also [its source code](https://github.com/vespa-engine/vespa/tree/master/client/go)
- [Multinode systems](https://docs.vespa.ai/en/operations-selfhosted/multinode-systems.html)
- [Using Kubernetes with Vespa](https://docs.vespa.ai/en/operations-selfhosted/using-kubernetes-with-vespa.html)
- [Multinode-HA sample application (GKE)](https://github.com/vespa-engine/sample-apps/blob/master/examples/operations/multinode-HA/gke/README.md)
