#!/bin/sh

sudo podman rm pg
sudo podman run --name pg \
  -p 5432:5432 \
  -e POSTGRESQL_PASSWORD=secret \
  -e POSTGRESQL_USER=luke \
  -e POSTGRESQL_ADMIN_PASSWORD=secret \
  -e POSTGRESQL_DATABASE=kitchensink \
  registry.access.redhat.com/rhscl/postgresql-10-rhel7:1