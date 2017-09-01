#!/usr/bin/env bash

export APP_HOME="$(cd "`dirname "$0"`"/../../..; pwd)"

# project folder name , e.g. hippos.service.test1
PROJECT_NAME="$(basename ${APP_HOME})"
# auto generate subproject name
SUB_PROJECT_NAME=
HIPPO_DIR=${APP_HOME}/hippo
HIPPO_BIN_DIR=${HIPPO_DIR}/bin
HIPPO_SBIN_DIR=${HIPPO_DIR}/sbin
HIPPO_CONF_DIR=${HIPPO_DIR}/etc
HIPPO_LOG_DIR=${HIPPO_DIR}/var/logs


. "${HIPPO_CONF_DIR}/env.sh"
. "${HIPPO_BIN_DIR}/runtime-env-info.sh"
. "${HIPPO_CONF_DIR}/${SUB_PROJECT_NAME}/${PROJECT_NAME}-${SUB_PROJECT_NAME}-env.sh"

while read assignment; do
  if [[ $assignment != *"#"* ]] ; then
    if [ ! -z "$assignment" -a "$assignment" != " " ]; then
      export "$assignment"
    fi
  fi
done < ${HIPPO_CONF_DIR}/env.sh

function start() {
  cmd=$EXECUTE_CMD
  sh ${HIPPO_SBIN_DIR}/daemon.sh ${PROJECT_NAME}-${SUB_PROJECT_NAME} start 1 $cmd
}

function stop() {
  sh ${HIPPO_SBIN_DIR}/daemon.sh ${PROJECT_NAME}-${SUB_PROJECT_NAME} stop 1
}

function status() {
  sh ${HIPPO_SBIN_DIR}/daemon.sh ${PROJECT_NAME}-${SUB_PROJECT_NAME} status 1
}

function restart() {
  stop ${PROJECT_NAME}-${SUB_PROJECT_NAME}
  start ${PROJECT_NAME}-${SUB_PROJECT_NAME}
}

function usage ()
{
    echo "[${PROJECT_NAME}-${SUB_PROJECT_NAME}]
    Usage: `basename $0` {arg}
    e.g. `basename $0` --start
    --start
    --stop
    --status
    --restart
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
      start
      ;;
    --stop)
      shift
      stop
      ;;
    --status)
      shift
      status
      ;;
    --restart)
      shift
      restart
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
