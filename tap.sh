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

tap_cmp_str() {
  if [ "$1" = "$2" ];then
    tap_pass "$3"
  else
    tap_fail "$3 - expected '$2' but got '$1'"
  fi
}

tap_cmp_int() {
  if [ "$1" -eq "$2" ];then
    tap_pass "$3"
  else
    tap_fail "$3 - '$2' does not equal '$1'"
  fi
}
