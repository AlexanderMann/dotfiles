PRETTY_WATERMARK_TIME=$(date -v-3m)
WATERMARK_TIME=$(date -j -f "%a %b %d %T %Z %Y" "${PRETTY_WATERMARK_TIME}" "+%s")
echo ${WATERMARK_TIME} :: ${PRETTY_WATERMARK_TIME}

for f in $(find . -name .git -maxdepth 3);
do
  work_dir=$(echo $f | sed 's|/.git||');
  git_args="--git-dir=$f --work-tree=$work_dir"
  echo $work_dir...

  if ! $(git --git-dir=$f --work-tree=$work_dir fetch --all > /dev/null 2>&1);
  then
    echo "    !!! :warning: Failed to fetch --all :: git fetch --all";
  else
    echo "    :thumbsup: fetch --all successful";
  fi
  
  if ! $(git --git-dir=$f --work-tree=$work_dir push --quiet --all origin > /dev/null 2>&1);
  then
    echo "    !!! :warning: Failed to push --all :: cd $work_dir; git push --all origin";
  else
    echo "    :thumbsup: push --all successful";
  fi

  if [ ! $(git --git-dir=$f --work-tree=$work_dir diff --quiet --exit-code) ]  ] || [[ $(git --git-dir=$f --work-tree=$work_dir ls-files --others --exclude-standard) ]];
  then
    echo "    !!! :warning: dirty diff :: cd $work_dir; git status";
  else
    echo "    :thumbsup: diff clean";
  fi

  if ! $(git --git-dir=$f --work-tree=$work_dir fetch --prune > /dev/null 2>&1);
  then
    echo "    !!! :warning: Failed to prune :: cd $work_dir; git fetch --prune";
  else
    echo "    :thumbsup: prune successful";
  fi

  read -p "    ?! Run branch housekeeping? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]];
  then
    git --git-dir=$f --work-tree=$work_dir branch --merged | egrep -v "(^\*|main|master|dev)" | xargs git --git-dir=$f --work-tree=$work_dir branch -d;
    git --git-dir=$f --work-tree=$work_dir branch -vv      | grep 'backup/'  | cut -d ' ' -f3 | xargs git --git-dir=$f --work-tree=$work_dir branch -D;
    git --git-dir=$f --work-tree=$work_dir branch -vv      | grep 'gone]'    | cut -d ' ' -f3 | xargs git --git-dir=$f --work-tree=$work_dir branch -D;
    
    echo "    Purging no remote branches with last commit older than: ${WATERMARK_TIME} (${PRETTY_WATERMARK_TIME})"

    for b in $(git --git-dir=$f --work-tree=$work_dir branch -vv | grep -v '\[' | cut -d ' ' -f3);
    do
      TS=$(git --git-dir=$f --work-tree=$work_dir show --format="%ct" ${b} | head -n 1)
      PRETTY_TS=$(git --git-dir=$f --work-tree=$work_dir show --format="%cD" ${b} | head -n 1)
      if [[ "${WATERMARK_TIME}" > "${TS}" ]];
      then
        echo "        ${b} has no remote, and last modified ${PRETTY_TS} < ${PRETTY_WATERMARK_TIME}";
        git --git-dir=$f --work-tree=$work_dir branch -D ${b};
      fi;
    done;
  fi

  echo;
done;
