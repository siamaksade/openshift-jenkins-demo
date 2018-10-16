## Eclipse Che Guide for CI/CD Demo

Here is a step-by-step guide for editing and pushing the code to the Gogs repository using Eclipse Che.

Click on Eclipse Che route url in the CI/CD project which takes you to the workspace administration page. Select the *Java* stack and click on the *Create* button to create a workspace for yourself.

![](../images/che-create-workspace.png?raw=true)

Once the workspace is created, click on *Open* button to open your workspace in the Eclipse Che in the browser.

![](../images/che-open-workspace.png?raw=true)

It might take a little while before your workspace is set up and ready to be used in your browser. Once it's ready, click on **Import Project...** in order to import the `openshift-tasks` Gogs repository into your workspace.

![](../images/che-import-project.png?raw=true)

Enter the Gogs repository HTTPS url for `openshift-tasks` as the Git repository url with Git username and password in the 
url: <br/>
`http://gogs:gogs@[gogs-hostname]/gogs/openshift-tasks.git`

 You can find the repository url in Gogs web console. Make sure the check the **Branch** field and enter `eap-7` in order to clone the `eap-7` branch which is used in this demo. Click on **Import**

![](../images/che-import-git.png?raw=true)

Change the project configuration to  **Maven** and then click **Save**

![](../images/che-import-maven.png?raw=true)

Configure you name and email to be stamped on your Git commity by going to **Profile > Preferences > Git > Committer**.

![](../images/che-configure-git-name.png?raw=true)

Follow the steps 6-10 in the above guide to edit the code in your workspace. 

![](../images/che-edit-file.png?raw=true)

In order to run the unit tests within Eclipse Che, wait till all dependencies resolve first. To make sure they are resolved, run a Maven build using the commands palette icon or by clicking on **Run > Commands Palette > build**. 

Make sure you run the build again, after fixing the bug in the service class.

Run the unit tests in the IDE after you have corrected the issue by right clicking on the unit test class and then **Run Test > Run JUnit Test**

![](../images/che-run-tests.png?raw=true)

![](../images/che-junit-success.png?raw=true)


Click on **Git > Commit** to commit the changes to the `openshift-tasks` git repository. Make sure **Push committed changes to ...** is checked. Click on **Commit** button.

![](../images/che-commit.png?raw=true)

As soon the changes are committed to the git repository, a new instances of pipeline gets triggers to test and deploy the 
code changes.