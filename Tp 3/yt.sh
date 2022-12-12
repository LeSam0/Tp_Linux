#!/bin/bash

if [[ $(find /srv/yt/downloads/ 2> /dev/null) ]]
then
  :
else
  exit
fi

if [[ $(find /var/log/yt/ 2> /dev/null) ]]
then
  :
else
  exit
fi

LINK=$(echo "${1}")
TITLE=$(youtube-dl -e $(echo "${LINK}"))
VIDEODESC=$(youtube-dl --get-description "${LINK}")
FILEPATH="/srv/yt/downloads/"${TITLE}/"$(youtube-dl "${LINK}" --get-filename)"
LOG="[$(date "+%y/%m/%d %H:%M:%S")] Video "${TITLE}" was downloaded. File path : "${FILEPATH}" "
mkdir -p ./downloads/"${TITLE}"
echo "${VIDEODESC}" > ./downloads/"${TITLE}"/description

cd ./downloads/"${TITLE}"
youtube-dl "${LINK}" > /dev/null
cd ../..

echo "Video "${LINK}" was dowloaded.
File path : "${FILEPATH}""

echo "${LOG}" >> /var/log/yt/download.log
