#!/bin/bash

# usage:
# start_run "title of the action"
# run "command 1"
# run "command 2"
# end_run

RED='\033[0;31m'
GREEN='\033[0;32m'
NORMAL='\033[0m'

RUN_STATE="/"
RUN_LOG_FILE=setup.log
RUN_RETURN_CODE=0

function print_sleep (){
    printf "\b$RUN_STATE" && sleep 0.1
}

function rotate_until (){
    while kill -0 $1 2> /dev/null; do
        case "$RUN_STATE" in
        "-")
            RUN_STATE="\\"
            print_sleep 
            ;;
        "\\")
            RUN_STATE="|"
            print_sleep 
            ;;
        "|")
            RUN_STATE="/"
            print_sleep 
            ;;
        "/")
            RUN_STATE="-"
            print_sleep 
            ;;
        esac
    done
}

function start_run(){
    if ! test -f "$RUN_LOG_FILE" ; then
        touch "$RUN_LOG_FILE"
    fi

    echo >> $RUN_LOG_FILE
    echo "### $@ ###" >> $RUN_LOG_FILE
    printf "   $@  "
}

function run (){
    if [[ "$RUN_RETURN_CODE" -eq 0 ]]; then
        { $@ ;} 2>>$RUN_LOG_FILE 1>>$RUN_LOG_FILE & 
        PID=$!
        rotate_until $PID
        wait $PID
        RUN_RETURN_CODE=$?
    else
        echo "the previous task was not run due to an error" >>$RUN_LOG_FILE
    fi
}

function end_run(){
    if [[ "$RUN_RETURN_CODE" -eq 0 ]]; then
        printf "\b... ${GREEN}done${NORMAL}\n"
    else
        printf "\b... ${RED}fail${NORMAL} --> check the log in setup.log\n"
        exit 1
    fi

}
