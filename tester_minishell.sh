#!/bin/bash
MINISHELL=./minishell

# ANSI colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELL='\033[1;33m'
BRIGHT_YELL='\033[1;93m'
CYAN='\033[1;36m'
NC='\033[0m'

# === Test group: Syntax Errors ===
syntax_tests=(
  "| ls"
  "ls |"
  "ls | | grep txt"
  ">"
  "cat <"
  "ls >"
  "ls > |"
  "ls > > file"
  "ls >>"
  "<<"
  "ls | > file"
  "ls > file |"
  "ls && echo hi"
  "ls || echo hi"
  "echo "\$\$""
  "ls |     "
  "         "
  "ls     >     "
  "echo >"
  "< <"
  'echo "'
)

syntax_expected=(
  "syntax error near unexpected token \`|'"
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`|'"
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`|'"
  "syntax error near unexpected token \`>'"
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`newline'"
  "" # Empty line — expected no output
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`&&'"
  "syntax error near unexpected token \`|'"
  "\$\$"
  "syntax error near unexpected token \`newline'"
  "" # Empty line — expected no output
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`newline'"
  "syntax error near unexpected token \`<'"
  "syntax error: unclosed quotes"
)

# === Test group: Input with and without spaces ===
spaces_tests=(
  "echo bla bla bla | wc"
  "echo nospaces|wc"
  "echo hello|cat -e|wc"
  'echo aaaaaaaaa$HOME'
  'echo aaaaaaaaa $USER'
)

spaces_expected=(
  "      1       3      12"
  "      1       1       9"
  "      1       1       7"
  "aaaaaaaaa/home/tkremnov"
  "aaaaaaaaa tkremnov"
)

# === Test group: Echo ===
echo_tests=(
  "echo hi"
  "echo"
  "echo -n -n hi"
  "echo -nnn -n hi"
  "echo -nnn -n hi -n"
  "echo hi -n"
  "echo echo"
  "echo –nnn"
  "echo -"
)

echo_expected=(
  "hi"
  "" # Empty line — expected no output
  "hi"
  "hi"
  "hi -n"
  "hi -n"
  "echo"
  "–nnn"
  "-"
)

# === Test group: Quotes and Environment VARs ===
quotes_var_tests=(
  "cat 'xd'"
  "cat \"xd\""
  "cat \"\""
  "cat ''"
  "echo \"> hi < hi\""
  "echo '> hi < hi'"
  "echo '\$USER'"
  "echo \"\$USER\""
  "echo \$USER"
  "echo \$USER\$USER"
  "echo \$USER'\$USER'\"\$USER\""
  "echo \"\$U\"SER"
  "echo \$\"USER\""
  "echo \$'USER'"
  "echo \" ' \""
  "echo ' \" '"
  "echo \"''''''''''''\""
  "echo \$U\$S\$E\$R"
  "echo \$?"
  "echo \$? \$?"
  "echo \$?aaaaaa"
  "echo \$asdUSER"
  $'export asd="$"\necho $asd$asd$asd"USER"'
  $'export asd="\'"\necho $asd$USER$asd echo'
  $'export asd=$USER\necho $asd'
  $'export asd=\'$USER\'\necho $asd$USER'
  $'export asd=echo\n"$asd" $USER'
  $'export asd=echo\nexport arg="hello world"\n"$asd" "$arg"'
  $'export asd=n\necho -$asd hi'
  "echo '\"\$HOME\"'"
  "echo \"'\$HOME'\""
  "echo '''''-''n' hi"
  "echo \$?"
  "echo '\$?'"
  "echo \"\$?\""
)

quotes_var_expected=(
  "cat: xd: No such file or directory"
  "cat: xd: No such file or directory"
  "cat: '': No such file or directory"
  "cat: '': No such file or directory"
  "> hi < hi"
  "> hi < hi"
  "\$USER"
  "$USER"
  "$USER"
  "$USER$USER"
  "${USER}\$USER${USER}"
  "SER"
  "USER"
  "USER"
  " ' "
  " \" "
  "''''''''''''"
  ""  # Empty line — expected no output
  "echo \$?"
  "echo \$? \$?"
  "echo \$?aaaaaa"
  ""  # Empty line — expected no output
  '$$$USER'
  "'$USER' echo"
  "$USER"
  '$USER'"$USER"
  "$USER"
  'hello world'
  'hi'
  '"$HOME"'
  "'$HOME'"
  "hi"
  "0"
  "\$?"
  "0"
)

# === Test group: Redirections ===
redir_tests=(
  $'cat <not_exist <bla\necho $?'
  $'<not_exist\necho $?'
  $'echo < Makefile hello < src/exec/exec.c'
  '> $HOME'
  $'> $HOME\necho $?'
  '>> $VAR_NAME'
  $'>> $VAR_NAME\necho $?'
  'ahsgayhgsasaaaaaaaaaaaaaaaaa > $HOME'
  $'ahsgayhgsasaaaaaaaaaaaaaaaaa > $HOME\necho $?'
)

redir_expected=(
  "1"
  "1"
  "hello"
  "$HOME: Is a directory"
  "1"
  "ambiguous redirect"
  "1"
  "$HOME: Is a directory"
  "1"
)

# === Test group: Pipes ===
pipe_tests=(
  $'echo hi | cat | ls'
  $'echo hello hi | echo hello hi | wc'
  $'cate | cate | cate | cate\necho $?'
  $'cate | cate | cate | cate | echo hi\necho $?'
  $'cate | cat asdasdasd\necho $?'
  $'echo hello world | cat'
  $'echo -e "line1\nline2\nline3" | grep line2 | wc -l'
)

pipe_expected=(
  "$(ls)"    # be careful: this uses the current directory listing at test runtime
  "      1       2       9"  # or whatever your wc outputs for "hello hi\n"
  $'cate: command not found\ncate: command not found\ncate: command not found\ncate: command not found\n127'
  $'hi\ncate: command not found\ncate: command not found\ncate: command not found\ncate: command not found\n0'
  $'cate: command not found\ncat: asdasdasd: No such file or directory\n1'
  'hello world'
  '1'
)

# === Test group: Bad Commands ===
bad_command_tests=(
  "lss"
  $'lss\necho $?'
  "./badfile"
  $'./badfile\necho $?'
  "./Makefile"
  $'./Makefile\necho $?'
  "./include/"
  $'./include/\necho $?'
  "''"
  $'\'\'\necho $?'
  '""'
  $'""\necho $?'
  "cat Makefile >\$HOME"
  $'cat Makefile >$HOME\necho $?'
  "cat <\$blablabla"
  $'cat <$blablabla\necho $?'
)

bad_command_expected=(
  "lss: command not found"
  "127"
  "No such file or directory"
  "127"
  "Permission denied"
  "126"
  "/include/: Is a directory"
  "126"
  "command '' not found"
  "127"
  "command '' not found"
  "127"
  "$HOME: Is a directory"
  "1"
  "ambiguous redirect"
  "1"
)

run_tests() {
  local label=$1
  shift
  local -n test_inputs=$1
  shift
  local -n test_expected=$1

  echo -e "${YELL}* * * $label * * *${NC}"

  for i in "${!test_inputs[@]}"; do
    input="${test_inputs[$i]}"
    expected="${test_expected[$i]}"
    echo "$input" | $MINISHELL > out.txt 2>&1
    result="$(cat out.txt)"
    test_num=$((i + 1))

    if grep -qF "$expected" out.txt; then
      echo -e "${GREEN}Test #$test_num: [OK]${NC} \"$input\""
    else
      echo -e "${RED}Test #$test_num: [FAIL]${NC} \"$input\""
      echo -e "  ${CYAN}Expected:${NC} $expected"
      echo -e "  ${BRIGHT_YELL}Got     :${NC} $result"
    fi
  done
  echo
}

# Call function with each group
run_tests "Syntax Error Tests" syntax_tests syntax_expected
run_tests "Spaces Tests" spaces_tests spaces_expected
run_tests "Echo" echo_tests echo_expected
run_tests "Quotes and Environment VARs" quotes_var_tests quotes_var_expected
run_tests "Redirections" redir_tests redir_expected
run_tests "Pipes" pipe_tests pipe_expected
run_tests "Bad Commands" bad_command_tests bad_command_expected

# Clean up
rm -f out.txt