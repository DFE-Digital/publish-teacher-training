# Deploying Find - Manage Courses App - Step by Step Guide 

All members of the Find development team are able to deploy into any of the environments.

## 1. Check what you're deploying

Go to the Find Build pipelines [Frontend](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=29) & [Backend](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build?definitionId=46)  and identify the commit you want to deploy. It is advisable to make note of the build id at this stage. 

Make sure to check the diff on GitHub to see if there's anything risky.

You also have to make sure that you're deploying only work that has been product reviewed and approved for deployment. 
See "To Deploy" colum on the  [Find Team board](https://trello.com/b/fXA6ioZN/team-board-find-team)
The "Product Review" column on the [Find Team board](https://trello.com/b/fXA6ioZN/team-board-find-team) should be empty.

## 2. Tell the team ![](https://www.webfx.com/tools/emoji-cheat-sheet/graphics/emojis/loudspeaker.png)

Summarise what you're deploying and tell the team in Slack on the `#twd_find` channel. Use ![](https://www.webfx.com/tools/emoji-cheat-sheet/graphics/emojis/rotating_light.png)  `:alert:`  and  ![](https://www.webfx.com/tools/emoji-cheat-sheet/graphics/emojis/loudspeaker.png)`:loudspeaker:` as required.


## 3. Deploy to staging

1. Load the [Find Postgraduate Teacher Training release pipeline](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_release?_a=releases&view=mine&definitionId=36)  in Azure DevOps.
2. Click the blue `:rocket:` "Create Release" button  at the top right of the page which will open "Create a new release" sub-menu. 
3. [Optional] Deselect the stages that you wish to run manually by changing its trigger from automated to manual. Release is made up of several stages i.e. backend, frontend, integration test. 
4. Under Artifacts section, master branch build artifacts should be already selected from the drop down list by default. Should you wish to change this select the version for the artifact sources for `manage-courses-backend`  and `manage-courses-frontend` drop down list.
5. [Optional] Specify release description.
6. Click the Create button to create the deployment.
7. Lastly, approve your deployment by clicking on "Approve" button. Find development team members have sufficient rights to approve deployments. 

## 4. Test on staging

Integration test stage is automatically triggered after frontend deployment. 
Take neccessary actions to test what you've just deployed. Be sure to keep an eye on Sentry for any incoming issues.
[Sentry - Frontend](https://sentry.io/organizations/dfe-bat/issues/?project=1407453)
[Sentry - Backend](https://sentry.io/organizations/dfe-bat/issues/?project=1377944)

## 5. Deploy to production

1. Load the release that triggered staging deployment [Find Postgraduate Teacher Training release pipeline](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_release?_a=releases&view=mine&definitionId=36) in Azure DevOps.
2. Production deployment is configured to auto-trigger upon successful deployment of staging stage but requires a pre-deploymental approval.
3. Click on the blue "Pending Approval" (clock) icon to approve/reject the release. Specify the comments and approve the release to trigger deployment or reject to terminate the release.

## 6. Test on production

Wait until the deploy finishes and, if necessary, test on production.
Validate the production environment before declaring the deploy as complete.

## 7. Move deploy cards to done

Tell your team mates that their work has gone out, and move over all of the cards in "To deploy" to done on the [Find Team board](https://trello.com/b/fXA6ioZN/team-board-find-team).

## Rolling back

*Note that this advice does not apply if you are deploying changes to the Azure
infrastructure. For rollback to the changes made to the infrastructure, the only way to roll
back is to run a full redeploy.*

Because we operate blue/green deployments, the previous version of the app is
always available in the staging slot. To roll back to it, follow these
instructions.

1. [Obtain elevated permissions using Azure PIM](pim-guide.md)
2. Visit the "staging" slot of the application service by searching
for it in the Azure portal. e.g. for production, type s121p01-find-as/staging into the search bar at the top of the screen.
3. Start the staging container by clicking "start", identified by a triangular "play" icon at the top of the main pane
4. Wait for the service to start, checking it by visiting the slot URL, which is displayed at the top right of the main pane
5. Once the staging app is running, you can swap the slots so that the old (staging) version becomes the live version. To do this, click "swap" at the top of the main pane, identified by a pair of arrows pointing in opposite directions
6. Confirm using the dialog that appears that you would like to swap the slots

Once the swap is complete, the old version of the app will be running at the live URL.

You should then shut down the staging slot, which now contains the faulty
version of the code. 

To roll back to an earlier version, please redeploy using the instruction given above whilst ensuring correct older build/artifact is selected when creating a release.
