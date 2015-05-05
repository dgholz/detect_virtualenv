detect_virtualenv
-----------------

Switch virtualenvs as easy as changing directories!

[![Build Status](https://travis-ci.org/dgholz/detect_virtualenv.svg?branch=master)](https://travis-ci.org/dgholz/detect_virtualenv)

To use this script, `source path/to/detect_virtualenv`. A function called `detect_virtualenv` will be defined. When called, the function will search the current working directory for a folder called `.venv`. If it finds that directory, it will attempt to activate it as a virtualenv. If it does not find it, it will move to the current directory's parent and restart its search (giving up once it has searched `/`).

By default, it will only detect a virtualenv called `.venv`. To detect virtualenvs with other names, set the `MY_VIRTUALENV_NAMES` variable to a colon-separated list of the names you use.

Install from GitHub
===================

```shell
git clone https://github.com/dgholz/detect_virtualenv.git ~/.vendor/detect_virtualenv
source ~/.vendor/detect_virtualenv/detect_virtualenv
```

Example
=======

(screencast goes here)
```shell
export MY_VIRTUALENV_NAMES=virtualenv_run:venv
cd a/dir/with/a/virtualenv
detect_virtualenv # finds and activates a virtualenv called virtualenv_run or venv
cd -
detect_virtualenv # deactivates the previously-found virtualenv
```

Automatically detecting virtualenvs
===================================

Add to `PROMPT_COMMAND`, so `detect_virtualenv` is invoked everytime the prompt is shown:

Override `cd` && `pushd` and `popd`, so `detect_virtualenv` is invoked everytime the directory is changed:
