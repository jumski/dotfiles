#!/usr/bin/env fish

# Smoke tests to verify fishtape is working correctly

@test "fishtape is working" (true; echo $status) -eq 0

@test "basic math works" (math "2 + 2") -eq 4

@test "can test file existence" -e ~/.dotfiles

@test "fish shell is available" (which fish) != ""

@test "string comparison works" "hello" = "hello"

@test "negative test works" "foo" != "bar"

@test "test status code success" (true; echo $status) -eq 0

@test "test status code failure" (false; echo $status) -eq 1

@test "multiline string test" (echo -e "line1\nline2" | string collect) = "line1
line2"