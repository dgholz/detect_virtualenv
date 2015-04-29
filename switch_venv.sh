MY_VIRTUALENV_NAMES=${MY_VIRTUALENV_NAMES:-.venv}

function find_dir_in_parents() {
    local needle=$1
    test -z "$needle" && return
    local look=$( readlink --canonicalize ${2:-.} )
    local old_look
    local only_in=$( dirname "$needle" )
    while [ "$look" != "$old_look" ]
    do
        old_look=$look
        look=$( dirname "$look" )
        test "$( readlink --canonicalize $only_in )" != "$old_look" && continue
        local candidate=$old_look/${needle#$old_look/}
        test -d "$candidate" && echo $candidate && break
    done
}

function switch_virtualenvs() {
    local new="$( readlink --canonicalize "$1/bin/activate" )"
    [ -n "${VIRTUAL_ENV+virtualenv active}" ] && deactivate
    test -e "$new" && source "$new"
    true
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
