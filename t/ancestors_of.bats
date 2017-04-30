load begin_and_end
load tmpdir

function setup() {
  begin && run setup_corpus
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
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
  local tempdir=$( get_tempdir_name )
  local -a parents
  # pipelines create subshells, which don;t update variables in the parent
  exec 99< <( ancestors_of "$tempdir/foo/bar" )
  while read -r -d '' parent
  do
      parents+=("$parent")
  done <&99
  exec 99<&-

  [ "${parents[0]}" = "$tempdir/foo/bar/" ]
  [ "${parents[1]}" = "$tempdir/foo/" ]
  [ "${parents[2]}" = "$tempdir/" ]
  [ "${parents[${#parents[@]} - 2]}" != "/" ]
  [ "${parents[${#parents[@]} - 1]}" = "/" ]
}

@test "lists parents resolves symlinks" {
  local tempdir=$( get_tempdir_name )
  local -a parents
  # pipelines create subshells, which don;t update variables in the parent
  exec 99< <( ancestors_of "$tempdir/foobie" )
  while read -r -d '' parent
  do
      parents+=("$parent")
  done <&99
  exec 99<&-

  [ "${parents[0]}" = "$tempdir/foo/bie/" ]
  [ "${parents[1]}" = "$tempdir/foo/" ]
  [ "${parents[2]}" = "$tempdir/" ]
  [ "${parents[${#parents[@]} - 2]}" != "/" ]
  [ "${parents[${#parents[@]} - 1]}" = "/" ]
}

# vim: ft=sh
