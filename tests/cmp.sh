#!/bin/sh
. "$PWD/tap.sh"

test_count=0
test_output() {
	test_count=$((test_count + 1))
	out=$(tap_cmp "$@")
	[ "$out" != "$4" ] && printf "not "
	echo "ok $test_count $2 ($4==$out)"
}

test_output "foo" "foo" "match succeeds" "ok 1 match succeeds"
test_output "foo" "bar" "mismatch fails" "not ok 1 mismatch fails - expected 'bar' but got 'foo'"
test_output "" "" "empty succeeds" "ok 1 empty succeeds"
echo '1..3'
