#!/bin/bash

set -xeo pipefail

[[ -z "$APPURL" ]] && {
  echo 'You need to set APPURL to the frontend URL'
  exit 1
}

set -u

echo Test to see if standard header is returned
curl "$APPURL" | grep -q 'BookWorm Incorporated'

echo Test creation of a book
curl -F 'title=foobar' -s -o /dev/null -w "%{http_code}" "$APPURL" | grep -q 200

echo Test update of a book
curl -F 'oldtitle=foobar' -F 'newtitle="Narf Narf Narf"' "${APPURL}/update"

echo Test deletion of a book
curl -F 'title="Narf Narf Narf"' "${APPURL}/delete" | grep -q 302
