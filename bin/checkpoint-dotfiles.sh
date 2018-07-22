#!/bin/bash
set -e
REPODIRS=(vimfiles dotfiles)
MESSAGE="Checkpoint commit"

# See https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL=()
function show_help() {
  cat <<EOF
usage $0 [-av]

Attempt to commit and push any changes to dot files to:
  ${REPODIRS[*]}
EOF
# The assumption is that we are not to fussy about tracking or describing changes.
# And its not a catastrophy if we add junk files to the repos - we can allways
# re-create the repo if we really care
}

force_add_flag=0
verbose_flag=0

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h) show_help
        exit 0
      ;;
    -v|--verbose)
      verbose_flag=1
      shift
      ;;
    -a|--add)
      force_add_flag=1
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional arguments.

for repodir in ${REPODIRS[*]}; do
  cd $HOME/$repodir
  echo ">> $HOME/$repodir"
  untracked=$(git ls-files --other --exclude-standard | wc -l)
  modified=0
  if ! git diff-index --quiet HEAD --; then
    modified=1
  fi

  if [[ $untracked -gt 0 || $modified -eq 1 ]] ; then
    if [[ $force_add_flag -ne 1 ]]; then
      echo "  ** $repodir has modified and/or untracked files, set --add or resolve manually"
      if [[ $verbose_flag -eq 1 ]]; then
        git status
      fi
      continue
    else
      git add .
    fi
  fi
  if git commit -m "$MESSAGE" &> /dev/null; then
    git push
  fi
done

