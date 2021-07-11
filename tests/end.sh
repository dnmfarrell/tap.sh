#!/bin/sh
. "$PWD/tap.sh"

out=$(TAP_TEST_COUNT=10;tap_end)
[ "$out" != "1..10" ] && printf "not "
echo "ok 1 end outputs the number of tests run (1..10==$out)"

out=$(tap_end "5")
[ "$out" != "1..5" ] && printf "not "
echo "ok 2 end outputs the planned number of tests (1..5==$out)"

echo '1..2'
