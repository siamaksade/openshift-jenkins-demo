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

Create a new project for CI/CD components

  ```
  $ oc new-project ci --display-name="CI/CD"
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

Jenkins needs to access OpenShift API to discover slave images as well accessing container images. Grant Jenkins service account enough privileges to invoke OpenShift API for the created projects:

  ```
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n ci
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n dev
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n stage
  ```

# Demo Guide

Jenkins has the Pipeline plugin pre-installed. A Jenkins pipeline job is also pre-configured which clones Tasks JAX-RS application source code from GitHub, builds, deploys and promotes the result through the deployment pipeline. Run an instance of the pipeline by starting the _tasks-cd-pipeline_ job.
