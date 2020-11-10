#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "Demo test" {
    assert_equal $(echo 1+1 | bc) 2
}