# Local OpenShift Container Platform

Download and install [Container Development Kit (CDK) 3.0](https://developers.redhat.com/products/cdk/hello-world/)

Start up an OpenShift cluster:

```
minishift start --memory=10240 --vm-driver=virtualbox
minishift addons enable xpaas
oc login $(minishift ip):8443 -u developer
```

Pre-pull the images to make sure the deployments go faster:

```
minishift ssh docker pull openshiftdemos/nexus:2.13.0-01
minishift ssh docker pull openshiftdemos/gogs:0.11.29
minishift ssh docker pull openshiftdemos/sonarqube:6.7
minishift ssh docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7
minishift ssh docker pull registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7
minishift ssh docker pull registry.access.redhat.com/jboss-eap-7/eap70-openshift
```