#!/usr/bin/env bash

set -e

CASKS=(
  flycut
  google-chrome
  google-cloud-sdk
  iterm2
  shiftit
  slack
)

THINGS=(
  autojump
  chruby
  git
  go
  jq
  lastpass-cli
  neovim
  python
  ruby-build
  the_silver_searcher
  watch
  wget
)

check_dependencies() {
  if ! which brew > /dev/null; then
    echo "homebrew not installed. please install homebrew."
    exit 1
  fi
}

install_things() {
  for cask in ${CASKS[@]}; do
    brew cask install "$cask" || brew cask upgrade "$cask"
  done

  for thing in ${THINGS[@]}; do
    brew install "$thing" || brew upgrade "$thing"
  done

  if ! ls ~/.bash_profile > /dev/null; then
    touch ~/.bash_profile
  fi
}

setup_go() {
  mkdir -p ~/workspace/go
  if ! grep GOPATH ~/.bash_profile; then
    echo "export GOPATH=$HOME/workspace/go" >> ~/.bash_profile
  fi
}

setup_gitconfig() {
  git config --global --replace-all alias.st status
  git config --global --replace-all alias.co checkout
  git config --global --replace-all alias.flog "log --pretty=fuller --decorate"
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
  chmod -X ~/.git-completion.bash
}

setup_vim() {
  if ! grep 'alias vim=nvim' ~/.bash_profile; then
    echo "alias vim=nvim" >> ~/.bash_profile
  fi

  curl vimfiles.luan.sh/install | bash
}

setup_bash() {
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
  ~/.bash_it/install.sh
  if ! grep BASH_IT ~/.bash_profile; then
    echo "export BASH_IT=$HOME/.bash_it" >> ~/.bash_profile
  fi
  if ! grep BASH_IT_THEME ~/.bash_profile; then
    echo "export BASH_IT_THEME='bobby'" >> ~/.bash_profile
  fi
  bash-it enable plugin git
}

main() {
  check_dependencies
  install_things
  setup_bash
  setup_go
  setup_gitconfig
  setup_vim
}

main "$@"
