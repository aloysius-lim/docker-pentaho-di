#!/usr/bin/env bats

setup() {
  load test_env
  : ${IMAGE:=abtpeople/pentaho-di:$TAG}

  DOCKER_ENV=""
  DOCKER_ENV="$DOCKER_ENV -e CARTE_NAME=mycarte"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_NETWORK_INTERFACE=eth0"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_PORT=8888"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_USER=user"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_PASSWORD=password"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_IS_MASTER=N"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_INCLUDE_MASTERS=Y"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_REPORT_TO_MASTERS=N"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_MASTER_NAME=mymaster"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_MASTER_HOSTNAME=master.domain"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_MASTER_PORT=9999"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_MASTER_USER=masteruser"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_MASTER_PASSWORD=masterpassword"
  DOCKER_ENV="$DOCKER_ENV -e CARTE_MASTER_IS_MASTER=Y"
  CONTAINER=$( docker run -d -p=8888:8888 $DOCKER_ENV --name=pdi_test_$BATS_TEST_NUMBER $IMAGE )
  TIMEOUT=60
  until [ "$TIMEOUT" -eq 0 ] || [ $( docker inspect -f {{.State.Running}} $CONTAINER ) = "true" ]; do
    sleep 1
    (( TIMEOUT-- ))
  done
  [ "$TIMEOUT" -gt 0 ]
}


teardown() {
  docker stop $CONTAINER && docker rm $CONTAINER
}


@test "carte_config.xml contains custom parameters" {
  TIMEOUT=60
  until [ "$TIMEOUT" -eq 0 ] || docker exec $CONTAINER ls /pentaho-di/carte_config.xml; do
    sleep 1
    (( TIMEOUT-- ))
  done
  [ "$TIMEOUT" -gt 0 ]
  # Give docker-entrypoint.sh time to customize the file
  sleep 1
  CARTE_CONFIG=$( docker exec $CONTAINER cat /pentaho-di/carte_config.xml )
  echo "$CARTE_CONFIG" | fgrep '<name>mycarte</name>'
  echo "$CARTE_CONFIG" | fgrep '<network_interface>eth0</network_interface>'
  echo "$CARTE_CONFIG" | fgrep '<port>8888</port>'
  echo "$CARTE_CONFIG" | fgrep '<username>user</username>'
  echo "$CARTE_CONFIG" | fgrep '<password>password</password>'
  echo "$CARTE_CONFIG" | fgrep '<master>N</master>'
  echo "$CARTE_CONFIG" | fgrep '<masters>'
  echo "$CARTE_CONFIG" | fgrep '<report_to_masters>N</report_to_masters>'
  echo "$CARTE_CONFIG" | fgrep '<name>mymaster</name>'
  echo "$CARTE_CONFIG" | fgrep '<hostname>master.domain</hostname>'
  echo "$CARTE_CONFIG" | fgrep '<port>9999</port>'
  echo "$CARTE_CONFIG" | fgrep '<username>masteruser</username>'
  echo "$CARTE_CONFIG" | fgrep '<password>masterpassword</password>'
  echo "$CARTE_CONFIG" | fgrep '<master>Y</master>'
}


@test "Carte responds on port 8888" {
  TIMEOUT=600
  until [ "$TIMEOUT" -eq 0 ] || nc -zv $CONTAINER_HOST 8888; do
    sleep 1
    (( TIMEOUT-- ))
  done
  [ "$TIMEOUT" -gt 0 ]
}
