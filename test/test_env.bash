#!/bin/bash
# Image to test
: ${IMAGE:=abtpeople/pentaho-di:test}

# Hostname to test connections
CONTAINER_HOST=localhost
if boot2docker 2> /dev/null && [ $( boot2docker status ) = "running" ]; then
  CONTAINER_HOST=$( boot2docker ip )
fi
