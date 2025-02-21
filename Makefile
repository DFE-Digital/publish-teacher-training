ifndef VERBOSE
.SILENT:
endif
SERVICE_SHORT=ptt
SERVICE_NAME=publish

.PHONY: help
help: ## Show this help
	echo Usage: make env [target]...
	echo
	echo "     Environments:"
	echo "       - qa"
	echo "       - review"
	echo "       - production"
	echo "       - staging"
	echo "       - sandbox"
	echo
	echo "  Examples:"
	echo
	echo "  $$ make qa print-app-secrets"
	echo "  $$ make review console PR_NUMBER=1234"
	echo
	echo "For more information regarding some of the commands run here:"
	echo "  https://github.com/DFE-Digital/publish-teacher-training/blob/main/guides/aks-cheatsheet.md"
	echo
	printf "\033[33m%s\033[0m\n" "Install utilities:"
	echo
	@grep -E '^install[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	echo
	printf "\033[33m%s\033[0m\n" "Manage or inspect secrets:"
	echo
	@grep -E '^(print|edit)[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	echo
	printf "\033[33m%s\033[0m\n" "Access the running app in given environment:"
	echo
	@grep -E '^(console|shell|logs):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	echo
	printf "\033[33m%s\033[0m\n" "Enable / Disable the maintainence page:"
	echo
	@grep -E '^(en|dis)able-maintenance:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## Install utilities
.PHONY: install-konduit
install-konduit: ## Install the konduit script, for accessing backend services
	[ ! -f bin/konduit.sh ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/master/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh \
		|| true

.PHONY: install-fetch-config
install-fetch-config: ## Install utility to fetch the cli config from teacher services
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

# Set "USE_DB_SETUP_COMMAND" to true for first time deployments, otherwise false.
review: ## make review deploy PR_NUMBER=2222 USE_DB_SETUP_COMMAND=true
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a name for your review app))
	$(if $(USE_DB_SETUP_COMMAND), , $(error Missing environment variable "USE_DB_SETUP_COMMAND", Set to true for first time deployments, otherwise false.))
	$(eval export TF_VAR_use_db_setup_command=$(USE_DB_SETUP_COMMAND))
	$(eval include global_config/review.sh)
	$(eval export TF_VAR_app_name=$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)
	echo https://$(SERVICE_NAME)-review-$(PR_NUMBER).test.teacherservices.cloud will be created in AKS

# Set "USE_DB_SETUP_COMMAND" to true for first time deployments, otherwise false.
dv_review: ## make dv_review deploy PR_NUMBER=2222 CLUSTER=cluster1 USE_DB_SETUP_COMMAND=true
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(if $(USE_DB_SETUP_COMMAND), , $(error Missing environment variable "USE_DB_SETUP_COMMAND", Set to true for first time deployments, otherwise false.))
	$(if $(CLUSTER), , $(error Missing environment variable "CLUSTER", Please specify a dev cluster name (eg 'cluster1')))
	$(eval export TF_VAR_use_db_setup_command=$(USE_DB_SETUP_COMMAND))
	$(eval include global_config/dv_review.sh)
	$(eval backend_key=-backend-config=key=$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_cluster=$(CLUSTER))
	$(eval export TF_VAR_app_name=$(PR_NUMBER))
	echo https://$(SERVICE_NAME)-review-$(PR_NUMBER).$(CLUSTER).development.teacherservices.cloud will be created in AKS

qa:
	$(eval include global_config/qa.sh)
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)

staging:
	$(eval include global_config/staging.sh)

sandbox:
	$(eval include global_config/sandbox.sh)

production:
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Missing CONFIRM_PRODUCTION=yes))
	$(eval include global_config/production.sh)

.PHONY: ci
ci:	## Run in automation environment
	$(eval export AUTO_APPROVE=-auto-approve)
	$(eval SKIP_CONFIRM=true)

read-keyvault-config:
	$(eval export key_vault_name=$(shell jq -r '.key_vault_name' terraform/aks/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_app_secret_name=$(shell jq -r '.key_vault_app_secret_name' terraform/aks/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_infra_secret_name=$(shell jq -r '.key_vault_infra_secret_name' terraform/aks/workspace_variables/$(DEPLOY_ENV).tfvars.json))

read-cluster-config:
	$(eval CLUSTER=$(shell jq -r '.cluster' terraform/aks/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/aks/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval CONFIG_LONG=$(shell jq -r '.app_environment' terraform/aks/workspace_variables/$(DEPLOY_ENV).tfvars.json))

print-app-secrets: read-keyvault-config install-fetch-config ## Print application secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} \
		-f yaml

edit-app-secrets: read-keyvault-config install-fetch-config ## Edit application secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} \
		-e -d azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} -f yaml

print-infra-secrets: read-keyvault-config install-fetch-config ## Print infrastructure secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} \
		-f yaml

edit-infra-secrets: read-keyvault-config install-fetch-config ## Edit infrastructure secrets
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} \
		-e -d azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} -f yaml

get-cluster-credentials: read-cluster-config set-azure-account ## make <config> get-cluster-credentials [ENVIRONMENT=<clusterX>]
	az aks get-credentials --overwrite-existing -g ${RESOURCE_NAME_PREFIX}-tsc-${CLUSTER_SHORT}-rg -n ${RESOURCE_NAME_PREFIX}-tsc-${CLUSTER}-aks
	kubelogin convert-kubeconfig -l $(if ${AAD_LOGIN_METHOD},${AAD_LOGIN_METHOD},azurecli)

console: get-cluster-credentials ## Run the Rails console in the given environment
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID} -- /bin/sh -c "cd /app && /usr/local/bin/bundle exec rails c"

logs: get-cluster-credentials ## Print logs from aks
	echo "config: $CONFIG_LONG"
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=publish-${APP_ID} --tail=-1 --timestamps=true

worker-logs: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=publish-${APP_ID}-worker --tail=-1 --timestamps=true

shell: get-cluster-credentials ## Start an ssh shell on the web pod
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID} -- /bin/sh

worker-shell: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID}-worker -- /bin/sh

.PHONY: vendor-modules
vendor-modules:
	rm -rf terraform/aks/vendor/modules
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/aks/vendor/modules/aks

### Infra Targets From Here

deploy-init: vendor-modules
	$(if $(IMAGE_TAG), , $(eval export IMAGE_TAG=main))
	$(eval export TF_VAR_docker_image=ghcr.io/dfe-digital/publish-teacher-training:$(IMAGE_TAG))
	az account set -s ${AZ_SUBSCRIPTION} && az account show
	terraform -chdir=terraform/aks init -reconfigure -upgrade -backend-config=./workspace_variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

deploy-plan: deploy-init
	terraform -chdir=terraform/aks plan -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS}

deploy: deploy-init
	terraform -chdir=terraform/aks apply -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

destroy: deploy-init
	terraform -chdir=terraform/aks destroy -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

publish:
	$(eval include global_config/publish-domain.sh)

find:
	$(eval include global_config/find-domain.sh)

set-azure-account:
	echo "Logging on to ${AZ_SUBSCRIPTION}"
	az account set -s $(AZ_SUBSCRIPTION)

set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teacher Training and Qualifications", "Product" : "Find postgraduate teacher training", "Service Line": "Teaching Workforce", "Service": "Teacher services", "Service Offering": "Find postgraduate teacher training"}' | jq . ))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.0)

arm-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}sa" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			"keyVaultName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-kv" ${WHAT_IF}

validate-arm-resources: set-what-if arm-resources

deploy-arm-resources: check-auto-approve arm-resources

set-production-subscription:
	$(eval AZ_SUBSCRIPTION=s189-teacher-services-cloud-production)

set-what-if:
	$(eval WHAT_IF=--what-if)

check-auto-approve:
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources # make publish validate-domain-resources AUTO_APPROVE=1

deploy-domain-resources: check-auto-approve domain-azure-resources # make publish deploy-domain-resources AUTO_APPROVE=1

.PHONY: vendor-domain-infra-modules
vendor-domain-infra-modules:
	rm -rf terraform/custom_domains/infrastructure/vendor/modules/domains
	TERRAFORM_MODULES_TAG=stable
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/custom_domains/infrastructure/vendor/modules/domains

domains-infra-init: set-production-subscription set-azure-account vendor-domain-infra-modules
	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DOMAINS_ID}_backend.tfvars

domains-infra-plan: domains-infra-init # make publish domains-infra-plan
	terraform -chdir=terraform/custom_domains/infrastructure plan -var-file workspace_variables/${DOMAINS_ID}.tfvars.json

domains-infra-apply: domains-infra-init # make publish domains-infra-apply
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DOMAINS_ID}.tfvars.json ${AUTO_APPROVE}

.PHONY: vendor-domain-modules
vendor-domain-modules:
	rm -rf terraform/custom_domains/environment_domains/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/custom_domains/environment_domains/vendor/modules/domains

domains-init: set-production-subscription set-azure-account vendor-domain-modules
	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}_backend.tfvars

domains-plan: domains-init  # make publish qa domains-plan
	terraform -chdir=terraform/custom_domains/environment_domains plan -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

domains-apply: domains-init # make publish qa domains-apply
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init # make publish qa domains-destroy
	terraform -chdir=terraform/custom_domains/environment_domains destroy -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

action-group-resources: set-azure-account # make env action-group-resources ACTION_GROUP_EMAIL=notificationemail@domain.com . Must be run before setting enable_monitoring=true for each subscription
	$(if $(ACTION_GROUP_EMAIL), , $(error Please specify a notification email for the action group))
	echo ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg
	az group create -l uksouth -g ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg --tags "Product=Find postgraduate teacher training" "Environment=Test" "Service Offering=Teacher services cloud"
	az monitor action-group create -n ${RESOURCE_NAME_PREFIX}-${SERVICE_NAME} -g ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg --action email ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-email ${ACTION_GROUP_EMAIL}

### Infra targets end

#### Maintenence targets

maintenance-image-push:
	$(if ${GITHUB_TOKEN},, $(error Provide a valid Github token with write:packages permissions as GITHUB_TOKEN variable))
	$(if ${MAINTENANCE_IMAGE_TAG},, $(eval export MAINTENANCE_IMAGE_TAG=$(shell date +%s)))
	docker build -t ghcr.io/dfe-digital/publish-maintenance:${MAINTENANCE_IMAGE_TAG} maintenance_page
	echo ${GITHUB_TOKEN} | docker login ghcr.io -u USERNAME --password-stdin
	docker push ghcr.io/dfe-digital/publish-maintenance:${MAINTENANCE_IMAGE_TAG}

maintenance-fail-over: get-cluster-credentials
	$(eval export CONFIG)
	./maintenance_page/scripts/failover.sh

enable-maintenance: maintenance-image-push maintenance-fail-over ## Enable the maintainence page

disable-maintenance: get-cluster-credentials ## Disable the maintainence page
	$(eval export CONFIG)
	./maintenance_page/scripts/failback.sh
