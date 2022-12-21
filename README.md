`tap.sh` is a POSIX-compliant test library for shell code. It emits [Test Anything Protocol](https://testanything.org/tap-specification.html) output, so you can run the your unit tests with any TAP-compatible test harness.

It comes with these functions:

```
tap_pass [description]            - pass a test
tap_fail [description]            - fail a test
tap_ok pass_flag [description]    - pass a test if pass_flag equals 1, else fail
tap_cmp_str got exp [description] - pass a test if got string equals exp, else fail
tap_cmp_int got exp [description] - pass a test if got integer equals exp, else fail
tap_end [count]                   - print the test plan and exit
```

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
pass=0
[ "$hello_out" = "Hello, you!" ] && pass=1
tap_ok "$pass" "hello \"you\""

# print our test plan to ensure we ran 2 tests
tap_end "2"
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

Uh oh, the second test case failed! It would be helpful if the test printed the mismatched variables to help us debug the issue. We can simplify our test cases to use the `tap_cmp_str` function to compare two strings and print them if they don't match:

```sh
#!/bin/sh

# import our test functions and our hello function
. "$PWD/tap.sh"
. "$PWD/examples/hello/hello.sh"

# test #1 does hello print the expected output?
hello_out=$(hello)
tap_cmp_str "$hello_out" "Hello, World!" "hello"

# test #2 does hello "you" print the expected output?
hello_out=$(hello "you")
tap_cmp_str "$hello_out" "Hello, you!" "hello \"you\""

# print our test plan to ensure we ran 2 tests
tap_end "2"
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

If you download this repo you can run this code for yourself from the root project directory.

Running tests with a test harness is useful as it can run multiple test files and tell us if the test suite passed or failed overall. It can execute tests concurrently so the test suite runs faster. And by default it limits output to only the summary, so the terminal isn't filled with noise. A few years ago I wrote an [introduction to prove](https://www.perl.com/article/177/2015/6/9/Get-to-grips-with-Prove-Perl-s-test-workhorse/) which describes its main features.

If prove isn't your jam, The TAP website has a [list](https://testanything.org/consumers.html) of other TAP parsers that can be used in conjunction with a test harness. A test harness can be as simple as a one liner, here using [tapview](https://gitlab.com/esr/tapview):

```
$ res="PASS";for t in examples/hello/*test.sh;do echo "$t"; "./$t" | tapview || res="FAIL";done;echo "$res"
examples/hello/hello-test.sh
..
2 tests, 0 failures.
PASS
```

Installation
------------
Clone/download this repo. The test suite emits TAP, so it can conveniently be run with `prove`:

```
$ prove tests/*
tests/cmp_int.sh .. ok
tests/cmp_str.sh .. ok
tests/end.sh ...... ok
tests/fail.sh ..... ok
tests/ok.sh ....... ok
tests/pass.sh ..... ok
All tests successful.
Files=6, Tests=23,  0 wallclock secs ( 0.05 usr  0.00 sys +  0.01 cusr  0.02 csys =  0.08 CPU)
Result: PASS
```

If you don't have a TAP test harness like prove, you can run the tests with this one liner and eyeball the output.

```
$ for t in tests/*;do "$t"; done
ok 1 1 (ok 1 match succeeds==ok 1 match succeeds)
ok 2 1 (not ok 1 mismatch fails - '1' does not equal '0'==not ok 1 mismatch fails - '1' does not equal '0')
ok 3 1 (not ok 1 non-int fails - '1' does not equal 'foo'==not ok 1 non-int fails - '1' does not equal 'foo')
ok 4  (not ok 1 empty fails - '' does not equal ''==not ok 1 empty fails - '' does not equal '')
1..4
ok 1 foo (ok 1 match succeeds==ok 1 match succeeds)
ok 2 bar (not ok 1 mismatch fails - expected 'bar' but got 'foo'==not ok 1 mismatch fails - expected 'bar' but got 'foo')
ok 3  (ok 1 empty succeeds==ok 1 empty succeeds)
1..3
ok 1 this prints 'ok'
ok 2 this prints 'ok'
ok 3 we used two tests before this tap_end
ok 4 since every test succeeded: resultcode of tap_end must be 0
ok 5 we forced 42 as test counter in this tap_end
ok 6 we forced a different test counter: resultcode of tap_end must be 1
ok 7 - overwrite result: (not ok 7 expecting a 'not ok' here)
ok 8 we used 7 tests before this tap_end
ok 9 we forced a failing test: resultcode of tap_end must be 1
1..9
ok 1  (not ok 1 ==not ok 1 )
ok 2 with expression (not ok 1 with expression==not ok 1 with expression)
1..2
ok 1  (ok 1 ==ok 1 )
ok 2 with expression (ok 1 with expression==ok 1 with expression)
ok 3  (not ok 1 ==not ok 1 )
1..3
ok 1  (ok 1 ==ok 1 )
ok 2 with expression (ok 1 with expression==ok 1 with expression)
1..2
```

If the tests pass, add `tap.sh` to your PATH environment variable, (or copy it to a location already in PATH) and you can start using it.

Alternatives
------------
* [shunit2](https://github.com/kward/shunit2) is an xUnit-style unit test framework for Bourne-like shell code
* [sharness](https://github.com/mlafeldt/Sharness) is a TAP unit test shell library like `tap.sh` but with more features
* The TAP website has a list of [shell test libraries](https://testanything.org/producers.html#shell) ("producers")
