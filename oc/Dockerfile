# The FROM will be replaced when building in OpenShift
FROM centos:7

MAINTAINER Erik Jacobs <erikmjacobs@gmail.com>

USER root
RUN yum clean all && \
    export INSTALL_PKGS="origin-clients" && \
    yum clean all && \
    yum -y --setopt=tsflags=nodocs install epel-release centos-release-openshift-origin && \
    yum install -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all
