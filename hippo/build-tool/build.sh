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
    "
}
args=`getopt -o ilhc:d: --long create-service:,delete-service:,list-services,install,check-install,help \
     -n 'build' -- "$@"`

if [ $? != 0 ] ; then
  echo "terminating..." >&2 ;
  exit 1 ;
fi
eval set -- "$args"



while true ; do
  case "$1" in
    -i|--install)
         install
         IS_INSTALL="true"
         shift
          ;;
    -l|--list-services)
         IS_LIST_SERVICES="true"
         shift
          ;;
    -c|--create-service)
         SUB_PROJECT_NAME="$2";
         shift 2
         if [[ -z $SUB_PROJECT_NAME ]] ; then
           echo "$(basename $0): missing SUB_PROJECT_NAME"
           usage
           exit 1
         fi
         create_service $SUB_PROJECT_NAME
         ;;
    -d|--delete-service)
        SUB_PROJECT_NAME="$2";
        shift 2
        if [[ -z $SUB_PROJECT_NAME ]] ; then
          echo "$(basename $0): missing SUB_PROJECT_NAME"
          usage
          exit 1
        fi
        delete_service $SUB_PROJECT_NAME
        ;;
    -h|--help )
        usage
        exit
        ;;
    --check-install )
        IS_CHECK_INSTALL="true"
        shift
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
      echo " Hippo Plugin not existed on $PROJECT_PATH"
      RETVAL=1
    else
      log_info " Hippo Plugin already installed on $PROJECT_PATH"
      RETVAL=0
    fi
}

function install(){
    log_info "Start to create service"
    create_service_func $1
}

function create_service(){
    log_info "Start to create service"
    create_service_func $1
}
function delete_service(){
    log_info "Start to delete service"
    delete_service_func $1
}
function list_services(){
    # log_info "list services"
    list_services_func
}

# call function

if [[ -n $IS_CHECK_INSTALL ]]; then
  check_installed
  exit $RETVAL
fi

if [[ -n $IS_LIST_SERVICES ]]; then
  list_services
fi
