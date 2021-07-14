#!/bin/sh
. "$PWD/tap.sh"

test_count=0
test_output() {
  test_count=$(( test_count+1 ))
  out=$(tap_cmp_int "$@" 2>/dev/null)
  [ "$out" != "$4" ] && printf "not "
  echo "ok $test_count $2 ($4==$out)"
}

test_output " 1" "1" "match succeeds" "ok 1 match succeeds"
test_output "0" "1"  "mismatch fails" "not ok 1 mismatch fails - '1' does not equal '0'"
test_output "foo" "1"  "non-int fails" "not ok 1 non-int fails - '1' does not equal 'foo'"
test_output "" ""  "empty fails" "not ok 1 empty fails - '' does not equal ''"
echo '1..4'
