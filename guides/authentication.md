# Authentication

## Find

The Find service is publicly available with one or two internal routes protected by basic auth.

### Basic Auth

The feature flags route in Find is protected by basic auth. The username and password are set in the `SETTINGS__BASIC_AUTH_USERNAME` and `SETTINGS__BASIC_AUTH_PASSWORD` environment variables.

## Publish

### Basic Auth

The Publish QA environment is protected by basic auth. The username and password can be provided by a Find/Publish team member.

### DfE Sign in

To access the staging and production environments, you will need to sign in with DfE Sign-in.

### Magic Link Sign in

In the event that DfE Sign-in is unavailable, we enable sign in via magic link. There are three ways this can be achieved.

1) The easiest way is to raise a PR with the new authentication mode in `settings.yml`. The authentication mode is already there, it just needs to be uncommented. E.G

```
authentication:
  mode: magic_link
```

Please be aware that this method requires CI to run, so will take some time. 

2) If you are unable to merge the PR, you can manually deploy the commit sha by following the steps below. 
**There will need to be a hold on merges for the duration of the incident, or the mode will be overwritten.**

- Raise a PR to set the authentication mode to `magic_link` as shown in step 1

- Copy the commit sha of the PR above and go to the Github actions tab

- Under actions on the left hand side, click on 'Deploy'

- On the right, click the dropdown which says 'Run workflow', choose `production` as the `Environment to deploy to` and
paste the commit sha in the second box

- Click the green `Run workflow` button


3) The final method you can use is to SSH into the production box. To do this, follow the steps below. 
**For this method, you must have CF production access.**
**There will need to be a hold on merges for the duration of the incident, or the mode will be overwritten.**

- Navigate to the app in the terminal, authenticate yourself using `cf login` and choose the `bat-prod` space.
- Set the authentication mode by running: `cf set-env publish-teacher-training-prod SETTINGS__AUTHENTICATION__MODE  magic_link`
- Restage the app by running: `cf restage publish-teacher-training-prod` (there will be a very brief period of downtime, lasting a few seconds)

When the incident is over, you can reset the authentication method to DfE Sign in and restage using the commands below (there will be a brief period of downtime, lasting a few seconds). Alternatively you can simply begin merging PRs again which will reset the authentication mode.

- `cf set-env publish-teacher-training-prod SETTINGS__AUTHENTICATION__MODE  dfe_signin`
- `cf restage publish-teacher-training-prod`

## API

The API is public and does not require authentication.
