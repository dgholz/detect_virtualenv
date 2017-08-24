function setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
}

@test "creates candidates for all possible names" {
  IFS=$'\n' read -d'' -r -a found < <( printf "%q\n" /foo/bar/baz /foo/bar /foo '' | append_relpath hi hello howdy ) || true
  [ "${found[0]}" = "/foo/bar/baz/hi" ]
  [ "${found[1]}" = "/foo/bar/baz/hello" ]
  [ "${found[2]}" = "/foo/bar/baz/howdy" ]
  [ "${found[3]}" = "/foo/bar/hi" ]
  [ "${found[7]}" = "/foo/hello" ]
  [ "${found[${#found[@]} - 1]}" = "''/howdy" ]
}

# vim: ft=sh
