CONFIG=production
CONFIG_SHORT=pd
ENV_SHORT=${CONFIG_SHORT}
AZ_SUBSCRIPTION=s189-teacher-services-cloud-production
AZURE_SUBSCRIPTION=${AZ_SUBSCRIPTION}
RESOURCE_PREFIX=s189p01
ENV_TAG=Prod
DNS_ZONE=ftt
RESOURCE_GROUP_NAME=${RESOURCE_PREFIX}-${DNS_ZONE}domains-rg
KEYVAULT_NAME=${RESOURCE_PREFIX}-${DNS_ZONE}domains-kv
STORAGE_ACCOUNT_NAME=${RESOURCE_PREFIX}${DNS_ZONE}domainstf
DOMAINS_ID=find
RUN_TERRAFILE=yes
