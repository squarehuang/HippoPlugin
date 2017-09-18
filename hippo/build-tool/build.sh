# #!/usr/bin/env bash
export PROJECT_HOME="$(cd "`dirname "$0"`"/../..; pwd)"
export PROJECT_NAME="$(basename ${PROJECT_HOME})"

export HIPPO_DIR=${PROJECT_HOME}/hippo
export HIPPO_BIN_DIR=${HIPPO_DIR}/bin
export HIPPO_CONF_DIR=${HIPPO_DIR}/etc

. "${HIPPO_CONF_DIR}/env.sh"
. "${HIPPO_DIR}"/build-tool/build-utils.sh


function usage ()
{
    echo "[build-service]
    Usage: `basename $0` [OPTIONS] PROJECT_PATH
    e.g. `basename $0` --install /apps/hippo_service_test1
    OPTIONS:
       -h|--help                             Show this message
       -i|--install                          Install Hippo Plugin to PROJECT_PATH
       -u|--uninstall                        Uninstall Hippo Plugin from PROJECT_PATH
       --check-install                       Check Plugin install on PROJECT_PATH
       -c|--create-service=SERVICE           Create a service
       -d|--delete-service=SERVICE           Delete a service
       -l|--list-services                    List services
       --check-service=SERVICE               Check service existed by SERVICE
       --cmd=\"CMD\"                         Command to run to service (py, jar, sh...) , you can use \"\\\${PROJECT_HOME}\" variable (${PROJECT_HOME}) to build command

    "
}
args=`getopt -o ilhuc:d: --long create-service:,delete-service:,check-service:,cmd:,list-services,install,uninstall,check-install,help \
     -n 'build' -- "$@"`

if [ $? != 0 ] ; then
  echo "terminating..." >&2 ;
  exit 1 ;
fi
eval set -- "$args"



while true ; do
  case "$1" in
    -i|--install)
         IS_INSTALL="true"
         shift
          ;;
    -u|--uninstall)
         IS_UNINSTALL="true"
         shift
          ;;
    -l|--list-services)
         IS_LIST_SERVICES="true"
         shift
          ;;
    -c|--create-service)
         IS_CREATE_SERVICE="true"
         SERVICE_NAME="$2";
         shift 2
         if [[ -z $SERVICE_NAME ]] ; then
           echo "$(basename $0): missing SERVICE_NAME"
           usage
           exit 1
         fi
         ;;
    -d|--delete-service)
        IS_DELETE_SERVICE="true"
        SERVICE_NAME="$2";
        shift 2
        if [[ -z $SERVICE_NAME ]] ; then
          echo "$(basename $0): missing SERVICE_NAME"
          usage
          exit 1
        fi
        ;;
    -h|--help )
        usage
        exit
        ;;
    --check-install )
        IS_CHECK_INSTALL="true"
        shift
        ;;
    --check-service )
        IS_CHECK_SERVICE="true"
        SERVICE_NAME="$2";
        shift 2
        if [[ -z $SERVICE_NAME ]] ; then
          echo "$(basename $0): missing SERVICE_NAME"
          usage
          exit 1
        fi
        ;;
    --cmd)
        CMD=$2;
        shift 2
        ;;
    --)
        shift ;
        break
        ;;
    *)
        echo "internal error!" ;
        exit 1
        ;;
  esac
done


for arg do
   PROJECT_PATH=$arg
done
# check for required args
if [[ -z $PROJECT_PATH ]] ; then
  echo "$(basename $0): missing PROJECT_PATH"
  usage
  exit 1
fi

function check_installed(){
    if [[ ! -d $PROJECT_PATH/hippo ]] ; then
      log_info " Hippo Plugin not exists on $PROJECT_PATH"
      RETVAL=1
    else
      log_info " Hippo Plugin already installed on $PROJECT_PATH"
      RETVAL=0
    fi

    return "$RETVAL"
}

function check_service(){
   check_installed
   retval_is_install=$?
    if [[ $retval_is_install == 1 ]] ; then
      RETVAL=1
      exit "$RETVAL"
    fi

    $PROJECT_PATH/hippo/build-tool/build-service.sh --check-service $SERVICE_NAME

}

function install(){
    check_installed
    retval_is_install=$?
    if [[ $retval_is_install == 0 ]] ; then
      exit
    fi
    log_info " Install Plugin on $PROJECT_PATH"
    install_plugin_func $PROJECT_PATH
}

function uninstall(){
    check_installed
    retval_is_install=$?
    if [[ $retval_is_install == 0 ]] ; then
      log_info " Uninstall Plugin on $PROJECT_PATH"
      uninstall_plugin_func $PROJECT_PATH
    fi


}

function create_service(){
    check_installed
    retval_is_install=$?
    if [[ $retval_is_install == 1 ]] ; then
      install
    fi

    if [[ -n $CMD ]] ; then
      $PROJECT_PATH/hippo/build-tool/build-service.sh --create-service $SERVICE_NAME --cmd "$CMD"
    else
      $PROJECT_PATH/hippo/build-tool/build-service.sh --create-service $SERVICE_NAME
    fi
}
function delete_service(){
  check_installed
  retval_is_install=$?
  if [[ $retval_is_install == 1 ]] ; then
    install
  fi
  $PROJECT_PATH/hippo/build-tool/build-service.sh --delete-service $SERVICE_NAME
}
function list_services(){
  # log_info "list services"
  # list_services_func
  check_installed
  retval_is_install=$?
  if [[ $retval_is_install == 1 ]] ; then
    RETVAL=1
    exit "$RETVAL"
  fi

  $PROJECT_PATH/hippo/build-tool/build-service.sh --list-services
}

# call function

if [[ -n $IS_CHECK_INSTALL ]]; then
  check_installed
  exit $RETVAL
fi

if [[ -n $IS_CHECK_SERVICE ]]; then
  check_service
  exit $RETVAL
fi


if [[ -n $IS_LIST_SERVICES ]]; then
  list_services
fi

if [[ -n $IS_INSTALL ]]; then
  install
  exit $RETVAL
fi

if [[ -n $IS_UNINSTALL ]]; then
  uninstall
  exit $RETVAL
fi

if [[ -n $IS_CREATE_SERVICE ]]; then
  create_service
fi

if [[ -n $IS_DELETE_SERVICE ]]; then
  delete_service
fi
