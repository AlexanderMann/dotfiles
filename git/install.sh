touch ~/.gitignore_global;
rm ~/.gitignore_global;
cp .gitignore_global ~;

touch ~/.git-completion.bash
rm ~/.git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
