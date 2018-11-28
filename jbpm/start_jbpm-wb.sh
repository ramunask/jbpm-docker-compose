#!/usr/bin/env bash

# create users
echo "Creating controller '$KIE_SERVER_CONTROLLER_USER' user that KIE Server could access it ..."
./add-user.sh -a -u $KIE_SERVER_CONTROLLER_USER -p $KIE_SERVER_CONTROLLER_PWD -g admin,kiemgmt,rest-all,kie-server

# Default arguments for running the KIE Execution server.
JBOSS_ARGUMENTS=" -b $JBOSS_BIND_ADDRESS -Djboss.bind.address.management=$JBOSS_BIND_ADDRESS -c $KIE_SERVER_PROFILE.xml"

# should we create management user?
if [ -n "$MANAGEMENT_USER" ]; then
    echo "Creating '$MANAGEMENT_USER' user for administration http://localhost:9990/console/index.html JBoss management console ..."
    ./add-user.sh -m -u $MANAGEMENT_USER -p $MANAGEMENT_PWD -g admin,kiemgmt,rest-all
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS -Djboss.bind.address.management=$JBOSS_BIND_ADDRESS "
fi

# should we disable demo?
if [ -n "$KIE_DEMO" ]; then
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS -Dorg.kie.demo=$KIE_DEMO -Dorg.kie.example=$KIE_DEMO "
fi

# should we enable debug?
if [ -n "$DEBUG" ]; then
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS --debug 9797 "
fi

# should we go through proxy?
if [ -n "$HTTP_PROXY_HOST" ]; then
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS -Dhttp.proxyHost=$HTTP_PROXY_HOST -Dhttp.proxyPort=$HTTP_PROXY_PORT "
fi
if [ -n "$HTTPS_PROXY_HOST" ]; then
    JBOSS_ARGUMENTS="$JBOSS_ARGUMENTS -Dhttps.proxyHost=$HTTPS_PROXY_HOST -Dhttps.proxyPort=$HTTPS_PROXY_PORT "
fi

# Start Wildfly with the given arguments.
echo "Running jBPM Workbench on JBoss Wildfly with following arguments $JBOSS_ARGUMENTS ..."
exec ./standalone.sh $JBOSS_ARGUMENTS
exit $?
