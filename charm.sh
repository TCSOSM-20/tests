#!/bin/bash
# Workaround for charm build


function build() {
  echo "$@"
  charm-build "$@"
}

params="$@"
delete=build

params=("${params[@]/$delete}")

build $params

