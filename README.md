# OpenShift 3 CI/CD Demo

This repository includes the infrastructure and pipeline definition for continuous delivery using Jenkins, Nexus and SonarQube on OpenShift.

# Setup

Create a new project for CI/CD components

  ```
  $ oc new-project ci
  ```

Create the CI/CD compoentns based on the provided template

  ```
  $ oc process -f cicd-template | oc create -f -
  ```

Create Dev and Stage projects for Tasks JAX-RS application

  ```
  $ oc new-project tasks-dev --display-name="Tasks - Dev"
  $ oc new-project tasks-stage --display-name="Tasks - Stage"
  ```

Jenkins needs to access OpenShift API to discover slave images as well accessing container images. Grant Jenkins service account enough privileges to invoke OpenShift API for the created projects:

  ```
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n ci
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n tasks-dev
  $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n tasks-stage
  ```

# Demo Guide

Jenkins has the Pipeline plugin pre-installed. A Jenkins pipeline job is also pre-configured which clones Tasks JAX-RS application source code from GitHub, builds, deploys and promotes the result through the deployment pipeline. The following diagram shows the steps included in the deployment pipeline:

![](https://raw.githubusercontent.com/siamaksade/openshift-cd-demo/openshift-3.x/images/pipeline.png)

Run an instance of the pipeline by starting the _tasks-cd-pipeline_ job.
