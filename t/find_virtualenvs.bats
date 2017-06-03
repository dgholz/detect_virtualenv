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
}

function teardown_corpus() {
  rm_tempdir
}

@test "dir to find is starting dir" {
  local found=$( cd "$tempdir/foo/bar/baz"; find_virtualenvs 'baz' | first0 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'baz' | first0 )
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
  local found=$( builtin cd "$tempdir/foo/bar"; find_virtualenvs 'baz' | first0 )
  [ "$found" = "$tempdir/foo/bar/baz" ]
}

@test "dir to find is sibling of starting dir" {
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'bie' | first0 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'quux' | first0 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'bletch' | first0 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'bie/bletch' | first0 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'xyzzy' | head -1 )
  [ -z "$found" ]
}

@test "no dir to find given (nothing found)" {
  builtin cd "$tempdir/foo/bar"
  local found=$( find_dir_in_parents )
  [ -z "$found" ]
}

@test "abs path to find and it's a sibling of an ancestor" {
  local found=$( cd "$tempdir/foo/bar"; VIRTUAL_ENV="$tempdir/quux" find_virtualenvs | first0 )
  [ "$found" = "$tempdir/quux" ]
}

@test "abs path to find but it's not a sibling of an ancestor (not found)" {
  local found=$( cd "$tempdir/foo/bar"; VIRTUAL_ENV="$tmpdir/quux/quuux" find_virtualenvs | first0 )
  [ -z "$found" ]
}

@test "prefer \$VIRTUAL_ENV if found" {
  local found=$( cd "$tempdir/foo/bar/baz"; VIRTUAL_ENV="$tempdir/quux" find_virtualenvs bar | head -1 )
  [ "$found" = "$tempdir/quux" ]
}

# vim: ft=sh
