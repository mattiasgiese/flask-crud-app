#!/bin/bash

set -xeio pipefail

[[ -z "$URL" ]] && {
  echo 'You need to set URL to the frontend URL'
  exit 1
}

echo Test to see if standard header is returned
curl "$URL" | grep -q 'BookWorm Incorporated'

echo Test creation of a book
# do stuff

echo Test update of a book
# do stuff

echo Test deletion of a book
# do stuff
