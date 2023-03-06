#!/bin/sh

sudo podman run -it --rm -e ENV_FILES=/opt/eap/extensions/db.env localhost/kitchensink:latest bash

