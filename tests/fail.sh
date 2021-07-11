#!/bin/sh
. "$PWD/tap.sh"

test_count=0
test_output() {
  test_count=$(( test_count+1 ))
  out=$(tap_fail "$1")
  [ "$out" != "$2" ] && printf "not "
  echo "ok $test_count $1 ($2==$out)"
}

test_output "" "not ok 1 "
test_output "with expression" "not ok 1 with expression"
echo '1..2'
