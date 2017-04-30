function setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
}

@test "recognise a dir whose parent is in our ancestry" {
  found=$(printf "%s\0" /foo/bar/baz/ /foo/bar/ /foo/ / | match_parent /foo/bar/quux)
  [ "$found" = "/foo/bar/quux" ]
}

@test "recognise dir as sibling to an ancestor when it has a weird character" {
  found=$(printf "%s\0" /foo/bar/baz/ /foo/bar/ /foo/ / | match_parent $'/foo/bie\nhi')
  [ "$found" = $'/foo/bie\nhi' ]
}

@test "recognise dir as sibling to an ancestor when ancestors have weird characters" {
  found=$(printf "/fo\no%s/\0" /bar/baz /bar '' | match_parent $'/fo\no/bie')
  [ "$found" = $'/fo\no/bie' ]
}

# vim: ft=sh
