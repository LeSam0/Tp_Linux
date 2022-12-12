#!/bin/bash

if [[ $(find /srv/yt/downloads/ 2> /dev/null) ]]
then
  :
else
  echo "Downloads folder (/srv/yt/downloads) didn't existe."
  exit
fi

if [[ $(find /var/log/yt/ 2> /dev/null) ]]
then
  :
else
  echo "Log file (/var/log/yt) didn't existe."
  exit
fi

LINKFILE="/srv/yt/link"

while :
do
  if [[ -s "${LINKFILE}" ]]
  then
    LINK=$(head -n1 "${LINKFILE}")
    if [[ $(youtube-dl -s "${LINK}" 2> /dev/null) ]]
    then
      TITLE=$(youtube-dl -e $(echo "${LINK}"))
      VIDEODESC=$(youtube-dl --get-description "${LINK}")
      FILEPATH="/srv/yt/downloads/"${TITLE}/"$(youtube-dl "${LINK}" --get-filename)"
      LOG="[$(date "+%y/%m/%d %H:%M:%S")] Video "${TITLE}" was downloaded. File path : "${FILEPATH}" "
      mkdir -p /srv/yt/downloads/"${TITLE}"
      echo "${VIDEODESC}" > /srv/yt/downloads/"${TITLE}"/description

      cd /srv/yt/downloads/"${TITLE}"
      youtube-dl "${LINK}" > /dev/null
      cd ../..

      echo "Video "${LINK}" was dowloaded.
      File path : "${FILEPATH}""

      echo "${LOG}" >> /var/log/yt/download.log
    else
      $(echo "[$(date "+%y/%m/%d %H:%M:%S")] Link : "${LINK}" isn't valid"  >> /var/log/yt/download.log)
    fi
    sed -i '1d' "${LINKFILE}"
  fi
  sleep 1
done
