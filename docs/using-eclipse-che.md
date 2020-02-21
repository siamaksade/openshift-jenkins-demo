## Eclipse Che Guide for CI/CD Demo

Here is a step-by-step guide for editing and pushing the code to the Gogs repository using Eclipse Che.

Click on Eclipse Che route url in the CI/CD project which takes you to the workspace administration page. Select the *Java Maven* stack. Under the *Projects* section, enter `openshift-tasks` as the *Project Name* and the following the Gogs repository URL as the Git repository URL (replace _gogs-hostname_ with your own Gogs URL):

`http://gogs:gogs@[gogs-hostname]/gogs/openshift-tasks.git`

Click on *Save* and then on *Create & Open* button to create and open your workspace.

![](../images/che-create-workspace.png?raw=true)

![](../images/che-workspace.png?raw=true)

You will be working on the `eap-7` branch of the Git repository. Click on the branch name on the left lower corner of the screen where it says `master` and then choose the `origin/eap-7` branch to switch your working branch to `eap-7` branch.

![](../images/che-select-git-ref.png?raw=true)

Follow the steps 6-10 in the above guide to edit the code in your workspace. 

![](../images/che-edit-file.png?raw=true)

Click on the `Source Control: Git` in the left sidebar to change to the source control explorer. From the `...` menu, click on `Commit All`. You can also use `Command + Shift + P` to open the commands palette and search for `Commit All`.

![](../images/che-commit.png?raw=true)

You will get a dialog asking if Che should add all modified resources for the commit. Click on *Yes*, enter a text as the commit message and then press enter.

![](../images/che-commit-all.png?raw=true)

As soon the changes are committed to the git repository, a new instances of pipeline gets triggers to test and deploy the code changes.








