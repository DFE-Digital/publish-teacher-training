# Azure Kubernetes Service / AKS cheatsheet

Requirements

Azure CIP account and access to the s189 subscription
- https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/#onboarding-users
- request s189 access from the devops team

azure-cli installed locally
- see https://technical-guidance.education.gov.uk/infrastructure/dev-tools/#azure-cli

kubectl installed locally
- see https://github.com/DFE-Digital/teacher-services-cloud#kubectl

All examples below show qa usage and you should adapt accordingly.

### Cluster and app info

There are several AKS clusters, but only 2 are relevant for publish services.

s189t01-tsc-test-aks
- in s189-teacher-services-cloud-test subscription
- in s189t01-tsc-ts-rg resource group
- contains bat-qa and bat-staging namespaces
- will hold publish review apps, publish-qa, publish-staging
- PIM self approval required

s189p01-tsc-production-aks
- in s189-teacher-services-cloud-production subscription
- in s189p01-tsc-pd-rg resource group
- contains bat-production namespace
- will hold publish-production and publish-sandbox
- PIM approval required

## Authentication

### Raising a PIM request

You need to activate the role in the desired cluster below:
https://portal.azure.com/?Microsoft_Azure_PIMCommon=true#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/azurerbac

Example: Activate `s189-teacher-services-cloud-test`. It will be approved automatically after a few seconds

### Azure setup

```
$ az login
```

Get access credentials for a managed Kubernetes cluster (passing the
environment name):

```
$ make production_aks get-cluster-credentials
```

## Show namespaces

```
$ kubectl get namespaces
```

## Show deployments

```
$ kubectl -n bat-qa get deployments
```

## Show pods

```
$ kubectl -n bat-qa get pods
```

## Get logs from a pod

Without tail:

```
$ kubectl -n bat-qa logs publish-qa-some-number
```

Tail:

```
$ kubectl -n bat-qa logs publish-qa-some-number -f
```

Logs from the ingress:

```
$ kubectl logs deployment/ingress-nginx-controller -f
```

Alternatively you can install kubetail and run:

```
$ kubetail -n bat-qa publish-qa-*
```

You can also get logs from a deployed app using make with aks-logs:

```
$ make review_aks aks-logs APP_NAME=1234
$ make qa_aks aks-logs
```

## Open a shell

```
$ kubectl -n bat-qa get deployments
$ kubectl -n bat-qa exec -ti deployment/publish-review-1234 -- sh
```

Alternatively you can enter directly on a pod:

```
$ kubectl -n bat-qa exec -ti publish-qa-some-number -- sh
```

You can run a rails console on a deployed app using make with aks-console:

```
$ make review_aks aks-console APP_NAME=1234
$ make qa_aks aks-console
```

You can connect using ssh on a deployed app using make with aks-ssh or aks-worker-ssh:

```
$ make review_aks aks-ssh APP_NAME=1234
$ make qa_aks aks-worker-ssh
```

## Show CPU / Memory Usage

All pods in a namespace:
```
kubectl -n bat-qa top pod
```

All pods:
```
kubectl top pod -A
```

## More info on a pod

```
$ kubectl -n bat-qa describe pods publish-somenumber-of-the-pod
```

## Scaling

The app:
```
$ kubectl -n bat-qa scale deployment/publish-loadtest --replicas 2
```

### Enter on console

```
kubectl -n bat-qa exec -ti publish-loadtest-some-pod-number -- bundle exec rails c
```


### Running tasks

```
kubectl -n bat-qa exec -ti publish-loadtest-some-pod-number -- bundle exec rake -T
```

### Access the DB

```
make install-konduit
bin/konduit.sh app-name -- psql
```

Example of loading test:

```
bin/konduit.sh publish-loadtest -- psql
```

## More info

For more info see
[Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
