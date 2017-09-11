# #!/usr/bin/env bash
export APP_HOME="$(cd "`dirname "$0"`"/../..; pwd)"
export PROJECT_NAME="$(basename ${APP_HOME})"

HIPPO_DIR=${APP_HOME}/hippo

. "${HIPPO_DIR}"/build-tool/build-utils.sh

function create_service(){
    log_info "Start to create service"
    create_service_func $1
}
function delete_service(){
    log_info "Start to delete service"
    delete_service_func $1
}
function list_services(){
    list_services_func
}
function check_service(){
    check_service_func $1
}

function usage ()
{
    echo "[build-service] SUB_PROJECT_NAME
    Usage: `basename $0`
    e.g. `basename $0`
    OPTIONS:
       -h|--help                             Show this message
       -c|--create-service=SUB_PROJECT_NAME  Create a service
       -d|--delete-service=SUB_PROJECT_NAME  Delete a service
       -l|--list-services                    List services
       --check-service=SUB_PROJECT_NAME    Check service existed by SUB_PROJECT_NAME
    "
}
args=`getopt -o hlc:d: --long create-service:,delete-service:,check-service:,list-services,help \
     -n 'build' -- "$@"`

if [ $? != 0 ] ; then
  echo "terminating..." >&2 ;
  exit 1 ;
fi
eval set -- "$args"



while true ; do
  case "$1" in
    -l|--list-services)
        list_services
         shift
          ;;
    -c|--check-service)
          SUB_PROJECT_NAME="$2";
          shift 2
          if [[ -z $SUB_PROJECT_NAME ]] ; then
            echo "$(basename $0): missing SUB_PROJECT_NAME"
            usage
            exit 1
          fi
          check_service $SUB_PROJECT_NAME
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
