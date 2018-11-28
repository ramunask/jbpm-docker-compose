#!/usr/bin/env bash

# update database configuration
echo "Update database connection setup"
./update-kie-config.sh

# create users
echo "Creating '$KIE_SERVER_USER' user with password '$KIE_SERVER_PWD', that jBPM Workbench could access it ..."
./add-user.sh -a -u $KIE_SERVER_USER -p $KIE_SERVER_PWD -g kie-server
echo "Creating '$KIE_SERVER_CONTROLLER_USER' user with password '$KIE_SERVER_CONTROLLER_PWD', that KIE Server could access it ..."
./add-user.sh -a -u $KIE_SERVER_CONTROLLER_USER -p $KIE_SERVER_CONTROLLER_PWD -g kie-server

# https://docs.jboss.org/jbpm/release/7.14.0.Final/jbpm-docs/html_single/index.html#_system_properties
# If not server identifier set via docker env variable, use the container's hostname as server id.
if [ ! -n "$KIE_SERVER_ID" ]; then
    export KIE_SERVER_ID=kie-server-$HOSTNAME
fi
echo "Using '$KIE_SERVER_ID' as KIE server identifier"

# If this KIE execution server container is linked with some KIE Workbench container, the following environemnt variables will be present, so configure the application arguments based on their values.
if [ -n "$KIE_WB_HOSTNAME" ] &&  [ -n "$KIE_WB_CONTEXT_PATH" ] &&  [ -n "$KIE_CONTEXT_PATH" ]; then
    
    # If not public IP configured using the DOCKER_IP env, obtain the internal network address for this container.
    if [ ! -n "$DOCKER_IP" ]; then
    # Obtain current container's IP address.
    DOCKER_IP=$(/sbin/ifconfig eth0 | grep 'inet' | cut -d: -f2 | awk '{ print $2}')
    fi
    # If not public port configured using the DOCKER_PORT env, use the default internal network HTTP port.
    if [ ! -n "$DOCKER_PORT" ]; then
        DOCKER_PORT=8080
    fi

    # KIE Workbench environment variables are set. Proceed with automatic configuration.
    echo "Detected successful link for KIE Workbench container. Applying automatic configuration for the link..."
    export KIE_SERVER_LOCATION="http://$DOCKER_IP:$DOCKER_PORT$KIE_CONTEXT_PATH/services/rest/server"
    export KIE_SERVER_CONTROLLER="http://$KIE_WB_HOSTNAME:8080$KIE_WB_CONTEXT_PATH/rest/controller"
    export KIE_MAVEN_REPO="http://$KIE_WB_HOSTNAME:8080$KIE_WB_CONTEXT_PATH/maven2"
fi

# Default arguments for running the KIE Execution server.
JBOSS_ARGUMENTS=" -b $JBOSS_BIND_ADDRESS -Dorg.kie.server.id=$KIE_SERVER_ID -Dorg.kie.server.user=$KIE_SERVER_USER -Dorg.kie.server.pwd=$KIE_SERVER_PWD -Dorg.kie.server.location=$KIE_SERVER_LOCATION "
echo "Using '$KIE_SERVER_LOCATION' as KIE server location"

# Controller argument for the KIE Execution server. Only enabled if set the environment variable/s or detected container linking.
if [ -n "$KIE_SERVER_CONTROLLER" ]; then
    echo "Using '$KIE_SERVER_CONTROLLER' as KIE server controller"
    echo "Using '$KIE_MAVEN_REPO' for the kie-workbench Maven repository URL"
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS -Dorg.kie.server.controller=$KIE_SERVER_CONTROLLER -Dorg.kie.server.controller.user=$KIE_SERVER_CONTROLLER_USER -Dorg.kie.server.controller.pwd=$KIE_SERVER_CONTROLLER_PWD "
fi

# should we go through proxy?
if [ -n "$HTTP_PROXY_HOST" ]; then
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS -Dhttp.proxyHost=$HTTP_PROXY_HOST -Dhttp.proxyPort=$HTTP_PROXY_PORT "
fi
if [ -n "$HTTPS_PROXY_HOST" ]; then
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS -Dhttps.proxyHost=$HTTPS_PROXY_HOST -Dhttps.proxyPort=$HTTPS_PROXY_PORT "
fi

# Start Wildfly with the given arguments.
echo "Running KIE Execution Server on JBoss Wildfly..."
exec ./standalone.sh $JBOSS_ARGUMENTS -c $KIE_SERVER_PROFILE.xml
exit $?