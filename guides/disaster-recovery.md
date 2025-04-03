# Postgres Disaster recovery

This document is a condensed version of the general guidelines for handling incidents involving partial or complete disaster striking the postgres database in Publish.

Be sure to review the general documentation maintained by Teacher Services if this is the first document you've reviewed.

 - [GDS Disaster recovery strategy].
 - [Disasters within Teacher services].
 - [Teacher services incident playbook]


[GDS Disaster recovery strategy]: https://gds-way.digital.cabinet-office.gov.uk/standards/incident-management.html#how-to-manage-technical-incidents
[Disasters within Teacher services]: https://github.com.mcas.ms/DFE-Digital/teacher-services-cloud/blob/main/documentation/disaster-recovery.md
[Teacher services incident playbook]: https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html#incident-playbook


## Initial steps for all situations

1. [Request a PIM approval!](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadgroup)
2. Inspect the database in the Azure portal 
    1. Go to the [Azure portal](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-ptt-pd-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/s189p01-ptt-pd-pg/overview)
    2. Check memory, CPU,  connections and throughput for any anomolies.
3. Start the incident process
    1. [Review the incident playbook](https://tech-docs.teacherservices.cloud/operating-a-service/incident-playbook.html) 
    2. Inform the Delivery and Product managers of the issue
4. Freeze the delivery pipeline to prevent merging and deployments 
    1. Increase minimum required reviews to merge - [GitHub settings - Branch protection rules](https://github.com/DFE-Digital/publish-teacher-training/settings/rules/2827787)
    2. If this is not done, a merge and deploy will remove the maintenance page
5. Enable Maintenance mode for the service 
    1. Run the [Enable maintenance](https://github.com/DFE-Digital/publish-teacher-training/actions/workflows/enable-maintenance.yml) workflow for the service and environment affected.
    2. Create a new branch off main locally
    3. In the [environment workspace variables](https://github.com/DFE-Digital/publish-teacher-training/blob/main/terraform/aks/workspace_variables/production.tfvars.json) set this value `"send_traffic_to_maintenance_page": true`
    4. Push the branch to GitHub
    5. Merge to main
    6. You'll need to undo this later
6. Test that maintenance mode is active and that the [temporary ingress URL](#temporary-ingress-urls) are accessible.
    1. Main: https://www.find-postgraduate-teacher-training.service.gov.uk/
    2. Ingress: https://find-temp.teacherservices.cloud/

## Database server is gone?

1. Create a new database server 
    1. Run the [Restore database from Azure storage workflow](https://github.com/DFE-Digital/publish-teacher-training/actions/workflows/postgres-restore.yml)
        1. Choose your new branch
        2. Choose the environment
        3. Choose `true` if the environment is production
        4. Leave the name blank, it will choose the latest scheduled db backup to restore
2. Once the workflow completes, use the [temporary ingress URLs](#temporary-ingress-urls) to confirm the app is restored correctly.

## Database is corrupted?

*Steps 2 & 3 can be run concurrently*

1. Scale down the service to stop more data corruption
    1. `kubectl -n bat-production get deployments`
    2. `kubectl -n bat-production scale deployment publish-production --replicas 0`
    3. `kubectl -n bat-production scale deployment publish-production --replicas 0`
2. [Take a backup of the live database](https://github.com/DFE-Digital/publish-teacher-training/actions/workflows/database-restore.yml)
    a. *When run manually, this workflow only does a backup of the database, not restore to other environments*
    b. This will be used in the incident review later.
    c. Give the backup a name and make a note of it for restoration. `ptt_[env]_adhoc_YYYY-MM-DD`
    d. The current production postgres server name is `s189p01-ptt-pd-pg`
    e. Once the workflow completes, the backup is stored in [Azure Storage here](https://portal.azure.com/?feature.msaljs=true#view/Microsoft_Azure_Storage/ContainerMenuBlade/~/overview/storageAccountId/%2Fsubscriptions%2F3c033a0c-7a1c-4653-93cb-0f2a9f57a391%2FresourceGroups%2Fs189p01-ptt-pd-rg%2Fproviders%2FMicrosoft.Storage%2FstorageAccounts%2Fs189p01pttdbbkppdsa/path/database-backup/etag/%220x8DB7D564A729C8E%22/defaultEncryptionScope/%24account-encryption-key/denyEncryptionScopeOverride~/false/defaultId//publicAccessVal/None)
3. Restore the live server to a new server at a Point in Time. You should know the exact minute to restore to.
    1. [Restore to Point in Time](https://github.com/DFE-Digital/publish-teacher-training/actions/workflows/postgres-ptr.yml)
        1. This workflow will create a new database server and restore the backup data into it.
        2. **Branch:** main
        3. **Environment:** production
        4. **Production?:** true
        5. **Time:** *One minute before the corruption happened* e.g. 2024-07-24T06:00:00
        6. **Name:** (defaults to `s189p01-ptt-pd-pg`)
        7. Once this completes, use tools to inspect the data in the database.
4. Validate that the PTR restore worked, that the data is correct and the problem resolved. (Be extremely careful)
    1. Install `konduit.sh` locally using the `make` command
    2. Connect to the PTR: `bin/konduit.sh -x -n bat-production -s s189p01-ptt-pd-pg-ptr publish_production -- psql`
    3. Connect to the live server: `bin/konduit.sh -x -n bat-production -s s189p01-ptt-pd-pg publish-production -- psql`
5. Now take a backup of the restored PTR database. This will be used to replace the production database.
    1. [Take a backup of the PTR database](https://github.com/DFE-Digital/publish-teacher-training/actions/workflows/database-restore.yml)
        1. **Branch:** main
        2. **Environment:** production
        3. **Backup filename:** `ptt_prod_YYYY-MM-DD-restore-to-ptr`
        4. **DB server name:** `s189p01-ptt-pd-pg-ptr`
6. Backup the PTR database server
    a. 

## Complete the process

1. Run [*Disable maintenance*](https://github.com/DFE-Digital/publish-teacher-training/actions/workflows/disable-maintenance.yml)
2. Check that the app is available at the primary URL
3. Unfreeze the pipeline

## Temporary ingress URLs

### Prod

| Service | URL                                                                                                |
| ------- | -------------------------------------------------------------------------------------------------- |
| Find    | [https://find-temp.teacherservices.cloud/](https://find-temp.teacherservices.cloud/)               |
| Publish | [https://publish-temp.teacherservices.cloud/](https://publish-temp.teacherservices.cloud/)         |
| API     | [https://api-publish-temp.teacherservices.cloud/](https://api-publish-temp.teacherservices.cloud/) |

### QA

| Service | URL                                                                                                          |
| ------- | ------------------------------------------------------------------------------------------------------------ |
| Find    | [https://find-temp.test.teacherservices.cloud/](https://find-temp.test.teacherservices.cloud/)               |
| Publish | [https://publish-temp.test.teacherservices.cloud/](https://publish-temp.test.teacherservices.cloud/)         |
| API     | [https://api-publish-temp.test.teacherservices.cloud/](https://api-publish-temp.test.teacherservices.cloud/) |

