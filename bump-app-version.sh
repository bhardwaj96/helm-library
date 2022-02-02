#!/usr/bin/env bash

set -e

## debug if desired
if [[ -n "${DEBUG}" ]]; then
    set -x
fi

## avoid noisy shellcheck warnings
MODE="${1}"
CHART_YAML="${2}"
## CHART_PATH="$(dirname "${CHART_YAML}")"
TAG="${GITHUB_REF##*/}"
[[ -n "${TAG}" ]] || TAG="0.0.0"
GITHUB_TOKEN="${GITHUB_TOKEN:-dummy}"
## HELM_REPO_USERNAME="${HELM_REPO_USERNAME:-github}"
## HELM_REPO_PASSWORD="${HELM_REPO_PASSWORD:-dummy}"
GENERIC_BIN_DIR="/usr/local/bin"

## make this script a bit more re-usable
GIT_REPOSITORY="github.com/${GITHUB_REPOSITORY}"

## temp working vars
TIMESTAMP="$(date +%s )"
TMP_DIR="/tmp/${TIMESTAMP}"

# export HELM_REPO_USERNAME
# export HELM_REPO_PASSWORD

## set up Git-User
git config --global user.name "bhardwaj96"
git config --global user.email "jyotibhardwaj96@gmail.com"

## temporary clone git repository
git clone "https://${GIT_REPOSITORY}" "${TMP_DIR}"
cd "${TMP_DIR}"
ls -lrth
## replace appVersion
sed -i "s#^appVersion:.*#appVersion: ${TAG}#g" "${CHART_YAML}"

## replace helm-chart version with current tag without 'v'-prefix
sed -i "s#^version:.*#version: ${TAG/v/}#g" "${CHART_YAML}"

## useful for debugging purposes
git status
password=Dhakkan@96
## Add new remote with credentials baked in url
git remote add publisher https://bhardwaj96:{password}@github.com/bhardwaj96/helm-library.git
# git remote add publisher "https://github.com/bhardwaj96/helm-library.git"

CHANGE_COUNT=$(git status --porcelain | wc -l)
echo = ${CHANGE_COUNT}
if [[ ${CHANGE_COUNT} -gt 0 ]] ; then
    ## add and commit changed file
    git add -A

    ## useful for debugging purposes
    git status

    ## stage changes
    git commit -m "Bump chartVersion and appVersion to '${TAG}'"

    ## rebase
    git pull --rebase publisher main
fi

## Install Helm
# if [[ ! -x "$(command -v helm)" ]]; then
#    export HELM_INSTALL_DIR="${GENERIC_BIN_DIR}"
  #  HELM_BIN="${GENERIC_BIN_DIR}/helm"

   # curl -sS -L https://raw.githubusercontent.com/helm/helm/v3.6.3/scripts/get-helm-3 | bash -s - --version v3.6.3
   # chmod +x "${HELM_BIN}"
# fi

## Install Helm push
# helm plugin install https://github.com/chartmuseum/helm-push.git

if [[ "${MODE}" == "publish" ]]; then

    ## publish changes
    git push publisher main

fi

exit 0
