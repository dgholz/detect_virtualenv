for sum in md5sum md5
do
  if which -s $sum
  then
    CHECKSUM=$(which $sum)
    break
  fi
done

function get_tempdir_name() {
  echo "$BATS_TMPDIR/$( echo ${1:-$BATS_TEST_FILENAME} $PPID | $CHECKSUM | awk '{ print $1 }' )"
}

function make_tempdir() {
  local tempdir=$( get_tempdir_name $1 )
  mkdir -p "$tempdir"
  echo "$tempdir"
}

function rm_tempdir() {
  local tempdir=$( get_tempdir_name $1 )
  rm --recursive --force -- "$tempdir"
}
