function setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
  function abs_path() {
    printf "${1%/}"
  }
}

@test "recognise a dir whose parent is in our ancestry" {
  found=$(ancestors_of /foo/bar/baz/ | match_parent /foo/bar/quux)
  [ "$found" = "/foo/bar/quux" ]
}

@test "recognise dir as sibling to an ancestor when it has a weird character" {
  found="$( eval echo "$(ancestors_of /foo/bar/baz/ | match_parent $'/foo/bie\nhi')" )"
  [ "$found" = $'/foo/bie\nhi' ]
}

@test "recognise dir as sibling to an ancestor when ancestors have weird characters" {
  found="$( eval echo "$(ancestors_of $'/fo\no/bar/baz/' | match_parent $'/fo\no/bie')" )"
  [ "$found" = $'/fo\no/bie' ]
}

# vim: ft=sh
