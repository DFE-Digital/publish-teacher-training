CONFIG=production
CONFIG_SHORT=pd
ENV_SHORT=${CONFIG_SHORT}
AZ_SUBSCRIPTION=s189-teacher-services-cloud-production
AZURE_SUBSCRIPTION=${AZ_SUBSCRIPTION}
RESOURCE_NAME_PREFIX=s189p01
DNS_ZONE=ptt
RESOURCE_GROUP_NAME=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg
KEYVAULT_NAME=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv
STORAGE_ACCOUNT_NAME=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf
DOMAINS_ID=publish
RUN_TERRAFILE=yes
