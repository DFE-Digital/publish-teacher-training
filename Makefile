ifndef VERBOSE
.SILENT:
endif
SERVICE_SHORT=ptt
SERVICE_NAME=publish
TERRAFILE_VERSION=0.8

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

install-terrafile: ## Install terrafile to manage terraform modules
	[ ! -f bin/terrafile ] \
		&& curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile \
		|| true

# Set "USE_DB_SETUP_COMMAND" to true for first time deployments, otherwise false.
review_aks: ## make review_aks deploy PR_NUMBER=2222 USE_DB_SETUP_COMMAND=true
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a name for your review app))
	$(eval export TF_VAR_use_db_setup_command=${USE_DB_SETUP_COMMAND:=false})
	$(eval include global_config/review_aks.sh)
	$(eval export TF_VAR_app_name=$(PR_NUMBER))
	$(eval backend_key=-backend-config=key=pr-$(PR_NUMBER).tfstate)
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)
	echo https://$(SERVICE_NAME)-review-$(PR_NUMBER).test.teacherservices.cloud will be created in AKS

# Set "USE_DB_SETUP_COMMAND" to true for first time deployments, otherwise false.
dv_review_aks: ## make dv_review_aks deploy PR_NUMBER=2222 CLUSTER=cluster1 USE_DB_SETUP_COMMAND=true
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(if $(CLUSTER), , $(error Missing environment variable "CLUSTER", Please specify a dev cluster name (eg 'cluster1')))
	$(eval export TF_VAR_use_db_setup_command=${USE_DB_SETUP_COMMAND:=false})
	$(eval include global_config/dv_review_aks.sh)
	$(eval backend_key=-backend-config=key=$(PR_NUMBER).tfstate)
	$(eval export TF_VAR_cluster=$(CLUSTER))
	$(eval export TF_VAR_app_name=$(PR_NUMBER))
	echo https://$(SERVICE_NAME)-review-$(PR_NUMBER).$(CLUSTER).development.teacherservices.cloud will be created in AKS

qa_aks:
	$(eval include global_config/qa_aks.sh)
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)

staging_aks:
	$(eval include global_config/staging_aks.sh)

sandbox_aks:
	$(eval include global_config/sandbox_aks.sh)

production_aks:
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Missing CONFIRM_PRODUCTION=yes))
	$(eval include global_config/production_aks.sh)

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
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)

aks-console: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID} -- /bin/sh -c "cd /app && /usr/local/bin/bundle exec rails c"

aks-logs: get-cluster-credentials
	echo "config: $CONFIG_LONG"
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=publish-${APP_ID} --tail=-1 --timestamps=true

aks-worker-logs: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=publish-${APP_ID}-worker --tail=-1 --timestamps=true

aks-ssh: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID} -- /bin/sh

aks-worker-ssh: get-cluster-credentials
	$(if $(PR_NUMBER), $(eval export APP_ID=review-$(PR_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID}-worker -- /bin/sh

### Infra Targets From Here

deploy-init: install-terrafile
	$(if $(IMAGE_TAG), , $(eval export IMAGE_TAG=main))
	$(eval export TF_VAR_docker_image=ghcr.io/dfe-digital/publish-teacher-training:$(IMAGE_TAG))
	az account set -s ${AZ_SUBSCRIPTION} && az account show
	[ "${RUN_TERRAFILE}" = "yes" ] && ./bin/terrafile -p terraform/aks/vendor/modules -f terraform/aks/workspace_variables/$(DEPLOY_ENV)_Terrafile || true
	terraform -chdir=terraform/aks init -reconfigure -upgrade -backend-config=./workspace_variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

deploy-plan: deploy-init
	terraform -chdir=terraform/aks plan -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS}

deploy: deploy-init
	terraform -chdir=terraform/aks apply -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

destroy: deploy-init
	terraform -chdir=terraform/aks destroy -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

delete_sanitised_backup_file:
	@if [ -f backup_sanitised/backup_sanitised.sql ]; then \
		rm backup_sanitised/backup_sanitised.sql; \
		echo "Backup file deleted."; \
	else \
		echo "Backup file does not exist."; \
	fi

restore-sanitised-data-to-review-app: read-cluster-config set-azure-account delete_sanitised_backup_file install-konduit # download and extract sanitised database to backup_sanitsed folder and restore
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval export sanitised_backup_workflow_run_id=$(shell gh run list -w "Database Backup and Restore" -s completed --json databaseId --jq '.[].databaseId' -L 1))
	@echo Download latest artifact for Database Backup and Restore workflow with run ID: ${sanitised_backup_workflow_run_id}
	gh run download ${sanitised_backup_workflow_run_id}
	bin/konduit.sh -i backup_sanitised/backup_sanitised.sql -t 7200 publish-review-$(PR_NUMBER) -- psql

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

domains-infra-init: set-production-subscription set-azure-account
	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DOMAINS_ID}_backend.tfvars

domains-infra-plan: domains-infra-init # make publish domains-infra-plan
	terraform -chdir=terraform/custom_domains/infrastructure plan -var-file workspace_variables/${DOMAINS_ID}.tfvars.json

domains-infra-apply: domains-infra-init # make publish domains-infra-apply
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DOMAINS_ID}.tfvars.json ${AUTO_APPROVE}

domains-init: set-production-subscription set-azure-account
	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}_backend.tfvars

domains-plan: domains-init  # make publish qa domains-plan
	terraform -chdir=terraform/custom_domains/environment_domains plan -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

domains-apply: domains-init # make publish qa domains-apply
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init # make publish qa domains-destroy
	terraform -chdir=terraform/custom_domains/environment_domains destroy -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

action-group-resources: set-azure-account # make env_aks action-group-resources ACTION_GROUP_EMAIL=notificationemail@domain.com . Must be run before setting enable_monitoring=true for each subscription
	$(if $(ACTION_GROUP_EMAIL), , $(error Please specify a notification email for the action group))
	echo ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg
	az group create -l uksouth -g ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg --tags "Product=Find postgraduate teacher training" "Environment=Test" "Service Offering=Teacher services cloud"
	az monitor action-group create -n ${RESOURCE_NAME_PREFIX}-${SERVICE_NAME} -g ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg --action email ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-email ${ACTION_GROUP_EMAIL}

### Infra targets end

### Environment aliases

.PHONY: review
review: review_aks

.PHONY: qa
qa: qa_aks

.PHONY: staging
staging: staging_aks

.PHONY: sandbox
sandbox: sandbox_aks

.PHONY: production
production: production_aks

.PHONY: logs
logs: aks-logs ## Print logs from aks

.PHONY: shell
shell: aks-ssh ## Start an ssh shell on the web pod

.PHONY: worker-shell
worker-shell: aks-worker-ssh

.PHONY: console
console: aks-console ## Run the Rails console in the given environment

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
