load begin_and_end
load tmpdir

function setup() {
  if begin
  then
    tempdir=$( make_tempdir )
    mkdir -p "$tempdir/venv/bin"
    cat <<-"EOF" >"$tempdir/venv/bin/activate"
		export _ACTIVATED_FOR="$BATS_TEST_NAME"
	EOF
  fi
  PATH="$BATS_TEST_DIRNAME/..:$PATH"
  source detect_virtualenv
  tempdir=$( get_tempdir_name )
}

function teardown() {
  if end
  then
    run rm_tempdir
  fi
  true
}

function deactivate() {
  _DEACTIVATED_FOR=$BATS_TEST_NAME
}

@test "no current virtualenv and new one given" {
  switch_virtualenvs "$tempdir/venv"
  [ "$_ACTIVATED_FOR" = "$BATS_TEST_NAME" ]
  [ -z "$_DEACTIVATED_FOR" ]
}

@test "current virtualenv and no new one given" {
  VIRTUAL_ENV="currently a virtualenv is active"
  switch_virtualenvs
  [ -z "$_ACTIVATED_FOR" ]
  [ "$_DEACTIVATED_FOR" = "$BATS_TEST_NAME" ]
}

@test "no current virtualenv and no new one given" {
  switch_virtualenvs
  [ -z "$_ACTIVATED_FOR" ]
  [ -z "$_DEACTIVATED_FOR" ]
}

@test "current virtualenv and new one given" {
  VIRTUAL_ENV="currently a virtualenv is active"
  switch_virtualenvs "$tempdir/venv"
  [ "$_ACTIVATED_FOR" = "$BATS_TEST_NAME" ]
  [ "$_DEACTIVATED_FOR" = "$BATS_TEST_NAME" ]
}

@test "new virtualenv matches current is a no-op" {
  VIRTUAL_ENV="$tempdir/venv"
  switch_virtualenvs "$tempdir/venv"
  [ -z "$_ACTIVATED_FOR" ]
  [ -z "$_DEACTIVATED_FOR" ]
}
