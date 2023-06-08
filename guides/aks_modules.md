## AKS terraform modules

The deployment relies on [terraform modules](https://github.com/DFE-Digital/terraform-modules/) to deploy applications and services to Kubernetes.
They follow this release cycle:
- main: all updates
- testing: updates under test in multiple environments
- stable: tested updates

To be able to detect breaking changes as soon as possible, the Publish environments are configured with different versions:
- review: main
- qa, staging: testing
- production, productiondata: stable

This is achieved by setting `version:` in the Terrafiles in the `terraform/aks/workspace_variables` folder. The version can point at a branch such as
main or a feature branch. Or a tag such as testing, stable or any other tag pointing at the desired commit id. The simple commit id cannot be used directly.

If an environment fails because of a module update, report it to the infra team. If it's blocking delivery, change the version to testing or stable
while this is being investigated.
