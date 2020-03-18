#!/usr/bin/env sh
#
# Author: Hsieh Chin Fan (typebrook) <typebrook@gmail.com>
# License: MIT
# https://gist.github.com/typebrook/4947769e266173303d8848f496e272c9
#
# Originally created by stefanbuck
# fork from: https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447
#
# --
# This script manages a release note or its asset with GitHub API v3.
# It accepts the following parameters:
#
# * repo
# * tag
# * type (asset or edit)
# * filename
# * github_api_token
# * overwrite (optional, could be ture, false, delete, default to be false)
#
# Example:
#
# # Upload a file as asset. If there is a asset with the same filename, then overwrite it.
# github-release.sh github_api_token=TOKEN repo=stefanbuck/playground tag=v0.1.0 type=asset filename=./build.zip overwrite=true
#
# # Edit a release note with file content
# github-release.sh github_api_token=TOKEN repo=stefanbuck/playground tag=v0.1.0 type=edit filename=note

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
GH_REPO="$GH_API/repos/$repo"
GH_TAGS="$GH_REPO/releases/tags/$tag"
AUTH="Authorization: token $github_api_token"

if [ "$tag" = 'LATEST' ]; then
  GH_TAGS="$GH_REPO/releases/latest"
fi
if [ "$type" = '' ]; then
  sed -E -n -e ' /^$/ q; /# --/,$ s/^# *//p' "$0"
  exit 0
fi

# Validate token.
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

# Read asset tags.
response=$(curl -sH "$AUTH" $GH_TAGS)

# Get ID of the release.
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=' | sed 's/id/release_id/')
[ "$release_id"  ] || { echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }

post_asset() {
  # Upload asset
  echo "Uploading asset... " > /dev/tty
  # Construct url
  GH_ASSET="https://uploads.github.com/repos/$repo/releases/$release_id/assets?name=$(basename $1)"

  curl --data-binary @"$filename" -H "$AUTH" -H "Content-Type: application/octet-stream" $GH_ASSET
}

delete_asset() {
  echo "Deleting asset($1)... " > /dev/tty
  curl -X "DELETE" -H "$AUTH" "$GH_REPO/releases/assets/$1"
}

upload_asset() {
  # Get ID of the asset based on given filename.
  # If exists, delete it.
  eval $(echo "$response" | grep -C2 "\"name\": \"$(basename $filename)\"" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=' | sed 's/id/asset_id/')
  if [ "$asset_id" = ""  ]; then
    echo "No need to overwrite asset"
    post_asset $filename
  else
    if [ "$overwrite" = "true" ]; then
      new_asset_id=$(post_asset ${filename}_bak | sed -E 's/^\{[^{]+"id":([0-9]+).+$/\1/')
      [ "$new_asset_id" = "" ] && exit 1 || delete_asset "$asset_id"

      echo "Renaming asset($new_asset_id) from $(basename $filename)_bak to $(basename $filename)" > /dev/tty
      curl -X PATCH -H "$AUTH" -H "Content-Type: application/json" \
        --data "{\"name\":\"$(basename $filename)\"}" "$GH_REPO/releases/assets/$new_asset_id"
    elif [ "$overwrite" = "delete" ]; then
      delete_asset "$asset_id"
      exit 0
    else
      echo "File already exists on tag $tag"
      echo "If you want to overwrite it, set overwrite=true"
      exit 1
    fi
  fi
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
  curl -X PATCH -H "$AUTH" -H "Content-Type: application/json" -d "$body" $GH_RELEASE
}

case $type in
  asset) upload_asset;;
  edit) edit_release;;
  *) echo "type should be 'asset' or 'edit'";;
esac
