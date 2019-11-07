FILENAME=$0

osm.utils.edit() {
    vim $FILENAME && source $FILENAME
}

#SERVER=https://master.apis.dev.openstreetmap.org
SERVER=https://api.openstreetmap.org
OSM_API=$SERVER/api/0.6
OSM_USER_PASSWD=$(cat $HOME/git/settings/tokens/osm)

# get .osm format data
osm.get() {
    curl -X GET $OSM_API/$1/$2 &&\
    echo $2 | xsel -ib
}
# extract an element from .osm format STDIN
osm.extract() {
    echo "<osm version=\"0.6\">"
    sed -nr "/^ *<$1 id=\"$2\".*/,/^ *<\/$1>/p" -
    echo "</osm>"
}
# get ids from .osm format STDIN
osm.get.ids() {
    sed -nr 's/.*<(node|way|relation) id=\"([^"]+)\".*/\1 \2/p'
}
osm.upload() {
    #source <(cat fetch | sed 's/^/osm.extract /g' | sed 's/$/ <new.osm/g')
    INPUT=$(cat -)
    echo $INPUT | osm.get.ids | sed 's/.*/osm.extract \0 <($INPUT)/g' | xargs tee
}
# query osm-related file with .osm format output
osm.file.query() {
    osmium tags-filter $1 $2 --output-format=osm --omit-referenced
}
# extract an element from osm file
osm.file.extract() {
    osmium getid $1 $2 --output-format=osm
}
# update .osm format STDIN with key-value
osm.update() {
    # remove original tag&value
    sed "/<tag k=\"$1\"/d" - | \
    # insert new tag&value
    sed -r "/<(node|way|relation)/a \ \ \ \ <tag k=\"$1\" v=\"$2\"\/>"
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
    curl -u $OSM_USER_PASSWD -i --upload-file - $SERVER/api/0.6/changeset/create |\
    tee /dev/tty |\
    tail -1 |\
    xsel -ib
}
# add a new element into changeset
osm.changeset.add() {
    element=$(cat -)
    header=$(echo $element | grep -E "<(node|way|relation)\s")
    ele_type=$(echo $header | sed -r 's/.*<(node|way|relation).*$/\1/')
    id=$(echo $header | sed -r 's/.* id=\"([^"]+)\".*$/\1/')

    echo $element | \
    sed -r "s/^( *<(node|way|relation).*version[^ ]+ )(.*)$/\1changeset=\"$1\">/" | \
    curl -X PUT -u $OSM_USER_PASSWD -i -T - $OSM_API/$ele_type/$id
}
# update changeset with a new comment
osm.changeset.update() {
    echo "<osm><changeset><tag k=\"comment\" v=\"$2\"/></changeset></osm>" | \
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
        CHANGE_URL=$SERVER/000/$SEQ_PATH.osc.gz
        echo $CHANGE_URL
        curl -o $NEW_SEQ.osc.gz $CHANGE_URL && \
        osmium apply-changes $PBF_FILE $NEW_SEQ.osc.gz \
            --output-header=osmosis_replication_sequence_number=$NEW_SEQ \
            --overwrite \
            --output $NEW_SEQ.osm.pbf

        PBF_FILE=$NEW_SEQ.osm.pbf
        (( NEW_SEQ++ ))
    done
}
