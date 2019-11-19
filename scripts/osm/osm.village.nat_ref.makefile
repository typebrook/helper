SHELL := /bin/bash

data/taiwan-latest.osm.pbf:
	mkdir -p data
	curl -o $@ http://download.geofabrik.de/asia/taiwan-latest.osm.pbf

data/village.zip:
	mkdir -p data
	curl -o $@ -L http://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx\?DATA\=B8AF344F-B5C6-4642-AF46-1832054399CE

data/VILLAGE_MOI_1081007.shp: data/village.zip
	@if [ ! -e $@ ]; then unzip $< -d data && rm data/*xml data/*xlsx; fi

village.csv: data/taiwan-latest.osm.pbf
	ogr2ogr $@ $< \
		-lco GEOMETRY=AS_XY \
		-dialect sqlite \
		-sql "SELECT osm_id, name, other_tags, ST_PointOnSurface(geometry) \
              FROM multipolygons \
              WHERE admin_level = '9'"

town.csv: data/taiwan-latest.osm.pbf
	ogr2ogr $@ $< \
		-dialect sqlite \
		-sql "SELECT osm_id, name, other_tags \
              FROM multipolygons \
              WHERE admin_level = '5' OR admin_level = '7' OR admin_level = '8'"

village.no_nat_ref.csv: village.csv
	grep -v nat_ref $< > $@

village.with_nat_ref.csv: village.csv
	(head -1 $<; grep nat_ref $<) |\
	sed -r "s/\"\"\".*nat_ref\"\"=>\"\"([^\"]+).*\"\"\"/\1/g" |\
	sed '1s/other_tags/nat_ref/;s/"//g' |\
	(sed -u 1q; sort -t',' -k5)> $@

village.gov.csv: data/VILLAGE_MOI_1081007.shp
	ogr2ogr -f CSV /vsistdout/ $< |\
	(sed -u 1q; sort -t',' -k1) |\
	sed 's/"//g'> $@

matched.csv: data/VILLAGE_MOI_1081007.shp village.no_nat_ref.csv
	ogr2ogr $@ $(word 2,$^) \
		-oo X_POSSIBLE_NAMES=X -oo Y_POSSIBLE_NAMES=Y \
		-dialect sqlite \
		-sql "SELECT osm.osm_id, osm.name, gov.* \
		      FROM 'village.no_nat_ref' osm, '$<'.VILLAGE_MOI_1081007 gov \
		      WHERE Intersects(gov.geometry, osm.geometry)"

matched.by_nat_ref.list: village.with_nat_ref.csv village.gov.csv 
	join -t',' -1 5 -2 1 <(sed 1d $<) <(sed 1d $(word 2,$^)) > $@

change.county_town_en.list: matched.by_nat_ref.list
	awk -F',' -v q=\" '{print $$4, "is_in:county", q$$6q, "is_in:town", q$$7q, "name:en", q$$9q }' $< |\
	sed 's/^/relation /' > $@

confilct.list: matched.csv
	cat $< | cut -d',' -f2 | sort | uniq -d | xargs -I {} grep {} $<

origin.osm: matched.csv data/taiwan-latest.osm.pbf
	cat $< |\
	sed 1d |\
	cut -d'"' -f2 |\
	sed -nr 's/.*/r\0/p' |\
	osmium getid $(word 2,$^) --id-file - --output-format=osm > $@

change.list: matched.csv
	cat $< |\
	sed 1d |\
	awk -F',' '{print "relation", $$1, "nat_ref", $$2}' > $@
