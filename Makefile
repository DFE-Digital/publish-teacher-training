ifndef VERBOSE
.SILENT:
endif

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

review:
	$(eval DEPLOY_ENV=review)
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a name for your review app))
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval backend_key=-backend-config=key=pr-$(APP_NAME).tfstate)
	$(eval export TF_VAR_paas_app_environment=review-$(APP_NAME))
	$(eval export TF_VAR_paas_web_app_host_name=$(APP_NAME))
	$(eval space=bat-qa)
	$(eval paas_env=pr-$(APP_NAME))
	$(eval backup_storage_secret_name=TTAPI-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)
	echo https://teacher-training-api-review-pr-$(APP_NAME).london.cloudapps.digital will be created in bat-qa space

.PHONY: qa
qa: ## Set DEPLOY_ENV to qa
	$(eval DEPLOY_ENV=qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval space=bat-qa)
	$(eval paas_env=qa)
	$(eval backup_storage_secret_name=TTAPI-STORAGE-ACCOUNT-CONNECTION-STRING-DEVELOPMENT)

.PHONY: staging
staging: ## Set DEPLOY_ENV to staging
	$(eval DEPLOY_ENV=staging)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)
	$(eval space=bat-staging)
	$(eval paas_env=staging)

.PHONY: sandbox
sandbox: ## Set DEPLOY_ENV to sandbox
	$(eval DEPLOY_ENV=sandbox)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval space=bat-prod)
	$(eval paas_env=sandbox)

.PHONY: production
production: ## Set DEPLOY_ENV to production
	$(eval DEPLOY_ENV=production)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))
	$(eval space=bat-prod)
	$(eval paas_env=prod)
	$(eval PARTIAL_HOSTNAME=www)
	$(eval backup_storage_secret_name=TTAPI-STORAGE-ACCOUNT-CONNECTION-STRING-PRODUCTION)

.PHONY: loadtest
loadtest: ## Set DEPLOY_ENV to loadtest
	$(eval DEPLOY_ENV=loadtest)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval space=bat-qa)
	$(eval paas_env=loadtest)

.PHONY: ci
ci:	## Run in automation environment
	$(eval export DISABLE_PASSCODE=true)
	$(eval export AUTO_APPROVE=-auto-approve)

.PHONY: rollover
rollover: ## Set DEPLOY_ENV to rollover
	$(eval DEPLOY_ENV=rollover)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval space=bat-prod)
	$(eval paas_env=rollover)

deploy-init:
	$(if $(IMAGE_TAG), , $(eval export IMAGE_TAG=main))
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_cf_sso_passcode=$(PASSCODE))
	$(eval export TF_VAR_paas_docker_image=ghcr.io/dfe-digital/publish-teacher-training:$(IMAGE_TAG))
	$(eval export TF_VAR_paas_app_secrets_file=./workspace_variables/app_secrets.yml)
	az account set -s ${AZ_SUBSCRIPTION} && az account show
	cd terraform && \
		terraform init -reconfigure -backend-config=workspace_variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key)
	echo "🚀 DEPLOY_ENV is $(DEPLOY_ENV)"

deploy-plan: deploy-init
	cd terraform && terraform plan -var-file=workspace_variables/$(DEPLOY_ENV).tfvars.json

deploy: deploy-init
	cd terraform && terraform apply -var-file=workspace_variables/$(DEPLOY_ENV).tfvars.json $(AUTO_APPROVE)

destroy: deploy-init
	cd terraform &&	terraform destroy -var-file=workspace_variables/$(DEPLOY_ENV).tfvars.json $(AUTO_APPROVE)

install-fetch-config:
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

read-deployment-config:
	$(eval export postgres_database_name=teacher-training-api-postgres-${paas_env})

read-keyvault-config:
	$(eval export key_vault_name=$(shell jq -r '.key_vault_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_app_secret_name=$(shell jq -r '.key_vault_app_secret_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_infra_secret_name=$(shell jq -r '.key_vault_infra_secret_name' terraform/workspace_variables/$(DEPLOY_ENV).tfvars.json))

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
	cf ssh teacher-training-api-${paas_env} -t -c "cd /app && /usr/local/bin/bundle exec rails c"

enable-maintenance: ## make qa enable-maintenance / make prod enable-maintenance CONFIRM_PRODUCTION=y
	$(if $(PARTIAL_HOSTNAME), $(eval API_HOSTNAME_ARG=""), $(eval API_HOSTNAME_ARG="--hostname ${DEPLOY_ENV}"))
	$(if $(PARTIAL_HOSTNAME), $(eval PUBLISH_HOSTNAME=${PARTIAL_HOSTNAME}), $(eval PUBLISH_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	cd service_unavailable_page && cf push
	eval cf map-route ttapi-unavailable api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf map-route ttapi-unavailable publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}2
	echo Waiting 5s for route to be registered... && sleep 5
	eval cf unmap-route teacher-training-api-${DEPLOY_ENV} api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf unmap-route teacher-training-api-${DEPLOY_ENV} publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}2

disable-maintenance: ## make qa disable-maintenance / make prod disable-maintenance CONFIRM_PRODUCTION=y
	$(if $(PARTIAL_HOSTNAME), $(eval API_HOSTNAME_ARG=""), $(eval API_HOSTNAME_ARG="--hostname ${DEPLOY_ENV}"))
	$(if $(PARTIAL_HOSTNAME), $(eval PUBLISH_HOSTNAME=${PARTIAL_HOSTNAME}), $(eval PUBLISH_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	eval cf map-route teacher-training-api-${DEPLOY_ENV} api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf map-route teacher-training-api-${DEPLOY_ENV} publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}2
	echo Waiting 5s for route to be registered... && sleep 5
	eval cf unmap-route ttapi-unavailable api.publish-teacher-training-courses.service.gov.uk ${API_HOSTNAME_ARG}
	cf unmap-route ttapi-unavailable publish-teacher-training-courses.service.gov.uk --hostname ${PUBLISH_HOSTNAME}2
	cf delete -rf ttapi-unavailable

restore-data-from-nightly-backup: read-deployment-config read-keyvault-config # make production restore-data-from-nightly-backup CONFIRM_PRODUCTION=YES CONFIRM_RESTORE=YES BACKUP_DATE="yyyy-mm-dd"
	bin/download-nightly-backup ${backup_storage_secret_name} ${key_vault_name} ${paas_env}-db-backup ${paas_env}_backup- ${BACKUP_DATE}
	$(if $(CONFIRM_RESTORE), , $(error Restore can only run with CONFIRM_RESTORE))
	bin/restore-nightly-backup ${space} ${postgres_database_name} ${paas_env}_backup- ${BACKUP_DATE}

upload-review-backup: read-deployment-config read-keyvault-config # make review upload-review-backup BACKUP_DATE=2022-06-10 APP_NAME=1234
	bin/upload-review-backup ${backup_storage_secret_name} ${key_vault_name} ${paas_env}-db-backup ${paas_env}_backup-${BACKUP_DATE}.sql.tar.gz

backup-review-database: read-deployment-config # make review backup-review-database APP_NAME=1234
	bin/backup-review-database ${postgres_database_name} ${paas_env}

get-image-tag:
	$(eval export TAG=$(shell cf target -s ${space} 1> /dev/null && cf app teacher-training-api-${paas_env} | grep -Po "docker image:\s+\S+:\K\w+"))
	@echo ${TAG}

get-postgres-instance-guid: ## Gets the postgres service instance's guid make qa get-postgres-instance-guid
	$(eval export DB_INSTANCE_GUID=$(shell cf target -s ${space} 1> /dev/null && cf service teacher-training-api-postgres-${paas_env} --guid))
	@echo ${DB_INSTANCE_GUID}

rename-postgres-service: ## make qa rename-postgres-service
	cf target -s ${space} 1> /dev/null
	cf rename-service teacher-training-api-postgres-${paas_env} teacher-training-api-postgres-${paas_env}-old

remove-postgres-tf-state: deploy-init ## make qa remove-postgres-tf-state PASSCODE=xxxx
	cd terraform && terraform state rm module.paas.cloudfoundry_service_instance.postgres

set-restore-variables:
	$(if $(IMAGE_TAG), , $(error can only run with an IMAGE_TAG))
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make ${space} get-postgres-instance-guid`))
	$(if $(SNAPSHOT_TIME), , $(error can only run with BEFORE_TIME, eg SNAPSHOT_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_paas_docker_image=ghcr.io/dfe-digital/publish-teacher-training:$(IMAGE_TAG))
	$(eval export TF_VAR_paas_restore_from_db_guid=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_db_backup_before_point_in_time=$(SNAPSHOT_TIME))
	echo "Restoring teacher-training-api from $(TF_VAR_paas_restore_from_db_guid) before $(TF_VAR_paas_db_backup_before_point_in_time)"

restore-postgres: set-restore-variables deploy ##  make qa restore-postgres IMAGE_TAG=12345abcdef67890ghijklmnopqrstuvwxyz1234 DB_INSTANCE_GUID=abcdb262-79d1-xx1x-b1dc-0534fb9b4 SNAPSHOT_TIME="2021-11-16 15:20:00" PASSCODE=xxxxx
