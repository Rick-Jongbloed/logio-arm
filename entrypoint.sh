#!/usr/bin/env bash
#copied stuff from the docker config for dsmr-reader
# https://github.com/xirixiz/dsmr-reader-docker/blob/master/src/Dockerfile

#set -o errexit
#set -o pipefail
#set -o nounset

#---------------------------------------------------------------------------------------------------------------------------
# VARIABLES
#---------------------------------------------------------------------------------------------------------------------------
: "${DEBUG:=false}"
: "${COMMAND:=$@}"
: "${TIMER:=60}"

function _start_supervisord() {
  _info "Starting supervisord..."
  cmd=$(command -v supervisord)
  "${cmd}" -n
}

_start_supervisord