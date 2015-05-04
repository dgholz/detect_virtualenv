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
  tempdir=$( make_tempdir )
  local found=$( find_dir_in_parents "quux" "$tempdir/foo/bar" )
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
  mkdir --parents "$tempdir"/foo/{bar/baz,bie/bletch}
  mkdir --parents "$tempdir"/quux/quuux
}

function teardown_corpus() {
  rm_tempdir
}

@test "dir to find is starting dir" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'baz' "$tempdir/foo/bar/baz" )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar
  # │   │   └── baz    # start & found
  # │   └── bie
  # │       └── bletch
  # └── quux
  #     └── quuux
  #
  [ "$found" = "$tempdir/foo/bar/baz" ]
}

@test "dir to find is in starting dir" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'baz' "$tempdir/foo/bar" )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar        # start
  # │   │   └── baz    # found
  # │   └── bie
  # │       └── bletch
  # └── quux
  #     └── quuux
  #
  [ "$found" = "$tempdir/foo/bar/baz" ]
}

@test "starting dir defaults to cwd" {
  local tempdir=$( get_tempdir_name )
  builtin cd "$tempdir/foo/bar"
  local found=$( find_dir_in_parents 'baz' )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar        # start
  # │   │   └── baz    # found
  # │   └── bie
  # │       └── bletch
  # └── quux
  #     └── quuux
  #
  [ "$found" = "$tempdir/foo/bar/baz" ]
}

@test "dir to find is sibling of starting dir" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'bie' "$tempdir/foo/bar" )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar        # start
  # │   │   └── baz
  # │   └── bie        # found
  # │       └── bletch
  # └── quux
  #     └── quuux
  #
  [ "$found" = "$tempdir/foo/bie" ]
}

@test "dir to find is parent's sibling" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'quux' "$tempdir/foo/bar" )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar        # start
  # │   │   └── baz
  # │   └── bie
  # │       └── bletch
  # └── quux           # found
  #     └── quuux
  #
  [ "$found" = "$tempdir/quux" ]
}

@test "dir to find is in sibling (not found)" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'bletch' "$tempdir/foo/bar" )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar        # start
  # │   │   └── baz
  # │   └── bie
  # │       └── bletch # not found
  # └── quux
  #     └── quuux
  #
  [ -z "$found" ]
}

@test "dir to find is sibling/child" {
  skip "can only find dirs whose dirname is . OR are abs paths"
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'bie/bletch' "$tempdir/foo/bar" )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar        # start
  # │   │   └── baz
  # │   └── bie
  # │       └── bletch # not found
  # └── quux
  #     └── quuux
  #
  [ -z "$found" ]
}

@test "dir to find doesn't exist (not found)" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'xyzzy' "$tempdir/foo/bar" )
  [ -z "$found" ]
}

@test "no dir to find given (nothing found)" {
  local tempdir=$( get_tempdir_name )
  builtin cd "$tempdir/foo/bar"
  local found=$( find_dir_in_parents )
  [ -z "$found" ]
}

# vim: ft=sh
