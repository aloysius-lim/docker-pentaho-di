#!/bin/bash
# Image to test
: ${TAG:=latest}

# Hostname to test connections
CONTAINER_HOST=localhost
if boot2docker 2> /dev/null && [ $( boot2docker status ) = "running" ]; then
  CONTAINER_HOST=$( boot2docker ip )
fi
