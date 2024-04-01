`tap.sh` is a POSIX-compliant test library for shell code. It emits [Test Anything Protocol](https://testanything.org/tap-specification.html) output, so you can run the your unit tests with any TAP-compatible test harness.

It comes with these functions:

```
tap_pass [description]            - pass a test
tap_fail [description]            - fail a test
tap_ok pass_flag [description]    - pass a test if pass_flag equals 0, else fail
tap_cmp got exp [description]     - pass a test if got string equals exp, else fail
tap_end                           - print the test plan and exit
```

Alternatives
------------
* [shunit2](https://github.com/kward/shunit2) is an xUnit-style unit test framework for Bourne-like shell code
* [sharness](https://github.com/mlafeldt/Sharness) is a TAP unit test shell library like `tap.sh` but with more features
* The TAP website has a list of [shell test libraries](https://testanything.org/producers.html#shell) ("producers")

Tutorial
--------
Imagine we have written a shell library called `examples/hello/hello.sh`. It has one function, which by default prints "Hello, World!":

```sh
hello() {
  subject="$1"
  [ -z "$subject" ] && subject="World!"
  echo "Hello, $subject"
}
```

To test it, we want to call `hello` and check it prints the expected output. Here's our test-script, `examples/hello/hello-test.sh`:

```sh
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

# print our test plan to ensure we got here
tap_end
```

We can run the test script from the command line:

```
./examples/hello/hello-test.sh 
ok 1 hello
1..1
```

This prints "ok" as our test passed! It also prints the number of tests run, so we can be sure all of our test script code was executed. However all this script does is emit TAP output. We can run it with a test harness which will interpret the output and tell us if the test passed or not. Perl's [prove](https://perldoc.perl.org/prove) is an easy harness to run and usually comes with Perl. You might already have it installed.

```
$ prove ./examples/hello/hello-test.sh
./examples/hello/hello-test.sh .. ok
All tests successful.
Files=1, Tests=1,  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)
Result: PASS
```

Our `hello` function actually has two code paths: the default is to print "Hello, World!" but it also accepts an optional subject to greet instead. Let's expand our test script to check that path:

```sh
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
[ "$hello_out" = "Hello, you!" ]
tap_ok $? "hello \"you\""

# print our test plan to ensure we ran 2 tests
tap_end 2
```

Test #2 checks that calling `hello` with "you" emits "Hello, you!" instead of the default. Instead of an if/else block, it calls `tap_ok` with a success flag to pass or fail the test. It also calls `tap_end` with the number of tests to ensure we ran both tests. Running it with `prove -v` shows us the individual tests run, as well as a summary:

```
$ prove -v examples/hello/hello-test.sh
examples/hello/hello-test.sh ..
ok 1 hello
not ok 2 hello "you"
1..2
Failed 1/2 subtests 

Test Summary Report
-------------------
examples/hello/hello-test.sh (Wstat: 0 Tests: 2 Failed: 1)
  Failed test:  2
Files=1, Tests=2,  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)
Result: FAIL
```

Uh oh, the second test case failed! It would be helpful if the test printed the mismatched variables to help us debug the issue. We can simplify our test cases to use the `tap_cmp` function to compare two strings and print them if they don't match:

```sh
#!/bin/sh

# import our test functions and our hello function
. "$PWD/tap.sh"
. "$PWD/examples/hello/hello.sh"

# test #1 does hello print the expected output?
hello_out=$(hello)
tap_cmp "$hello_out" "Hello, World!" "hello"

# test #2 does hello "you" print the expected output?
hello_out=$(hello "you")
tap_cmp "$hello_out" "Hello, you!" "hello 'you'"

# print our test plan to ensure we ran 2 tests
tap_end 2
```

Re-running the tests, now we get some actionable output:

```
$ prove -v examples/hello/hello-test.sh 
examples/hello/hello-test.sh .. 
ok 1 hello
not ok 2 hello "you" - expected 'Hello, you!' but got 'Hello, you'
1..2
Failed 1/2 subtests 

Test Summary Report
-------------------
examples/hello/hello-test.sh (Wstat: 0 Tests: 2 Failed: 1)
  Failed test:  2
Files=1, Tests=2,  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)
Result: FAIL
```

Our `hello` function is appending the "!" in the wrong place; we want to greet everybody with enthusiasm, not just the "World"!. Here's the fixed-up version, with the "!" moved to the `echo` argument:

```sh
hello() {
  subject="$1"
  [ -z "$subject" ] && subject="World"
  echo "Hello, $subject!"
}
```

And now the tests pass:

```
$ prove -v examples/hello/hello-test.sh
examples/hello/hello-test.sh ..
ok 1 hello
ok 2 hello "you"
1..2
ok
All tests successful.
Files=1, Tests=2,  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)
Result: PASS
```
