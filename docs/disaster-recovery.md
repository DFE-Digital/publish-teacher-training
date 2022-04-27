# Disaster recovery


This documentation covers one scenario:

- [Loss of database instance](#loss-of-database-instance)

In case of any above database disaster, please do the following:

### Freeze pipeline

Alert all developers that no one should merge to main branch.

### Maintenance mode

If the database is unavailable then the API application will return a 500 response.

In the instance of data loss, if the application is unavailable, ##TO DO: find out what the application does
If the application is still available and there is a risk of users adding data, enable [Maintenance mode](maintenance-mode.md).

### Set up a virtual meeting

Set up virtual meeting via Zoom, Slack, Teams or Google Hangout, inviting all the relevant technical stakeholders. Regularly provide updates on
the #twd_publish Slack channel to keep product owners abreast of developments.

### Internet Connection

Ensure whoever is executing the process has a reliable and reasonably fast Internet connection.

## Loss of database instance

In case the database instance is lost, the objectives are:

- Recreate the lost postgres database instance
- Restore data from nightly backup stored in Azure.  The point-in-time and snapshot backups created by the PaaS Postgres service will not be available if it's been deleted.

### Recreate the lost postgres database instance

Please note, this process should take about 5 mins* to complete. In case the database service is deleted or in an inconsistent state we must recreate it and repopulate it.
First make sure it is fully gone by running

```
cf services | grep teacher-training-api
# check output for lost or corrupted instance
cf delete-service <instance-name>
```
Then recreate the lost postgres database instance using the following make recipes `deploy-plan` and `deploy`.  To see the proposed changes:

```
TAG=$(cf app teacher-training-api-prod | grep -Po "docker image:\s+\S+:\K\w+")
make <env> deploy-plan passcode=<my-passcode> IMAGE_TAG=${TAG}
```
To apply proposed changes i.e. create new database instance:
```
TAG=$(cf app teacher-training-api-prod | grep -Po "docker image:\s+\S+:\K\w+")
make <env> deploy-plan passcode=<my-passcode> CONFIRM_RESTORE=YES IMAGE_TAG=${TAG}
```
This will create a new postgres database instance as described in the terraform configuration file.

\* based on ~2 min restore time of sanitised db and ~5 min restore time when testing process in QA

### Restore Data From Nightly Backup

Once the lost database instance has been recreated, the last nightly backup will need to be restored. To achieve this, use the following makefile recipe: `restore-data-from-nightly-backup`. The following will need to be set: `passcode` (a [GOV.UK PaaS one-time passcode](https://login.london.cloud.service.gov.uk/passcode)), `CONFIRM_PRODUCTION=YES`,  `CONFIRM_RESTORE=YES` and `BACKUP_DATE="yyyy-mm-dd"`.  You will need to be logged into GovUK PaaS and Azure using the `az` and `cf` CLIs.

```
make production restore-data-from-nightly-backup CONFIRM_PRODUCTION=YES CONFIRM_RESTORE=YES BACKUP_DATE="yyyy-mm-dd"
```

This will download the latest daily backup from Azure Storage and then populate the new database with data.  If more than one backup has been created on the date specified the script will select the most recent from that date.
