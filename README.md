detect_virtualenv
=================

Switch virtualenvs as easy as changing directories!

[![Build Status](https://travis-ci.org/dgholz/detect_virtualenv.svg?branch=master)](https://travis-ci.org/dgholz/detect_virtualenv)

`detect_virtualenv` is a function that will search for [virtualenvs](https://virtualenv.pypa.io/en/latest/) in the current directory and its parents. When it finds one, it will activate it; if it doesn't find one, it will deactivate any active virtualenv.

By default, it will only detect a virtualenv called `.venv`. To instead detect virtualenvs with other names, set the `MY_VIRTUALENV_NAMES` variable to a colon-separated list of the names you use e.g. `export MY_VIRTUALENV_NAMES=cool_virtualev:rad_venv:ve`.

Install from GitHub
-------------------

```shell
git clone https://github.com/dgholz/detect_virtualenv.git ~/.vendor/detect_virtualenv
. ~/.vendor/detect_virtualenv/detect_virtualenv # enable just for this sesson
echo . ~/.vendor/detect_virtualenv/detect_virtualenv >> ~/.bashrc # enable for new sessions
```

Example
-------

[Screencast of simple behaviour](https://dgholz.github.io/detect_virtualenv/detect_virtualenv_simple.gif)

```shell
export MY_VIRTUALENV_NAMES=cool_virtualev:rad_venv:ve # add this to your ~/.bashrc to set it for all new sessions
pushd a/dir/with/a/virtualenv
detect_virtualenv # finds and activates a virtualenv called virtualenv_run or venv
cd subdir
detect_virtualenv # finds the virtualenv in the parent
popd
detect_virtualenv # deactivates the previously-found virtualenv
```

Automatically detecting virtualenvs
-----------------------------------

You can configure your shell to automatically execute `detect_virtualenv`.

### Add to `PROMPT_COMMAND`, so `detect_virtualenv` is invoked everytime the prompt is shown

`detect_virtualenv` provides a helper function, which is automatically run if it is sourced with `on_prompt` as the first argument:
```shell
. path/to/detect_virtualenv on_prompt
```
It will avoid adding to `PROMPT_COMMAND` if it is already present.

### Override `cd`, `pushd`, and `popd`, so `detect_virtualenv` is invoked everytime the directory is changed:

Not recommended, as other tools may override `cd` et al. e.g. `rvm`. Only use if you are certain no other part of your `~/.bashrc` changes these builtins:
```shell
. path/to/detect_virtualenv
function cd()    { builtin cd    "$@" && detect_virtualenv }
function pushd() { builtin pushd "$@" && detect_virtualenv }
function popd()  { builtin popd  "$@" && detect_virtualenv }
```
