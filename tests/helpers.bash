load 'libs/bats-support/load'
load 'libs/bats-assert/load'

assert_exists() {
  assert [ -e "$1" ]
}

refute_exists() {
  assert [ ! -e "$1" ]
}

assert_contains() {
  local item
  for item in "${@:2}"; do
    if [[ "$item" == "$1" ]]; then
      return 0
    fi
  done

  batslib_print_kv_single_or_multi 8 \
        'expected' "$1" \
        'actual'   "$(echo ${@:2})" \
      | batslib_decorate 'item was not found in the array' \
      | fail
}

setupEnv() {
  export TEST_DIRECTORY="$(mktemp -d)"
  cd $TEST_DIRECTORY
}

teardownEnv() {
  if [ $BATS_TEST_COMPLETED ]; then
    rm -rf $TEST_DIRECTORY
  else
    echo "** Did not delete $TEST_DIRECTORY, as test failed **"
  fi
}
