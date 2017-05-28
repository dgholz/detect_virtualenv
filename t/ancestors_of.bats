load begin_and_end
load tmpdir

function setup() {
  begin && run setup_corpus
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
  tempdir=$( get_tempdir_name )
}

function teardown() {
  end && run teardown_corpus
  true
}

function setup_corpus() {
  local tempdir=$( make_tempdir )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar
  # │   │   └── baz
  # │   └── bie
  # │       └── bletch
  # └── quux
  #     └── quuux
  #
  mkdir -p "$tempdir"/foo/{bar/baz,bie/bletch}
  mkdir -p "$tempdir"/quux/quuux
  ln -s foo/bie "$tempdir"/foobie
}

function teardown_corpus() {
  rm_tempdir
}

@test "lists parents" {
  local -a parents
  # pipelines create subshells, which don;t update variables in the parent
  exec 4< <( ancestors_of "$tempdir/foo/bar" )
  while IFS= read -r -d '' parent
  do
      parents+=("$parent")
  done <&4
  exec 4<&-

  [ "${parents[0]}" = "$tempdir/foo/bar" ]
  [ "${parents[1]}" = "$tempdir/foo" ]
  [ "${parents[2]}" = "$tempdir" ]
  [ "${parents[${#parents[@]} - 2]}" != "" ]
  [ "${parents[${#parents[@]} - 1]}" = "" ]
}

@test "lists parents resolves symlinks" {
  local -a parents
  # pipelines create subshells, which don;t update variables in the parent
  exec 4< <( ancestors_of "$tempdir/foobie" )
  while IFS= read -r -d '' parent
  do
      parents+=("$parent")
  done <&4
  exec 4<&-

  [ "${parents[0]}" = "$tempdir/foo/bie" ]
  [ "${parents[1]}" = "$tempdir/foo" ]
  [ "${parents[2]}" = "$tempdir" ]
  [ "${parents[${#parents[@]} - 2]}" != "" ]
  [ "${parents[${#parents[@]} - 1]}" = "" ]
}

# vim: ft=sh
