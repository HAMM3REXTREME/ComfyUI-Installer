#!/usr/bin/env bash
set -e
# Add pyenv to PATH
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

# Install the correct Python version
python_version=$(cat .python-version)
printf "Python version needed: $python_version\n"
pyenv install -s "$python_version"
