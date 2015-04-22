function find_dir_in_parents() {
    local dirname=$1
    local look=$( readlink --canonicalize ${2:-.} )
    while [ "$look" != '/' ]
    do
        local candidate=$look/$dirname
        test -d "$candidate" && echo $candidate && break
        look=$( dirname "$look" )
    done
}

function switch_virtualenvs() {
    local new="$( readlink --canonicalize "$1/bin/activate" )"
    test -x "$new" || return
    [ -n "${VIRTUAL_ENV+virtualenv active}" ] && deactivate
    source "$new"
}

function detect_virtualenv() {
    local dir=${1:-.venv}
    local found=$( find_dir_in_parents "$dir" )
    if [ -n "$find" -a "$VIRTUAL_ENV" != "$find" ]
    then
        switch_virtualenvs "$find"
    fi
}

PROMPT_COMMAND="detect_virtualenv; $PROMPT_COMMAND"
