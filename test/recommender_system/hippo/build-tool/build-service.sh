# #!/usr/bin/env bash
export PROJECT_HOME="$(cd "`dirname "$0"`"/../..; pwd)"
export PROJECT_NAME="$(basename ${PROJECT_HOME})"

export HIPPO_DIR=${PROJECT_HOME}/hippo
export HIPPO_BIN_DIR=${HIPPO_DIR}/bin
export HIPPO_CONF_DIR=${HIPPO_DIR}/etc

. "${HIPPO_CONF_DIR}/env.sh"
. "${HIPPO_DIR}"/build-tool/build-utils.sh

function create_service(){
    log_info "Start to create service"
    create_service_func $SERVICE_NAME "$CMD"
}
function delete_service(){
    log_info "Start to delete service"
    delete_service_func $SERVICE_NAME
}
function list_services(){
    list_services_func
}
function check_service(){
    check_service_func $SERVICE_NAME
}

function usage ()
{
    echo "[build-service] SERVICE
    Usage: `basename $0`
    e.g. `basename $0`
    OPTIONS:
       -h|--help                    Show this message
       -c|--create-service=SERVICE  Create a service
       -d|--delete-service=SERVICE  Delete a service
       -l|--list-services           List services
       --check-service=SERVICE      Check service existed by SERVICE
       --cmd=\"CMD\"                  Command to run to service (py, jar, sh...) , you can use \"\\\${PROJECT_HOME}\" variable (${PROJECT_HOME}) to build command
    "
}
args=`getopt -o hlc:d: --long create-service:,delete-service:,check-service:,cmd:,list-services,help \
     -n 'build' -- "$@"`

if [ $? != 0 ] ; then
  echo "terminating..." >&2 ;
  exit 1 ;
fi
eval set -- "$args"



while true ; do
  case "$1" in
    -l|--list-services)
        IS_LIST_SERVICES="true"
         shift
          ;;
    --check-service)
        IS_CHECK_SERVICE="true"
        SERVICE_NAME="$2";
        shift 2
        if [[ -z $SERVICE_NAME ]] ; then
          echo "$(basename $0): missing SERVICE_NAME"
          usage
          exit 1
        fi
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
    --cmd)
        CMD=$2;
        shift 2
        ;;
    -h|--help )
        usage
        exit
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



# call function

if [[ -n $IS_CHECK_SERVICE ]]; then
  check_service
  exit $RETVAL
fi


if [[ -n $IS_LIST_SERVICES ]]; then
  list_services
fi


if [[ -n $IS_CREATE_SERVICE ]]; then
  create_service
fi

if [[ -n $IS_DELETE_SERVICE ]]; then
  delete_service
fi
