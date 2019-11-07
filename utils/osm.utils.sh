FILENAME=$0

osm.utils.edit() {
    vim $FILENAME
}

OSM_API='https://api.openstreetmap.org/api/0.6'
OSM_USER_PASSWD=$(cat $HOME/git/settings/tokens/osm)

osm.get() {
    curl -X GET $OSM_API/$1/$2
}
osm.file.query() {
    osmium tags-filter $1 $2 --output-format=osm --omit-referenced
}
osm.extract() {
    echo "<osm version=\"0.6\">"
    sed -nr "/^ *<$1 id=\"$2\".*/,/^ *<\/$1>/p" -
    echo "</osm>"
}
osm.update() {
    # remove original tag&value
    sed "/<tag k=\"$1\"/d" - | \
    # insert new tag&value
    sed -r "/<(node|way|relation)/a \ \ \ \ <tag k=\"$1\" v=\"$2\"\/>"
}
osm.changeset.add() {
    element=$(cat -)
    header=$(echo $element | grep -E "<(node|way|relation)\s")
    ele_type=$(echo $header | sed -r 's/.*<(node|way|relation).*$/\1/')
    id=$(echo $header | sed -r 's/.* id=\"([^"]+)\".*$/\1/')

    echo $element | \
    sed -r "s/^( *<(node|way|relation).*version[^ ]+ )(.*)$/\1changeset=\"$1\">/" | \
    curl -X PUT -u $OSM_API_USER_PASSWD -i -T - $OSM_API/$ele_type/$id
}
osm.changeset.update() {
    echo "<osm><changeset><tag k=\"comment\" v=\"$2\"/></changeset></osm>" | \
    curl -X PUT -u $OSM_API_USER_PASSWD -i -T - $OSM_API/changeset/$1
}
osm.changeset.close() {
    curl -X PUT -u $OSM_API_USER_PASSWD -i $OSM_API/changeset/$1/close
}
osm.pbf.update() {
    PBF_FILE=$1
    SERVER=http://download.geofabrik.de/asia/taiwan-updates

    osmium fileinfo $PBF_FILE | \
    grep osmosis_replication_sequence_number | \
    cut -d'=' -f2 | \
    sed 's/$/+1/' | bc | \
    read NEW_SEQ

    SEQ_PATH=$(echo $NEW_SEQ | sed -r 's/(.{1})(.{3})/00\1\/\2/')
    STATE_URL=$SERVER/000/$SEQ_PATH.state.txt

    while [ $(curl.code $STATE_URL) != "404" ]
    do
        CHANGE_URL=$SERVER/000/$SEQ_PATH.osc.gz
        echo $CHANGE_URL
        curl -o $NEW_SEQ.osc.gz $CHANGE_URL && \
        osmium apply-changes $PBF_FILE $NEW_SEQ.osc.gz \
            --output-header=osmosis_replication_sequence_number=$NEW_SEQ \
            --overwrite \
            --output $NEW_SEQ.osm.pbf

        PBF_FILE=$NEW_SEQ.osm.pbf
        NEW_SEQ=$((NEW_SEQ+1))
        SEQ_PATH=$(echo $NEW_SEQ | sed -r 's/(.{1})(.{3})/00\1\/\2/')
        STATE_URL=$SERVER/000/$SEQ_PATH.state.txt
    done
}
