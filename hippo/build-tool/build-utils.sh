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
if [ -z "${APP_HOME}" ]; then
  export APP_HOME="$(cd "`dirname "$0"`"/../..; pwd)"
fi

PROJECT_NAME="$(basename ${APP_HOME})"
HIPPO_DIR=${APP_HOME}/hippo
HIPPO_BIN_DIR=${HIPPO_DIR}/bin
HIPPO_CONF_DIR=${HIPPO_DIR}/etc
. "${HIPPO_CONF_DIR}/env.sh"



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
  retval=$?
  if [[ retval == 0 ]] ; then
    log_info "Hippo Plugin successfully installed on ${project_path}"
  fi
}

function create_service_func (){
    subproject_name=$1
    ENV_PATH="${HIPPO_CONF_DIR}/env.sh"
    ## read subproject name and generate service_name
    service_name="${PROJECT_NAME}-${subproject_name}"
    if [[ $SERVICE_LIST =~ $service_name ]]; then
      log_warn "a Sub-project name \"${subproject_name}\" is already existed, please type another one"
      exit 1
    elif [[ -z ${subproject_name} ]]; then
      exit 1
    fi

    if [ -d "${HIPPO_BIN_DIR}/${subproject_name}" ]; then rm -r "${HIPPO_BIN_DIR}/${subproject_name}"; fi
    if [ -d "${HIPPO_CONF_DIR}/${subproject_name}" ]; then rm -r "${HIPPO_CONF_DIR}/${subproject_name}"; fi


    # get SERVICE_LIST values from env.sh
    if [ -z ${SERVICE_LIST} ]; then
      service_value="$service_name"
    else
      service_value="${SERVICE_LIST},${service_name}"
    fi
    # substitute service value
    grep -q "^SERVICE_LIST" "$ENV_PATH" && sed_command "s/^SERVICE_LIST.*/SERVICE_LIST=\"${service_value}\"/" "$ENV_PATH" || echo "SERVICE_LIST=\"${service_value}\"" >> "$ENV_PATH"

    # generate service folder and run shell
    # filename pattern : run-${PROJECT_NAME}-${SUB_PROJECT_NAME}.sh
    mkdir -p "${HIPPO_BIN_DIR}/${subproject_name}"
    echo "create folder : ${HIPPO_BIN_DIR}/${subproject_name}"
    cp -r "${HIPPO_DIR}/build-tool/.template/bin/run-template.sh" "${HIPPO_BIN_DIR}/${subproject_name}/run-template.sh"

    # add subproject name into run script
    sed_command "s/^SUB_PROJECT_NAME=.*/SUB_PROJECT_NAME=\"${subproject_name}\"/" "${HIPPO_BIN_DIR}/${subproject_name}/run-template.sh"
    mv "${HIPPO_BIN_DIR}/${subproject_name}/run-template.sh" "${HIPPO_BIN_DIR}/${subproject_name}/run-${service_name}.sh"

    # generate service folder and env file
    # filename pattern : ${PROJECT_NAME}-${SUB_PROJECT_NAME}-env.sh
    mkdir -p "${HIPPO_CONF_DIR}/${subproject_name}"
    log_info "[BUILD] create folder : ${HIPPO_CONF_DIR}/${subproject_name}"
    cp -r "${HIPPO_DIR}/build-tool/.template/etc/template-env.sh" "${HIPPO_CONF_DIR}/${subproject_name}/${service_name}-env.sh"

    log_info "[BUILD] Service Name : ${service_name}"
}

function delete_service_func() {
    subproject_name=$1
    ENV_PATH="${HIPPO_CONF_DIR}/env.sh"
    service_name="${PROJECT_NAME}-${subproject_name}"
    if [[ ! -d ${HIPPO_BIN_DIR}/${subproject_name} ]] && [[ ! -d ${HIPPO_CONF_DIR}/${subproject_name} ]]; then
        log_warn "Sub-project name \"${subproject_name}\" is not existed"
        yn=""
    else
      # delete sub-project folder and modify env.sh
      if [ -d "${HIPPO_BIN_DIR}/${subproject_name}" ]; then rm -r "${HIPPO_BIN_DIR}/${subproject_name}"; fi
      if [ -d "${HIPPO_CONF_DIR}/${subproject_name}" ]; then rm -r "${HIPPO_CONF_DIR}/${subproject_name}"; fi

      sed_command "s/\"${service_name},/\"/g" "$ENV_PATH"
      sed_command "s/,${service_name},/,/g" "$ENV_PATH"
      sed_command "s/,${service_name}\"/\"/g" "$ENV_PATH"
      log_info "[DELETE] Service Name : ${service_name}"
    fi
}
function list_services_func() {
    printf "%-40s %-40s %-40s \n" PROJECT_NAME SUB_PROJECT_NAME SERVICE_NAME

    for element in ${SERVICE_LIST//,/ } ; do
      SUB_PROJECT_NAME=$(echo ${element} | sed -e "s/${PROJECT_NAME}-//g" )
      printf '%-40s %-40s %-40s \n' ${PROJECT_NAME} ${SUB_PROJECT_NAME} ${element}
    done
}

function check_service_func() {
    subproject_name=$1
    service_name="${PROJECT_NAME}-${subproject_name}"
    if [[ $SERVICE_LIST =~ $service_name ]]; then
      exit 0
    else
      log_warn "a Sub-project name \"${subproject_name}\" not exists"
      exit 1
    fi


}
