# #!/usr/bin/env bash
export APP_HOME="$(cd "`dirname "$0"`"/../..; pwd)"
export PROJECT_NAME="$(basename ${APP_HOME})"

HIPPO_DIR=${APP_HOME}/hippo

. "${HIPPO_DIR}"/build-tool/build-utils.sh


function usage ()
{
    echo "[build-service]
    Usage: `basename $0` [OPTIONS] PROJECT_PATH
    e.g. `basename $0` --install /apps/hippo_service_test1
    OPTIONS:
       -h|--help           Show this message
       -i|--install
       --check-install     Check Plugin install on PROJECT_PATH
       -c|--create-service <SUB_PROJECT_NAME>  Create a service by SUB_PROJECT_NAME
       -d|--delete-service <SUB_PROJECT_NAME>  Delete a service by SUB_PROJECT_NAME
       -l|--list-services  List services
       --check-service <SUB_PROJECT_NAME>  Check service existed by SUB_PROJECT_NAME
    "
}
args=`getopt -o ilhc:d: --long create-service:,delete-service:,check-service:,list-services,install,check-install,help \
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
    -l|--list-services)
         IS_LIST_SERVICES="true"
         shift
          ;;
    -c|--create-service)
         IS_CREATE_SERVICE="true"
         SUB_PROJECT_NAME="$2";
         shift 2
         if [[ -z $SUB_PROJECT_NAME ]] ; then
           echo "$(basename $0): missing SUB_PROJECT_NAME"
           usage
           exit 1
         fi
         ;;
    -d|--delete-service)
        IS_DELETE_SERVICE="true"
        SUB_PROJECT_NAME="$2";
        shift 2
        if [[ -z $SUB_PROJECT_NAME ]] ; then
          echo "$(basename $0): missing SUB_PROJECT_NAME"
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
        SUB_PROJECT_NAME="$2";
        shift 2
        if [[ -z $SUB_PROJECT_NAME ]] ; then
          echo "$(basename $0): missing SUB_PROJECT_NAME"
          usage
          exit 1
        fi
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

    $PROJECT_PATH/hippo/build-tool/build-service.sh --check-service $SUB_PROJECT_NAME

}

function install(){
    log_info " Install Plugin"
    check_installed
    retval_is_install=$?
    if [[ $retval_is_install == 0 ]] ; then
      exit
    fi

    install_plugin_func $PROJECT_PATH
}

function create_service(){
    check_installed
    retval_is_install=$?
    if [[ $retval_is_install == 1 ]] ; then
      install
    fi

    subproject_name=$1
    $PROJECT_PATH/hippo/build-tool/build-service.sh --create-service $SUB_PROJECT_NAME
}
function delete_service(){
  check_installed
  retval_is_install=$?
  if [[ $retval_is_install == 1 ]] ; then
    install
  fi
  $PROJECT_PATH/hippo/build-tool/build-service.sh --create-service $SUB_PROJECT_NAME
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

if [[ -n $IS_CREATE_SERVICE ]]; then
  create_service
fi

if [[ -n $IS_DELETE_SERVICE ]]; then
  delete_service
fi
