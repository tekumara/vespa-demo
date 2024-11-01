#!/usr/bin/env bash

set -euo pipefail

[[ "$#" -eq 0 ]] && echo -e "Start/stop kubectl port-forward whilst running a command.\n\nUsage: $0 TYPE/NAME [LOCAL_PORT:]REMOTE_PORT command [args..]" >&2 && exit 42

die() {
    echo -e ERROR: "$@" >&2
    exit 42
}

cleanup() {
    local exit_status="$?"
    kill "$kubectl_pid"
    wait "$kubectl_pid" 2> /dev/null || true
    echo "kubectl port-forward stopped" >&2
    exit "${exit_status}"
}

kubectl port-forward "$1" "$2" >&2 &
kubectl_pid=$!
echo kubectl port-forward "$1" "$2" >&2

trap 'cleanup' ERR
timeout 5 sh -c "until nc -z localhost $2; do sleep 0.1; done" || die "timed out"
shift 2
"$@"
cleanup
