#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  $ oc login http://console.your.openshift.com                               #"
echo "###############################################################################"

function usage() {
    echo
    echo "Usage:"
    echo " $0 [command] [options]"
    echo " $0 --help"
    echo
    echo "Example:"
    echo " $0 deploy --project-suffix mydemo"
    echo
    echo "COMMANDS:"
    echo "   deploy                   Set up the demo projects and deploy demo apps"
    echo "   delete                   Clean up and remove demo projects and objects"
    echo "   idle                     Make all demo servies idle"
    echo "   unidle                   Make all demo servies unidle"
    echo 
    echo "OPTIONS:"
    echo "   --user [username]         The admin user for the demo projects. mandatory if logged in as system:admin"
    echo "   --project-suffix [suffix] Suffix to be added to demo project names e.g. ci-SUFFIX. If empty, user will be used as suffix"
    echo
}

ARG_USERNAME=
ARG_PROJECT_SUFFIX=
ARG_COMMAND=

while :; do
    case $1 in
        deploy)
            ARG_COMMAND=deploy
            ;;
        delete)
            ARG_COMMAND=delete
            ;;
        idle)
            ARG_COMMAND=idle
            ;;
        unidle)
            ARG_COMMAND=unidle
            ;;
        --user)
            if [ -n "$2" ]; then
                ARG_USERNAME=$2
                shift
            else
                printf 'ERROR: "--user" requires a non-empty value.\n' >&2
                usage
                exit 255
            fi
            ;;
        --project-suffix)
            if [ -n "$2" ]; then
                ARG_PROJECT_SUFFIX=$2
                shift
            else
                printf 'ERROR: "--project-suffix" requires a non-empty value.\n' >&2
                usage
                exit 255
            fi
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            shift
            ;;
        *) # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done


################################################################################
# CONFIGURATION                                                                #
################################################################################

LOGGEDIN_USER=$(oc whoami)
OPENSHIFT_USER=${ARG_USERNAME:-$LOGGEDIN_USER}
PRJ_SUFFIX=${ARG_PROJECT_SUFFIX:-`echo $OPENSHIFT_USER | sed -e 's/[-@].*//g'`}
GITHUB_ACCOUNT=${GITHUB_ACCOUNT:-OpenShiftDemos}
GITHUB_REF=${GITHUB_REF:-ocp-3.6}

function deploy() {
  oc new-project dev-$PRJ_SUFFIX   --display-name="Tasks - Dev"
  oc new-project stage-$PRJ_SUFFIX --display-name="Tasks - Stage"
  oc new-project cicd-$PRJ_SUFFIX  --display-name="CI/CD"

  sleep 2

  oc policy add-role-to-user edit system:serviceaccount:cicd-$PRJ_SUFFIX:jenkins -n dev-$PRJ_SUFFIX
  oc policy add-role-to-user edit system:serviceaccount:cicd-$PRJ_SUFFIX:jenkins -n stage-$PRJ_SUFFIX

  if [ $LOGGEDIN_USER == 'system:admin' ] ; then
    oc adm policy add-role-to-user admin $ARG_USERNAME -n dev-$PRJ_SUFFIX >/dev/null 2>&1
    oc adm policy add-role-to-user admin $ARG_USERNAME -n stage-$PRJ_SUFFIX >/dev/null 2>&1
    oc adm policy add-role-to-user admin $ARG_USERNAME -n cicd-$PRJ_SUFFIX >/dev/null 2>&1
    
    oc annotate --overwrite namespace dev-$PRJ_SUFFIX   demo=openshift-cd-$PRJ_SUFFIX >/dev/null 2>&1
    oc annotate --overwrite namespace stage-$PRJ_SUFFIX demo=openshift-cd-$PRJ_SUFFIX >/dev/null 2>&1
    oc annotate --overwrite namespace cicd-$PRJ_SUFFIX  demo=openshift-cd-$PRJ_SUFFIX >/dev/null 2>&1

    oc adm pod-network join-projects --to=cicd-$PRJ_SUFFIX dev-$PRJ_SUFFIX stage-$PRJ_SUFFIX >/dev/null 2>&1
  fi

  sleep 2

  # local template=https://raw.githubusercontent.com/$GITHUB_ACCOUNT/openshift-cd-demo/$GITHUB_REF/cicd-template.yaml
  local template=/Users/ssadeghi/Projects/openshift-cd-demo/cicd-template.yaml
  oc process -f $template \
      --param DEV_PROJECT=dev-$PRJ_SUFFIX \
      --param STAGE_PROJECT=stage-$PRJ_SUFFIX \
      -n cicd-$PRJ_SUFFIX | oc create -f - -n cicd-$PRJ_SUFFIX

  sleep 5

  oc set resources dc/jenkins --limits=memory=1Gi -n cicd-$PRJ_SUFFIX
}

function make_idle() {
  echo_header "Idling Services"
  oc idle -n dev-$PRJ_SUFFIX --all
  oc idle -n stage-$PRJ_SUFFIX --all
  oc idle -n cicd-$PRJ_SUFFIX --all
}

function make_unidle() {
  echo_header "Unidling Services"
  local _DIGIT_REGEX="^[[:digit:]]*$"

  for project in dev-$PRJ_SUFFIX stage-$PRJ_SUFFIX cicd-$PRJ_SUFFIX
  do
    for dc in $(oc get dc -n $project -o=custom-columns=:.metadata.name); do
      local replicas=$(oc get dc $dc --template='{{ index .metadata.annotations "idling.alpha.openshift.io/previous-scale"}}' -n $project 2>/dev/null)
      if [[ $replicas =~ $_DIGIT_REGEX ]]; then
        oc scale --replicas=$replicas dc $dc -n $project
      fi
    done
  done
}

function set_default_project() {
  if [ $LOGGEDIN_USER == 'system:admin' ] ; then
    oc project default >/dev/null
  fi
}

function echo_header() {
  echo
  echo "########################################################################"
  echo $1
  echo "########################################################################"
}

################################################################################
# MAIN: DEPLOY DEMO                                                            #
################################################################################

if [ "$LOGGEDIN_USER" == 'system:admin' ] && [ -z "$ARG_USERNAME" ] ; then
  # for verify and delete, --project-suffix is enough
  if [ "$ARG_COMMAND" == "delete" ] || [ "$ARG_COMMAND" == "verify" ] && [ -z "$ARG_PROJECT_SUFFIX" ]; then
    echo "--user or --project-suffix must be provided when running $ARG_COMMAND as 'system:admin'"
    exit 255
  # deploy command
  elif [ "$ARG_COMMAND" != "delete" ] && [ "$ARG_COMMAND" != "verify" ] ; then
    echo "--user must be provided when running $ARG_COMMAND as 'system:admin'"
    exit 255
  fi
fi

pushd ~ >/dev/null
START=`date +%s`

echo_header "OpenShift CI/CD Demo ($(date))"

case "$ARG_COMMAND" in
    delete)
        echo "Delete demo..."
        oc delete project dev-$PRJ_SUFFIX stage-$PRJ_SUFFIX cicd-$PRJ_SUFFIX
        echo
        echo "Delete completed successfully!"
        ;;
      
    idle)
        echo "Idling demo..."
        make_idle
        echo
        echo "Idling completed successfully!"
        ;;

    unidle)
        echo "Unidling demo..."
        make_unidle
        echo
        echo "Unidling completed successfully!"
        ;;

    deploy)
        echo "Deploying demo..."
        deploy
        echo
        echo "Provisioning completed successfully!"
        ;;
        
    *)
        echo "Invalid command specified: '$ARG_COMMAND'"
        usage
        ;;
esac

set_default_project
popd >/dev/null

END=`date +%s`
echo "(Completed in $(( ($END - $START)/60 )) min $(( ($END - $START)%60 )) sec)"
echo 