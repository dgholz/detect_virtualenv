function get_tempdir_name() {
  echo "$BATS_TMPDIR/$( echo ${1:-$BATS_TEST_FILENAME} $PPID | md5sum | awk '{ print $1 }' )"
}

function make_tempdir() {
  local tempdir=$( get_tempdir_name $1 )
  mkdir --parents "$tempdir"
  echo "$tempdir"
}

function rm_tempdir() {
  local tempdir=$( get_tempdir_name $1 )
  rm --recursive --force -- "$tempdir"
}
