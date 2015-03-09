#######################################################################
#                                                                     #
# Creates a Jenkins image with TicketMonster job configured  		  #
#                                                                     #
#######################################################################

FROM siamaksade/jenkins:1.587

MAINTAINER Siamak Sadeghianfar <ssadeghi@redhat.com>

# Copy SSH Key Pair
ADD config/.ssh /var/lib/jenkins/.ssh
RUN chown -R jenkins:jenkins /var/lib/jenkins/.ssh/
RUN chmod 755 /var/lib/jenkins/.ssh/
RUN chmod 600 /var/lib/jenkins/.ssh/id_rsa*

# Install Plugins
RUN wget -O /var/lib/jenkins/plugins/openshift-deployer.hpi 		http://updates.jenkins-ci.org/download/plugins/openshift-deployer/1.2.0/openshift-deployer.hpi
RUN wget -O /var/lib/jenkins/plugins/build-pipeline-plugin.hpi 		http://updates.jenkins-ci.org/download/plugins/build-pipeline-plugin/1.4.3/build-pipeline-plugin.hpi
RUN wget -O /var/lib/jenkins/plugins/jquery.hpi 					http://updates.jenkins-ci.org/download/plugins/jquery/1.7.2-1/jquery.hpi
RUN wget -O /var/lib/jenkins/plugins/parameterized-trigger.hpi 		http://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.25/parameterized-trigger.hpi
RUN wget -O /var/lib/jenkins/plugins/sonar.hpi 						http://updates.jenkins-ci.org/download/plugins/sonar/2.1/sonar.hpi
RUN wget -O /var/lib/jenkins/plugins/javadoc.hpi 					http://updates.jenkins-ci.org/download/plugins/javadoc/1.2/javadoc.hpi
RUN wget -O /var/lib/jenkins/plugins/delivery-pipeline-plugin.hpi 	https://updates.jenkins-ci.org/download/plugins/delivery-pipeline-plugin/0.8.6/delivery-pipeline-plugin.hpi
RUN wget -O /var/lib/jenkins/plugins/token-macro.hpi 				https://updates.jenkins-ci.org/download/plugins/token-macro/1.9/token-macro.hpi
RUN wget -O /var/lib/jenkins/plugins/jquery-ui.hpi 					https://updates.jenkins-ci.org/download/plugins/jquery-ui/1.0.2/jquery-ui.hpi

# Jenkins Settings
ADD config/jenkins-config.xml /var/lib/jenkins/config.xml

# Maven Global Settings
ADD config/maven-settings.xml /usr/share/apache-maven/conf/settings.xml

# SonarQube Settings
ADD config/sonar-settings.xml /var/lib/jenkins/hudson.plugins.sonar.SonarPublisher.xml

# OpenShift Deployer Settings
ADD config/openshift-settings.xml /var/lib/jenkins/org.jenkinsci.plugins.openshift.DeployApplication.xml

# Build Jobs
RUN mkdir -p /var/lib/jenkins/jobs/ticket-monster-{analysis,build,deploy-dev,func-test,release,test}

ADD config/job-analysis.xml 		/var/lib/jenkins/jobs/ticket-monster-analysis/config.xml
ADD config/job-build.xml 			/var/lib/jenkins/jobs/ticket-monster-build/config.xml
ADD config/job-release.xml 			/var/lib/jenkins/jobs/ticket-monster-release/config.xml
ADD config/job-deploy-dev.xml 		/var/lib/jenkins/jobs/ticket-monster-deploy-dev/config.xml
ADD config/job-deploy-systest.xml 	/var/lib/jenkins/jobs/ticket-monster-deploy-systest/config.xml
ADD config/job-deploy-perftest.xml 	/var/lib/jenkins/jobs/ticket-monster-deploy-perftest/config.xml
ADD config/job-deploy-preprod.xml 	/var/lib/jenkins/jobs/ticket-monster-deploy-preprod/config.xml
ADD config/job-test-func.xml 		/var/lib/jenkins/jobs/ticket-monster-test-func/config.xml
ADD config/job-test-int.xml 		/var/lib/jenkins/jobs/ticket-monster-test-int/config.xml
ADD config/job-test-sys.xml 		/var/lib/jenkins/jobs/ticket-monster-test-sys/config.xml
ADD config/job-test-perf.xml 		/var/lib/jenkins/jobs/ticket-monster-test-perf/config.xml

# Disable SNI Extension
RUN sed -i "s/JENKINS_JAVA_OPTIONS/#JENKINS_JAVA_OPTIONS/g" /etc/sysconfig/jenkins
RUN echo "JENKINS_JAVA_OPTIONS=\"-Djava.awt.headless=true -Djsse.enableSNIExtension=false\"" >> /etc/sysconfig/jenkins

# Set Permissions
RUN chown -R jenkins:jenkins /var/lib/jenkins