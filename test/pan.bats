#!/usr/bin/env bats

@test "pan.sh exists in the path" {
  run docker run --rm --name=pdi_test_$BATS_TEST_NUMBER $IMAGE which pan.sh
  [ "$output" = '/opt/pentaho-di/data-integration/pan.sh' ]
}


@test "pan.sh runs test transformation to print message to log" {
  run docker run --rm --name=pdi_test_$BATS_TEST_NUMBER $IMAGE pan.sh -rep=docker-pentaho-di -dir=/ -trans=test-trans
  [ "$status" -eq 0 ]
  echo "$output" | grep 'MY_MESSAGE = Hello World!'
}
