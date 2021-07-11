TAP_TEST_COUNT=0
TAP_FAIL_COUNT=0

tap_pass() {
  TAP_TEST_COUNT=$(( TAP_TEST_COUNT+1 ))
  echo "ok $TAP_TEST_COUNT $1"
}

tap_fail() {
  TAP_TEST_COUNT=$(( TAP_TEST_COUNT+1 ))
  TAP__FAIL_COUNT=$(( TAP__FAIL_COUNT+1 ))
  echo "not ok $TAP_TEST_COUNT $1"
}

tap_end() {
  num_tests="$1"
  [ -z "$num_tests" ] && num_tests="$TAP_TEST_COUNT"
  echo "1..$num_tests"
  exit $(( TAP_FAIL_COUNT > 0 ))
}

tap_ok() {
  if [ "$1" -eq 1 ];then
    tap_pass "$2"
  else
    tap_fail "$2"
  fi
}
