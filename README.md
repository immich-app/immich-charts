# Immich Charts

Installs [Immich](https://github.com/immich-app/immich), a self-hosted photo and video backup solution directly 
from your mobile phone. 

# Goal

This repo contains helm charts the immich community developed to help deploying Immich on Kubernetes cluster.

It leverages bjw-s the [library-chart](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common) to make configuration as easy as possible. 

# Installation

```
$ helm repo add immich https://immich-app.github.io/immich-charts
$ helm install --create-namespace --namespace immich immich immich/immich
```

# Configuration

The immich chart is highly customizable. You can see a detailed documentation
of all possible changes within the `charts/immich/values.yaml` file.

## Uninstalling the Chart

To see the currently installed Immich chart:

```console
helm ls --namespace immich
```

To uninstall/delete the `immich` chart:

```console
helm delete --namespace immich immich
```

The command removes all the Kubernetes components associated with the chart and deletes the release.
