#!/bin/bash
# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# Downloads necessary to build with OPTIMIZED_KERNEL_DIR=xtensa.
#
# Called with four arguments:
# 1 - Path to the downloads folder which is typically
#     tensorflow/lite/micro/tools/make/downloads
# 2 - URL to downoad external library
# 3 - Name of the library directory once it is unzipped.
# 4 - MD5 checksum for library
#
# This script is called from the Makefile and uses the following convention to
# enable determination of sucess/failure:
#
#   - If the script is successful, the only output on stdout should be SUCCESS.
#     The makefile checks for this particular string.
#
#   - Any string on stdout that is not SUCCESS will be shown in the makefile as
#     the cause for the script to have failed.
#
#   - Any other informational prints should be on stderr.

set -e

DOWNLOADS_DIR=${1}
if [ ! -d ${DOWNLOADS_DIR} ]; then
  echo "The top-level downloads directory: ${DOWNLOADS_DIR} does not exist."
  exit 1
fi

# URL to downoad external library
LIBRARY_URL=${2}
# Name of the library directory once it is unzipped.
LIBRARY_DIRNAME=${3}
# MD5 checksum
LIBRARY_MD5=${4}

LIBRARY_INSTALL_PATH=${DOWNLOADS_DIR}/${LIBRARY_DIRNAME}
if [ -d ${LIBRARY_INSTALL_PATH} ]; then
  echo >&2 "${LIBRARY_INSTALL_PATH} already exists, skipping the download."
else
  TMP_ZIP_ARCHIVE_NAME="xtensa_library.zip"
  wget ${LIBRARY_URL} -O /tmp/${TMP_ZIP_ARCHIVE_NAME} >&2
  MD5=`md5sum /tmp/${TMP_ZIP_ARCHIVE_NAME} | awk '{print $1}'`

  if [[ ${MD5} != ${LIBRARY_MD5} ]]
  then
    echo "Bad checksum. Expected: ${LIBRARY_MD5}, Got: ${MD5}"
    exit 1
  fi

  unzip -qo /tmp/${TMP_ZIP_ARCHIVE_NAME} -d ${DOWNLOADS_DIR} >&2
fi

echo "SUCCESS"
