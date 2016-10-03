# Local OpenShift Container Platform 3.3 Setup on Linux

1. Download and install the OpenShift CLI from [Red Hat Customer Portal](http://access.redhat.com)

2. Start up a cluster using ```oc cluster```.

  ```
  oc cluster up --metrics --image=registry.access.redhat.com/openshift3/ose
  ```

3. If you want to enable Pipeline tech preview feature, bring the cluster down, enable the pipelines and bring it up again.

  ```
  oc cluster down

  # create a script to enable pipelines
  echo "window.OPENSHIFT_CONSTANTS.ENABLE_TECH_PREVIEW_FEATURE.pipelines = true;" \
      > /var/lib/origin/openshift.local.config/master/tech-preview.js

  # add the script to master-config as an extension
  sed -i 's/extensionScript.*/extensionScripts:\n  - \/var\/lib\/origin\/openshift.local.config\/master\/tech-preview.js/' \
      /var/lib/origin/openshift.local.config/master/master-config.yaml

  # bring the cluster up using the existing configurations
  oc cluster up --image=registry.access.redhat.com/openshift3/ose --use-existing-config
  ```

  __Note:__ use ```--public-hostname``` option with ```oc cluster``` to specify the network address

4. Remove installed imagestreams and install the RHE and JBoss imagestreams

  ```
  oc login -u system:admin
  oc delete is --all -n openshift
  oc create -f https://raw.githubusercontent.com/openshift/origin/master/examples/image-streams/image-streams-rhel7.json -n openshift
  oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json -n openshift
  ```
