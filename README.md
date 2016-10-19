# OpenShift 3 CI/CD Demo

This repository includes the infrastructure and pipeline definition for continuous delivery using Jenkins, Nexus and SonarQube on OpenShift. On every pipeline execution, the code goes through the following steps:

1. Code is cloned from Gogs, built, tested and analyzed for bugs and bad patterns
2. The WAR artifact is pushed to Nexus Repository manager
3. A Docker image (_tasks:latest_) is built based on the _Tasks_ application WAR artifact deployed on JBoss EAP 6
4. The _Tasks_ Docker image is deployed in a fresh new container in DEV project
5. If tests successful, the DEV image is tagged with the application version (_tasks:7.x_) in the STAGE project
6. The staged image is deployed in a fresh new container in the STAGE project

The following diagram shows the steps included in the deployment pipeline:

![](https://github.com/OpenShiftDemos/openshift-cd-demo/blob/openshift-3.3/images/pipeline.png)

The application used in this pipeline is a JAX-RS application which is available on GitHub and is imported into Gogs during the setup process:
[https://github.com/OpenShiftDemos/openshift-tasks](https://github.com/OpenShiftDemos/openshift-tasks/tree/eap-7)

# Setup

Follow these [instructions](https://github.com/OpenShiftDemos/openshift-cd-demo/tree/openshift-3.3/docs/oc-cluster.md) in order to create a local OpenShift cluster. Otherwise using your current OpenShift cluster, create the following projects for CI/CD components, Dev and Stage environments:

  ```
  oc new-project dev --display-name="Tasks - Dev"
  oc new-project stage --display-name="Tasks - Stage"
  oc new-project cicd --display-name="CI/CD"
  ```

Jenkins needs to access OpenShift API to discover slave images as well accessing container images. Grant Jenkins service account enough privileges to invoke OpenShift API for the created projects:

  ```
  oc policy add-role-to-user edit system:serviceaccount:cicd:default -n dev
  oc policy add-role-to-user edit system:serviceaccount:cicd:default -n stage
  ```
Create the CI/CD components based on the provided template

  ```
  oc process -f cicd-template.yaml | oc create -f -
  ```

__Note:__ you need ~6GB memory for running this demo.

# Guide

1. A Jenkins pipeline is pre-configured which clones Tasks application source code from Gogs (running on OpenShift), builds, deploys and promotes the result through the deployment pipeline. In the CI/CD project, click on _Builds_ and then _Pipelines_ to see the list of defined pipelines. If the [tech preview pipeline feature](https://docs.openshift.com/container-platform/3.3/install_config/web_console_customization.html#web-console-enable-tech-preview-feature) is not enabled on your OpenShift cluster, go directly to the pipelines section with this url: https://OPENSHIFT.MASTER/console/project/cicd/browse/pipelines

  Click on _tasks-pipeline_ and _Configuration_ and explore the pipeline definition.

  You can also explore the pipeline job in Jenkins by clicking on the Jenkins route url, logging in with the following credentials, clicking on _tasks-pipeline_ and _Configure_.

  __Jenkins credentials:__ _admin/password_  
  __Gogs credentials:__ _gogs/password_

2. Run an instance of the pipeline by starting the _tasks-pipeline_ in OpenShift or Jenkins.

3. During pipeline execution, verify a new Jenkins slave pod is created within _CI/CD_ project to execute the pipeline.

4. Pipelines pauses at _Deploy STAGE_ for approval in order to promote the build to the STAGE environment. Click on this step on the pipeline and then _Promote_.

5. After pipeline completion, demonstrate the following:
  * Explore the _snapshots_ repository in Nexus and verify _openshift-tasks_ is pushed to the repository
  * Explore SonarQube and verify a project is created with metrics, stats, code coverage, etc
  * Explore _Tasks - Dev_ project in OpenShift console and verify the application is deployed in the DEV environment
  * Explore _Tasks - Stage_ project in OpenShift console and verify the application is deployed in the STAGE environment  


6. Clone the _openshift-tasks_ git repository and using an IDE (e.g. JBoss Developer Studio), remove the ```@Ignore``` annotation from ```src/test/java/org/jboss/as/quickstarts/tasksrs/service/UserResourceTest.java``` test methods to enable the unit tests. Commit and push to the git repo.

7. Check out Jenkins, a pipeline instance is created and is being executed. The pipeline will fail during unit tests due to the enabled unit test.

8. Check out the failed unit and test ```src/test/java/org/jboss/as/quickstarts/tasksrs/service/UserResourceTest.java``` and run it in the IDE.

9. Fix the test by modifying ```src/main/java/org/jboss/as/quickstarts/tasksrs/service/UserResource.java``` and uncommenting the sort function in _getUsers_ method.

10. Run the unit test in the IDE. The unit test runs green. Commit and push the fix to the git repository and verify a pipeline instance is created in Jenkins and executes successfully.

![](https://github.com/OpenShiftDemos/openshift-cd-demo/blob/openshift-3.3/images/jenkins-pipeline.png)

# Enabling OpenShift 3.3 Pipelines with "oc cluster"
Pipeline in OpenShift 3.3 is a tech preview feature and disabled by default. The steps required to enable this feature is detailed in [OpenShift documentation](https://access.redhat.com/documentation/en/openshift-container-platform/3.3/paged/installation-and-configuration/chapter-29-customizing-the-web-console#web-console-enable-tech-preview-feature).

# Troubleshoot

* SonarQube sometimes fails to load quality profiles requires for static analysis. Scale down the SonarQube pod and its database to 0 and then scale them up to 1 again in order to re-initialize SonarQube.

* Downloading the images might take a while depending on the network. Remove the _install-gogs_ pod and re-create the app to retry Gogs initialization.

  ```
  $ oc delete pod install-gogs
  $ oc process -f cicd-template.yaml | oc create -f -

  pod "install-gogs" created
  Error from server: routes "jenkins" already exists
  Error from server: deploymentconfigs "jenkins" already exists
  Error from server: serviceaccounts "jenkins" already exists
  Error from server: rolebinding "jenkins_edit" already exists
  ...
  ```

* If the cicd-pipeline Jenkins job has disappeared, scale Jenkins pod to 0 and up to 1 again to force a job sync with OpenShift pipelines.

* If pipeline execution fails with ```error: no match for "jboss-eap70-openshift"```, import the jboss imagestreams in OpenShift.

  ```
  oc login -u system:admin
  oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json -n openshift
  ```
