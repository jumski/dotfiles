# Testing with Fishtape

TAP-compliant test runner for Fish shell.

## Commands

```fish
script/test         # all tests
script/test wt      # module tests
fishtape-run        # alias for script/test
fishtape-watch      # watch mode
```

## Structure

```
module/
├── functions/
├── tests/          # test directory
│   └── *.test.fish # test files
```

## Writing Tests

```fish
#!/usr/bin/env fish

# Basic syntax
@test "description" [actual] operator expected

# Examples
@test "math" (math "2 + 2") -eq 4
@test "strings" "foo" = "foo"
@test "file exists" -e ~/.dotfiles
@test "is directory" -d ~/.dotfiles
@test "command success" (true; echo $status) -eq 0
@test "command fails" (false; echo $status) -eq 1
@test "in PATH" (which fish) != ""

# Testing functions
source /path/to/function.fish
@test "function output" (my_func "arg") = "expected"

# Multiline
@test "multiline" (echo -e "a\nb" | string collect) = "a
b"
```

## Output

```
TAP version 13
ok 1 test description
not ok 2 failing test
  ---
    operator: =
    expected: foo
    actual: bar
    at: ~/test.fish:10
  ...
1..2
# pass 1
# fail 1
```

## Notes

- Test files excluded from shell startup (filtered in `fish/config.fish`)
- Always source functions before testing
- Each test should be independent
- Test both success and failure cases