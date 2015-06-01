#!/usr/bin/env bats

setup() {
  load test_env
  CONTAINER=$( docker run -d -p=8080:8080 --name=pdi_test_$BATS_TEST_NUMBER $IMAGE )
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


@test "carte.sh exists in the path" {
  run docker exec $CONTAINER which carte.sh
  [ "$output" = '/opt/pentaho-di/data-integration/carte.sh' ]
}


@test "carte_config.xml contains default parameters" {
  TIMEOUT=60
  until [ "$TIMEOUT" -eq 0 ] || docker exec $CONTAINER ls /pentaho-di/carte_config.xml; do
    sleep 1
    (( TIMEOUT-- ))
  done
  [ "$TIMEOUT" -gt 0 ]
  # Give docker-entrypoint.sh time to customize the file
  sleep 1
  CARTE_CONFIG=$( docker exec $CONTAINER cat /pentaho-di/carte_config.xml )
  echo "$CARTE_CONFIG" | fgrep '<name>carte-server</name>'
  echo "$CARTE_CONFIG" | fgrep '<network_interface>eth0</network_interface>'
  echo "$CARTE_CONFIG" | fgrep '<port>8080</port>'
  echo "$CARTE_CONFIG" | fgrep '<username>cluster</username>'
  echo "$CARTE_CONFIG" | fgrep '<password>cluster</password>'
  echo "$CARTE_CONFIG" | fgrep '<master>Y</master>'
  ! (echo "$CARTE_CONFIG" | fgrep '<masters>')
}


@test "Carte responds on port 8080" {
  TIMEOUT=600
  until [ "$TIMEOUT" -eq 0 ] || nc -zv $CONTAINER_HOST 8080; do
    sleep 1
    (( TIMEOUT-- ))
  done
  [ "$TIMEOUT" -gt 0 ]
}
