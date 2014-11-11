#######################################################################
#                                                                     #
# Creates a Jenkins image with a Delivery Pipline for deploying       #
# TicketMonster application to OpenShift                              #
#                                                                     #
#######################################################################

FROM library/jenkins:1.584

MAINTAINER Siamak Sadeghianfar <ssadeghi@redhat.com>

USER root

# Generate SSH Key Pair
RUN mkdir -p /var/jenkins_home/.ssh \
		&& ssh-keygen -t rsa -q -N "" -f /var/jenkins_home/.ssh/id_rsa \
		&& chmod 755 /var/jenkins_home/.ssh/

# Install Maven
ENV MAVEN_VERSION 3.0.5
ENV M2_HOME /opt/maven
RUN wget http://apache.mirrors.spacedump.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O - | tar -xz && mv apache-maven-$MAVEN_VERSION $M2_HOME

# Install Plugins
RUN mkdir /var/jenkins_home/plugins \
    && wget -O /var/jenkins_home/plugins/openshift-deployer.hpi 		http://updates.jenkins-ci.org/download/plugins/openshift-deployer/1.0.4/openshift-deployer.hpi \
    && wget -O /var/jenkins_home/plugins/build-pipeline-plugin.hpi 	http://updates.jenkins-ci.org/download/plugins/build-pipeline-plugin/1.4.3/build-pipeline-plugin.hpi \
    && wget -O /var/jenkins_home/plugins/jquery.hpi 					http://updates.jenkins-ci.org/download/plugins/jquery/1.7.2-1/jquery.hpi \
    && wget -O /var/jenkins_home/plugins/parameterized-trigger.hpi 	http://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.25/parameterized-trigger.hpi \
    && wget -O /var/jenkins_home/plugins/sonar.hpi 					http://updates.jenkins-ci.org/download/plugins/sonar/2.1/sonar.hpi \
    && wget -O /var/jenkins_home/plugins/javadoc.hpi 					http://updates.jenkins-ci.org/download/plugins/javadoc/1.2/javadoc.hpi \
    && wget -O /var/jenkins_home/plugins/delivery-pipeline-plugin.hpi 	https://updates.jenkins-ci.org/download/plugins/delivery-pipeline-plugin/0.8.6/delivery-pipeline-plugin.hpi \
    && wget -O /var/jenkins_home/plugins/token-macro.hpi 				https://updates.jenkins-ci.org/download/plugins/token-macro/1.9/token-macro.hpi \
    && wget -O /var/jenkins_home/plugins/jquery-ui.hpi 				https://updates.jenkins-ci.org/download/plugins/jquery-ui/1.0.2/jquery-ui.hpi

# Jenkins Settings
# ADD config/jenkins-config.xml /var/jenkins_home/config.xml

# Maven Global Settings
# ADD config/maven-settings.xml /usr/share/apache-maven/conf/settings.xml

# SonarQube Settings
# ADD config/sonar-settings.xml /var/jenkins_home/hudson.plugins.sonar.SonarPublisher.xml

# OpenShift Deployer Settings
# ADD config/openshift-settings.xml /var/jenkins_home/org.jenkinsci.plugins.openshift.DeployApplication.xml

# Build Jobs
# RUN mkdir -p /var/jenkins_home/jobs/ticket-monster-{analysis,build,deploy-dev,func-test,release,test}

# ADD config/job-analysis.xml 		/var/jenkins_home/jobs/ticket-monster-analysis/config.xml
# ADD config/job-build.xml 			/var/jenkins_home/jobs/ticket-monster-build/config.xml
# ADD config/job-release.xml 			/var/jenkins_home/jobs/ticket-monster-release/config.xml
# ADD config/job-deploy-dev.xml 		/var/jenkins_home/jobs/ticket-monster-deploy-dev/config.xml
# ADD config/job-deploy-systest.xml 	/var/jenkins_home/jobs/ticket-monster-deploy-systest/config.xml
# ADD config/job-deploy-perftest.xml 	/var/jenkins_home/jobs/ticket-monster-deploy-perftest/config.xml
# ADD config/job-deploy-preprod.xml 	/var/jenkins_home/jobs/ticket-monster-deploy-preprod/config.xml
# ADD config/job-test-func.xml 		/var/jenkins_home/jobs/ticket-monster-test-func/config.xml
# ADD config/job-test-int.xml 		/var/jenkins_home/jobs/ticket-monster-test-int/config.xml
# ADD config/job-test-sys.xml 		/var/jenkins_home/jobs/ticket-monster-test-sys/config.xml
# ADD config/job-test-perf.xml 		/var/jenkins_home/jobs/ticket-monster-test-perf/config.xml

# Disable SNI Extension
RUN echo "JAVA_OPTS=\"-Djsse.enableSNIExtension=false\"" > /etc/default/jenkins

# Set Permissions
RUN chown -R jenkins:jenkins /var/jenkins_home