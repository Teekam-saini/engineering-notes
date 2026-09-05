# Week 4: Day 22 — Environment Variables

## Overview

Today we learn how the Linux shell stores and passes configuration information to programs.

Environment variables are extremely important because they allow scripts and programs to work without hardcoding machine-specific paths.

This is especially useful in VLSI development, where tools such as:

* Icarus Verilog
* Verilator
* GTKWave
* Yosys
* Vivado
* Questa/ModelSim
* Synopsys tools

may be installed in different locations on different machines.

Instead of hardcoding:

```text
/home/teekam/project/rtl
```

we can use:

```bash
$RTL_DIR
```

This makes our scripts much more portable.

---

# 1. What Are Environment Variables?

Every Linux process has an **environment**.

The environment is basically a collection of:

```text
KEY=VALUE
```

pairs.

For example:

```bash
HOME=/home/teekam
USER=teekam
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
```

Each variable has:

```text
NAME → VALUE
```

For example:

```text
USER → teekam
HOME → /home/teekam
```

We access a variable using `$`:

```bash
echo $USER
```

Output:

```text
teekam
```

The `$` means:

> "Give me the value stored inside this variable."

---

# 2. Why Environment Variables Matter

Suppose we have this command:

```bash
iverilog -o /home/teekam/project/sim.out \
         /home/teekam/project/rtl/counter.v \
         /home/teekam/project/testbench/tb_counter.v
```

This works only if the project exists exactly at:

```text
/home/teekam/project
```

If another person has:

```text
/home/rahul/project
```

the script breaks.

Instead, we can use:

```bash
PROJECT_ROOT="$HOME/project"
```

Then:

```bash
iverilog -o "$PROJECT_ROOT/sim.out" \
         "$PROJECT_ROOT/rtl/counter.v" \
         "$PROJECT_ROOT/testbench/tb_counter.v"
```

Now the script automatically uses the current user's home directory.

This is one of the major reasons environment variables are useful.

---

# 3. Shell Variables vs Environment Variables

This distinction is extremely important.

## Shell Variable

A normal variable belongs to the current shell:

```bash
PROJECT="riscv_cpu"
```

We can use it:

```bash
echo "$PROJECT"
```

Output:

```text
riscv_cpu
```

But a child process normally cannot see it.

Example:

```bash
PROJECT="riscv_cpu"

bash -c 'echo "$PROJECT"'
```

Output:

```text
```

The child shell does not receive the variable.

---

# 4. Exported Environment Variable

Use `export`:

```bash
export PROJECT="riscv_cpu"
```

Now the variable becomes part of the environment inherited by child processes.

```bash
bash -c 'echo "$PROJECT"'
```

Output:

```text
riscv_cpu
```

The important idea is:

```text
Normal shell variable
        |
        v
Current shell only


exported variable
        |
        v
Current shell
        |
        +----> child process
        |
        +----> another child process
```

A child process inherits a copy of the parent's environment.

It does NOT mean that changes made by the child automatically travel back into the parent.

---

# 5. Viewing Environment Variables

## `printenv`

To display environment variables:

```bash
printenv
```

Example:

```text
HOME=/home/teekam
USER=teekam
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
```

---

## View One Variable

```bash
printenv PATH
```

or:

```bash
printenv HOME
```

Example:

```text
/home/teekam
```

---

# 6. Using `echo`

Another common method:

```bash
echo "$PATH"
echo "$HOME"
echo "$USER"
echo "$SHELL"
echo "$PWD"
```

Example:

```text
teekam@linux:~$ echo "$USER"
teekam

teekam@linux:~$ echo "$HOME"
/home/teekam
```

---

# 7. `env` vs `set`

These commands are related but not identical.

## `env`

```bash
env
```

Normally displays the environment variables exported to processes.

For example:

```text
HOME=/home/teekam
USER=teekam
PATH=/usr/bin:/bin
SHELL=/bin/bash
```

---

## `set`

```bash
set
```

Shows shell variables, functions, and other shell state.

It can therefore produce a much larger amount of output.

For example:

```bash
set | head -30
```

shows the first 30 lines.

### Important correction

The statement:

```text
env = everything
```

is not correct.

`env` primarily shows the environment passed to processes.

`set` shows a broader collection of shell state.

---

# 8. Important Built-in Variables

Linux shells provide many useful variables.

## `$HOME`

Your home directory:

```bash
echo "$HOME"
```

Example:

```text
/home/teekam
```

---

## `$USER`

Current username:

```bash
echo "$USER"
```

Example:

```text
teekam
```

---

## `$SHELL`

Your login/default shell:

```bash
echo "$SHELL"
```

Example:

```text
/bin/bash
```

Note:

`$SHELL` usually indicates the user's configured login shell. It is not always guaranteed to tell you which shell is currently executing a particular script.

To identify the current Bash process more directly, you can use:

```bash
ps -p $$ -o comm=
```

---

## `$PWD`

Current working directory:

```bash
echo "$PWD"
```

Example:

```text
/home/teekam/linux_training/day22
```

After:

```bash
cd /tmp
```

then:

```bash
echo "$PWD"
```

becomes:

```text
/tmp
```

---

## `$OLDPWD`

Stores the previous working directory.

Example:

```bash
cd /tmp
cd /home/teekam
```

Now:

```bash
echo "$OLDPWD"
```

will normally show:

```text
/tmp
```

This is also related to:

```bash
cd -
```

which switches to the previous directory.

---

## `$HOSTNAME`

Machine hostname:

```bash
echo "$HOSTNAME"
```

Example:

```text
wednesday
```

---

## `$TERM`

Describes the terminal type:

```bash
echo "$TERM"
```

Example:

```text
xterm-256color
```

Programs use this information to determine terminal capabilities.

---

## `$EDITOR`

Preferred text editor.

It may or may not already be configured:

```bash
echo "$EDITOR"
```

You can set it:

```bash
export EDITOR=nano
```

Now:

```bash
echo "$EDITOR"
```

prints:

```text
nano
```

---

## `$LANG`

Controls locale/language-related behavior:

```bash
echo "$LANG"
```

Example:

```text
en_IN.UTF-8
```

The exact value depends on your system.

---

## `$PS1`

Controls the primary shell prompt.

Example:

```bash
echo "$PS1"
```

A Bash prompt might contain things such as:

```text
\u
```

for username and:

```text
\h
```

for hostname.

---

# 9. Creating Variables

A shell variable is created using:

```bash
NAME=value
```

Do NOT put spaces around `=`.

Correct:

```bash
project="riscv_cpu"
```

Incorrect:

```bash
project = "riscv_cpu"
```

The second version is interpreted as a command named `project`.

Humans see assignment. Bash sees syntax and judges us accordingly.

---

# 10. Using Variables

```bash
project="riscv_cpu"
width=32
```

Use them:

```bash
echo "$project"
echo "$width"
```

Output:

```text
riscv_cpu
32
```

You can also combine them with text:

```bash
echo "Project: $project"
echo "Width: $width bits"
```

Output:

```text
Project: riscv_cpu
Width: 32 bits
```

---

# 11. Why Quotes Are Important

Prefer:

```bash
echo "$HOME"
```

instead of:

```bash
echo $HOME
```

Especially when using paths.

Suppose:

```bash
PROJECT_ROOT="/home/teekam/My Projects/riscv"
```

Without quotes:

```bash
cd $PROJECT_ROOT
```

can cause problems because the path contains a space.

Use:

```bash
cd "$PROJECT_ROOT"
```

Similarly:

```bash
iverilog -o "$SIM_DIR/sim.out" "$RTL_DIR/counter.v"
```

Quoting variables is a very good shell scripting habit.

---

# 12. Export

To turn a shell variable into an environment variable:

```bash
export PROJECT="riscv_cpu"
```

Now child processes can access it.

Test:

```bash
export MY_VAR="hello"

bash -c 'echo "$MY_VAR"'
```

Output:

```text
hello
```

Without export:

```bash
MY_VAR="hello"

bash -c 'echo "$MY_VAR"'
```

Output:

```text
```

---

# 13. The `PATH` Variable

`PATH` is one of the most important environment variables.

It tells the shell where to search for executable commands.

View it:

```bash
echo "$PATH"
```

Example:

```text
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Each directory is separated by:

```text
:
```

So:

```text
/usr/local/bin:/usr/bin:/bin
```

means:

```text
1. /usr/local/bin
2. /usr/bin
3. /bin
```

The shell searches these directories when looking for commands.

---

# 14. Example: Running `iverilog`

When you type:

```bash
iverilog
```

the shell searches directories listed in `$PATH`.

If `iverilog` exists in:

```text
/usr/bin/iverilog
```

and `/usr/bin` is in `$PATH`, the command works.

If it isn't found in any PATH directory:

```text
iverilog: command not found
```

This is why PATH problems are so common.

---

# 15. Find Where a Command Comes From

Use:

```bash
which iverilog
```

Example:

```text
/usr/bin/iverilog
```

A more Bash-native command is:

```bash
command -v iverilog
```

This is generally preferable in scripts because it is a shell builtin.

---

# 16. Adding a Directory to PATH

For the current shell session:

```bash
export PATH="$PATH:/new/directory"
```

Example:

```bash
export PATH="$PATH:$HOME/linux_training/day14_project/scripts"
```

Now commands/scripts inside that directory can potentially be executed from anywhere.

For example:

```bash
compile.sh
```

instead of:

```bash
/home/teekam/linux_training/day14_project/scripts/compile.sh
```

---

# 17. PATH Changes Are Temporary

If you run:

```bash
export PATH="$PATH:/my/scripts"
```

the change normally applies only to the current shell and processes launched from it.

Close the terminal and open a new one:

```bash
echo "$PATH"
```

The change will usually be gone unless it was placed in a startup configuration file.

---

# 18. Making PATH Permanent

For Bash, add the PATH modification to:

```text
~/.bashrc
```

Example:

```bash
echo 'export PATH="$PATH:$HOME/linux_training/day14_project/scripts"' >> ~/.bashrc
```

Then reload:

```bash
source ~/.bashrc
```

Check:

```bash
echo "$PATH"
```

The directory should now be present.

---

# 19. Important PATH Warning

Do not blindly do this:

```bash
export PATH="/new/directory"
```

That replaces your entire PATH.

You could accidentally lose:

```text
/usr/bin
/bin
/usr/sbin
```

and many commands may stop working.

Usually you want:

```bash
export PATH="$PATH:/new/directory"
```

or:

```bash
export PATH="/new/directory:$PATH"
```

The position matters.

---

# 20. PATH Order Matters

Suppose:

```text
PATH=/home/teekam/bin:/usr/bin
```

and both directories contain a program called:

```text
hello
```

The shell finds:

```text
/home/teekam/bin/hello
```

first.

Therefore:

```text
Earlier PATH entry
        ↓
searched first
```

This means PATH order can determine which version of a program runs.

---

# 21. `export`, `unset`, and `readonly`

## Export

```bash
export TOOL_VERSION="2.0"
```

Check:

```bash
echo "$TOOL_VERSION"
```

Output:

```text
2.0
```

---

## Unset

Remove the variable:

```bash
unset TOOL_VERSION
```

Now:

```bash
echo "$TOOL_VERSION"
```

prints nothing.

Check more clearly:

```bash
printenv TOOL_VERSION
```

If it is not present, nothing is printed.

---

## Read-only Variable

```bash
readonly MAX_WIDTH=64
```

Trying:

```bash
MAX_WIDTH=32
```

produces an error such as:

```text
bash: MAX_WIDTH: readonly variable
```

A readonly variable cannot be changed or unset during that shell's lifetime.

---

# 22. See Exported Variables

Use:

```bash
export -p
```

This displays exported variables.

---

# 23. Variable Scope

Think of shell processes like this:

```text
Parent Shell
     |
     | exported variables
     v
Child Process
     |
     +----> Child Process
```

Example:

```bash
export PROJECT="riscv_cpu"
bash
```

The new Bash process inherits:

```text
PROJECT=riscv_cpu
```

But if the child changes its variable:

```bash
PROJECT="another_project"
```

the parent does NOT change.

This is because the child receives its own copy.

---

# 24. `source` vs Executing a Script

This is one of the most important concepts today.

Suppose:

```bash
setup.sh
```

contains:

```bash
export PROJECT_ROOT="/home/teekam/project"
```

If you execute:

```bash
./setup.sh
```

the script runs in a child process.

After it finishes, the exported variable disappears with that child process.

So:

```bash
./setup.sh
echo "$PROJECT_ROOT"
```

will normally produce:

```text
```

---

# 25. Using `source`

Instead:

```bash
source setup.sh
```

or:

```bash
. setup.sh
```

The script executes in the current shell.

Therefore:

```bash
source setup.sh
echo "$PROJECT_ROOT"
```

will still have:

```text
PROJECT_ROOT=/home/teekam/project
```

### Remember

```text
./script.sh
     ↓
new/child shell
     ↓
variables disappear after script exits


source script.sh
     ↓
current shell
     ↓
variables remain
```

This is why environment setup files are normally sourced.

---

# 26. Default Variable Values

Bash provides useful parameter expansion syntax.

## `${VAR:-default}`

Use the default if `VAR` is unset or empty.

```bash
echo "${PROJECT:-default_project}"
```

If:

```bash
PROJECT=""
```

the result is:

```text
default_project
```

If:

```bash
PROJECT="riscv_cpu"
```

the result is:

```text
riscv_cpu
```

Important:

```text
:- 
```

means unset OR empty.

---

# 27. `${VAR:=default}`

This does two things:

1. Uses the default if the variable is unset or empty.
2. Assigns that default to the variable.

Example:

```bash
echo "${PROJECT:=default_project}"
```

Afterward:

```bash
echo "$PROJECT"
```

prints:

```text
default_project
```

---

# 28. `${VAR:?message}`

Useful when a variable is required.

```bash
echo "${PROJECT:?"PROJECT must be set!"}"
```

If `PROJECT` is missing or empty, Bash reports an error.

This is useful for scripts that should not continue without required configuration.

Example:

```bash
PROJECT="${PROJECT:?"PROJECT must be set!"}"
```

---

# 29. `${VAR:+alternate}`

Uses the alternate value when `VAR` is set and non-empty.

Example:

```bash
PROJECT="riscv_cpu"

echo "${PROJECT:+"project is set to $PROJECT"}"
```

Output:

```text
project is set to riscv_cpu
```

If `PROJECT` is empty or unset, the expansion produces nothing.

---

# 30. Quick Parameter Expansion Table

| Syntax              | Meaning                            |
| ------------------- | ---------------------------------- |
| `${VAR:-default}`   | Use default if unset or empty      |
| `${VAR:=default}`   | Use default and assign it          |
| `${VAR:?message}`   | Error if unset or empty            |
| `${VAR:+alternate}` | Use alternate if set and non-empty |

These forms are extremely useful in production shell scripts.

---

# 31. Practice Setup

Create the Day 22 directory:

```bash
cd ~/linux_training
mkdir -p day22
cd day22
```

Create:

```bash
show_env.sh
```

using:

```bash
cat > show_env.sh << 'EOF'
#!/bin/bash

echo "=== Environment Information ==="

echo "User: $USER"
echo "Home: $HOME"
echo "Shell: $SHELL"
echo "Current Dir: $PWD"
echo "Hostname: $HOSTNAME"

echo ""

echo "=== PATH Directories ==="

echo "$PATH" | tr ':' '\n'

echo ""

echo "=== Custom Variables ==="

echo "Project: ${PROJECT:-not set}"
echo "VLSI Home: ${VLSI_HOME:-not set}"
EOF
```

Make it executable:

```bash
chmod +x show_env.sh
```

Run:

```bash
./show_env.sh
```

---

# 32. Environment Variables in VLSI Scripts

## Bad Approach: Hardcoded Paths

```bash
#!/bin/bash

iverilog -o /home/teekam/projects/sim.out \
         /home/teekam/projects/rtl/counter.v \
         /home/teekam/projects/testbench/tb_counter.v
```

Problems:

* Depends on one username.
* Depends on one directory structure.
* Difficult to move to another machine.
* Difficult to reuse.
* Difficult for teammates to use.

---

# 33. Better Approach: Environment Variables

```bash
#!/bin/bash

export PROJECT_ROOT="$HOME/linux_training/day14_project"
export RTL_DIR="$PROJECT_ROOT/rtl"
export TB_DIR="$PROJECT_ROOT/testbench"
export SIM_DIR="$PROJECT_ROOT/sim_output"

iverilog -o "$SIM_DIR/sim.out" \
         "$RTL_DIR/counter.v" \
         "$TB_DIR/tb_counter.v"
```

Now:

```text
PROJECT_ROOT
      |
      +---- rtl
      |
      +---- testbench
      |
      +---- sim_output
```

The script doesn't need to know the user's username.

---

# 34. Better Still: Separate Environment Setup

Instead of putting all configuration inside every script, create:

```text
project_env.sh
```

Example:

```bash
#!/bin/bash

export PROJECT_NAME="riscv_cpu"

export PROJECT_ROOT="$HOME/linux_training/day14_project"
export RTL_DIR="$PROJECT_ROOT/rtl"
export TB_DIR="$PROJECT_ROOT/testbench"
export SIM_DIR="$PROJECT_ROOT/sim_output"
export SCRIPTS_DIR="$PROJECT_ROOT/scripts"

export PATH="$PATH:$SCRIPTS_DIR"

echo "Environment set for: $PROJECT_NAME"
echo "Project root: $PROJECT_ROOT"
```

Then:

```bash
source project_env.sh
```

Now all of these variables are available:

```bash
echo "$PROJECT_NAME"
echo "$PROJECT_ROOT"
echo "$RTL_DIR"
echo "$TB_DIR"
echo "$SIM_DIR"
echo "$SCRIPTS_DIR"
```

---

# 35. Assignment 1 — Environment Explorer

## Requirement

Create:

```text
explore_env.sh
```

It must:

1. Print all environment variables sorted alphabetically.
2. Count environment variables.
3. Print PATH directories one per line.
4. Show which PATH directories exist.
5. Show which PATH directories do not exist.

---

## Solution

```bash
#!/bin/bash

echo "========================================"
echo "        ENVIRONMENT EXPLORER"
echo "========================================"

echo ""
echo "=== Environment Variables ==="

printenv | sort

echo ""
echo "=== Total Environment Variables ==="

count=$(printenv | wc -l)
echo "Total: $count"

echo ""
echo "=== PATH Directories ==="

echo "$PATH" | tr ':' '\n'

echo ""
echo "=== PATH Directory Status ==="

while IFS= read -r dir
do
    if [ -d "$dir" ]; then
        echo "[EXISTS]     $dir"
    else
        echo "[NOT FOUND]  $dir"
    fi
done < <(echo "$PATH" | tr ':' '\n')
```

Make executable:

```bash
chmod +x explore_env.sh
```

Run:

```bash
./explore_env.sh
```

---

## Explanation

### `printenv | sort`

```bash
printenv | sort
```

means:

```text
printenv
   ↓
produce environment variables
   ↓
sort
   ↓
alphabetical order
```

---

### Count Variables

```bash
count=$(printenv | wc -l)
```

`wc -l` counts lines.

Since `printenv` normally prints one variable per line:

```text
variable 1
variable 2
variable 3
...
```

the number of lines gives us the number of environment entries.

---

### Split PATH

```bash
echo "$PATH" | tr ':' '\n'
```

Converts:

```text
/usr/bin:/bin:/usr/local/bin
```

into:

```text
/usr/bin
/bin
/usr/local/bin
```

---

### Check Directory

```bash
[ -d "$dir" ]
```

means:

> Does this path exist and is it a directory?

---

### Process PATH Directories

```bash
while IFS= read -r dir
do
    ...
done
```

reads one PATH directory at a time.

---

# 36. Assignment 2 — Project Environment Setup

## Requirement

Create:

```text
setup_vlsi_env.sh
```

It must:

* Set `PROJECT_ROOT`
* Set `RTL_DIR`
* Set `TB_DIR`
* Set `SIM_DIR`
* Set `SCRIPTS_DIR`
* Add `SCRIPTS_DIR` to PATH
* Set `EDITOR=nano`
* Set `PROJECT_NAME` using a default
* Print confirmation
* Be sourced

---

## Solution

```bash
#!/bin/bash

export PROJECT_NAME="${PROJECT_NAME:-riscv_cpu}"

export PROJECT_ROOT="$HOME/linux_training/day14_project"
export RTL_DIR="$PROJECT_ROOT/rtl"
export TB_DIR="$PROJECT_ROOT/testbench"
export SIM_DIR="$PROJECT_ROOT/sim_output"
export SCRIPTS_DIR="$PROJECT_ROOT/scripts"

export PATH="$PATH:$SCRIPTS_DIR"

export EDITOR="nano"

echo "========================================"
echo "       VLSI ENVIRONMENT SETUP"
echo "========================================"

echo "PROJECT_NAME = $PROJECT_NAME"
echo "PROJECT_ROOT = $PROJECT_ROOT"
echo "RTL_DIR      = $RTL_DIR"
echo "TB_DIR       = $TB_DIR"
echo "SIM_DIR      = $SIM_DIR"
echo "SCRIPTS_DIR  = $SCRIPTS_DIR"
echo "EDITOR       = $EDITOR"

echo ""
echo "VLSI environment loaded successfully."
```

Run:

```bash
source setup_vlsi_env.sh
```

Then verify:

```bash
echo "$PROJECT_NAME"
echo "$PROJECT_ROOT"
echo "$RTL_DIR"
echo "$TB_DIR"
echo "$SIM_DIR"
echo "$SCRIPTS_DIR"
echo "$EDITOR"
```

---

## Why `${PROJECT_NAME:-riscv_cpu}`?

Suppose:

```bash
PROJECT_NAME="my_cpu"
source setup_vlsi_env.sh
```

Because `PROJECT_NAME` is already set:

```bash
PROJECT_NAME="${PROJECT_NAME:-riscv_cpu}"
```

keeps:

```text
my_cpu
```

But if:

```bash
unset PROJECT_NAME
```

then:

```bash
source setup_vlsi_env.sh
```

sets:

```text
PROJECT_NAME=riscv_cpu
```

This makes the setup script configurable.

---

# 37. Important: Why Must It Be Sourced?

Do:

```bash
source setup_vlsi_env.sh
```

not:

```bash
./setup_vlsi_env.sh
```

Because we want the variables to remain in our current shell.

After:

```bash
source setup_vlsi_env.sh
```

this works:

```bash
echo "$RTL_DIR"
```

After:

```bash
./setup_vlsi_env.sh
```

the variables set inside the child process disappear when the script exits.

---

# 38. Assignment 3 — PATH Manager

## Requirement

Create:

```text
add_to_path.sh
```

It should:

1. Accept a directory as `$1`.
2. Check whether the directory exists.
3. Check whether it is already in PATH.
4. Add it if necessary.
5. Print a confirmation.
6. Error if the directory doesn't exist.

---

## Solution

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: source add_to_path.sh <directory>"
    return 1 2>/dev/null || exit 1
fi

dir="$1"

if [ ! -d "$dir" ]; then
    echo "Error: directory does not exist:"
    echo "$dir"
    return 1 2>/dev/null || exit 1
fi

case ":$PATH:" in
    *:"$dir":*)
        echo "Already in PATH:"
        echo "$dir"
        return 0 2>/dev/null || exit 0
        ;;
esac

export PATH="$PATH:$dir"

echo "Added to PATH:"
echo "$dir"
```

---

# 39. Why This Assignment Has an Important Problem

There is a subtle shell concept here.

If you execute:

```bash
./add_to_path.sh "$HOME/bin"
```

the script runs in a child process.

It can modify its own PATH, but when it exits, the parent shell's PATH is unchanged.

Therefore, to actually modify your current shell's PATH, use:

```bash
source add_to_path.sh "$HOME/bin"
```

This is why the usage message says:

```bash
source add_to_path.sh <directory>
```

The original assignment says to create a PATH manager but does not explicitly mention this parent/child process issue. It matters.

---

# 40. Test Assignment 3

First check:

```bash
echo "$PATH"
```

Then:

```bash
source add_to_path.sh "$HOME/bin"
```

If the directory exists and isn't already in PATH:

```text
Added to PATH:
/home/teekam/bin
```

Check:

```bash
echo "$PATH"
```

Run again:

```bash
source add_to_path.sh "$HOME/bin"
```

Now:

```text
Already in PATH:
/home/teekam/bin
```

---

# 41. Why `case ":$PATH:"`?

A naive check might be:

```bash
echo "$PATH" | grep "$dir"
```

But this can produce false matches.

For example:

```text
/home/teekam/bin
```

might accidentally match:

```text
/home/teekam/bin_backup
```

We want to check complete PATH entries.

Therefore:

```bash
case ":$PATH:" in
    *:"$dir":*)
```

adds separators around the entire PATH:

```text
:/usr/bin:/bin:/home/teekam/bin:
```

Now the directory must match as a complete entry.

---

# 42. If You Specifically Want `grep`

The assignment specifically mentions using:

```bash
echo "$PATH" | grep
```

A simple version is:

```bash
if echo "$PATH" | grep -q "$dir"; then
    echo "Already in PATH"
else
    export PATH="$PATH:$dir"
    echo "Added to PATH"
fi
```

But this is less robust because `grep` can match substrings.

A better version using `grep` is:

```bash
if echo ":$PATH:" | grep -qF ":$dir:"; then
    echo "Already in PATH"
else
    export PATH="$PATH:$dir"
    echo "Added to PATH"
fi
```

Here:

```text
-q
```

means quiet.

And:

```text
-F
```

means fixed-string matching rather than regular-expression matching.

---

# 43. Assignment 4 — Environment-Aware Compile Script

## Requirement

Modify the Day 14 `compile.sh`.

It should:

* Use `$RTL_DIR` if available.
* Use `$TB_DIR` if available.
* Use `$SIM_DIR` if available.
* Otherwise use:

  * `./rtl`
  * `./testbench`
  * `./sim_output`
* Print which mode is being used.

---

# 44. Solution

```bash
#!/bin/bash

if [ -n "${RTL_DIR:-}" ] && \
   [ -n "${TB_DIR:-}" ] && \
   [ -n "${SIM_DIR:-}" ]; then

    echo "========================================"
    echo "Environment-variable mode"
    echo "========================================"

    RTL="$RTL_DIR"
    TB="$TB_DIR"
    SIM="$SIM_DIR"

else

    echo "========================================"
    echo "Relative-path mode"
    echo "========================================"

    RTL="./rtl"
    TB="./testbench"
    SIM="./sim_output"
fi

echo "RTL directory : $RTL"
echo "TB directory  : $TB"
echo "SIM directory : $SIM"

mkdir -p "$SIM"

echo ""
echo "Compiling..."

iverilog -o "$SIM/sim.out" \
         "$RTL/counter.v" \
         "$TB/tb_counter.v"

if [ $? -eq 0 ]; then
    echo ""
    echo "Compilation successful."
    echo "Output: $SIM/sim.out"
else
    echo ""
    echo "Compilation failed."
    exit 1
fi
```

Make executable:

```bash
chmod +x compile.sh
```

---

# 45. Better Version Using Default Expansion

We can simplify the same script.

```bash
#!/bin/bash

if [ -n "${RTL_DIR:-}" ] && \
   [ -n "${TB_DIR:-}" ] && \
   [ -n "${SIM_DIR:-}" ]; then

    echo "Mode: Environment variables"

else

    echo "Mode: Relative paths"

fi

RTL="${RTL_DIR:-./rtl}"
TB="${TB_DIR:-./testbench}"
SIM="${SIM_DIR:-./sim_output}"

mkdir -p "$SIM"

echo "RTL = $RTL"
echo "TB  = $TB"
echo "SIM = $SIM"

iverilog -o "$SIM/sim.out" \
         "$RTL/counter.v" \
         "$TB/tb_counter.v"

if [ $? -eq 0 ]; then
    echo "Compilation successful."
else
    echo "Compilation failed."
    exit 1
fi
```

This is cleaner because:

```bash
RTL="${RTL_DIR:-./rtl}"
```

means:

```text
If RTL_DIR exists and isn't empty
        ↓
use RTL_DIR

otherwise
        ↓
use ./rtl
```

---

# 46. An Even Better Compile Script

Instead of checking `$?` separately, we can use `if` directly:

```bash
#!/bin/bash

RTL="${RTL_DIR:-./rtl}"
TB="${TB_DIR:-./testbench}"
SIM="${SIM_DIR:-./sim_output}"

if [ -n "${RTL_DIR:-}" ] && \
   [ -n "${TB_DIR:-}" ] && \
   [ -n "${SIM_DIR:-}" ]; then

    echo "Mode: Environment variables"

else

    echo "Mode: Relative paths"

fi

echo "RTL directory : $RTL"
echo "TB directory  : $TB"
echo "SIM directory : $SIM"

mkdir -p "$SIM"

echo ""
echo "Compiling..."

if iverilog -o "$SIM/sim.out" \
            "$RTL/counter.v" \
            "$TB/tb_counter.v"; then

    echo ""
    echo "Compilation successful."
    echo "Simulation executable: $SIM/sim.out"

else

    echo ""
    echo "Compilation failed."
    exit 1

fi
```

This is the version I recommend using.

---

# 47. Complete Day 22 Directory

After completing the assignments:

```text
day22/
├── explore_env.sh
├── setup_vlsi_env.sh
├── add_to_path.sh
└── compile.sh
```

You may also have:

```text
show_env.sh
project_env.sh
```

from the practice sections.

---

# 48. Complete Testing Procedure

## Step 1: Enter Day 22

```bash
cd ~/linux_training/day22
```

---

## Step 2: Make Scripts Executable

```bash
chmod +x explore_env.sh
chmod +x setup_vlsi_env.sh
chmod +x add_to_path.sh
chmod +x compile.sh
```

---

## Step 3: Run Environment Explorer

```bash
./explore_env.sh
```

Check that it:

* prints environment variables
* sorts them
* counts them
* prints PATH entries
* checks PATH directories

---

## Step 4: Load VLSI Environment

```bash
source setup_vlsi_env.sh
```

Then:

```bash
echo "$PROJECT_NAME"
echo "$PROJECT_ROOT"
echo "$RTL_DIR"
echo "$TB_DIR"
echo "$SIM_DIR"
echo "$SCRIPTS_DIR"
echo "$EDITOR"
```

---

## Step 5: Verify PATH

```bash
echo "$PATH"
```

Check that:

```text
$SCRIPTS_DIR
```

is present.

You can also use:

```bash
echo "$PATH" | tr ':' '\n'
```

---

## Step 6: Test PATH Manager

```bash
source add_to_path.sh "$HOME/bin"
```

If `$HOME/bin` doesn't exist, create it:

```bash
mkdir -p "$HOME/bin"
```

Then:

```bash
source add_to_path.sh "$HOME/bin"
```

Run it again:

```bash
source add_to_path.sh "$HOME/bin"
```

The second time it should say:

```text
Already in PATH
```

---

## Step 7: Test Compile Script With Environment Variables

After loading:

```bash
source setup_vlsi_env.sh
```

run:

```bash
./compile.sh
```

It should report:

```text
Mode: Environment variables
```

---

## Step 8: Test Relative-Path Mode

Remove the variables:

```bash
unset RTL_DIR
unset TB_DIR
unset SIM_DIR
```

Then run:

```bash
./compile.sh
```

It should report:

```text
Mode: Relative paths
```

and use:

```text
./rtl
./testbench
./sim_output
```

---

# 49. Environment Variable Debugging

When a script behaves strangely, check its environment.

Use:

```bash
printenv
```

Check a specific variable:

```bash
printenv PROJECT_ROOT
```

Check PATH:

```bash
echo "$PATH"
```

Check a command:

```bash
command -v iverilog
```

Check whether a variable exists:

```bash
if [ -n "${PROJECT_ROOT:-}" ]; then
    echo "PROJECT_ROOT is set"
else
    echo "PROJECT_ROOT is not set"
fi
```

---

# 50. Common Mistakes

## Mistake 1: Spaces Around `=`

Wrong:

```bash
PROJECT = "riscv"
```

Correct:

```bash
PROJECT="riscv"
```

---

## Mistake 2: Forgetting `$`

Wrong:

```bash
echo PROJECT
```

Output:

```text
PROJECT
```

Correct:

```bash
echo "$PROJECT"
```

---

## Mistake 3: Forgetting `export`

This:

```bash
PROJECT="riscv"
bash -c 'echo "$PROJECT"'
```

does not normally work.

Use:

```bash
export PROJECT="riscv"
```

---

## Mistake 4: Replacing PATH

Dangerous:

```bash
export PATH="/home/teekam/bin"
```

Better:

```bash
export PATH="$PATH:/home/teekam/bin"
```

---

## Mistake 5: Running Environment Setup Instead of Sourcing

Wrong:

```bash
./setup_vlsi_env.sh
```

Correct:

```bash
source setup_vlsi_env.sh
```

when you want variables to remain in the current shell.

---

## Mistake 6: Not Quoting Paths

Risky:

```bash
cd $PROJECT_ROOT
```

Better:

```bash
cd "$PROJECT_ROOT"
```

Especially if the path might contain spaces.

---

# 51. Important Mental Model

Think about Linux like this:

```text
                    Linux System
                         |
                         v
                    Parent Shell
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
       Command        Script         Program
          |              |              |
          +--------------+--------------+
                         |
                         v
                 Environment Variables
```

Exported variables travel downward:

```text
Parent
  |
  | export
  v
Child
  |
  v
Grandchild
```

But information does not automatically travel upward:

```text
Child
  |
  X
  |
Parent
```

A child process cannot normally modify the environment of its parent.

This is the reason:

```bash
source setup.sh
```

is different from:

```bash
./setup.sh
```

---

# 52. Environment Variables in VLSI

Environment variables become particularly useful as projects grow.

For example:

```bash
export PROJECT_ROOT="$HOME/riscv_cpu"

export RTL_DIR="$PROJECT_ROOT/rtl"
export TB_DIR="$PROJECT_ROOT/testbench"
export SIM_DIR="$PROJECT_ROOT/sim"
export SYNTH_DIR="$PROJECT_ROOT/synth"
export SCRIPTS_DIR="$PROJECT_ROOT/scripts"
```

Then different tools can use those locations.

Simulation:

```bash
iverilog -o "$SIM_DIR/sim.out" \
         "$RTL_DIR/counter.v" \
         "$TB_DIR/tb_counter.v"
```

Synthesis:

```bash
yosys -s "$SCRIPTS_DIR/synth.ys"
```

Waveform:

```bash
gtkwave "$SIM_DIR/wave.vcd"
```

Now the project has a central configuration.

---

# 53. Why This Matters for Real VLSI Work

Imagine a large project:

```text
riscv_cpu/
├── rtl/
├── testbench/
├── sim/
├── synth/
├── constraints/
├── scripts/
├── reports/
└── build/
```

Instead of writing:

```bash
/home/teekam/riscv_cpu/rtl
/home/teekam/riscv_cpu/testbench
/home/teekam/riscv_cpu/sim
/home/teekam/riscv_cpu/synth
```

everywhere, define:

```bash
PROJECT_ROOT="$HOME/riscv_cpu"
```

and build everything from that:

```bash
RTL_DIR="$PROJECT_ROOT/rtl"
TB_DIR="$PROJECT_ROOT/testbench"
SIM_DIR="$PROJECT_ROOT/sim"
SYNTH_DIR="$PROJECT_ROOT/synth"
```

This is the beginning of proper build/environment management.

---

# 54. Final Command Cheat Sheet

```bash
# View all environment variables
printenv

# View one variable
printenv PATH

# Print variable
echo "$PATH"

# Create shell variable
PROJECT="riscv_cpu"

# Create environment variable
export PROJECT="riscv_cpu"

# Remove variable
unset PROJECT

# Show exported variables
export -p

# Show shell variables/functions
set

# Show environment
env

# Add directory to PATH
export PATH="$PATH:/some/directory"

# Split PATH into lines
echo "$PATH" | tr ':' '\n'

# Find executable
command -v iverilog

# Source a script
source setup.sh

# Alternative source syntax
. setup.sh

# Default value
echo "${PROJECT:-default_project}"

# Default and assign
echo "${PROJECT:=default_project}"

# Error if missing
echo "${PROJECT:?PROJECT must be set}"

# Alternate if set
echo "${PROJECT:+PROJECT is set}"
```

---

# 55. Day 22 Key Concepts

The most important things to remember are:

### 1. Variable

```bash
PROJECT="riscv_cpu"
```

A normal shell variable.

### 2. Environment Variable

```bash
export PROJECT="riscv_cpu"
```

Available to child processes.

### 3. PATH

```bash
echo "$PATH"
```

Tells the shell where to search for executable commands.

### 4. Add to PATH

```bash
export PATH="$PATH:/directory"
```

Adds a directory for the current shell.

### 5. Permanent PATH

Put the export command in:

```text
~/.bashrc
```

and reload:

```bash
source ~/.bashrc
```

### 6. Source

```bash
source setup.sh
```

Runs the script in the current shell.

### 7. Execute

```bash
./setup.sh
```

Runs the script as a separate process.

### 8. Default Value

```bash
${VAR:-default}
```

Use a default if the variable is unset or empty.

### 9. Quote Variables

Prefer:

```bash
"$VAR"
```

especially for paths.

### 10. Child Processes

Exported environment variables move:

```text
parent → child
```

but changes made by the child do not normally move:

```text
child → parent
```

---

# 56. Final Assignment Checklist

## Assignment 1 — Environment Explorer

* [x] Print environment variables
* [x] Sort alphabetically
* [x] Count variables
* [x] Split PATH
* [x] Check existing PATH directories
* [x] Check missing PATH directories

## Assignment 2 — VLSI Environment

* [x] `PROJECT_ROOT`
* [x] `RTL_DIR`
* [x] `TB_DIR`
* [x] `SIM_DIR`
* [x] `SCRIPTS_DIR`
* [x] Add scripts to PATH
* [x] Set `EDITOR=nano`
* [x] Default `PROJECT_NAME`
* [x] Print confirmation
* [x] Source instead of execute

## Assignment 3 — PATH Manager

* [x] Accept `$1`
* [x] Check directory
* [x] Check PATH
* [x] Add directory
* [x] Avoid duplicates
* [x] Report errors
* [x] Source to modify the current shell

## Assignment 4 — Environment-Aware Compile

* [x] Use `$RTL_DIR`
* [x] Use `$TB_DIR`
* [x] Use `$SIM_DIR`
* [x] Relative-path fallback
* [x] Print current mode
* [x] Compile with Icarus Verilog
* [x] Report success/failure

---

# Day 22 Summary

Environment variables are configuration values associated with a process.

The most important variable is:

```bash
PATH
```

because it determines where the shell searches for executable commands.

The most important command for creating an environment variable is:

```bash
export
```

The most important command for loading environment configuration into the current shell is:

```bash
source
```

And the most useful Bash parameter expansion for portable scripts is:

```bash
${VAR:-default}
```

The overall pattern to remember is:

```text
Variable
   ↓
export
   ↓
Environment
   ↓
Child processes inherit it
```

For VLSI projects:

```text
PROJECT_ROOT
      |
      +---- RTL_DIR
      |
      +---- TB_DIR
      |
      +---- SIM_DIR
      |
      +---- SYNTH_DIR
      |
      +---- SCRIPTS_DIR
```

This lets your scripts use project configuration without hardcoding your username, home directory, or machine-specific paths.

That is the real purpose of environment variables: **separating configuration from the actual script logic.**

---

# End of Day 22

Next:

**Day 23 — Shell Configuration: `.bashrc`, aliases, and functions**
