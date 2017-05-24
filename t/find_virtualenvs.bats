load begin_and_end
load tmpdir

function setup() {
  begin && run setup_corpus
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
  function has_activate_script() {
    while read -r -d '' candidate
    do
      [ -d "${candidate}" ] && printf "%s\0" "$candidate"
    done
  }
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
}

function teardown_corpus() {
  rm_tempdir
}

@test "dir to find is starting dir" {
  local tempdir=$( get_tempdir_name )
  local found=$( cd "$tempdir/foo/bar/baz"; ancestors_of | append_relpath baz | has_activate_script | xargs -n1 -0 | head -1 )
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

@test "doesn't mind if cd is not the same as builtin cd" {
  function cd() {
      builtin cd "$tempdir/bie/bletch"
  }
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'baz' "$tempdir/foo/bar" )
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

@test "start dir doesn't exist (nothing found)" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents 'foo' "$tempdir/foobar" )
  [ -z "$found" ]
}

@test "no dir to find given (nothing found)" {
  local tempdir=$( get_tempdir_name )
  builtin cd "$tempdir/foo/bar"
  local found=$( find_dir_in_parents )
  [ -z "$found" ]
}

@test "abs path to find and it's a sibling of an ancestor" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents "$tempdir/quux" "$tempdir/foo/bar" )
  [ "$found" = "$tempdir/quux" ]
}

@test "abs path to find but it's not a sibling of an ancestor (not found)" {
  local tempdir=$( get_tempdir_name )
  local found=$( find_dir_in_parents "$tempdir/quux/quuux" "$tempdir/foo/bar" )
  [ -z "$found" ]
}

# vim: ft=sh
