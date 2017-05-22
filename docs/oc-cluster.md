# Local OpenShift Origin 1.5

1. Download and install [Minishift](https://docs.openshift.org/latest/minishift/getting-started/installing.html)

2. Start up an OpenShift cluster

  ```
  minishift start --memory=8192 --vm-driver=virtualbox
  ```

3. Remove installed imagestreams and install the RHEL and JBoss imagestreams

  ```
  oc login [LOCAL-OPENSHIFT-MASTER] -u developer
  oc delete is --all -n openshift --as=system:admin
  oc create -f https://raw.githubusercontent.com/openshift/origin/master/examples/image-streams/image-streams-rhel7.json -n openshift --as=system:admin
  oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json -n openshift --as=system:admin
  ```
