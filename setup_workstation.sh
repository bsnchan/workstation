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
  bosh-cli
  chruby
  git
  go
  jq
  kubernetes-cli
  lastpass-cli
  neovim
  python
  ruby-build
  sublime-text
  the_silver_searcher
  watch
  wget
)

check_dependencies() {
  if ! which brew > /dev/null; then
    echo "homebrew not installed. please install homebrew."
    exit 1
  fi

  if [[ -z "$GIT_NAME" ]]; then
    echo "GIT_NAME environment variable must be set to setup git config."
    exit 1
  fi

  if [[ -z "$GIT_EMAIL" ]]; then
    echo "GIT_EMAIL environment variable must be set to setup git config."
    exit 1
  fi

  brew tap cloudfoundry/tap
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
  git config --global user.name \""$GIT_NAME"\"
  git config --global user.email "$GIT_EMAIL"
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

keys() {
  if ! grep loadkey ~/.bash_profile; then
  echo 'loadkey() {
  echo "$(lpass show github-ssh-key --notes)" > ~/.ssh/id_rsa && \
  chmod 600 ~/.ssh/id_rsa && \
  ssh-add -t 8h ~/.ssh/id_rsa && \
  rm ~/.ssh/id_rsa
}' >> ~/.bash_profile
  fi
}

main() {
  check_dependencies
  install_things
  setup_bash
  setup_go
  setup_gitconfig
  setup_vim
  keys
}

main "$@"
