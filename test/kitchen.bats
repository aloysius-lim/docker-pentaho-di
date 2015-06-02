#!/usr/bin/env bats

setup() {
  load test_env
  : ${IMAGE:=abtpeople/pentaho-di:$TAG-test-kitchenpan}
}

@test "kitchen.sh exists in the path" {
  run docker run --rm --name=pdi_test_$BATS_TEST_NUMBER $IMAGE which kitchen.sh
  [ "$output" = '/opt/pentaho-di/data-integration/kitchen.sh' ]
}


@test "kitchen.sh runs test transformation to print message to log" {
  run docker run --rm --name=pdi_test_$BATS_TEST_NUMBER $IMAGE kitchen.sh -rep=docker-pentaho-di -dir=/ -job=test-job
  [ "$status" -eq 0 ]
  echo "$output" | grep 'MY_MESSAGE = Hello World!'
}
