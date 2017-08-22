#!/usr/bin/env bash

export APP_HOME="$(cd "`dirname "$0"`"/../..; pwd)"

#PROJECT_NAME="$(basename ${APP_HOME})"
RUN_DIR=${APP_HOME}/sbin
HIPPO_DIR=${APP_HOME}/hippo
HIPPO_BIN_DIR=${HIPPO_DIR}/bin
HIPPO_SBIN_DIR=${HIPPO_DIR}/sbin
HIPPO_CONF_DIR=${HIPPO_DIR}/etc
HIPPO_LOG_DIR=${HIPPO_DIR}/var/logs


. "${HIPPO_CONF_DIR}/env.sh"
. "${HIPPO_BIN_DIR}/runtime-env-info.sh"

while read assignment; do
  if [[ $assignment != *"#"* ]] ; then
    if [ ! -z "$assignment" -a "$assignment" != " " ]; then
      export "$assignment"
    fi
  fi
done < ${HIPPO_CONF_DIR}/env.sh

function start() {
  PROJECT_NAME=$1
  if [[ -z $PROJECT_NAME ]] ; then
    echo "$(basename $0): missing SERVICE"
    usage
    exit 1
  fi
  cmd="sh ${RUN_DIR}/test_socket.sh"
  sh ${HIPPO_SBIN_DIR}/daemon.sh $PROJECT_NAME start 1 $cmd
}

function stop() {
  PROJECT_NAME=$1
  if [[ -z $PROJECT_NAME ]] ; then
    echo "$(basename $0): missing SERVICE"
    usage
    exit 1
  fi
  sh ${HIPPO_SBIN_DIR}/daemon.sh $PROJECT_NAME stop 1
}

function status() {
  PROJECT_NAME=$1
  if [[ -z $PROJECT_NAME ]] ; then
    echo "$(basename $0): missing SERVICE"
    usage
    exit 1
  fi
  sh ${HIPPO_SBIN_DIR}/daemon.sh $PROJECT_NAME status 1
}

function restart() {
  PROJECT_NAME=$1
  if [[ -z $PROJECT_NAME ]] ; then
    echo "$(basename $0): missing SERVICE"
    usage
    exit 1
  fi
  stop $PROJECT_NAME
  start $PROJECT_NAME
}

function usage ()
{
    temp_serivce_name="$(basename ${APP_HOME})"
    echo "[run-service]
    Usage: `basename $0` {arg}
    e.g. `basename $0` --start "$temp_serivce_name"
    --start <SERVICE>
    --stop <SERVICE>
    --status <SERVICE>
    --restart <SERVICE>
    -h, --help
    "
}

if [ ! -n "$1" ];then
    usage
    exit 1
fi

case "$1" in
    --start)
      shift
      start $@
      ;;
    --stop)
      shift
      stop $@
      ;;
    --status)
      shift
      status $@
      ;;
    --restart)
      shift
      restart $@
      ;;
    -h | --help)
      usage
      exit
      ;;
    *)
      usage
      exit 1
      ;;
esac
