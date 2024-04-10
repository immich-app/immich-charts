# Contributing Guidelines

Contributions are welcome via GitHub pull requests. This document outlines the process to help get your contribution accepted.

## How to Contribute

1. Fork this repository, develop, and test your changes
1. Remember to sign off your commits as described above
1. Submit a pull request

***NOTE***: In order to make testing and merging of PRs easier, please submit changes to multiple charts in separate PRs.

### Technical Requirements

* Must follow [Charts best practices](https://helm.sh/docs/topics/chart_best_practices/).
* Must pass CI jobs for linting and installing changed charts.
* Any change to a chart requires a version bump following [semver](https://semver.org/) principles. See [Immutability](#immutability) and [Versioning](#versioning) below.

Once changes have been merged, the release job will automatically run to package and release changed charts.

### Immutability

Chart releases must be immutable. Any change to a chart warrants a chart version bump even if it is only a change to the documentation.

### Versioning

The chart `version` should follow [semver](https://semver.org/).

### Development & Testing

1. Install `minikube` and `helm`.
2. Start a `minikube` cluster via

   ```bash
   minikube start
   ```

3. Create `PersistentVolumeClaim` by executing following command in shell

    ```bash
    minikube kubectl -- create -f - <<EOF
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: pvc-immich
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    EOF
    ```

4. From the `charts/immich` directory execute the following command.
   This will install the dependencies listed in `Chart.yml` and deploy the current state of the helm chart found locally.
   If you want to test a branch, make sure to switch to the respective branch first.

   ```bash
   helm install --dependency-update immich . -f values.yaml --set immich.persistence.library.existingClaim=pvc-immich --set redis.enabled=true --set postgresql.enabled=true
   ```

5. Immich is now deployed in `minikube`.
   To access it, it's port needs to be forwarded first from `minikube` to localhost first via

   ```bash
   minikube kubectl -- port-forward svc/immich-server 3001:3001
   ```

   Now Immich is accessible at [http://localhost:3001](http://localhost:3001) and volume contents at `/tmp/hostpath-provisioner/default`.

6. Clean resources after testing (can skip `delete pvc` and `minikube delete` if testing again, but it's good to test with fresh installation)

   ```bash
   helm uninstall immich
   minikube kubectl -- delete pvc pvc-immich data-immich-postgresql-0 redis-data-immich-redis-master-0
   minikube stop
   ```

7. Delete `minikube` cluster (will delete all cached images and volumes) via

   ```bash
   minikube delete
   ```
