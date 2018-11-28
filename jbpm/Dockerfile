###########################################################################
# Dockerfile that provides the image for JBoss jBPM Workbench 7.14.0.Final
###########################################################################

####### BASE ############
FROM jboss/jbpm-workbench:7.14.0.Final

####### MAINTAINER ############
LABEL maintainer="Ramūnas K"

####### EXPOSE HTTP ADDRESS ############
# http jbpm-console port
EXPOSE 8080
# git port
EXPOSE 8001
# debug port (if DEBUG environment variable is set)
EXPOSE 9797

####### ENVIRONMENT ############
ENV KIE_SERVER_CONTROLLER_USER admin
ENV KIE_SERVER_CONTROLLER_PWD admin

# pass environment variables if management user should be created
#ENV MANAGEMENT_USER admin
#ENV MANAGEMENT_PWD admin

ENV KIE_DEMO false

####### PERFORM CONFIGURATION UPDATE ############
USER root

# install required software
RUN yum install -y dos2unix

# configure standalone.xml
ADD jbpm-custom.cli $JBOSS_HOME/bin/
ADD start_jbpm-wb.sh $JBOSS_HOME/bin/
RUN dos2unix $JBOSS_HOME/bin/start_jbpm-wb.sh && \
    chown jboss:jboss $JBOSS_HOME/bin/jbpm-custom.cli && \
    chown jboss:jboss $JBOSS_HOME/bin/start_jbpm-wb.sh

# Switchback to jboss user
USER jboss

# execute cli commands
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/bin/jbpm-custom.cli && \
    rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/current

####### CREATE USERS ############
# see available parameters at https://access.redhat.com/documentation/en-us/red_hat_jboss_fuse_service_works/6.0/html/administration_and_configuration_guide/chap-managing_user_accounts
RUN cd /opt/jboss/wildfly/bin/ && \
    # application users
    ./add-user.sh -a -u wbadmin -p wbadmin -g user,admin,analyst,process-admin,kie-server,kiemgmt,rest-all


####### RUNNING JBPM-WB ############
WORKDIR $JBOSS_HOME/bin/
CMD ["./start_jbpm-wb.sh"]