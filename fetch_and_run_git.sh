#!/bin/bash

# Copyright 2013-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

# This script can help you download and run a script from S3 using aws-cli.
# It can also download a zip file from S3 and run a script from inside.
# See below for usage instructions.

PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
BASENAME="${0##*/}"

usage () {
  if [ "${#@}" -ne 0 ]; then
    echo "* ${*}"
    echo
  fi
  cat <<ENDUSAGE
Run

Usage:

${BASENAME} giturl entrypoint [-r]

giturl: a git url, e.g. https://github.com/patrickmineault/your-head-is-there-to-move-you-around.git
entrypoint: an entrypoint, e.g. run.sh

-r: install requirements.txt from giturl before doing anything else.
ENDUSAGE
  exit 2
}

# Standard function to print an error and exit with a failing return code
error_exit () {
  echo "${BASENAME} - ${1}" >&2
  exit 1
}

# Check that necessary programs are available
which git >/dev/null 2>&1 || error_exit "Unable to find git CLI executable."
which unzip >/dev/null 2>&1 || error_exit "Unable to find unzip executable."

# Create a temporary directory to hold the downloaded contents, and make sure
# it's removed later, unless the user set KEEP_BATCH_FILE_CONTENTS.
cleanup () {
   if [ -z "${KEEP_BATCH_FILE_CONTENTS}" ] \
     && [ -n "${TMPDIR}" ] \
     && [ "${TMPDIR}" != "/" ]; then
      rm -r "${TMPDIR}"
   fi
}
trap 'cleanup' EXIT HUP INT QUIT TERM

# Fetch and run a script
fetch_and_run_script () {
  # Create a temporary file and download the script
  git clone "$1" "./repo"
  cd ./repo; 

  if [ "$3" == "-r" ]; then
    pip install -r requirements.txt
  fi

  # Make the temporary file executable and run it with any given arguments
  chmod u+x "$2" || error_exit "Failed to chmod script."
  exec "./$2"
}

if [ -z "$1" ]; then
  error_exit "Must specify a repository to clone"
fi;

if [ -z "$2" ]; then
  error_exit "Must specify a shell script to run"
fi;

fetch_and_run_script "${@}"