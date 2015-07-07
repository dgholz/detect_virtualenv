function setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv

  function find_dir_in_parents() {
      echo "$@"
  }
  function switch_virtualenvs() {
      _SWITCH_TO=$@
  }
}

@test "toggle status defaults to enabled" {
  [ "$( detect_virtualenv --status )" = "on" ]
  detect_virtualenv hi
  [ "$_SWITCH_TO" = "hi" ]
}

@test "toggle off" {
  detect_virtualenv --off
  [ "$( detect_virtualenv --status )" = "off" ]
  detect_virtualenv hi
  [ "${_SWITCH_TO-never set}" = "never set" ]
}

@test "toggle on" {
  export DETECT_VIRTUALENV_STATUS=off
  detect_virtualenv --on
  [ "$( detect_virtualenv --status )" = "on" ]
  detect_virtualenv hi
  [ "$_SWITCH_TO" = "hi" ]
}

@test "toggle deactivated" {
  detect_virtualenv --deactivate
  [ "$( detect_virtualenv --status )" = "off" ]
  [ "${_SWITCH_TO-not set}" = "" ]
  detect_virtualenv hi
  [ "${_SWITCH_TO-not set}" = "" ]
}

@test "set status with environment variable" {
  export DETECT_VIRTUALENV_STATUS=off
  [ "$( detect_virtualenv --status )" = "off" ]
  export DETECT_VIRTUALENV_STATUS=on
  [ "$( detect_virtualenv --status )" = "on" ]
}

# vim: ft=sh
