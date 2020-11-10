#!./tests/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

load 'helpers'

dbi=$(pwd)/dropbox-ignore
background_pid=''

setup() {
    setupEnv
}

teardown() {
    if [ -n "$background_pid" ]; then
        # Kill children and any of their subprocesses:
        pkill -P $background_pid
        kill "$background_pid"
    fi

    teardownEnv
}

@test "Can ignore an individual file" {
    touch ./test-file
    $dbi ignore ./test-file

    run $dbi is-ignored ./test-file
    assert_success
}

@test "Can unignore an individual file" {
    touch ./test-file
    $dbi ignore ./test-file
    $dbi unignore ./test-file

    run $dbi is-ignored ./test-file
    assert_failure
}

@test "Can ignore a file extension" {
    touch ./txt
    touch ./file.txt
    touch ./file.md

    $dbi ignore . '*.txt'

    run $dbi is-ignored ./file.txt
    assert_success
    run $dbi is-ignored ./file.md
    assert_failure
    run $dbi is-ignored ./txt
    assert_failure
}

@test "Can unignore a file extension" {
    touch ./txt
    touch ./file1.txt
    touch ./file2.txt
    touch ./file.md

    $dbi ignore . '*.txt'
    $dbi unignore . '*2.txt'

    run $dbi is-ignored ./file1.txt
    assert_success
    run $dbi is-ignored ./file2.txt
    assert_failure
    run $dbi is-ignored ./file.md
    assert_failure
    run $dbi is-ignored ./txt
    assert_failure
}

@test "Can list ignored files" {
    touch ./txt
    touch ./file1.txt
    touch ./file2.txt
    touch ./file.md

    $dbi ignore . '*.txt'
    run $dbi list-ignored .

    assert_equal $(echo "$output" | wc -l) 2
    assert_line "./file1.txt"
    assert_line "./file2.txt"
}

@test "Can automatically ignore newly created files" {
    touch ./file1.txt
    touch ./file2.md

    $dbi watch . '*.txt' &
    background_pid=$!

    touch ./file3.txt
    touch ./file4.md
    sleep 0.1

    # Should ignore new matching files:
    run $dbi is-ignored ./file3.txt
    assert_success

    # Should not ignore non-matching files:
    run $dbi is-ignored ./file4.md
    assert_failure

    # Should not touch existing files:
    run $dbi is-ignored ./file1.txt
    assert_failure
    run $dbi is-ignored ./file2.md
    assert_failure
}

@test "Can automatically ignore files in new subdirectories" {
    $dbi watch . '*.txt' &
    background_pid=$!
    sleep 0.5

    mkdir new-dir
    touch new-dir/file.txt
    sleep 0.1

    run $dbi is-ignored ./new-dir/file.txt
    assert_success
}

@test "Can automatically ignore files from multiple patterns" {
    $dbi watch . '*.txt' '*/.git' &
    background_pid=$!
    sleep 0.5

    mkdir new-dir
    touch new-dir/file.md
    touch new-dir/file.txt
    mkdir new-dir/.git
    sleep 0.1

    # Ignores new matching files
    run $dbi is-ignored ./new-dir/file.txt
    assert_success

    # Ignores new matching directories
    run $dbi is-ignored ./new-dir/.git
    assert_success

    # Doesn't ignore non-matching files
    run $dbi is-ignored ./new-dir/
    assert_failure
    run $dbi is-ignored ./new-dir/file.md
    assert_failure
}