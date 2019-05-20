#!/usr/bin/env bash

#####
##  This script is just a basic script to start the minishift deployment and CICD Demo
##  TODOS:
##      Move to onsible playbook
##      Add checks and install and configure minishift in needed
#####

RHN_USER=cbrandt1
CPUS=12
MEMORY=16384
OCP_TAG=v3.11.98
IMAGES="openshiftdemos/sonarqube:7.0 sonatype/nexus3:3.13.0 openshift/wildfly-120-centos openshiftdemos/gogs:0.11.34"
GIT_URL=

function setup_minishift () {
    echo " TODO: dsetup minishift In progress"
    # minishift setup-cdk
    # minishift profile set dev_sec_ops-${OCP_TAG}
}

function start_minishift () {
    minishift start --cpus ${CPUS} --memory ${MEMORY} --username ${RHN_USER} --openshift-version=${OCP_TAG} 
}

function pull_images () {

    for image in ${IMAGES}
    do
        minishift ssh -- docker pull ${image}
    # minishift ssh docker pull openshiftdemos/gogs:0.11.34 && minishift ssh docker pull openshiftdemos/sonarqube:7.0 && minishift ssh docker pull sonatype/nexus3:3.13.0 && minishift ssh docker pull openshift/wildfly-120-cento
    done
}

function setup_cicd () {
    minishift login -u system:admin --insecure-skip-tls-verify=true
    oc adm policy add-role-to-user cluster-admin admin
    bash ./scripts/provision.sh deploy --user admin --deploy-che
}

setup_minishift
start_minishift
pull_images
setup_cicd


#EOF