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
IMAGES="openshiftdemos/sonarqube:7.0 sonatype/nexus3:3.13.0 docker.io/openshift/wildfly-120-centos7 \
        openshiftdemos/gogs:0.11.34 eclipse/che-server:nightly docker.io/siamaksade/sonarqube:latest \
        registry.access.redhat.com/rhscl/postgresql-96-rhel7"
GIT_URL=

function setup_minishift () {
    echo " TODO: setup minishift In progress"
    ## Create and enable stability
    # minishift setup-cdk
    minishift profile set devsecops
    minishift addons enable xpaas
    minishift addons enable admin-user
}

function start_minishift () {
    minishift start --cpus ${CPUS} --memory ${MEMORY} --username ${RHN_USER} --openshift-version=${OCP_TAG} 
}

function pull_images () {

    for image in ${IMAGES}
    do
        echo " Pulling ${image} image..."
        minishift ssh -- docker pull ${image}
    done
}

sleep 10 

function setup_cicd () {
    oc login -u system:admin --insecure-skip-tls-verify=true
    oc adm policy add-role-to-user -- cluster-admin admin
    bash ./scripts/provision.sh deploy --user admin --deploy-che
}

setup_minishift
start_minishift
pull_images
setup_cicd


#EOF