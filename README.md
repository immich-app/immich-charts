# Immich Charts

Installs [Immich](https://github.com/immich-app/immich), a self-hosted photo and video backup solution directly 
from your mobile phone. 

# Goal

This repo contains helm charts the immich community developed to help deploying Immich on Kubernetes cluster.

It leverages bjw-s the [library-chart](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common) to make configuration as easy as possible. 

# Installation Guide

1. Copy the default configuration

    ```bash
    #recommended
    curl -L https://raw.githubusercontent.com/immich-app/immich-charts/main/charts/immich/values.yaml -o my-values.yaml

    #or if you know what to do
    touch my-values.yaml
    ```

1. Create namespace.

    `kubectl create ns immich`

1. Generate `pvc` which will store the metadata.

    `immich-pvc.yaml`

    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: <<pvc-name>>
      namespace: immich
    spec:
      storageClassName: <<storageClassName>>
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: <<size>>
    ```

1. Create `pvc`:

    ```bash
    kubectl apply -f immich-pvc.yaml

    # persistentvolumeclaim/immich-pvc created
    ```

1. Add the `<<pvc-name>>` to `immich.persistence.library.existingClaim` in `my-values.yaml`:

    ```yaml
    ...
    immich:
      persistence:
        library:
          existingClaim: <<pvc-name>>
    ...
    ```

1. Generate `Secret` which will be used in `postgresql` dependency.

    `immich-postgresql-secret.yaml`

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: <<secret-name>>
      namespace: immich
    type: Opaque
    stringData:
      postgres-password: <<postgres-password>>
      password: <<password>>
      replication-password: <<replication-password>>
    ```

1. Create `Secret`:

    ```bash
    kubectl apply -f immich-postgresql-secret.yaml

    # secret/immich-postgresql-secret created
    ```

1. Add the secret in `my-values.yaml`:

    ```yaml
    ...
    postgresql:
      enabled: true
      global:
        postgresql:
          auth:
            # Add existingSecret here
            existingSecret: <<secret-name>>
            username: immich
            database: immich
            password: immich
    ...
    ```

1. Configure the other options as you like.

1. Finally `add repo` and `install`.

    ```bash
    helm repo add immich https://immich-app.github.io/immich-charts
    helm install --namespace immich immich immich/immich -f my-values.yaml

    # To watch
    kubectl get pods -n immich --watch
    ```

# Configuration

The immich chart is highly customizable. You can see a detailed documentation
of all possible configurations in [charts/immich/values.yaml](https://github.com/immich-app/immich-charts/blob/main/charts/immich/values.yaml).

## Upgrade the Chart

```bash
helm upgrade -f my-values.yaml immich immich-charts/immich -n immich
```

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
