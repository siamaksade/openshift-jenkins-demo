FROM sonatype/nexus:2.13.0-01

MAINTAINER Siamak Sadeghianfar <ssadeghi@redhat.com>

ENV SONATYPE_WORK /nexus-data

USER root
COPY conf/nexus.xml ${SONATYPE_WORK}/conf/nexus.xml
RUN chown -R nexus ${SONATYPE_WORK} && \
    chmod -R ugo+rw ${SONATYPE_WORK}

USER nexus
