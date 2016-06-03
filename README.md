# OpenShift 3 CI/CD Demo

This repository includes the infrastructure and pipeline definition for continuous delivery using Jenkins, Nexus and SonarQube on OpenShift.

# Setup

Create a new project for CI/CD components

  ```
  $ oc new-project ci
  $ oc policy add-role-to-user view -z default
  ```

Create the CI/CD compoentns based on the provided template

  ```
  $ oc process -f cicd-template.yaml | oc create -f -
  ```

Create Dev and Stage projects for Tasks JAX-RS application

  ```
  $ oc new-project dev --display-name="Tasks - Dev"
  $ oc new-project stage --display-name="Tasks - Stage"
  ```

Create the Tasks JAX-RS applications in Dev and Stage projects
  ```
  $ oc new-app jboss-eap64-openshift~https://github.com/siamaksade/openshift-tasks.git --name=tasks -n dev
  $ oc expose svc/tasks -n dev

  $ oc new-app jboss-eap64-openshift~https://github.com/siamaksade/openshift-tasks.git --name=tasks -n stage
  $ oc expose svc/tasks -n stage
  ```

OpenShift immediately starts a build for each project. Optionally you can cancel those builds since we will trigger the builds from Jenkins.
  ```
  $ oc cancel-build tasks-1 -n dev
  $ oc cancel-build tasks-1 -n stage
  ```

Jenkins needs to access OpenShift API to discover slave images as well accessing container images. Grant Jenkins service account enough privileges to invoke OpenShift API for the created projects:

  ```
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n ci
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n dev
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n stage
  ```

# Demo Guide

Jenkins has the Pipeline plugin pre-installed. A Jenkins pipeline job is also pre-configured which clones Tasks JAX-RS application source code from GitHub, builds, deploys and promotes the result through the deployment pipeline. The following diagram shows the steps included in the deployment pipeline:

![](https://raw.githubusercontent.com/siamaksade/openshift-cd-demo/openshift-3.x/images/pipeline.png)

Run an instance of the pipeline by starting the _tasks-cd-pipeline_ job.
