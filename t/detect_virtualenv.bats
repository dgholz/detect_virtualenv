load begin_and_end

function setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv

  function switch_virtualenvs() {
    _SWITCH_TO=$@
  }

  function fake_find_virtualenv() {
    local pattern
    pattern=$1; shift
    echo "$@" | xargs -n1 | grep "$pattern" | while read l; do printf "%s\0" "$l"; done
  }
}

@test "switch to first virtualenv found" {
  function find_virtualenvs() {
    fake_find_virtualenv "[d]" "$@"
  }
  detect_virtualenv first:second:third
  [ "$_SWITCH_TO" = "second" ]
}

@test "take virtualenvs to find from MY_VIRTUALENV_NAMES" {
  function find_virtualenvs() {
    fake_find_virtualenv "[i]" "$@"
  }
  MY_VIRTUALENV_NAMES=first:second:third
  detect_virtualenv
  [ "$_SWITCH_TO" = "first" ]
}

@test "switch to \"\" if no dirs found" {
  function find_virtualenvs() {
    fake_find_virtualenv '^$' "$@"
  }
  detect_virtualenv quux:quuux:quuuux
  [ "${_SWITCH_TO-not set}" = "" ]
}

# vim: ft=sh
