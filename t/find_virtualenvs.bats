load begin_and_end
load tmpdir

function setup() {
  begin && run setup_corpus
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
  function has_activate_script() {
    while read -r candidate
    do
      local unescaped_candidate=$(printf "%b" "$candidate")
      [ -d "${unescaped_candidate}" ] && echo "$candidate"
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
  local found=$( cd "$tempdir/foo/bar/baz"; find_virtualenvs 'baz' | head -1 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'baz' | head -1 )
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
  local found=$( builtin cd "$tempdir/foo/bar"; find_virtualenvs 'baz' | head -1 )
  [ "$found" = "$tempdir/foo/bar/baz" ]
}

@test "dir to find is sibling of starting dir" {
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'bie' | head -1 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'quux' | head -1 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'bletch' | head -1 )
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
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'bie/bletch' | head -1 )
  #
  # $tempdir
  # ├── foo
  # │   ├── bar        # start
  # │   │   └── baz
  # │   └── bie
  # │       └── bletch # found
  # └── quux
  #     └── quuux
  #
  [ "$found" = "$tempdir/foo/bie/bletch" ]
}

@test "dir to find doesn't exist (not found)" {
  local found=$( cd "$tempdir/foo/bar"; find_virtualenvs 'xyzzy' | head -1 )
  [ -z "$found" ]
}

@test "no dir to find given (nothing found)" {
  builtin cd "$tempdir/foo/bar"
  local found=$( find_virtualenvs )
  [ -z "$found" ]
}

@test "abs path to find and it's a sibling of an ancestor" {
  local found=$( cd "$tempdir/foo/bar"; VIRTUAL_ENV="$tempdir/quux" find_virtualenvs | head -1 )
  [ "$found" = "$tempdir/quux" ]
}

@test "abs path to find but it's not a sibling of an ancestor (not found)" {
  local found=$( cd "$tempdir/foo/bar"; VIRTUAL_ENV="$tmpdir/quux/quuux" find_virtualenvs | head -1 )
  [ -z "$found" ]
}

@test "prefer \$VIRTUAL_ENV if found" {
  local found=$( cd "$tempdir/foo/bar/baz"; VIRTUAL_ENV="$tempdir/quux" find_virtualenvs bar | head -1 )
  [ "$found" = "$tempdir/quux" ]
}

# vim: ft=sh
