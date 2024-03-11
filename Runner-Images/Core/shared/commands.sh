#!/bin/bash
verbose() {
  echo -e "$*"
  ade log --type verbose --content "$*"
}

header() {
  echo -e "\n>>> $* ...\n"
  ade log --content "\n>>> $* ...\n"
}

log() {
  echo -e "$*" 
  ade log --content "$*" 

  #If error log is not empty, call error function; then exit with error code DeploymentError
  if [ -s $ADE_ERROR_LOG ]; then
    errorMessage="$(cat $ADE_ERROR_LOG)"

    if [ $(echo "$errorMessage" | jq empty > /dev/null 2>&1; echo $?) -eq 0 ]; then
        # the component deployment output was identified as JSON - lets extract some error information to return a more meaningful output
        errorMessage="$( echo $errorMessage | jq --raw-output '.. | .message? | select(. != null) | "Error: \(.)\n"' | sed 's/\\n/\n/g'  )"
    fi

    error "$errorMessage" 
    exit 1
  fi
}

error() {
  echo -e "$*"
  ade log --type error --content "$*"
}