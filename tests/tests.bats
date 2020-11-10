#!./tests/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

load 'helpers'

dbi=$(pwd)/scripts/

setup() {
  setupEnv
}

teardown() {
  teardownEnv
}

@test "Can ignore an individual file" {
    touch ./test-file
    $dbi/ignore-file ./test-file

    run $dbi/is-ignored ./test-file
    assert_success
}

@test "Can unignore an individual file" {
    touch ./test-file
    $dbi/ignore-file ./test-file
    $dbi/unignore-file ./test-file

    run $dbi/is-ignored ./test-file
    assert_failure
}

@test "Can ignore a file extension" {
    touch ./txt
    touch ./file.txt
    touch ./file.md

    $dbi/ignore-pattern . '*.txt'

    run $dbi/is-ignored ./file.txt
    assert_success
    run $dbi/is-ignored ./file.md
    assert_failure
    run $dbi/is-ignored ./txt
    assert_failure
}

@test "Can unignore a file extension" {
    touch ./txt
    touch ./file1.txt
    touch ./file2.txt
    touch ./file.md

    $dbi/ignore-pattern . '*.txt'
    $dbi/unignore-pattern . '*2.txt'

    run $dbi/is-ignored ./file1.txt
    assert_success
    run $dbi/is-ignored ./file2.txt
    assert_failure
    run $dbi/is-ignored ./file.md
    assert_failure
    run $dbi/is-ignored ./txt
    assert_failure
}

@test "Can list ignored files" {
    touch ./txt
    touch ./file1.txt
    touch ./file2.txt
    touch ./file.md

    $dbi/ignore-pattern . '*.txt'
    run $dbi/list-ignored .

    assert_equal $(echo "$output" | wc -l) 2
    assert_line "./file1.txt"
    assert_line "./file2.txt"
}