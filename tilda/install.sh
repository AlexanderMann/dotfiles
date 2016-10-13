set -x

touch ~/.bashrc;
rm ~/.bashrc;
cp .bashrc ~;
source ~/.bashrc;

touch ~/.bash_profile;
rm ~/.bash_profile;
cp .bash_profile ~;

touch ~/.lein/profiles.clj;
rm ~/.lein/profiles.clj;
cp .lein/profiles.clj ~/.lein/profiles.clj;
lein deps;

set +x
