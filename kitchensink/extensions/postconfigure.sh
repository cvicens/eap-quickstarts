#!/usr/bin/env bash

set -x
echo ">>>>>> Executing postconfigure.sh <<<<<<<"

echo ">>>>>> Executing config-system-properties.cli <<<<<<<"
$JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/extensions/config-system-properties.cli

echo ">>>>>> Executing kitchensink-ds.cli <<<<<<<"
$JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/extensions/kitchensink-ds.cli

