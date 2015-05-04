function begin() {
  [ "$BATS_TEST_NUMBER" = 1 ]
}

function end() {
  [ "$BATS_TEST_NAME" = "${BATS_TEST_NAMES[@]:(-1)}" ]
}

