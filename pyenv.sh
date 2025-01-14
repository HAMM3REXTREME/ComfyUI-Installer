#!/usr/bin/env bash
# Add pyenv to PATH
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
# Setup correct Python version
python_version=$(cat .python-version)
echo "Python version needed: $python_version"
pyenv install -s "$python_version"
