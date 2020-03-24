set -x

touch ~/.bashrc;
rm ~/.bashrc;
cp .bashrc ~;

touch ~/.bash_profile;
rm ~/.bash_profile;
cp .bash_profile ~;

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew update;
brew tap Homebrew/bundle;
brew bundle;

source ~/.bashrc;

touch ~/.lein/profiles.clj;
rm ~/.lein/profiles.clj;
cp .lein/profiles.clj ~/.lein/profiles.clj;
lein deps;

set +x
