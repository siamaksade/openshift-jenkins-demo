*For other versions of OpenShift, follow the instructions in the corresponding branch e.g. ocp-3.7, origin-3.7, etc*

# CI/CD Demo - OpenShift Container Platform 3.7

This repository includes the infrastructure and pipeline definition for continuous delivery using Jenkins, Nexus and SonarQube on OpenShift. On every pipeline execution, the code goes through the following steps:

1. Code is cloned from Gogs, built, tested and analyzed for bugs and bad patterns
2. The WAR artifact is pushed to Nexus Repository manager
3. A container image (_tasks:latest_) is built based on the _Tasks_ application WAR artifact deployed on JBoss EAP 6
4. The _Tasks_ container image is deployed in a fresh new container in DEV project
5. If tests successful, the DEV image is tagged with the application version (_tasks:7.x_) in the STAGE project
6. The staged image is deployed in a fresh new container in the STAGE project

The following diagram shows the steps included in the deployment pipeline:

![](images/pipeline.png?raw=true)

The application used in this pipeline is a JAX-RS application which is available on GitHub and is imported into Gogs during the setup process:
[https://github.com/OpenShiftDemos/openshift-tasks](https://github.com/OpenShiftDemos/openshift-tasks/tree/eap-7)

# Prerequisites
* 8+ GB memory for OpenShift (10+ GB memory if using SonarQube)
* JBoss EAP 7 imagestreams imported to OpenShift (see Troubleshooting section for details)

# Setup on RHPDS

If you have access to RHPDS, provisioning of this demo is automated via the service catalog under **OpenShift Demos &rarr; OpenShift CI/CD for Monolith**. If you don't know what RHPDS is, read the instructions in the next section.

# Setup on OpenShift (Script)
You can se the `scripts/provision.sh` script provided to deploy the entire demo:

  ```
  ./provision.sh --help
  ./provision.sh deploy --with-sonar --ephemeral
  ./provision.sh delete
  ```
  
# Setup on OpenShift (Manual)
Follow these [instructions](docs/local-cluster.md) in order to create a local OpenShift cluster. Otherwise using your current OpenShift cluster, create the following projects for CI/CD components, Dev and Stage environments:

  ```shell
  # Create Projects
  oc new-project dev --display-name="Tasks - Dev"
  oc new-project stage --display-name="Tasks - Stage"
  oc new-project cicd --display-name="CI/CD"

  # Grant Jenkins Access to Projects
  oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n dev
  oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n stage
  ```
OpenShift 3.7 by default uses an older version of Jenkins. Import a newer Jenkins image in order to use with this demo:
  ```
  oc login -u system:admin
  oc import-image jenkins:v3.7 --from="registry.access.redhat.com/openshift3/jenkins-2-rhel7" --confirm -n openshift
  oc tag jenkins:v3.7 jenkins:latest -n openshift
  ```
  
You can choose to use either SonarQube for static code and security analysis or instead use Maven plugins 
and generated reports within the Jenkins:

  ```
  # Deploy Pipeline with SonarQube
  oc new-app -n cicd -f cicd-template.yaml

  # Deploy Pipeline without SonarQube
  oc new-app -n cicd -f cicd-template.yaml --param=WITH_SONAR=false
  ```

To use custom project names, change `cicd`, `dev` and `stage` in the above commands to
your own names and use the following to create the demo:

  ```shell
  oc new-app -n cicd -f cicd-template.yaml --param DEV_PROJECT=dev-project-name --param STAGE_PROJECT=stage-project-name
  ```

# Guide

1. A Jenkins pipeline is pre-configured which clones Tasks application source code from Gogs (running on OpenShift), builds, deploys and promotes the result through the deployment pipeline. In the CI/CD project, click on _Builds_ and then _Pipelines_ to see the list of defined pipelines.

    Click on _tasks-pipeline_ and _Configuration_ and explore the pipeline definition.

    You can also explore the pipeline job in Jenkins by clicking on the Jenkins route url, logging in with the OpenShift credentials and clicking on _tasks-pipeline_ and _Configure_.

2. Run an instance of the pipeline by starting the _tasks-pipeline_ in OpenShift or Jenkins.

3. During pipeline execution, verify a new Jenkins slave pod is created within _CI/CD_ project to execute the pipeline.

4. Pipelines pauses at _Deploy STAGE_ for approval in order to promote the build to the STAGE environment. Click on this step on the pipeline and then _Promote_.

5. After pipeline completion, demonstrate the following:
  * Explore the _snapshots_ repository in Nexus and verify _openshift-tasks_ is pushed to the repository
  * Explore SonarQube or pipeline in Jenkins and show the metrics, stats, code coverage, etc
  * Explore _Tasks - Dev_ project in OpenShift console and verify the application is deployed in the DEV environment
  * Explore _Tasks - Stage_ project in OpenShift console and verify the application is deployed in the STAGE environment  

![](images/jenkins-analysis.png?raw=true)

6. Clone and checkout the _eap-7_ branch of the _openshift-tasks_ git repository and using an IDE (e.g. JBoss Developer Studio), remove the ```@Ignore``` annotation from ```src/test/java/org/jboss/as/quickstarts/tasksrs/service/UserResourceTest.java``` test methods to enable the unit tests. Commit and push to the git repo.

7. Check out Jenkins, a pipeline instance is created and is being executed. The pipeline will fail during unit tests due to the enabled unit test.

8. Check out the failed unit and test ```src/test/java/org/jboss/as/quickstarts/tasksrs/service/UserResourceTest.java``` and run it in the IDE.

9. Fix the test by modifying ```src/main/java/org/jboss/as/quickstarts/tasksrs/service/UserResource.java``` and uncommenting the sort function in _getUsers_ method.

10. Run the unit test in the IDE. The unit test runs green. Commit and push the fix to the git repository and verify a pipeline instance is created in Jenkins and executes successfully.

![](images/openshift-pipeline.png?raw=true)

# Troubleshoot

* If pipeline execution fails with ```error: no match for "jboss-eap70-openshift"```, import the jboss imagestreams in OpenShift.

  ```
  oc login -u system:admin
  oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json -n openshift
  ```

* If you get this maven error during the static analysis, you are running out of memory and need more memory for OpenShift: 
  ```
  [Static Analysis] /opt/rh/rh-maven33/root/usr/bin/mvn: line 9:   298 Killed
  ``` 
