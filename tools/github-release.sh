#!/usr/bin/env sh
#
# Author: Hsieh Chin Fan (typebrook) <typebrook@gmail.com>
# License: MIT
# https://gist.github.com/typebrook/4947769e266173303d8848f496e272c9
#
# Originally created by stefanbuck
# fork from: https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447
#
#
# This script accepts the following parameters:
#
# * owner
# * repo
# * tag
# * type (asset or edit)
# * filename
# * github_api_token
# * overwrite (optional, could be ture, false, delete, default to be false)
#
# Script to manage a release or its asset using the GitHub API v3.
#
# Example:
#
# github-release.sh github_api_token=TOKEN owner=stefanbuck repo=playground tag=v0.1.0 type=asset filename=./build.zip overwrite=true
#

# Check dependencies.
set -e

# Validate settings.
[ "$TRACE" ] && set -x

CONFIG=$@

for line in $CONFIG; do
  eval "$line"
done

# Define variables.
GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$owner/$repo"
GH_TAGS="$GH_REPO/releases/tags/$tag"
AUTH="Authorization: token $github_api_token"

if [ "$tag" = 'LATEST' ]; then
  GH_TAGS="$GH_REPO/releases/latest"
fi
if [ "$type" = '' ]; then
  sed -E -n -e ' /^$/ q; 11,$ s/^# *//p' "$0"
  exit 0
fi

# Validate token.
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

# Read asset tags.
response=$(curl -sH "$AUTH" $GH_TAGS)

# Get ID of the release.
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=' | sed 's/id/release_id/')
[ "$release_id"  ] || { echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }

upload_asset() {
  # Get ID of the asset based on given filename.
  # If exists, delete it.
  eval $(echo "$response" | grep -C2 "\"name\":.\+$(basename $filename)" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=' | sed 's/id/asset_id/')
  if [ "$asset_id" = ""  ]; then
    echo "No need to overwrite asset"
  else
    if [ "$overwrite" = "true" ] || [ "$overwrite" = "delete" ]; then
      echo "Deleting asset($asset_id)... "
      curl  -X "DELETE" -H "$AUTH" "$GH_REPO/releases/assets/$asset_id"
      if [ "$overwrite" = "delete" ]; then
          exit 0
      fi
    else
      echo "File already exists on tag $tag"
      echo "If you want to overwrite it, set overwrite=true"
      exit 1
    fi
  fi

  # Upload asset
  echo "Uploading asset... "

  # Construct url
  GH_ASSET="https://uploads.github.com/repos/$owner/$repo/releases/$release_id/assets?name=$(basename $filename)"

  curl --data-binary @"$filename" -H "$AUTH" -H "Content-Type: application/octet-stream" $GH_ASSET
}

edit_release() {
  GH_RELEASE="$GH_REPO/releases/$release_id"
  body=$(cat <<EOF
{
  "tag_name": "$tag",
  "target_commitish": "master",
  "name": "daily-taiwan-pbf",
  "body": "$(cat $filename | sed 's/"/\\"/g; $! s/$/\\n/' | tr -d '\n')",
  "draft": false,
  "prerelease": false
}
EOF
  )
  curl -v -X PATCH -H "$AUTH" -H "Content-Type: application/json" -d "$body" $GH_RELEASE
}

case $type in
  asset) upload_asset;;
  edit) edit_release;;
  *) echo "type should be 'asset' or 'edit'";;
esac
