#!/bin/bash

# Logs a header message. This is written to the operation's logs.
# TODO: change function name
# TODO: stop using tee, instead customer logs should all be written to the operation, not stdout.
trace() {
    echo -e "\n>>> $@ ...\n" | tee -a $ACTION_OUTPUT
}

# Logs a standard message. This is written to the operation's logs.
# TODO: consider writing directly to operation logs to support a better live view of the operation.
log() {
  echo -e "$@" | tee -a $ACTION_OUTPUT
}

# Logs an error message. This is written to the operation's logs.
error() {
    echo "Error: $@" 1>&2 | tee -a $ACTION_OUTPUT
}