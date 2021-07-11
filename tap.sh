TAP_TEST_COUNT=0
TAP_TEST_FAIL_COUNT=0

tap_ok() {
  TAP_TEST_COUNT=$(( TAP_TEST_COUNT+1 ))
  if [ "$1" != 1 ];then
    TAP_TEST_FAIL_COUNT=$(( TAP_TEST_FAIL_COUNT+1 ))
    printf "not "
  fi
  echo "ok $TAP_TEST_COUNT $2"
}

tap_pass() {
  TAP_TEST_COUNT=$(( TAP_TEST_COUNT+1 ))
  echo "ok $TAP_TEST_COUNT $1"
}

tap_fail() {
  TAP_TEST_COUNT=$(( TAP_TEST_COUNT+1 ))
  TAP_TEST_FAIL_COUNT=$(( TAP_TEST_FAIL_COUNT+1 ))
  echo "not ok $TAP_TEST_COUNT $1"
}

tap_end() {
  echo "1..$TAP_TEST_COUNT"
  exit "$TAP_TEST_FAIL_COUNT"
}
