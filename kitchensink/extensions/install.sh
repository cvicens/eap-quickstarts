#!/bin/bash
echo ">>>>>>> Running install.sh <<<<<<"
echo ${injected_dir}
if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    echo "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

injected_dir=$1
source /usr/local/s2i/install-common.sh
configure_drivers ${injected_dir}/driver-oracle.env
# configure_drivers ${injected_dir}/driver-postgresql.env
# configure_drivers ${injected_dir}/driver-mysql.env

# copy any needed files into the target build.
cp -rf ${injected_dir} $JBOSS_HOME/extensions

# ${JBOSS_HOME}/bin/jboss-cli.sh --file="${injected_dir}/config-system-properties-empty.cli"