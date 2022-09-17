# Immich Charts

a collection of Helm charts to deploy [Immich](https://immich.app)

# Goal

This repo contains helm charts the immich community developed to help deploying Immich on Kubernetes cluster.

It leverages bjw-s the [library-chart](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common) to make configuration as easy as possible. 


# Installation

Currently these helm-charts are not (yet) deployed to a helm-registry. So you have to install them by checking out this repo

```
$ git checkout https://github.com/immich-app/immich-charts.git
$ cd immich-charts
$ helm install charts/apps/immich -f myvalues.yaml
```

# Configuration

## immich
This chart has a dependency on the [postgresql-chart](https://artifacthub.io/packages/helm/bitnami/postgresql) and [redis-chart](https://artifacthub.io/packages/helm/bitnami/redis). As you could provide your own instances both of these are turned off by default.

You can enable (and configure) them by adding this sample configuration to your `values.yaml`

```yaml
postgresql:
  enabled: true
  global:
    postgresql:
      auth:
        existingSecret: thesecretiprovideforcredentials

redis:
  enabled: true
  auth:
    enabled: false
```

An example configuration (via [ArgoCD])(https://argoproj.github.io/cd/)) can be found at [PixelJonas cluster-gitops](https://github.com/PixelJonas/cluster-gitops/blob/master/manifests/argocd/apps/immich/base/apps/immich-chart-app.yaml#L17-L47)

# Notable changes to the library chart

As Immich is deployed using multiple deployments which talk to each other we don't use the `controller` defined in the library chart, but multiple copies of it.
All Deployments can be configured like the `controller`.

Example:

```yaml

server:
  enabled: true
  env:
    NODE_ENV: "production"
  service:
    main:
      enabled: true
      primary: true
      type: ClusterIP
      ports:
        http:
          enabled: true
          primary: true
          port: 3001
          protocol: HTTP
  image:
    # -- image repository
    repository: altran1502/immich-server
    # -- image tag
    tag: release
    # -- image pull policy
    pullPolicy: IfNotPresent
  command: "/bin/sh"
  args:
    - "./start-server.sh"

```

the different deployments are called:
- `server`
- `web`
- `machine_learning`
- `microservice`
- `proxy`

A full list of all configuration values can be found [in the library-chart repo](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common#values)

