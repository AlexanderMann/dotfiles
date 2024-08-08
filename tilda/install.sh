set -x

# Finder
defaults write com.apple.Finder AppleShowAllFiles true
killall Finder

# Oh my ZSH
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm ~/.zshrc;
cp .zshrc ~;

source ~/.zshrc;

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew update;
brew tap Homebrew/bundle;
brew bundle;

touch ~/.lein/profiles.clj;
rm ~/.lein/profiles.clj;
cp .lein/profiles.clj ~/.lein/profiles.clj;
lein deps;

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

set +x
