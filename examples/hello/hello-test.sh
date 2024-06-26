#!/bin/sh

# import our test functions and our hello function
. "$PWD/tap.sh"
. "$PWD/examples/hello/hello.sh"

# test #1 does hello() print the expected output?
hello_out=$(hello)
tap_cmp "$hello_out" "Hello, World!" "hello"

# test #2 does hello "you" print the expected output?
hello_out=$(hello "you")
tap_cmp "$hello_out" "Hello, you!" "hello 'you'"

# print the test plan
tap_end 2
