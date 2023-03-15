#!/bin/bash

set -eu

TARGETS="infra community games official lscr"
for TARGET in $TARGETS; do
  paasify document_collection barbu-it-paasify-collection-$TARGET --out src/collections/$TARGET
done
echo "Over"
