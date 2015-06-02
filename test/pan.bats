#!/usr/bin/env bats

setup() {
  load test_env
  : ${IMAGE:=abtpeople/pentaho-di:$TAG-test-kitchenpan}
}

@test "pan.sh exists in the path" {
  run docker run --rm --name=pdi_test_$BATS_TEST_NUMBER $IMAGE which pan.sh
  [ "$output" = '/opt/pentaho-di/data-integration/pan.sh' ]
}


@test "pan.sh runs test transformation to print message to log" {
  run docker run --rm --name=pdi_test_$BATS_TEST_NUMBER $IMAGE pan.sh -rep=docker-pentaho-di -dir=/ -trans=test-trans
  [ "$status" -eq 0 ]
  echo "$output" | grep 'MY_MESSAGE = Hello World!'
}
