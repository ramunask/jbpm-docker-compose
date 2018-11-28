#!/usr/bin/env bash

echo ""
echo "Using Database settings:"
echo "Host: $DB_HOST"
echo "Port: $DB_PORT"
echo "Name: $DB_NAME"
echo "User: $DB_USER"
echo "Server Config: $KIE_SERVER_PROFILE"

# If cli file not found, exit.
CLI_FILE=./update-kie-config.cli

sed -i "s/--server-config=standalone.xml/--server-config=$KIE_SERVER_PROFILE.xml/" $CLI_FILE
sed -i "s/--user-name=jbpm/--user-name=$DB_USER/" $CLI_FILE
sed -i "s/--password=jbpm/--password=$DB_PASSWORD/" $CLI_FILE
sed -i "s/ServerName=localhost/ServerName=$DB_HOST/" $CLI_FILE
sed -i "s/DatabaseName=jbpm/DatabaseName=$DB_NAME/" $CLI_FILE
sed -i "s/PortNumber=5432/PortNumber=$DB_PORT/" $CLI_FILE

./jboss-cli.sh --file=$CLI_FILE
exit $?