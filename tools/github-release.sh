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
# * action (optional, could be upload, overwrite, rename, delete, default to be upload)
# * extra  (optional, new filename for action 'rename')
# * create (optional, create a new release if it doesn't exist)
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
# Keep tty
exec 3>&1

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
release_id=$(echo "$response" | grep -m1 -w \"id\": | sed -E -e 's/[^0-9]//g')
if [ -z "$release_id" ]; then
  if [ "$create" = 'true' ]; then
    body=$(cat <<EOF
{
  "tag_name": "$tag",
  "target_commitish": "master",
  "name": "$tag",
  "body": "",
  "draft": false,
  "prerelease": false
}
EOF
    )
    response=$(curl -H "$AUTH" -H "Content-Type: application/json" -d "$body" "$GH_REPO/releases")
    release_id=$(echo "$response" | grep -m1 -w \"id\": | sed -E -e 's/[^0-9]//g')
  else
    echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2
    exit 1
  fi
fi

post_asset() {
  # Upload asset
  echo "Uploading asset... " >&3
  # Construct url
  GH_ASSET="https://uploads.github.com/repos/$repo/releases/$release_id/assets?name=$1"

  curl --data-binary @"$filename" -H "$AUTH" -H "Content-Type: application/octet-stream" $GH_ASSET
}

rename_asset() {
  echo "Renaming asset($1) from $2 to $3" >&3
  curl -X PATCH -H "$AUTH" -H "Content-Type: application/json" \
    --data "{\"name\":\"$3\", \"label\":\"$3\"}" "$GH_REPO/releases/assets/$1"
}

delete_asset() {
  echo "Deleting asset($1)... " >&3
  curl -X "DELETE" -H "$AUTH" "$GH_REPO/releases/assets/$1"
}

upload_asset() {
  # Get ID of the asset based on given filename.
  # If exists, delete it.
  eval $(echo "$response" | grep -C2 "\"name\": \"$(basename $filename)\"" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=' | sed 's/id/asset_id/')
  if [ "$asset_id" = ""  ]; then
    echo "No need to overwrite asset"
    post_asset $(basename $filename)
  else
    if [ "$action" = "overwrite" ]; then
      new_asset_id=$(post_asset "bak_$(basename $filename)" | sed -E 's/^\{[^{]+"id":([0-9]+).+$/\1/')
      [ "$new_asset_id" = "" ] && exit 1 || delete_asset "$asset_id"

      rename_asset "$new_asset_id" "bak_$(basename $filename)" "$(basename $filename)"
    elif [ "$action" = "rename" ]; then
      rename_asset "$asset_id" "$filename" "$extra"
    elif [ "$action" = "delete" ]; then
      delete_asset "$asset_id"
      exit 0
    else
      echo "File already exists on tag $tag"
      echo "If you want to overwrite it, set action=overwrite"
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
  "name": "$tag",
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
