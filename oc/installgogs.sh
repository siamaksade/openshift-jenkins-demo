#!/bin/bash

set -x

# Use the oc client to get the url for the gogs route
GOGSROUTE=$(oc get route gogs -o template --template='{{.spec.host}}')

# Use the oc client to get the postgres variables into the current shell"
eval $(oc env dc/postgresql-gogs --list | grep -v \#)

# postgres has a readiness probe, so checking if there is at least one
# endpoint means postgres is alive and ready, so we can then attempt to install gogs
# we're willing to wait 60 seconds for it, otherwise something is wrong.
x=1
oc get ep postgresql-gogs -o yaml | grep "\- addresses:"
while [ ! $? -eq 0 ]
do
  sleep 3
  x=$(( $x + 1 ))

  if [ $x -gt 20 ]
  then
    exit 255
  fi

  oc get ep postgresql-gogs -o yaml | grep "\- addresses:"
done

# now we wait for gogs to be ready in the same way
x=1
oc get ep gogs -o yaml | grep "\- addresses:"
while [ ! $? -eq 0 ]
do
  sleep 3
  x=$(( $x + 1 ))

  if [ $x -gt 20 ]
  then
    exit 255
  fi

  oc get ep gogs -o yaml | grep "\- addresses:"
done

# we might catch the router before it's been updated, so wait just a touch
# more
sleep 10

RETURN=$(curl -o /dev/null -sL -w "%{http_code}" http://$GOGSROUTE/install \
--form db_type=PostgreSQL \
--form db_host=postgresql-gogs:5432 \
--form db_user=$POSTGRESQL_USER \
--form db_passwd=$POSTGRESQL_PASSWORD \
--form db_name=gogs \
--form ssl_mode=disable \
--form db_path=data/gogs.db \
--form "app_name=Gogs: Go Git Service" \
--form repo_root_path=/home/gogs/gogs-repositories \
--form run_user=gogs \
--form domain=localhost \
--form ssh_port=22 \
--form http_port=3000 \
--form app_url=http://$GOGSROUTE/ \
--form log_root_path=/opt/gogs/log)

if [ $RETURN != "200" ]
then
  exit 255
fi
