set -x

touch ~/.gitignore_global;
rm ~/.gitignore_global;
cp .gitignore_global ~;

git config --global core.excludesfile ~/.gitignore_global;
git config --global user.name "AlexanderMann"
git config --global user.email mannimal09@gmail.com

touch ~/.git-completion.bash
rm ~/.git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

set +x
