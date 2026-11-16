# Test the CalDAV/CardDAV API (Xandikos behind nginx basic auth) at topo.tw/dav/
#
# Credentials: put a line in ~/.netrc
#   machine topo.tw login pham password <secret>
# or pass them per run: make test DAV_USER=pham DAV_PASS=<secret>
#
# Suggestion: for deeper/compliance testing, see the open source
#   - caldav-tester (Apple CalendarServer test suite)
#   - python `caldav` library (pip install caldav) for scripted client checks

.ONESHELL:
.SILENT:
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

BASE      ?= https://topo.tw
DAV       ?= $(BASE)/dav
USER_PATH ?= /dav/user
CAL       ?= $(DAV)/user/calendars/calendar
BOOK      ?= $(DAV)/user/contacts/addressbook
DAV_USER  ?= pham
DAV_PASS  ?=
TEST_UID  ?= make-test-$(shell date +%s)
FILES     ?= $(DAV)/user/files
FILE      ?=
NAME      ?= $(notdir $(FILE))

AUTH := $(if $(DAV_PASS),-u '$(DAV_USER):$(DAV_PASS)',--netrc-optional)
CURL := curl -sS --fail-with-body $(AUTH)
XML  := -H 'Content-Type: application/xml; charset=utf-8'
PRETTY := xmllint --format -

.PHONY: help test noauth discover options principal home calendars addressbooks \
        events contacts roundtrip mkcol upload ls download rm rmcol files-roundtrip

help: ## List targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-14s %s\n", $$1, $$2}'

test: noauth discover options principal calendars addressbooks events roundtrip ## Run all checks
	@echo "ALL OK"

noauth: ## Expect 401 without credentials
	code=$$(curl -s -o /dev/null -w '%{http_code}' -X PROPFIND $(DAV)/)
	[[ $$code == 401 ]] && echo "noauth: 401 OK" || { echo "noauth: got $$code, expected 401"; exit 1; }

discover: ## Check /.well-known/{caldav,carddav} redirect to /dav/
	for w in caldav carddav; do
	  loc=$$(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' $(BASE)/.well-known/$$w)
	  echo "$$w -> $$loc"; [[ $$loc == 30?\ $(DAV)/ ]]
	done

options: ## Show DAV compliance classes and allowed methods
	$(CURL) -X OPTIONS -D - -o /dev/null $(DAV)/ | grep -iE '^(dav|allow):'

principal: ## PROPFIND current-user-principal and home sets
	$(CURL) -X PROPFIND -H 'Depth: 0' $(XML) $(DAV)/ --data '<?xml version="1.0"?>
	<d:propfind xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav" xmlns:a="urn:ietf:params:xml:ns:carddav">
	  <d:prop><d:current-user-principal/><c:calendar-home-set/><a:addressbook-home-set/></d:prop>
	</d:propfind>' | $(PRETTY)

calendars: ## List calendars in the calendar home
	$(CURL) -X PROPFIND -H 'Depth: 1' $(XML) $(DAV)/user/calendars/ --data '<?xml version="1.0"?>
	<d:propfind xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/">
	  <d:prop><d:displayname/><d:resourcetype/><cs:getctag/><c:supported-calendar-component-set/></d:prop>
	</d:propfind>' | $(PRETTY)

addressbooks: ## List address books in the contacts home
	$(CURL) -X PROPFIND -H 'Depth: 1' $(XML) $(DAV)/user/contacts/ --data '<?xml version="1.0"?>
	<d:propfind xmlns:d="DAV:" xmlns:cs="http://calendarserver.org/ns/">
	  <d:prop><d:displayname/><d:resourcetype/><cs:getctag/></d:prop>
	</d:propfind>' | $(PRETTY)

events: ## REPORT events in the next 30 days (FROM/TO override, UTC yyyymmddThhmmssZ)
	FROM=$${FROM:-$$(date -u +%Y%m%dT000000Z)}; TO=$${TO:-$$(date -u -d '+30 days' +%Y%m%dT000000Z)}
	$(CURL) -X REPORT -H 'Depth: 1' $(XML) $(CAL)/ --data "<?xml version=\"1.0\"?>
	<c:calendar-query xmlns:d=\"DAV:\" xmlns:c=\"urn:ietf:params:xml:ns:caldav\">
	  <d:prop><d:getetag/><c:calendar-data/></d:prop>
	  <c:filter><c:comp-filter name=\"VCALENDAR\"><c:comp-filter name=\"VEVENT\">
	    <c:time-range start=\"$$FROM\" end=\"$$TO\"/></c:comp-filter></c:comp-filter></c:filter>
	</c:calendar-query>" | grep -E '^(SUMMARY|DTSTART)' || echo "(no events $$FROM..$$TO)"

contacts: ## Print FN of every vCard in the address book
	$(CURL) -X REPORT -H 'Depth: 1' $(XML) $(BOOK)/ --data '<?xml version="1.0"?>
	<a:addressbook-query xmlns:d="DAV:" xmlns:a="urn:ietf:params:xml:ns:carddav">
	  <d:prop><a:address-data><a:prop name="FN"/></a:address-data></d:prop>
	</a:addressbook-query>' | grep -oP '^FN:\K.*' | sort

roundtrip: ## PUT a test event, GET it back, then DELETE it
	url=$(CAL)/$(TEST_UID).ics; now=$$(date -u +%Y%m%dT%H%M%SZ); ics=$$(mktemp)
	printf 'BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//make//test//EN\r\nBEGIN:VEVENT\r\nUID:%s\r\nDTSTAMP:%s\r\nDTSTART:%s\r\nDURATION:PT15M\r\nSUMMARY:make roundtrip\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n' \
	  '$(TEST_UID)' $$now $$now > $$ics
	trap 'rm -f $$ics; $(CURL) -o /dev/null -X DELETE "$$url" 2>/dev/null || true' EXIT
	$(CURL) -o /dev/null -w 'PUT    %{http_code}\n' -X PUT -H 'Content-Type: text/calendar' -H 'If-None-Match: *' --data-binary @$$ics "$$url"
	$(CURL) "$$url" | grep -q 'UID:$(TEST_UID)' && echo "GET    200 (UID matches)"
	$(CURL) -o /dev/null -w 'DELETE %{http_code}\n' -X DELETE "$$url"
	code=$$(curl -s $(AUTH) -o /dev/null -w '%{http_code}' "$$url"); [[ $$code == 404 ]] && echo "GONE   404"

# --- Plain file storage (Xandikos accepts any file in a plain collection) ---
# nginx default client_max_body_size is 1 MB: larger uploads get 413.

mkcol: ## Create the plain collection FILES (default /dav/user/files/)
	$(CURL) -o /dev/null -w 'MKCOL %{http_code} $(FILES)/\n' -X MKCOL $(FILES)/

upload: ## Upload FILE=path into FILES (NAME= to rename)
	[[ -f '$(FILE)' ]] || { echo "usage: make upload FILE=path [NAME=remote-name]"; exit 1; }
	$(CURL) -o /dev/null -w 'PUT %{http_code} $(FILES)/$(NAME)\n' -X PUT \
	  -H "Content-Type: $$(file -b --mime-type '$(FILE)')" --data-binary @'$(FILE)' '$(FILES)/$(NAME)'

ls: ## List files in FILES with size and type
	$(CURL) -X PROPFIND -H 'Depth: 1' $(XML) $(FILES)/ --data '<?xml version="1.0"?>
	<d:propfind xmlns:d="DAV:"><d:prop><d:getcontentlength/><d:getcontenttype/></d:prop></d:propfind>' \
	| python3 -c 'import sys,xml.etree.ElementTree as E; D="{DAV:}"; [print(*[r.findtext(".//"+D+t) or "-" for t in ("getcontentlength","getcontenttype","href")], sep="\t") for r in E.parse(sys.stdin).iter(D+"response")]' \
	| column -t

download: ## Download NAME from FILES (OUT= to save elsewhere)
	[[ -n '$(NAME)' ]] || { echo "usage: make download NAME=remote-name [OUT=path]"; exit 1; }
	$(CURL) -o '$(or $(OUT),$(NAME))' '$(FILES)/$(NAME)' && echo "saved $(or $(OUT),$(NAME))"

rm: ## Delete NAME from FILES
	[[ -n '$(NAME)' ]] || { echo "usage: make rm NAME=remote-name"; exit 1; }
	$(CURL) -o /dev/null -w 'DELETE %{http_code} $(FILES)/$(NAME)\n' -X DELETE '$(FILES)/$(NAME)'

rmcol: ## Delete the whole FILES collection
	$(CURL) -o /dev/null -w 'DELETE %{http_code} $(FILES)/\n' -X DELETE $(FILES)/

files-roundtrip: ## MKCOL a temp collection, upload/compare/delete a random file, remove it
	col=$(DAV)/user/$(TEST_UID); src=$$(mktemp); dst=$$(mktemp); head -c 4096 /dev/urandom > $$src
	trap 'rm -f $$src $$dst; $(CURL) -o /dev/null -X DELETE "$$col/" 2>/dev/null || true' EXIT
	$(CURL) -o /dev/null -w 'MKCOL  %{http_code}\n' -X MKCOL "$$col/"
	$(CURL) -o /dev/null -w 'PUT    %{http_code}\n' -X PUT -H 'Content-Type: application/octet-stream' --data-binary @$$src "$$col/rand.bin"
	$(CURL) -o $$dst "$$col/rand.bin" && cmp -s $$src $$dst && echo "GET    200 (byte-identical)"
	$(CURL) -o /dev/null -w 'DELETE %{http_code} (file)\n' -X DELETE "$$col/rand.bin"
	$(CURL) -o /dev/null -w 'DELETE %{http_code} (collection)\n' -X DELETE "$$col/"
