#!/bin/sh

# import our test functions and our hello function
. "$PWD/tap.sh"
. "$PWD/examples/hello/hello.sh"

# test #1 does hello() print the expected output?
hello_out=$(hello)
if [ "$hello_out" = "Hello, World!" ];then
  tap_pass "hello"
else
  tap_fail "hello"
fi

# test #2 does hello "you" print the expected output?
hello_out=$(hello "you")
pass=0
[ "$hello_out" = "Hello, you!" ] && pass=1
tap_ok "$pass" "hello you"

# print our test plan to ensure we ran 2 tests
tap_end "2"
