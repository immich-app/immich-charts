# Immich Charts

Installs [Immich](https://github.com/immich-app/immich), a self-hosted photo and video backup solution directly 
from your mobile phone. 

# Goal

This repo contains helm charts the immich community developed to help deploy Immich on Kubernetes cluster.

It leverages the bjw-s [common-library chart](https://github.com/bjw-s/helm-charts/tree/923ef40a39520979c98f354ea23963ee54f54433/charts/library/common) to make configuration as easy as possible. 

# Installation

```
$ helm repo add immich https://immich-app.github.io/immich-charts
$ helm install --create-namespace --namespace immich immich immich/immich -f values.yaml
```

There are a few things that you are required to configure in your values.yaml before installing the chart:
* You need to separately create a PVC for your library volume and configure `immich.persistence.library.existingClaim` to reference that PVC
* You need to make sure that Immich has access to a redis, postgresql, and typesense instance. You can do this either by enabling them directly in the values.yaml, or by manually setting the entries under the `env` key to point to existing instances.
* You need to set `image.tag` to the version you want to use, as this chart does not update with every Immich release.

# Configuration

The immich chart is highly customizable. You can see a detailed documentation
of all possible changes within the `charts/immich/values.yaml` file.

## Chart architecture 

This chart uses the [common library](https://github.com/bjw-s/helm-charts/tree/923ef40a39520979c98f354ea23963ee54f54433/charts/library/common). The top level `env` and `image` keys are applied to every component of the Immich stack, and the entries under the `server`, `microservices`, etc... keys define the specific values for each component. You can freely add more top level keys to be applied to all the components, please reference [the common library's values.yaml](https://github.com/bjw-s/helm-charts/blob/923ef40a39520979c98f354ea23963ee54f54433/charts/library/common/values.yaml) to see what keys are available.

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
