#!/bin/bash

# Spotify legacy token

LEGACY_TOKEN="YOUR_LEGACY_TOKEN"
trap onexit INT

# Helper for https://api.slack.com/methods/users.profile.set Slack API Method

function setProfile() {
  PAYLOAD=$1
  echo "Calling https://api.slack.com/methods/users.profile.set with $PAYLOAD"
  curl -X POST -H "Authorization: Bearer $LEGACY_TOKEN" -H "Content-Type: application/json; charset=UTF-8" -s -d "$PAYLOAD" "https://slack.com/api/users.profile.set" > /dev/null
}

function reset() {
  echo 'Resetting status'
  PAYLOAD="{ \"profile\": { \"status_text\" : \"\", \"status_emoji\" : \"\" } }"n
  setProfile "$PAYLOAD"
}

function onexit() {
  echo 'Exiting'
  reset
  exit
}

function getSong() {
  SONG=$(osascript -e 'tell application "Spotify" to artist of current track & " - " & name of current track')
  echo $SONG
}

pgrep Spotify > /dev/null
if [ $? -ne 0 ]; then
  echo 'Spotify is not running, exiting'
  exit 0
fi

state=$(osascript -e 'tell application "Spotify" to player state')
echo "$(date) Spotify state: $state"

if [[ "$state" != "playing" ]]; then
  echo 'Spotify is not playing any song, exiting'
  reset
else
  SONG=$(getSong)
  echo "Detected Spotify track: $SONG"

  PAYLOAD="{ \"profile\": { \"status_text\": \"$SONG\", \"status_emoji\": \":headphones:\" } }"
  setProfile "$PAYLOAD"
fi

echo "Done"
exit 0
