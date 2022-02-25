#!/usr/bin/env bash

SRC_URL="https://api.github.com/repos/carrot2/carrot2/releases/latest"

RELEASES=$(curl ${SRC_URL} | jq '[ . | {tag_name: .tag_name, draft: .draft, assets: [.assets[].browser_download_url]}]')

mkdir -m777 carrot2_mirror
cd carrot2_mirror

for RELEASE in $(echo ${RELEASES} | jq -r '.[]? | @base64'); do
  DRAFT=$(echo ${RELEASE} | base64 --decode | jq -r '.draft')
  NAME=$(echo ${RELEASE} | base64 --decode | jq -r '.tag_name')
  URLS=$(echo ${RELEASE} | base64 --decode | jq -r '.assets | .[]')

  if [[ "${DRAFT}" != "false" ]]; then
    continue
  fi

  RELEASE_DEST=${NAME}
  if [[ -d ${RELEASE_DEST} ]]; then
    continue
  fi

  mkdir -p -m777 ${RELEASE_DEST}
  wget -P ${RELEASE_DEST} --no-verbose ${URLS}
  
done
