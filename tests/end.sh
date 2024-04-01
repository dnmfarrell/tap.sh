#!/bin/sh
# Testsuite for tap_end
#
# ###########################
# Warning:
# using tap_* test functions after tap_end violates the TAP spec
# but we depend on an implementation detail here
#
# dont't do that in your code
# ###########################

# try tap.sh from the current directory first,
# fallback to an installed version
if [ -x "$PWD/tap.sh" ]; then
	. "$PWD/tap.sh"
else
	. tap.sh
fi

# we need more than one passed test to make sure, that the values in
# the plan line have the correct order and tap_end returns success
tap_ok 0 "this prints 'ok'"
tap_pass "this prints 'ok'"

# verify plan line: "1..2" and resultcode: 0 (every test before the tap_end succeded)
end_out=$(tap_end)
end_rc=$?
out="$(echo "$end_out" | grep -v "^#" | head -1)"
tap_cmp "$out" "1..2" "we used two tests before this tap_end"
tap_cmp 0 $end_rc "since every test succeeded: resultcode of tap_end must be 0"

# verify, that we can force a test counter for the plan line during tst_end
# and that tap_end returns a failure, when the internal test counter does not match
end_out=$(tap_end "42")
end_rc=$?
out="$(echo "$end_out" | grep -v "^#" | head -1)"
tap_cmp "$out" "1..42" "we forced 42 as test counter in this tap_end"
tap_cmp 1 $end_rc "we forced a different test counter: resultcode of tap_end must be 1"

# we need a failed test to make sure, that tap_end returns failure
printf "ok 7 - overwrite result: (" && tap_fail "expecting a 'not ok' here)"

# verify plan line: "1..7" and resultcode: 1 (we forced a failing test)
end_out=$(tap_end)
end_rc=$?
out="$(tap_end | grep -v "^#" | head -1)"
tap_cmp "$out" "1..7" "we used 7 tests before this tap_end"
tap_cmp 1 $end_rc "we forced a failing test: resultcode of tap_end must be 1"

# can't use tap_end here: the tap_fail above would fail this testsuite
echo "1..9"
