# vespa demo

vespa HA running in a local kubernetes cluster.

## Getting started

Prerequisites:

- [k3d](https://k3d.io/) (for creating a local kubernetes cluster)
- kubectl

Install vespsa cli, create k3d cluster and deploy vespa:

```
make install
```

## Usage

Endpoints:

- TODO

Run

- `make ping`

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

https://raw.githubusercontent.com/vespa-engine/sample-apps/master/examples/operations/multinode-HA/img/multinode-HA.svg


## References

- [Multinode systems](https://docs.vespa.ai/en/operations-selfhosted/multinode-systems.html)
- [Using Kubernetes with Vespa](https://docs.vespa.ai/en/operations-selfhosted/using-kubernetes-with-vespa.html)
