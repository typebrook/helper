FILENAME=$0

osm.help() {
    echo "
COMMANDS:
  osm.utils.edit
  osm.get
  osm.get.full
  osm.get.history
  osm.in_relations
  osm.in_ways
  osm.extract
  osm.extract.ids
  osm.upload.to
  osm.query
  osm.file.query
  osm.file.extract
  osm.update
  osm.changeset.create
  osm.changeset.add
  osm.changeset.update
  osm.changeset.close
  osm.pbf.update
    "
}
osm.utils.edit() {
    vim $FILENAME && source $FILENAME
}

#SERVER=https://master.apis.dev.openstreetmap.org
SERVER=https://api.openstreetmap.org
OSM_API=$SERVER/api/0.6
OSM_USER_PASSWD=$(cat $HOME/git/settings/tokens/osm)

# get .osm format data
osm.fetch() {
    curl -X GET $OSM_API/$1/$2 |\
    tee /tmp/osm &&\
    echo content of $1 $2 is copied into /tmp/osm > /dev/tty
}
osm.fetch.full() {
    curl -X GET $OSM_API/$1/$2/full |\
    tee /tmp/osm &&\
    echo content of $1 $2 and its members are copied into /tmp/osm > /dev/tty
}
osm.fetch.history() {
    curl -X GET $OSM_API/$1/$2/history |\
    tee /tmp/osm &&\
    echo history of $1 $2 are copied into /tmp/osm > /dev/tty
}
osm.in_relations() {
    curl -X GET $OSM_API/$1/$2/relations |\
    tee /tmp/osm &&\
    echo relations contain $1 $2 are copied into /tmp/osm > /dev/tty
}
osm.in_ways() {
    curl -X GET $OSM_API/node/$1/ways |\
    tee /tmp/osm &&\
    echo ways contain node $1 are copied into /tmp/osm > /dev/tty
}
# extract an element from .osm format STDIN
osm.extract() {
    echo "<osm version=\"0.6\">"
    sed -nr "/^ *<$1 id=\"$2\".*/,/^ *<\/$1>/p" -
    echo "</osm>"
}
# get ids from .osm format STDIN
osm.extract.ids() {
    sed -nr 's/.*<(node|way|relation) id=\"([^"]+)\".*/\1 \2/p'
}
# upload .osm format STDIN to a given changeset
# allows multiple elements in osm body
osm.upload.to() {
    cat - > /tmp/osm

    osm.extract.ids < /tmp/osm |\
    sed 's#.*#osm.extract \0 < /tmp/osm#g' |\
    sed "s/.*/\0 \| osm.changeset.add $1/g" |\
    while read -r command
    do
        echo $command
        source<(echo "($command &)")
    done
}
# query .osm format STDIN
osm.query() {
    osmium tags-filter - $@ --input-format=osm --output-format=osm --omit-referenced
}
# query osm-related file with .osm format output
osm.file.query() {
    file=$1; shift
    osmium tags-filter $file $@ --output-format=osm --omit-referenced
}
# extract an element from osm file
osm.file.extract() {
    file=$1; shift
    osmium getid $file $@ --output-format=osm
}
# update .osm format STDIN with key-value
osm.update() {
    # remove original tag&value
    sed "/<tag k=\"$1\"/d" - | \
    if [ "$2" != "" ]; then
        # insert new tag&value
        sed -r "/<(node|way|relation)/a \ \ \ \ <tag k=\"$1\" v=\"$2\"\/>"
    else
        # just print it
        sed ''
    fi
}
# create a new changeset
osm.changeset.create() {

    echo -n "type comment: "
    read comment

    info="<osm>
            <changeset>
              <tag k='comment' v='$comment'/>
            </changeset>
          </osm>
         "

    echo $info |\
    curl -u $OSM_USER_PASSWD -i --upload-file - $OSM_API/changeset/create |\
    tee /dev/tty |\
    tail -1 |\
    xsel -ib
}
# add a new element into changeset
osm.changeset.add() {
    element=$(cat)
    header=$(echo $element | grep -E "<(node|way|relation)\s")
    ele_type=$(echo $header | sed -r 's/.*<(node|way|relation).*$/\1/')
    id=$(echo $header | sed -r 's/.* id=\"([^"]+)\".*$/\1/')

    echo $element | \
    sed -r "s/^( *<(node|way|relation).*version[^ ]+ )(.*)$/\1changeset=\"$1\">/" | \
    curl -X PUT -u $OSM_USER_PASSWD -i -T - $OSM_API/$ele_type/$id
}
# update changeset with a new comment
osm.changeset.update() {
    echo -n 'type comment: '
    read -r comment

    echo "<osm><changeset><tag k=\"comment\" v=\"$comment\"/></changeset></osm>" | \
    curl -X PUT -u $OSM_USER_PASSWD -i -T - $OSM_API/changeset/$1
}
# close a changeset
osm.changeset.close() {
    curl -X PUT -u $OSM_USER_PASSWD -i $OSM_API/changeset/$1/close
}
# update an .osm.pbf file
osm.pbf.update() {
    PBF_FILE=$1
    SERVER=http://download.geofabrik.de/asia/taiwan-updates

    # get next sequence number and store it into NEW_SEQ
    osmium fileinfo $PBF_FILE | \
    grep osmosis_replication_sequence_number | \
    cut -d'=' -f2 | \
    sed 's/$/+1/' | bc | \
    read NEW_SEQ

    # while server has osc file with given sequence number,
    # get it and do file update
    while
        SEQ_PATH=$(echo $NEW_SEQ | sed -r 's/(.{1})(.{3})/00\1\/\2/')
        STATE_URL=$SERVER/000/$SEQ_PATH.state.txt
        [ $(curl.code $STATE_URL) != "404" ]
    do
        mkdir -p changes
        CHANGE_URL=$SERVER/000/$SEQ_PATH.osc.gz
        echo $CHANGE_URL
        curl -o changes/$NEW_SEQ.osc.gz $CHANGE_URL && \
        osmium apply-changes $PBF_FILE changes/$NEW_SEQ.osc.gz \
            --output-header=osmosis_replication_sequence_number=$NEW_SEQ \
            --overwrite \
            --output $NEW_SEQ.osm.pbf

        PBF_FILE=$NEW_SEQ.osm.pbf
        ((NEW_SEQ++))
    done
}
