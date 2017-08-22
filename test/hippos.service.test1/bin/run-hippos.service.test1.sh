#!/usr/bin/env bash

PROJECT_NAME="hippos.service.test1"

export APP_HOME="$(cd "`dirname "$0"`"/..; pwd)"

BIN_DIR=$(dirname "$0")
SBIN_DIR=${APP_HOME}/sbin
CONF_DIR=${APP_HOME}/etc

. "${CONF_DIR}/${PROJECT_NAME}-env.sh"
. "${BIN_DIR}/runtime-env-info.sh"

python ${SBIN_DIR}/kafka_app.py &
echo $!
