hello() {
  subject="$1"
  [ -z "$subject" ] && subject="World"
  echo "Hello, $subject!"
}
