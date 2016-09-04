# OpenShift 3 CI/CD Demo

This repository includes the infrastructure and pipeline definition for continuous delivery using Jenkins, Nexus and SonarQube on OpenShift. On every pipeline execution, the code goes through the following steps:

1. Code is cloned from Git, built, tested and analyzed for bugs and bad patterns
2. The WAR artifact is pushed to Nexus Repository manager
3. A Docker image (_tasks:latest_) is built based on the _Tasks_ application WAR artifact deployed on JBoss EAP 6
4. The _Tasks_ Docker image is deployed in a fresh new container in DEV project
5. If tests successful, the DEV image is tagged with the application version (_tasks:6.4.0_) in the STAGE project
6. The staged image is deployed in a fresh new container in the STAGE project

The following diagram shows the steps included in the deployment pipeline:

![](https://raw.githubusercontent.com/OpenShiftDemos/openshift-cd-demo/master/images/pipeline.png)

# Setup

Create projects for CI/CD components and also DEV and STAGE environments:

  ```
  $ oc new-project dev --display-name="Tasks - Dev"
  $ oc new-project stage --display-name="Tasks - Stage"
  $ oc new-project cicd --display-name="CI/CD"
  ```

Create the CI/CD compoentns based on the provided template. Note that about ~10GB memory is required for all the containers provisioned in this demo.

  ```
  $ oc process -f cicd-gogs-template.yaml | oc create -f -
  ```

Jenkins needs to access OpenShift API to discover slave images as well accessing container images. Grant Jenkins service account enough privileges to invoke OpenShift API for the created projects:

  ```
  $ oc policy add-role-to-user edit system:serviceaccount:cicd:default -n cicd
  $ oc policy add-role-to-user edit system:serviceaccount:cicd:default -n dev
  $ oc policy add-role-to-user edit system:serviceaccount:cicd:default -n stage
  ```

# Demo Guide

1. RunJenkins has the Pipeline plugin pre-installed. A Jenkins pipeline job is also pre-configured which clones Tasks JAX-RS application source code from GitHub, builds, deploys and promotes the result through the deployment pipeline. Click on ```tasks-cd-pipeline``` and _Configure_ and explore the pipeline definition.

2. Run an instance of the pipeline by starting the ```tasks-cd-pipeline``` job.

3. During pipeline execution, verify a new Jenkins slave pod is created within the _CI/CD_ project to execute the pipeline. Pipeline executions suspends at STAGE phase, and waits for the deployment managers approval to proceed. Click on on _Deploy to STAGE_ step on the pipeline and then _Promote_.

![](https://raw.githubusercontent.com/OpenShiftDemos/openshift-cd-demo/master/images/jenkins-pipeline-input.png)

4. After pipeline completion, demonstrate the following:
  * Explore the ```snapshots``` repository in Nexus and verify ```openshift-tasks``` is pushed to the repository
  * Explore SonarQube and verify a project is created with metrics, stats, code coverage, etc
  * Explore _Tasks - Dev_ project in OpenShift console and verify the application is deployed in the DEV environment
  * Explore _Tasks - Stage_ project in OpenShift console and verify the application is deployed in the STAGE environment  

5. Clone the ```openshift-tasks``` git repository from Gogs and using an IDE (e.g. JBoss Developer Studio), remove the ```@Ignore``` annotation from ```src/test/java/org/jboss/as/quickstarts/tasksrs/service/UserResourceTest.java``` test methods to enable the unit tests. Commit and push to the git repo. Pipeline gets triggered via a webhook that is defined on the git repository in Gogs.

6. Check out Jenkins, a pipeline instance is created and is being executed. The pipeline will fail during unit tests due to the enabled unit test.

7. Check out the failed unit and test ```src/test/java/org/jboss/as/quickstarts/tasksrs/service/UserResourceTest.java``` and run it in the IDE.

8. Fix the test by modifying ```src/main/java/org/jboss/as/quickstarts/tasksrs/service/UserResource.java``` and uncommenting the sort function in ```getUsers``` method.

9. Run the unit test in the IDE. The unit test runs green. Commit and push the fix to the git repository and verify a pipeline instance is created in Jenkins and executes successfully.

![](https://raw.githubusercontent.com/OpenShiftDemos/openshift-cd-demo/master/images/jenkins-pipeline.png)
