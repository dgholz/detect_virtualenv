MY_VIRTUALENV_NAMES=${MY_VIRTUALENV_NAMES:-.venv}

function find_dir_in_parents() {
    local needle=$1
    test -z "$needle" && return
    local look=$( readlink --canonicalize ${2:-.} )
    while [ "$look" != '/' ]
    do
        local candidate=$look/$needle
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
    local dirs=${1:-$MY_VIRTUALENV_NAMES}
    local -a venvs
    IFS=';' read -ra dirs <<< "$VIRTUAL_ENV;$dirs"
    for dir in "${dirs[@]}"
    do
        local found=$( find_dir_in_parents "$dir" )
        if [ -n "$found" ]
        then
            venvs+=($found)
        fi
    done
    if [ "$VIRTUAL_ENV" != "${venvs[0]}" ]
    then
        switch_virtualenvs "${venvs[0]}"
    fi
}

PROMPT_COMMAND="detect_virtualenv; $PROMPT_COMMAND"
