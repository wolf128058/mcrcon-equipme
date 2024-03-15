#!/bin/bash

## filename     give-item.sh
## description: give a minecraft-player an item via remote-console
## author:      jonas.hess@mailbox.org
## ================================================================

SETTINGS="data/defaults.json"
PLAYER=$(jq -r '.player' $SETTINGS )
RCONHOST=$(jq -r '.host' $SETTINGS )
RCONPORT=$(jq -r '.port' $SETTINGS )
RCONPWD=$(jq -r '.password' $SETTINGS )
RCON=$(jq -r '.bin' $SETTINGS )
PRE="$RCON -p$RCONPWD -H $RCONHOST -P $RCONPORT "

# Parse command line arguments
while getopts ":p:i:" opt; do
  case $opt in
    p)
      PLAYER="$OPTARG"
      ;;
    i)
      JSONFILE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if -i option is provided
if [ -z "$JSONFILE" ]; then
  echo "Error: -i <itemfile> is required."
  exit 1
fi

CONFIG=$(jq -c '.properties' "$JSONFILE" | jq -r 'to_entries | map("\(.key):\(.value|tojson|gsub("\\\"";"\"")|gsub("^\"|\"$";""))") | join(",")' |     sed 's/"\([^"]*\)"/\1/g' | sed 's/Name:\([^\}]*\)/Name:\"\1\"/')
ITEM=$(jq -r '.type' "$JSONFILE" )
AMOUNT=$(jq -r '.amount' "$JSONFILE" )

$PRE "whisper $PLAYER $AMOUNT $ITEM incoming!"
$PRE "give "$PLAYER" $ITEM $AMOUNT {$CONFIG}"
