#!/bin/bash
# refer to https://www.jianshu.com/p/dd1b924fe48e, thanks for the author
set -eu

git-log-flat-colored() {
  git --no-pager log --format="%C(yellow)%h%Creset %C(cyan)%cd%Creset %s %Cgreen%an%Creset" --date=short "$@"
}

CURRENT_FEATURE=$(git symbolic-ref --short -q HEAD)
CURRENT_PATH=$(git rev-parse --show-toplevel)
REFERENCE_BRANCH="origin/main"

echo -e "\033[0;34m >>-----当前核查仓库路径${CURRENT_PATH}-----<< \033[0m"

# Check if the "origin/main" branch exists, and if so, update the remote record and compare for any backward commits
if git rev-parse --verify ${REFERENCE_BRANCH} >/dev/null 2>&1; then

  git fetch origin

  NB_COMMITS_BEHIND=$(git rev-list --left-right --count ${REFERENCE_BRANCH}...@ | cut -f1)

  if [ "${NB_COMMITS_BEHIND}" -gt "0" ]; then
    echo -e "\033[0;31m >>-----${CURRENT_FEATURE}-----<< 当前分支有 ${NB_COMMITS_BEHIND} 个提交落后于 \"${REFERENCE_BRANCH}\", 请合并最新的 master 分支代码\n \033[0m"
    git-log-flat-colored ${REFERENCE_BRANCH} | head -"${NB_COMMITS_BEHIND}"
    exit 2
  else
    echo -e "\033[0;32m >>-----${CURRENT_FEATURE}-----<<当前分支包含 ${REFERENCE_BRANCH} 分支上的所有提交记录 \033[0m"
  fi
else
  echo -e "\033[0;31m >>-----不能比较，检测${REFERENCE_BRANCH}不存在-----<< \033[0m"
  exit 2
fi
