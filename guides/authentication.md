# Authentication

## Find

The Find service is publicly available. We are in the process of looking into adding candidate accounts via GOV.UK One Login.

## Publish

### Basic Auth

The Publish QA and Review environments are protected by basic auth. The username and password can be provided by a Find/Publish team member.

### DfE Sign in

To access the staging and production environments, you will need to sign in with DfE Sign-in.

If you need to test DfE Sign In before release, 

1. Enable `mode: dfe_signin` as the authentication mode in config/settings/qa.yml
2. Run the "Deploy" workflow and deploy your branch to QA (Use worflow from: 'main')

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
**For this method, you must have Azure production access.**
**There will need to be a hold on merges for the duration of the incident, or the mode will be overwritten.**

- Use kubectl to list the configmaps: `kubectl -n bat-production get cm`. Copy the name of the one starting with "ptt-production".
- Edit the configmap: `kubectl -n bat-production edit cm <configmap>`
- Set the authentication mode: `SETTINGS__AUTHENTICATION__MODE: magic_link`
- Restart the app by running: `kubectl -n bat-production rollout restart deployment publish-production`

When the incident is over, you can reset the authentication method to DfE Sign in and restage using the same commands, but with the value: `SETTINGS__AUTHENTICATION__MODE: dfe_signin`.

Alternatively you can simply begin merging PRs again which will reset the authentication mode.

## API

The API is public and does not require authentication.
