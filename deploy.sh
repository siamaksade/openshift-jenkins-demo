#!/bin/bash

echo "####################################################"
echo " MAKE SURE YOU ARE LOGGED IN:"
echo " $ oc login http://console.your.openshift.com"
echo "####################################################"

PROJECT_SUFFIX=

if [ ! -z "$1" ]; then
  PROJECT_SUFFIX="-$1"
fi

oc new-project dev$PROJECT_SUFFIX --display-name="Tasks - Dev"
oc new-project stage$PROJECT_SUFFIX --display-name="Tasks - Stage"
oc new-project cicd$PROJECT_SUFFIX --display-name="CI/CD"

sleep 2

oc policy add-role-to-user edit system:serviceaccount:cicd$PROJECT_SUFFIX:jenkins -n dev$PROJECT_SUFFIX
oc policy add-role-to-user edit system:serviceaccount:cicd$PROJECT_SUFFIX:jenkins -n stage$PROJECT_SUFFIX

sleep 2

oc process -f cicd-template.yaml --param DEV_PROJECT=dev$PROJECT_SUFFIX --param STAGE_PROJECT=stage$PROJECT_SUFFIX -n cicd$PROJECT_SUFFIX | oc create -f - -n cicd$PROJECT_SUFFIX