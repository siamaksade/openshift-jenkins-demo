# Local OpenShift Container Platform 3.5 Setup on Linux

1. Download and install the OpenShift CLI from [Red Hat Customer Portal](http://access.redhat.com)

2. Start up a cluster using ```oc cluster```.

  ```
  oc cluster up --metrics
  ```

  __Note:__ use ```--public-hostname``` option with ```oc cluster``` to specify the network address

4. Remove installed imagestreams and install the RHEL and JBoss imagestreams

  ```
  oc login -u system:admin
  oc delete is --all -n openshift
  oc create -f https://raw.githubusercontent.com/openshift/origin/master/examples/image-streams/image-streams-rhel7.json -n openshift
  oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json -n openshift
  ```
