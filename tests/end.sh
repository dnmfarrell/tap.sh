#!/bin/sh
. "$PWD/tap.sh"

out=$(TAP_TEST_COUNT=10;tap_end)
[ "$out" != "1..10" ] && printf "not "
echo "ok 1 end outputs the test plan (1..10==$out)"
echo '1..1'
