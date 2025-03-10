#!/bin/bash

external_urls=$(terraform -chdir=terraform/custom_domains/environment_domains output -json external_urls | jq -r '.[]')
for url in ${external_urls} ; do
    echo "Check health for ${url}/healthcheck ..."
    curl -sS --fail "${url}/healthcheck" > /dev/null
done
