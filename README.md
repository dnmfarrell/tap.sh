`tap.sh` is a POSIX-compliant test library for shell code. It emits [Test Anything Protocol](https://testanything.org/tap-specification.html) output, so you can run the your unit tests with any TAP-compatible test harness.

It comes with four functions:

```
tap_pass [description]         - pass a test
tap_fail [description]         - fail a test
tap_ok pass_flag [description] - pass a test if pass_flag equals 1, else fail
tap_end [count]                - print the test plan and exit
```

Example
-------
Imagine we have written a shell library called `examples/hello/hello.sh`. It has one function, which by default prints "Hello, World!":

```sh
hello() {
  subject="$1"
  [ -z "$subject" ] && subject="World"
  echo "Hello, $subject!"
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
pass=0
[ "$hello_out" = "Hello, you!" ] && pass=1
tap_ok "$pass" "hello you"

# print our test plan to ensure we ran 2 tests
tap_end "2"
```

Test #2 checks that calling `hello` with "you" emits "Hello, you!" instead of the default. Instead of an if/else block, it calls `tap_ok` with a success flag to pass or fail the test. It also calls `tap_end` with the number of tests to ensure we ran both tests. Running it with `prove -v` shows us the individual tests run, as well as a summary:

```
prove -v ./examples/hello/hello-test.sh
./examples/hello/hello-test.sh ..
ok 1 hello
ok 2 hello you
1..2
ok
All tests successful.
Files=1, Tests=2,  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)
Result: PASS
```

If you download this repo you can run this code for yourself from the root project directory.

Running tests with a test harness is useful as it can run multiple test files and tell us if the test suite passed or failed overall. It can execute tests concurrently so the test suite runs faster. And by default it limits output to only the summary and any failed tests, so the terminal isn't filled with noise. A few years ago I wrote an [introduction to prove](https://www.perl.com/article/177/2015/6/9/Get-to-grips-with-Prove-Perl-s-test-workhorse/) which describes its main features.

Alternatives
------------
* [shunit2](https://github.com/kward/shunit2) is an xUnit-style unit test framework for Bourne-like shell code
* [sharness](https://github.com/mlafeldt/Sharness) is a TAP unit test shell library like `tap.sh` but with more features
* The TAP website has a list of [shell test libraries](https://testanything.org/producers.html#shell) ("producers")
