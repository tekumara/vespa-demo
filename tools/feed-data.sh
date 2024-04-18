#!/usr/bin/env bash

# see https://github.com/vespa-engine/sample-apps/blob/924c3f4ccb4688d63e2cc68dc42838c221f6eff8/examples/operations/multinode-HA/gke/README.md#feed-data

set -euo pipefail

i=0
for doc in album-recommendation/ext/*.json; do
    echo curl -H Content-Type:application/json -d @$doc \
        http://localhost:8080/document/v1/mynamespace/music/docid/$i
    i=$(($i + 1))
    echo
done
