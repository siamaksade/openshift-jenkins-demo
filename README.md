Continuous Delivery Demo on OpenShift
=================

This demo sets up a complete Continuous Delivery environment running in Docker containers and uses OpenShift as the deployment environment. As the artifact moves forward in the delivery pipeline, new containers (gears) are created on OpenShift and the artifact gets deployed onto these containers which represent Dev, System Test, Performance Test and Pre-Production environments. 

This demo uses Fig as a simple orchestration tool to create the Docker containers required for this demo. Docker is used for simplicity in this demo and is not essential to the delivery pipeline.

Infrastructure
======
This demo uses the following components to create the delivery pipeline. Jenkins, Nexus and Sonar run in their own Docker containers while BitBucket is used as an external Git-based source repository.

**Jenkins**
Description: continuous delivery orchestration engine
Address: http://DOCKER_HOST:8080/jenkins

**Sonatype Nexus**
Description: artifact repository for archiving release binaries
Address: http://DOCKER_HOST:8081/nexus


**SonarQube**
Description: static code analysis engine extracting various quality metrics from the code
Address: http://DOCKER_HOST:9000

**Git**
Description: source repository hosting the ticket-monster Java application
Address: https://rhdemoss@bitbucket.org/rhdemoss/ticketmonster-openshift.git

Note: if running _boot2docker_ on Mac OSX, _DOCKER_HOST_ is the ip of boot2docker virtual machine. 



Delivery Pipeline
=================
The delivery pipeline in this demo is divided into five phases each containing a number of activities (jobs) that need to succeed in order to promote the artefact to the next phase. Each change in the application is a potential production release according to Continuous Delivery principles and can go in production if it successfully passes through all the phases in the pipeline.

1. Build: compilation and unit test, integration tests and static code analysis
2. Dev: release to Nexus, release tag in Git, deploy to DEV server (on OpenShift) and running functional tests
3. System Test: deploy to System Test server (on OpenShift) and running system tests
4. Perf Test: deploy to Performance Test server (on OpenShift) and running performance tests
5. Pre Production (Stage): deploy to Pre-Production server (on OpenShift)

[TBA: image of delivery pipeline in Jenkins]

Instructions
============
1. Install Fig
[TBA: link to Fig installation page]

2. Clone the git repo

   ```
   git clone https://github.com/siamaksade/openshift-cd-demo
   cd openshift-cd-demo
   ```

3. Start the environment
   ```
   fig up -d
   ```
   This step will download the required Docker images from Docker registery and start Jenkins, Nexus and Sonar containers. Depending on your internet connection, it might take some minutes.

4. Browse to http://DOCKER_HOST:8080/jenkins and go to _Manage Jenkins > Configure System_. Scroll down to _OpenShift_ section and enter your OpenShift configs. If using OpenShift Online, enter your username and password in the respective textboxes. If using OpenShift Enterprise, also enter the address to your broker. Click on "Check Login" to validate your username and password. If successfull, click on "Upload SSH Public Key" to upload the Jenkins SSH keys to OpenShift.

   [TBA: image of openshift config]

5. Go to jobs list and start the _ticket-monster-build_ job by clicking on the play icon.

6. Go to the _Delivery Pipeline_ to see how the build progresses in the delivery pipeline.


