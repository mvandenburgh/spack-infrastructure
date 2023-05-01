# Spack Infrastructure

This contains code and configuration for Spack's various infrastructure
services, including:

* Kubernetes: [k8s.spack.io](https://k8s.spack.io)
* CDash: [cdash.spack.io](https://cdash.spack.io)
* GitLab: [gitlab.spack.io](https://gitlab.spack.io)

Why isn't my GitLab CI pipeline running yet? Please see our [Deferred Pipelines Documentation](docs/deferred_pipelines.md)

## Secret Management

The kubernetes cluster makes use of [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets), and as such, requires specific steps to be taken in order to create/update secrets.

Sealed secrets are publicly defined encrypted secrets that can only be decrypted within the cluster. Once `SealedSecret` resources are applied to the cluster, the sealed secret controller unseals them, creating a regular secret (same name and namespace) containing the decrypted data.

### Creating a new secret
To create a new secret, simply copy and un-comment the SealedSecret template (`k8s/production/sealed-secrets/sealed-secret-template.yaml`), or any other existing SealedSecret definition, to the intended file. Convention is to name the file containing your new sealed secrets to be named `sealed-secrets.yaml`.

### Updating a secret
Once you have a file containing one or more SealedSecret resources, you'll need to add/update its values. To do so, a helper script has been created, which takes the secret file as an argument. It can be used as followed:

```
./scripts/secrets.py k8s/**/sealed-secrets.yaml
```

This will prompt you to select the specific secret you want to modify (if several are defined), and which key within the secret's data you want to update (or create a new entry). This prompts you to enter the raw unencrypted value into your shell, which will be sealed, base64 encoded and placed into the file. Comments in the secrets file are not affected by the script, and are encouraged.

Sealed Secrets are *write only*, and as such, cannot be read directly from the definitions in this repository. However, if you have cluster access, you can read the secret value from the cluster.

**Note**: Due to logistical issues with retrieving it on demand, the public certificate is stored in this repository under `k8s/production/sealed-secrets/cert.pem`. This is the *public* part of the public/private key pair, and is **not** sensitive information. The secrets scripts will use this certificate automatically, but if there is ever a need to use a *different* certificate, it can be set with the `SEALED_SECRETS_CERT` environment variable.

## Restoring from Backup

- Delete the persistent volume (PV) and persistent volume claim (PVC) for the old volume that's being replaced.
   - `kubectl delete -f pv.yaml -f pvc.yaml`
- Create a new volume from a snapshot in the [AWS web console](https://console.aws.amazon.com)
- Update `pv.yaml` to reference the newly created volumeId.
- Recreate the PV and PVC
   - `kubectl apply -f pv.yaml -f pvc.yaml`

License
----------------

Spack is distributed under the terms of both the MIT license and the
Apache License (Version 2.0). Users may choose either license, at their
option.

All new contributions must be made under both the MIT and Apache-2.0
licenses.

See [LICENSE-MIT](https://github.com/spack/spack-infrastructure/blob/master/LICENSE-MIT),
[LICENSE-APACHE](https://github.com/spack/spack-infrastructure/blob/master/LICENSE-APACHE),
[COPYRIGHT](https://github.com/spack/spack-infrastructure/blob/master/COPYRIGHT), and
[NOTICE](https://github.com/spack/spack-infrastructure/blob/master/NOTICE) for details.

SPDX-License-Identifier: (Apache-2.0 OR MIT)

LLNL-CODE-811652
