[![Build Status](https://travis-ci.org/dgholz/detect_virtualenv.svg?branch=master)](https://travis-ci.org/dgholz/detect_virtualenv)

```shell
git clone https://github.com/dgholz/detect_virtualenv.git ~/.vendor/detect_virtualenv
source ~/.vendor/detect_virtualenv/detect_virtualenv
export MY_VIRTUALENV_NAMES=virtualenv_run:venv
cd a/dir/with/a/virtualenv
detect_virtualenv # finds and activates a virtualenv called virtualenv_run or venv
cd -
detect_virtualenv # deactivates the previously-found virtualenv
```
