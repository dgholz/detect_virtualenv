load begin_and_end

function setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv

  function find_dir_in_parents() {
    _DETECT_FROM=$@
  }
}

@test "toggle status defaults to enabled" {
  [ "$( detect_virtualenv --status )" = "on" ]
  detect_virtualenv hi
  [ "$_DETECT_FROM" = "hi" ]
}

@test "toggle off" {
  detect_virtualenv --off
  [ "$( detect_virtualenv --status )" = "off" ]
  detect_virtualenv hi
  [ "$_DETECT_FROM-never set" = "never set" ]
}

@test "toggle on" {
  export DETECT_VIRTUALENV_STATUS=off
  detect_virtualenv --on
  [ "$( detect_virtualenv --status )" = "on" ]
  detect_virtualenv hi
  [ "$_DETECT_FROM" = "hi" ]
}

@test "set status with environment variable" {
  export DETECT_VIRTUALENV_STATUS=off
  [ "$( detect_virtualenv --status )" = "off" ]
  export DETECT_VIRTUALENV_STATUS=on
  [ "$( detect_virtualenv --status )" = "on" ]
}

# vim: ft=sh
