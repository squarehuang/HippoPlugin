function log_info (){
    echo "[INFO]$*"
}

function log_warn (){
    echo "[WARN]$*"
}

function log_error (){
    echo
    echo "[ERROR]$*"
    echo
    exit 1
}
# if [ -z "${PROJECT_HOME}" ]; then
#   export PROJECT_HOME="$(cd "`dirname "$0"`"/../..; pwd)"
# fi

# PROJECT_NAME="$(basename ${PROJECT_HOME})"
# HIPPO_DIR=${PROJECT_HOME}/hippo
# HIPPO_BIN_DIR=${HIPPO_DIR}/bin
# HIPPO_CONF_DIR=${HIPPO_DIR}/etc
# . "${HIPPO_CONF_DIR}/env.sh"



function sed_command (){
    # sed command is different in Linux and MacOS, so we need this function
    os=$(uname -s)
    if [ $os == "Linux" ]; then
        sed -i $1 $2
    elif [ $os == "Darwin" ]; then
        sed -i '' $1 $2
    fi
}

function stat_permission (){
    # stat command is different in Linux and MacOS, so we need this function
    os=$(uname -s)
    if [ $os == "Linux" ]; then
        stat -c %a $1
    elif [ $os == "Darwin" ]; then
        stat -f %Lp $1
    fi
}

function install_plugin_func (){
  project_path=$1
  # TODO check permission
  # clone hippo folder to target project
  rsync -avz --exclude 'build.sh' "${HIPPO_DIR}" ${project_path}/
  chmod -R 755 ${project_path}/hippo
  if [[ -d ${project_path}/hippo ]] ; then
    log_info " Hippo Plugin successfully installed on ${project_path}"
  fi
}

function uninstall_plugin_func (){
  project_path=$1
  if [[ -d ${project_path}/hippo ]] ; then
    rm -r ${project_path}/hippo
    if [[ ! -d ${project_path}/hippo ]] ; then
      log_info " Hippo Plugin was successfully uninstalled from ${project_path}"
    fi
  fi
}

function create_service_func (){
    service_name=$1
    shift
    cmd=$1
    ENV_PATH="${HIPPO_CONF_DIR}/env.sh"
    ## read service_name
    if [[ $SERVICE_LIST =~ $service_name ]]; then
      log_warn "a Service name \"${service_name}\" is already existed, please type another one"
      exit 1
    elif [[ -z ${service_name} ]]; then
      exit 1
    fi

    if [ -d "${HIPPO_BIN_DIR}/${service_name}" ]; then rm -r "${HIPPO_BIN_DIR}/${service_name}"; fi
    if [ -d "${HIPPO_CONF_DIR}/${service_name}" ]; then rm -r "${HIPPO_CONF_DIR}/${service_name}"; fi


    # get SERVICE_LIST values from env.sh
    if [ -z ${SERVICE_LIST} ]; then
      service_value="$service_name"
    else
      service_value="${SERVICE_LIST},${service_name}"
    fi
    # substitute service value
    grep -q "^SERVICE_LIST" "$ENV_PATH" && sed_command "s/^SERVICE_LIST.*/SERVICE_LIST=\"${service_value}\"/" "$ENV_PATH" || echo "SERVICE_LIST=\"${service_value}\"" >> "$ENV_PATH"

    # generate service folder and run shell
    # filename pattern : run-${service_name}.sh
    mkdir -p "${HIPPO_BIN_DIR}/${service_name}"
    log_info "[BUILD] create folder : ${HIPPO_BIN_DIR}/${service_name}"
    rsync -az "${HIPPO_DIR}/build-tool/.template/bin/run-template.sh" "${HIPPO_BIN_DIR}/${service_name}/run-template.sh"
    # add service name into run script
    sed_command "s/^SERVICE_NAME=.*/SERVICE_NAME=\"${service_name}\"/" "${HIPPO_BIN_DIR}/${service_name}/run-template.sh"
    mv "${HIPPO_BIN_DIR}/${service_name}/run-template.sh" "${HIPPO_BIN_DIR}/${service_name}/run-${service_name}.sh"
    chmod 755 "${HIPPO_BIN_DIR}/${service_name}/run-${service_name}.sh"

    # generate service folder and env file
    # filename pattern : ${service_name}-env.sh
    mkdir -p "${HIPPO_CONF_DIR}/${service_name}"
    log_info "[BUILD] create folder : ${HIPPO_CONF_DIR}/${service_name}"
    rsync -az "${HIPPO_DIR}/build-tool/.template/etc/template-env.sh" "${HIPPO_CONF_DIR}/${service_name}/${service_name}-env.sh"
    chmod 755 "${HIPPO_CONF_DIR}/${service_name}/${service_name}-env.sh"

    if [[ -n $cmd ]] ; then
      log_info "[BUILD] add EXECUTE_CMD=\"${cmd}\" to ${HIPPO_CONF_DIR}/${service_name}/${service_name}-env.sh"
      sed_command "/^EXECUTE_CMD/d" "${HIPPO_CONF_DIR}/${service_name}/${service_name}-env.sh"
      echo "EXECUTE_CMD=\"${cmd}\"" >> "${HIPPO_CONF_DIR}/${service_name}/${service_name}-env.sh"
    fi
    log_info "[BUILD] Service Name : ${service_name}"
}

function delete_service_func() {
    service_name=$1
    ENV_PATH="${HIPPO_CONF_DIR}/env.sh"
    if [[ ! -d ${HIPPO_BIN_DIR}/${service_name} ]] && [[ ! -d ${HIPPO_CONF_DIR}/${service_name} ]]; then
        log_warn "Service name \"${service_name}\" is not existed"
        yn=""
    else
      # delete service_name folder and modify env.sh
      if [ -d "${HIPPO_BIN_DIR}/${service_name}" ]; then rm -r "${HIPPO_BIN_DIR}/${service_name}"; fi
      if [ -d "${HIPPO_CONF_DIR}/${service_name}" ]; then rm -r "${HIPPO_CONF_DIR}/${service_name}"; fi

      sed_command "s/\"${service_name},/\"/g" "$ENV_PATH"
      sed_command "s/,${service_name},/,/g" "$ENV_PATH"
      sed_command "s/,${service_name}\"/\"/g" "$ENV_PATH"
      log_info "[DELETE] Service Name : ${service_name}"
    fi
}
function list_services_func() {
    printf "%-40s %-40s %-40s \n" PROJECT_NAME SERVICE_NAME

    for element in ${SERVICE_LIST//,/ } ; do
      printf '%-40s %-40s %-40s \n' ${PROJECT_NAME} ${element}
    done
}

function check_service_func() {
    service_name=$1
    if [[ $SERVICE_LIST =~ $service_name ]]; then
      exit 0
    else
      log_warn "a Service name \"${service_name}\" not exists"
      exit 1
    fi


}
