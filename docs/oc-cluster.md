# Local OpenShift Origin

Download and install [Minishift](https://docs.openshift.org/latest/minishift/getting-started/installing.html)

Start up an OpenShift cluster:

```
minishift start --memory=8192 --vm-driver=virtualbox
minishift addons enable xpaas
oc login $(minishift ip):8443 -u developer
```

Pre-pull the images to make sure the deployments go faster:

```
minishift ssh docker pull openshiftdemos/nexus:2.13.0-01
minishift ssh docker pull openshiftdemos/gogs:0.9.113
minishift ssh docker pull openshiftdemos/sonarqube:6.0
minishift ssh docker pull openshift/jenkins-2-centos7
minishift ssh docker pull openshift/jenkins-slave-maven-centos7
minishift ssh docker pull registry.access.redhat.com/jboss-eap-7/eap70-openshift
```