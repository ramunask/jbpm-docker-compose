###########################################################################
# Dockerfile that provides the image for KIE Execution Server 7.14.0.Final
###########################################################################

####### BASE ############
FROM jboss/kie-server:7.14.0.Final

####### MAINTAINER ############
LABEL maintainer="Ramūnas K"

####### EXPOSE HTTP ADDRESS ############
EXPOSE 8080

####### ENVIRONMENT ############
# ENV KIE_SERVER_ID kie-server

ENV KIE_SERVER_PROFILE standalone-full

ENV KIE_SERVER_LOCATION http://localhost:8080/kie-server/services/rest/server
ENV KIE_SERVER_USER kieserver
ENV KIE_SERVER_PWD kieserver1!
ENV KIE_SERVER_CONTROLLER_USER admin
ENV KIE_SERVER_CONTROLLER_PWD admin

ENV KIE_MAVEN_REPO http://localhost:8080/jbpm-console/maven2
ENV KIE_MAVEN_REPO_USER admin
ENV KIE_MAVEN_REPO_PASSWORD admin

ENV KIE_WB_CONTEXT_PATH /jbpm-console
ENV KIE_CONTEXT_PATH /kie-server

ENV DB_HOST localhost
ENV DB_PORT 5432
ENV DB_NAME postgres
ENV DB_USER postgres

ENV JAVA_OPTS -Xms256m -Xmx1024m -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8 -Dmail.mime.charset=UTF-8

####### Drools KIE Server CUSTOM CONFIGURATION ############
RUN mkdir -p $HOME/.m2
ADD start_kie-server.sh $JBOSS_HOME/bin/start_kie-server.sh
ADD settings.xml $JBOSS_HOME/../.m2/settings.xml
ADD http://central.maven.org/maven2/org/postgresql/postgresql/42.2.5/postgresql-42.2.5.jar $JBOSS_HOME/bin/drivers/postgresql.jar
ADD update-kie-config.cli $JBOSS_HOME/bin/
ADD update-kie-config.sh $JBOSS_HOME/bin/
ADD start_kie-server.sh $JBOSS_HOME/bin/

# switch to user root
USER root

# install required software
RUN yum install -y dos2unix

RUN dos2unix $JBOSS_HOME/bin/start_kie-server.sh && \
    dos2unix $JBOSS_HOME/bin/update-kie-config.sh && \
    chown jboss:jboss $JBOSS_HOME/bin/update-kie-config.sh && \
    chown jboss:jboss $JBOSS_HOME/bin/update-kie-config.cli && \
    chown jboss:jboss $JBOSS_HOME/bin/start_kie-server.sh && \
    chown jboss:jboss $JBOSS_HOME/bin/drivers/postgresql.jar && \
    chown jboss:jboss $JBOSS_HOME/../.m2/settings.xml

####### CUSTOM JBOSS USER ############
# Switchback to jboss user
USER jboss

####### CREATE USERS ############
# see available parameters at https://access.redhat.com/documentation/en-us/red_hat_jboss_fuse_service_works/6.0/html/administration_and_configuration_guide/chap-managing_user_accounts
 RUN cd /opt/jboss/wildfly/bin/ && \
    # create application users, same as in jbpm machine, just roles here are simply kie-server?
    ./add-user.sh -a -u wbadmin -p wbadmin -g kie-server

####### RUNNING KIE-SERVER ############
WORKDIR $JBOSS_HOME/bin/
CMD ["./start_kie-server.sh"]