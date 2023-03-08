#!/bin/sh

# --env-file ./extensions/kitchensink.env -e ENV_FILES=/opt/eap/extensions/kitchensink.env 

sudo podman run -it --rm \
  -e DB_HOST=192.168.50.17 \
  -e DB_PORT=5432 \
  -e DB_NAME=kitchensink \
  -e DB_USERNAME=luke \
  -e DB_PASSWORD=secret \
  -p 8080:8080 \
  --name kitchensink ${USE_POD} localhost/kitchensink:latest bash



