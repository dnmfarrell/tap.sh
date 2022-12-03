#!/bin/sh

# Testsuite for tap_end
#
# try tap.sh from the source tree first,
# fallback to the installed version
if [ -x "$PWD/tap.sh" ]
then
    . "$PWD/tap.sh"
else
  if [ -x "../tap.sh" ]
  then
    . "../tap.sh"

  else
    . tap.sh
  fi
fi

# we need more than one passed test to make sure, that the values in
# the plan line have the correct order and tap_end returns success
tap_ok 1 "- this prints 'ok'"
tap_pass "- this prints 'ok'"

# verify plan line: "1..2" and resultcode: 0 (every test succeded)
end_out=$( tap_end )
end_rc=$?

out="`echo "$end_out" | grep -v "^#" `"
tap_cmp_str "$out"  "1..2" "- we had 2 tests before tap_end"
tap_cmp_int 0 $end_rc "- tap_end had a resultcode of 0"


# we need a failed test to make sure, that tap_end returns failure
# but we replace the output with a "ok"
# so a test harness sees no failure here
echo  "ok 5 - replaced output of tap_fail" && tap_fail >/dev/null

# verify plan line: "1..5" and resultcode: 1 (we had a failing test)
end_out=$( tap_end )
end_rc=$?
out="`tap_end | grep -v "^#" `"
tap_cmp_str "$out"  "1..5" "- we had 5 tests before tap_end"
tap_cmp_int 1 $end_rc "- tap_end had a resultcode of 1"


# verify, that we can force a test counter for the plan line during tst_end
end_out=$(tap_end "12" )
out="`echo "$end_out" | grep -v "^#" `"

tap_cmp_str "$out"  "1..12" "- we forced 12 as test counter in tap_end"

# finish this testsuite for tap_end
# we avoid tap_end here, so a test harness sees no failure
echo "1..$TAP_TEST_COUNT"
