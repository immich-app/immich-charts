#!/bin/bash
## This Script is intended to get Version Names from the Helm Chart to Build
## a new Bitnami Image based of pgvector.rs

# Get yq
[ -f ./yq_linux_amd64 ] || curl -L https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 > yq_linux_amd64
chmod +x yq_linux_amd64

# Export Vars
export BITNAMI_TAG=$(./yq_linux_amd64 '.postgresql.image.tag' ../../charts/immich/values.yaml)
echo BITNAMI_TAG=$BITNAMI_TAG