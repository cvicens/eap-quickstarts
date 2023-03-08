#!/bin/sh

sudo podman run -it --rm --env-file ./extensions/kitchensink.env -e ENV_FILES=/opt/eap/extensions/kitchensink.env \
  --name kitchensink ${USE_POD} localhost/kitchensink:latest bash



