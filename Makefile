ifndef VERBOSE
.SILENT:
endif
SERVICE_SHORT=ptt
SERVICE_NAME=publish
TERRAFILE_VERSION=0.8

help:
	echo "Environment setup targets:"
	echo "  review     - configure for review app"
	echo "  qa"
	echo "  staging"
	echo "  production"
	echo ""
	echo "Commands:"
	echo "  deploy-plan - Print out the plan for the deploy, does not deploy."
	echo ""
	echo "Command Options:"
	echo "      APP_NAME  - name of the review application being setup, only required when DEPLOY_ENV is review"
	echo "      IMAGE_TAG - git sha of a built image, see builds in GitHub Actions"
	echo "      PASSCODE  - your authentication code for GOVUK PaaS, retrieve from"
	echo "                  https://login.london.cloud.service.gov.uk/passcode"
	echo ""
	echo "Examples:"
	echo "  Create a review app"
	echo "    You will need to retrieve the authentication code from GOVUK PaaS"
	echo "    visit https://login.london.cloud.service.gov.uk/passcode. Then run"
	echo "    deploy-plan to test:"
	echo ""
	echo "        make review APP_NAME=<APP_NAME> deploy-plan IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"
	echo "  Delete a review app"
	echo ""
	echo "        make review APP_NAME=<APP_NAME> destory IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"
	echo "Examples:"
	echo "  Deploy an pre-built image to qa"
	echo ""
	echo "        make qa deploy IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"

install-terrafile: ## Install terrafile to manage terraform modules
	[ ! -f bin/terrafile ] \
		&& curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile \
		|| true

review:
	$(eval DEPLOY_ENV=review)
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a name for your review app))
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval backend_key=-backend-config=key=pr-$(APP_NAME).tfstate)
	$(eval export TF_VAR_paas_app_environment=review-$(APP_NAME))
	$(eval export TF_VAR_paas_web_app_host_name=$(APP_NAME))
	$(eval space=bat-qa)
	$(eval paas_env=pr-$(APP_NAME))
	$(eval PLATFORM=paas)
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)
	echo https://publish-teacher-training-pr-$(APP_NAME).london.cloudapps.digital will be created in bat-qa space

review_aks: ## make review_aks deploy APP_NAME=2222 USE_DB_SETUP_COMMAND=true
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a name for your review app))
	$(if $(USE_DB_SETUP_COMMAND), , $(error Missing environment variable "USE_DB_SETUP_COMMAND", Set to true for first time deployments, otherwise false.))
	$(eval export TF_VAR_use_db_setup_command=$(USE_DB_SETUP_COMMAND))
	$(eval export DISABLE_PASSCODE=1)
	$(eval include global_config/review_aks.sh)
	$(eval export TF_VAR_app_name=$(APP_NAME))
	$(eval backend_key=-backend-config=key=pr-$(APP_NAME).tfstate)
	$(eval export TF_VAR_paas_app_environment=review-$(APP_NAME))
	$(eval export TF_VAR_paas_web_app_host_name=$(APP_NAME))
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})
	echo https://$(SERVICE_NAME)-review-$(APP_NAME).test.teacherservices.cloud will be created in AKS

dv_review_aks: ## make dv_review_aks deploy APP_NAME=2222 CLUSTER=cluster1 USE_DB_SETUP_COMMAND=true
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a pr number for your review app))
	$(if $(CLUSTER), , $(error Missing environment variable "CLUSTER", Please specify a dev cluster name (eg 'cluster1')))
	$(if $(USE_DB_SETUP_COMMAND), , $(error Missing environment variable "USE_DB_SETUP_COMMAND", Set to true for first time deployments, otherwise false.))
	$(eval export TF_VAR_use_db_setup_command=$(USE_DB_SETUP_COMMAND))
	$(eval export DISABLE_PASSCODE=1)
	$(eval include global_config/dv_review_aks.sh)
	$(eval backend_key=-backend-config=key=$(APP_NAME).tfstate)
	$(eval export TF_VAR_cluster=$(CLUSTER))
	$(eval export TF_VAR_app_name=$(APP_NAME))
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})
	echo https://$(SERVICE_NAME)-review-$(APP_NAME).$(CLUSTER).development.teacherservices.cloud will be created in AKS

qa_aks:
	$(eval include global_config/qa_aks.sh)
	$(eval export DISABLE_PASSCODE=1)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)

staging_aks:
	$(eval include global_config/staging_aks.sh)
	$(eval export DISABLE_PASSCODE=1)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

sandbox_aks:
	$(eval include global_config/sandbox_aks.sh)
	$(eval export DISABLE_PASSCODE=1)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

production_aks:
	$(eval include global_config/production_aks.sh)
	$(eval export DISABLE_PASSCODE=1)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

.PHONY: qa
qa: ## Set DEPLOY_ENV to qa
	$(eval DEPLOY_ENV=qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval space=bat-qa)
	$(eval paas_env=qa)
	$(eval PLATFORM=paas)
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)

.PHONY: staging
staging: ## Set DEPLOY_ENV to staging
	$(eval DEPLOY_ENV=staging)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)
	$(eval space=bat-staging)
	$(eval paas_env=staging)
	$(eval PLATFORM=paas)

.PHONY: sandbox
sandbox: ## Set DEPLOY_ENV to sandbox
	$(eval DEPLOY_ENV=sandbox)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval space=bat-prod)
	$(eval paas_env=sandbox)
	$(eval PLATFORM=paas)

.PHONY: production
production: ## Set DEPLOY_ENV to production
	$(eval DEPLOY_ENV=production)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))
	$(eval space=bat-prod)
	$(eval paas_env=prod)
	$(eval PLATFORM=paas)
	$(eval PARTIAL_HOSTNAME=www)
	$(eval backup_storage_secret_name=PUBLISH-STORAGE-ACCOUNT-CONNECTION-STRING-PRODUCTION)

.PHONY: loadtest
loadtest: ## Set DEPLOY_ENV to loadtest
	$(eval DEPLOY_ENV=loadtest)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval space=bat-prod)
	$(eval paas_env=loadtest)
	$(eval PLATFORM=paas)

.PHONY: pentest
pentest: ## Set DEPLOY_ENV to pentest
	$(eval DEPLOY_ENV=pentest)

.PHONY: rollover
rollover: ## Set DEPLOY_ENV to rollover
	$(eval DEPLOY_ENV=rollover)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval space=bat-prod)
	$(eval paas_env=rollover)
	$(eval PLATFORM=paas)

.PHONY: ci
ci:	## Run in automation environment
	$(eval export DISABLE_PASSCODE=true)
	$(eval export AUTO_APPROVE=-auto-approve)

deploy-init: install-terrafile
	$(if $(IMAGE_TAG), , $(eval export IMAGE_TAG=main))
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_cf_sso_passcode=$(PASSCODE))
	$(eval export TF_VAR_docker_image=ghcr.io/dfe-digital/publish-teacher-training:$(IMAGE_TAG))
	az account set -s ${AZ_SUBSCRIPTION} && az account show
	[ "${RUN_TERRAFILE}" = "yes" ] && ./bin/terrafile -p terraform/$(PLATFORM)/vendor/modules -f terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV)_Terrafile || true
	terraform -chdir=terraform/$(PLATFORM) init -reconfigure -upgrade -backend-config=./workspace_variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key)
	echo "🚀 DEPLOY_ENV is $(DEPLOY_ENV)"

deploy-plan: deploy-init
	terraform -chdir=terraform/$(PLATFORM) plan -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS}

deploy: deploy-init
	terraform -chdir=terraform/$(PLATFORM) apply -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

destroy: deploy-init
	terraform -chdir=terraform/$(PLATFORM) destroy -var-file=./workspace_variables/$(DEPLOY_ENV).tfvars.json ${TF_VARS} $(AUTO_APPROVE)

install-fetch-config:
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

.PHONY: install-konduit
install-konduit: ## Install the konduit script, for accessing backend services
	[ ! -f bin/konduit.sh ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/master/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh \
		|| true

read-deployment-config:
	$(eval export postgres_database_name=publish-teacher-training-postgres-${paas_env})

read-keyvault-config:
	$(eval export key_vault_name=$(shell jq -r '.key_vault_name' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_app_secret_name=$(shell jq -r '.key_vault_app_secret_name' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_infra_secret_name=$(shell jq -r '.key_vault_infra_secret_name' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))

read-cluster-config:
	$(eval CLUSTER=$(shell jq -r '.cluster' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval CONFIG_LONG=$(shell jq -r '.app_environment' terraform/$(PLATFORM)/workspace_variables/$(DEPLOY_ENV).tfvars.json))

edit-app-secrets: read-keyvault-config install-fetch-config
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} \
		-e -d azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} -f yaml

print-app-secrets: read-keyvault-config install-fetch-config
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} \
		-f yaml

edit-infra-secrets: read-keyvault-config install-fetch-config
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} \
		-e -d azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} -f yaml

print-infra-secrets: read-keyvault-config install-fetch-config
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} \
		-f yaml

console:
	cf target -s ${space}
	cf ssh publish-teacher-training-${paas_env} -t -c "cd /app && /usr/local/bin/bundle exec rails c"

get-cluster-credentials: read-cluster-config set-azure-account ## make <config> get-cluster-credentials [ENVIRONMENT=<clusterX>]
	az aks get-credentials --overwrite-existing -g ${RESOURCE_NAME_PREFIX}-tsc-${CLUSTER_SHORT}-rg -n ${RESOURCE_NAME_PREFIX}-tsc-${CLUSTER}-aks

aks-console: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=review-$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID} -- /bin/sh -c "cd /app && /usr/local/bin/bundle exec rails c"

aks-logs: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=review-$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=publish-${APP_ID} --tail=-1 --timestamps=true

aks-worker-logs: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=review-$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=publish-${APP_ID}-worker --tail=-1 --timestamps=true

aks-ssh: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=review-$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID} -- /bin/sh

aks-worker-ssh: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=review-$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/publish-${APP_ID}-worker -- /bin/sh

enable-maintenance: ## make qa enable-maintenance / make prod enable-maintenance CONFIRM_PRODUCTION=y
	$(if $(PARTIAL_HOSTNAME), $(eval API_HOSTNAME_ARG=""), $(eval API_HOSTNAME_ARG="--hostname ${DEPLOY_ENV}"))
	$(if $(PARTIAL_HOSTNAME), $(eval PUBLISH_HOSTNAME=${PARTIAL_HOSTNAME}), $(eval PUBLISH_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	cd service_unavailable_page && cf push
	eval cf map-route publish-unavailable api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf map-route publish-unavailable publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}
	cf map-route publish-unavailable find-postgraduate-teacher-training.service.gov.uk --hostname ${PUBLISH_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	eval cf unmap-route publish-teacher-training-${DEPLOY_ENV} api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf unmap-route publish-teacher-training-${DEPLOY_ENV} publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}
	cf unmap-route publish-teacher-training-${DEPLOY_ENV} find-postgraduate-teacher-training.service.gov.uk --hostname ${PUBLISH_HOSTNAME}

disable-maintenance: ## make qa disable-maintenance / make prod disable-maintenance CONFIRM_PRODUCTION=y
	$(if $(PARTIAL_HOSTNAME), $(eval API_HOSTNAME_ARG=""), $(eval API_HOSTNAME_ARG="--hostname ${DEPLOY_ENV}"))
	$(if $(PARTIAL_HOSTNAME), $(eval PUBLISH_HOSTNAME=${PARTIAL_HOSTNAME}), $(eval PUBLISH_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	eval cf map-route publish-teacher-training-${DEPLOY_ENV} api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf map-route publish-teacher-training-${DEPLOY_ENV} publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}
	cf map-route publish-teacher-training-${DEPLOY_ENV} find-postgraduate-teacher-training.service.gov.uk --hostname ${PUBLISH_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	eval cf unmap-route publish-unavailable api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf unmap-route publish-unavailable publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}
	cf unmap-route publish-unavailable find-postgraduate-teacher-training.service.gov.uk --hostname ${PUBLISH_HOSTNAME}
	cf delete -rf publish-unavailable

restore-data-from-nightly-backup: read-deployment-config read-keyvault-config # make production restore-data-from-nightly-backup CONFIRM_PRODUCTION=YES CONFIRM_RESTORE=YES BACKUP_DATE="yyyy-mm-dd"
	bin/download-nightly-backup ${backup_storage_secret_name} ${key_vault_name} ${paas_env}-db-backup ${paas_env}_backup- ${BACKUP_DATE}
	$(if $(CONFIRM_RESTORE), , $(error Restore can only run with CONFIRM_RESTORE))
	bin/restore-nightly-backup ${space} ${postgres_database_name} ${paas_env}_backup- ${BACKUP_DATE}

delete_sanitised_backup_file:
	@if [ -f backup_sanitised/backup_sanitised.sql ]; then \
		rm backup_sanitised/backup_sanitised.sql; \
		echo "Backup file deleted."; \
	else \
		echo "Backup file does not exist."; \
	fi

restore-sanitised-data-to-review-app: read-cluster-config set-azure-account delete_sanitised_backup_file install-konduit # download and extract sanitised database to backup_sanitsed folder and restore
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a pr number for your review app))
	$(eval export sanitised_backup_workflow_run_id=$(shell gh run list -w "Database Backup and Restore" -s completed --json databaseId --jq '.[].databaseId' -L 1))
	@echo Download latest artifact for Database Backup and Restore workflow with run ID: ${sanitised_backup_workflow_run_id}
	gh run download ${sanitised_backup_workflow_run_id}
	bin/konduit.sh -i backup_sanitised/backup_sanitised.sql -t 7200 publish-review-$(APP_NAME) -- psql

upload-review-backup: read-deployment-config read-keyvault-config # make review upload-review-backup BACKUP_DATE=2022-06-10 APP_NAME=1234
	bin/upload-review-backup ${backup_storage_secret_name} ${key_vault_name} ${paas_env}-db-backup ${paas_env}_backup-${BACKUP_DATE}.sql.tar.gz

backup-review-database: read-deployment-config # make review backup-review-database APP_NAME=1234
	bin/backup-review-database ${postgres_database_name} ${paas_env}

get-image-tag:
	$(eval export TAG=$(shell cf target -s ${space} 1> /dev/null && cf app publish-teacher-training-${paas_env} | awk -F : '$$1 == "docker image" {print $$3}'))
	@echo ${TAG}

get-postgres-instance-guid: ## Gets the postgres service instance's guid make qa get-postgres-instance-guid
	$(eval export DB_INSTANCE_GUID=$(shell cf target -s ${space} 1> /dev/null && cf service publish-teacher-training-postgres-${paas_env} --guid))
	@echo ${DB_INSTANCE_GUID}

rename-postgres-service: ## make qa rename-postgres-service
	cf target -s ${space} 1> /dev/null
	cf rename-service publish-teacher-training-postgres-${paas_env} publish-teacher-training-postgres-${paas_env}-old

remove-postgres-tf-state: deploy-init ## make qa remove-postgres-tf-state PASSCODE=xxxx
	terraform -chdir=terraform/$(PLATFORM) state rm module.paas.cloudfoundry_service_instance.postgres

set-restore-variables:
	$(if $(IMAGE_TAG), , $(error can only run with an IMAGE_TAG))
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make ${space} get-postgres-instance-guid`))
	$(if $(SNAPSHOT_TIME), , $(error can only run with BEFORE_TIME, eg SNAPSHOT_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_docker_image=ghcr.io/dfe-digital/publish-teacher-training:$(IMAGE_TAG))
	$(eval export TF_VAR_paas_restore_from_db_guid=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_db_backup_before_point_in_time=$(SNAPSHOT_TIME))
	echo "Restoring publish-teacher-training from $(TF_VAR_paas_restore_from_db_guid) before $(TF_VAR_paas_db_backup_before_point_in_time)"

restore-postgres: set-restore-variables deploy ##  make qa restore-postgres IMAGE_TAG=12345abcdef67890ghijklmnopqrstuvwxyz1234 DB_INSTANCE_GUID=abcdb262-79d1-xx1x-b1dc-0534fb9b4 SNAPSHOT_TIME="2021-11-16 15:20:00" PASSCODE=xxxxx

publish:
	$(eval include global_config/publish-domain.sh)

find:
	$(eval include global_config/find-domain.sh)

set-azure-account:
	echo "Logging on to ${AZ_SUBSCRIPTION}"
	az account set -s $(AZ_SUBSCRIPTION)

set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teacher Training and Qualifications", "Product" : "Find postgraduate teacher training", "Service Line": "Teaching Workforce", "Service": "Teacher services", "Service Offering": "Find postgraduate teacher training", "Environment" : "$(ENV_TAG)"}' | jq . ))

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
