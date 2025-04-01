#!/bin/bash

upgradeCli() {
  UPGRADE_CLI_URL=$(set -e; ade upgrade 2> >(tee -a $ADE_ERROR_LOG))
  if [ -n "$UPGRADE_CLI_URL" ]; then
    verbose "Upgrading ADE CLI to latest version"
    wget -O ade-upgrade.zip $UPGRADE_CLI_URL
    mkdir ade-upgrade && unzip ade-upgrade.zip -d ade-upgrade && cd /ade-upgrade
    cp -f ade ../adecli/ade && cp -f appsettings.json ../adecli/ && cd ..
  fi
  verbose "ADE CLI is up to date"
}

executeCommand() {
    ade execute --operation $ADE_OPERATION_NAME --command $* 2> >(tee -a $ADE_ERROR_LOG)
    source /tmp/diff.sh
}

verbose() {
  echo -e "$*"
  ade log --type verbose --operation $ADE_OPERATION_NAME --content "$*"
}

header() {
  echo -e "\n>>> $* ...\n"
  ade log --operation $ADE_OPERATION_NAME --content "\n>>> $* ...\n"
}

log() {
  echo -e "$*" 
  ade log --operation $ADE_OPERATION_NAME --content "$*"
}

error() {
  echo -e "$*"
  ade log --operation $ADE_OPERATION_NAME --type error --content "$*"
}