#!/usr/bin/env bash

PROJECT_NAME="hippos.service.test1"

export PROJECT_HOME="$(cd "`dirname "$0"`"/..; pwd)"

BIN_DIR=$(dirname "$0")
SBIN_DIR=${PROJECT_HOME}/sbin
CONF_DIR=${PROJECT_HOME}/etc

. "${CONF_DIR}/${PROJECT_NAME}-env.sh"
. "${BIN_DIR}/runtime-env-info.sh"

python ${SBIN_DIR}/kafka_app.py &
echo $!
