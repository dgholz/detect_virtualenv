load begin_and_end

function setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv

  function switch_virtualenvs() {
    _SWITCH_TO=$@
  }
}

@test "switch to first virtualenv found" {
  function find_dir_in_parents() {
    echo $@ | grep [e]
  }
  detect_virtualenv first:second:third
  [ "$_SWITCH_TO" = "second" ]
}

@test "take virtualenvs to find from MY_VIRTUALENV_NAMES" {
  function find_dir_in_parents() {
    echo $@ | grep [i]
  }
  MY_VIRTUALENV_NAMES=first:second:third
  detect_virtualenv
  [ "$_SWITCH_TO" = "first" ]
}

@test "prefer \$VIRTUAL_ENV if found" {
  function find_dir_in_parents() {
    echo $@
  }
  VIRTUAL_ENV=this_virtualenv
  detect_virtualenv foo:bar:this_virtualenv:baz
  [ "$_SWITCH_TO" = "this_virtualenv" ]
}

@test "switch to \"\" if no dirs found" {
  function find_dir_in_parents() {
    :
  }
  detect_virtualenv quux:quuux:quuuux
  [ "${_SWITCH_TO-not set}" = "" ]
}

# vim: ft=sh
