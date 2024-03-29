#+----------------------------------------------------------------------------------------------------------+
# Functions

#################################
# Set env
#################################


# DESC: Generic script initialisation
function initScript() {
    # Script time
    readonly time_start="$(date +%s)"
    readonly fmt_time_start="$(date -d @${time_start} "+%Y-%m-%d %H:%M:%S")"

    # Useful paths
    readonly orig_cwd="$PWD"
    readonly script_path="${BASH_SOURCE[1]}"
    readonly script_dir="$(dirname "$script_path")"
    readonly script_name="$(basename "$script_path")"
    readonly script_params="$*"

    #+----------------------------------------------------------------------------+
    # Directories pathes
    readonly bin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    readonly root_dir="$(realpath $bin_dir/..)"
    readonly conf_dir="${root_dir}/config"
    readonly sql_dir="${root_dir}/sql"
    readonly var_dir="${root_dir}/var"
    readonly log_dir="${var_dir}/log"
    readonly tmp_dir="${var_dir}/tmp"

    #+----------------------------------------------------------------------------+
    # Shell colors
    readonly RCol="\e[0m";# Text Reset
    readonly Red="\e[1;31m"; # Text Dark Red
    readonly Gre="\e[1;32m"; # Text Dark Green
    readonly Yel="\e[1;33m"; # Text Yellow
    readonly Mag="\e[1;35m"; # Text Magenta
    readonly Gra="\e[1;30m"; # Text Dark Gray
    readonly Whi="\e[1;37m"; # Text Dark White
    readonly Blink="\e[5m"; #Text blink

    #+----------------------------------------------------------------------------+
    # Section separator
    readonly sep_limit=100
    readonly sep="$(printf "=%.0s" $(seq 1 ${sep_limit}))\n"

    #+----------------------------------------------------------------------------+
    # Important to always set as we use it in the exit handler
    readonly ta_none="$(tput sgr0 2> /dev/null || true)"
}

# DESC log
# ARGS  
#       $1 : log_type 
#       $2 : log message
# OUT none
log() {
    
    if [[ $# -lt 2 ]]; then
        exitScript 'log 2 arguments required' 2
    fi

    log_type=$1
    log_message=$2

    if [ "${log_type}" = "RESTORE" ] ; then
        log_file=${restore_oo_log_file}
    fi

    if [ "${log_type}" = "SQL" ] ; then
        log_file=${sql_log_file}
    fi

    if [ -z "${init_time}" ] ; then 
        init_time=$(date +%s)
    fi

    cur_time=$(date +%s)
    elapsed_time=$(date -u -d "0 ${cur_time} seconds - ${init_time} seconds" +"%H:%M:%S")
 
    echo >> ${log_file}
    echo "(${elapsed_time}) ${log_message}" >> ${log_file}

    if [ -n "${verbose}" ] ; then
        echo "${echo_opts} - (${elapsed_time}) ${log_message}"
    fi
}

# ARGS $1 file
        # $2 exit message
#
checkError() {
    file_path=$1
    exitMessage=$2
    cmd=$3
    err=$(grep -A1 -i -E 'erreur|error' ${file_path})

    if [ -n "$err" ] ; then
        exitScript "${exitMessage}\n\n${err}\n\n${cmd}" 2
    fi
}


# DESC: exec a ps file
# ARGS: $1 : db_name
#       $2 : file_path
#       $3 : msg_log
#       $4 : msg_error
#
exec_sql_file() {

    db_name=$1
    file_path=$2
    msg_log=$3
    options=$4

    log SQL "${msg_log}"

    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_name} \
        ${options} \
        -f ${file_path} \
        &>> ${sql_log_file}

    cmd="psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_name} ${options} -f ${file_path}"

    checkError ${sql_log_file} "${msg_log} : Erreur(s)" "${cmd}"

}

#################################
# ExitScript
#################################

# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
# OUTS: None
# NOTE: The convention used in this script for exit codes is:
#       0: Normal exit
#       1: Abnormal exit due to external error
#       2: Abnormal exit due to script error
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function exitScript() {
    if [[ $# -eq 1 ]]; then
        printf '%s\n' "${1}"
        exit 0
    fi

    if [[ ${2-} =~ ^[0-9]+$ ]]; then
        if [[ ${2} -ne 0 ]]; then
            printError "${1}"
        else
            printInfo "${1}"
        fi
        exit ${2}
    fi

    exitScript 'Missing required argument to exitScript()!' 2
}

# DESC: Pretty print the provided string
# ARGS: $1 (required): Message to print (defaults to a yellow)
#       $2 (optional): Colour to print the message with. This can be an ANSI
#                      escape code.
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function printPretty() {
    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required argument to printPretty()!' 2
    fi

    if [[ -n ${2-} ]]; then
        echo -e "${2}${1}${RCol}"
    else
        echo -e "${Yel}${1}${RCol}"
    fi
}

function clean_media_file_name() {
    find -wholename "*media*[ \(\)']*" -type f | rename "s/[ \(\)']/_/g"

}

function printTitle() {
    if [ ! -n "$cpt_title" ] ; then
        cpt_title=0
    fi

    export cpt_title=$((cpt_title+1))

    printPretty "${cpt_title}. $1"
}

# DESC: Print a section message
# ARGS: $1 (required): Message to print
# OUTS: None
function printMsg() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to printMsg()!' 2
    fi
    printPretty "--> ${1}" ${Yel}
}

# DESC: Print infos message
# ARGS: $1 (required): Message to print
# OUTS: None
function printInfo() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to printInfo()!' 2
    fi
    printPretty "--> ${1}" ${Whi}
}

# DESC: Print an error message
# ARGS: $1 (required): Message to print
# OUTS: None
function printError() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to printError()!' 2
    fi
    printPretty "--> ${1}" ${Red}
}

# DESC: Only printPretty() the provided string if verbose mode is enabled
# ARGS: $@ (required): Passed through to printPretty() function
# OUTS: None
# SOURCE: https://github.com/ralish/bash-script-template/blob/stable/source.sh
function printVerbose() {
    if [[ -n ${verbose-} ]]; then
        printPretty "${@}"
    fi
}


#################################
# Get value
#################################

# DESC: get value of var whose name is $1_$2 
# ARGS: $1 : first part var name
#       $2 : second part (key) of var name 
# OUTS: var value (echo)
# USAGE: a=$(getValue GeoNature_org)
function getValue() {
    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required arguments (1) to getValue()' 2
    fi

    var_name=$1
    var_value=${!var_name}
    echo $var_value
}


    # export PGPASSWORD=${user_pg_pass}; \
    #     psql -h ${db_host}  -p ${db_port} -U ${user_pg} \
    #     -d ${db_name} \
    #     ${s_action}



# DESC: check if DB exists
# ARGS: $1 : database name
# OUTS: 0 if true
# USAGE: database_exists test
function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf
    # as appropriate.

    db_name=$1

    if [ -z $1 ]
        then
        # Argument is null
        return 1
    else
        # Grep DB name in the list of databases
        export PGPASSWORD=${user_pg_pass};\
        psql -tAl -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres -tAl | grep  "${db_name}|"  > /dev/null
        
        return $?
    fi
}

# DESC: check if schema exists
# ARGS: $1 : database name
#       $2 : schema name
# OUTS: 0 if false
# USAGE: schema_exists db_name schema_name
function schema_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf
    # as appropriate.
    if [[ $# -lt 2 ]]; then
        exitScript 'Missing required arguments (2) to schema_exists ()' 2
    fi

    db_name=$1
    schema_name=$2

    if ! database_exists $1; then
        return 1
    fi

    res=$(psql -tA -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_name} -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${schema_name}'")

    if [ -n "$res" ] ; then  
        return 0
    else
        return 1
    fi
}


# DESC: check if table exists
# ARGS: $1 : database name
#       $2 : schema name
#       $3 : table_name
# OUTS: 0 if true
# USAGE: schema_exists db_name schema_name
function table_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf
    # as appropriate.
    if [[ $# -lt 3 ]]; then
        exitScript 'Missing required arguments (3) to table_exists ()' 2
    fi
    
    db_name=$1
    schema_name=$2
    table_name=$3

    if ! schema_exists ${db_name} ${schema_name}; then
        return 1
    fi

    res=$(psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_name} -c "SELECT * FROM information_schema.tables WHERE table_schema = '${schema_name}' AND table_name = '${table_name}';")

    if [ -n "$res" ] ; then  
        return 0
    else
        return 1
    fi
}


test_patch() {
    test_value=$1
    res=$(echo "${patch}" | grep "${test_value}")
    return $?
}