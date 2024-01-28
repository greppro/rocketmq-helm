#!/bin/bash

check_runtime() {
  java -version
  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Missing java"
    exit "500"
  fi
}

run_as_other_user_if_needed() {
  if [[ "$(id -u)" == "0" ]]; then
    # If running as root, drop to specified UID and run command
    exec chroot --userspec=1000:0 / "${@}"
  else
    # Either we are running in Openshift with random uid and are a member of the root group
    # or with a custom --user
    exec "${@}"
  fi
}

take_file_ownership() {
  if [[ "$(id -u)" == "0" ]]; then
    chown -R 1000:0 "$ROCKETMQ_HOME"
    mkdir -p /etc/rocketmq
    chown -R 1000:0 "/etc/rocketmq"
    if [[ -d "$HOME" ]]; then
      chown -R 1000:0 "$HOME"
    fi
  fi
}

start_server() {
  check_runtime
  run_as_other_user_if_needed "/mq-server-start.sh"
}

take_file_ownership
if [[ "$@" = "start" ]]; then
  start_server
else
  exec "$@"
fi
