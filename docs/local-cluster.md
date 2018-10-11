# Local OKD Origin

Download and install [Minishift](https://docs.okd.io/latest/minishift/getting-started/installing.html)

Start up an OpenShift cluster:

```
minishift addons enable xpaas
minishift start --memory=10240 --vm-driver=virtualbox
oc login -u developer
```

Pre-pull the images to make sure the deployments go faster:

```
minishift ssh docker pull openshiftdemos/gogs:0.11.34
minishift ssh docker pull openshiftdemos/sonarqube:7.0
minishift ssh docker pull sonatype/nexus3:3.13.0
minishift ssh docker pull openshift/wildfly-120-centos7
```