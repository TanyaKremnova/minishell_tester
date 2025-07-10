# 🧪 Minishell Tester
A simple shell tester script for checking some **mandatory parts** of your 42 `minishell` project.  
This tester runs various syntax, pipes, quotes, redirection, and bad command cases — so you can catch edge cases fast.

## ⚠️ License
This tester is open for anyone to use, adapt, and share.

## ℹ️ About
It tests a variety of scenarios, such as:

- **Syntax errors:** invalid pipes, redirects, unclosed quotes.
- **Echo edge cases:** `echo`, `echo -n`, multiple `-n` flags.
- **Quotes and environment variables:** `"`, `'`, `$USER`, mixed quoting.
- **Redirections:** invalid files, multiple redirs.
- **Pipes:** multiple pipes in sequence.
- **Bad commands:** non-existing commands, bad files.

### 🗂️ Example Test Cases
   ```bash
# Syntax tests
"| ls"
"ls |"
"ls | | grep txt"
">"
"cat <"
"ls >"

# Echo tests
"echo hi"
"echo"
"echo -n -n hi"
"echo -nnn -n hi"
"echo -nnn -n hi -n"

# Quotes and variable tests
"echo $USER"
"echo '$USER'"
"echo "$USER""
"echo $USER$USER"
   ```

## 🗂️ How It Works
The script pipes each test input into your minishell binary, captures the output, and compares it to the expected result.

## 🔄 How to Use
1. Make sure tester_minishell.sh is in the same folder as your compiled ./minishell binary.

2. Make the tester executable:
   ```bash
   chmod +x tester_minishell.sh
   ```

3. Run the tester:
   ```bash
   ./tester_minishell.sh
   ```

## 👩🏻‍💻 Author
- Tanya Kremnova ([@TanyaKremnova](https://github.com/TanyaKremnova))