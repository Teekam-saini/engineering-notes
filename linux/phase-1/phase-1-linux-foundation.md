### Path Manipulation

## Absolute Path
- Starts from the root (`/`)
- Independent of the current directory.
- Example:
  ```bash
  /home/user/project/file.v
  ```

## Relative Path
- Starts from the current directory.
- Example:
  ```bash
  ../tb/tb.v
  ```

### Why Relative Paths?
- Portable across different systems.
- Preferred in scripts and Git repositories.
- Makes projects easier to share.

---

# Special Path Symbols

| Symbol | Meaning |
|--------|---------|
| `.` | Current directory |
| `..` | Parent directory |
| `~` | Home directory |
| `-` | Previous directory (`cd` only) |

---

# Navigation Commands

| Command | Description |
|---------|-------------|
| `pwd` | Print current working directory |
| `cd ..` | Move to parent directory |
| `cd ~` | Go to home directory |
| `cd -` | Return to previous directory |
| `cd ../../project` | Navigate using a relative path |

---

# Wildcards (Globbing)

| Wildcard | Meaning |
|----------|---------|
| `*` | Match zero or more characters |
| `?` | Match exactly one character |
| `[abc]` | Match one character: `a`, `b`, or `c` |
| `[a-z]` | Match one character in the range `a-z` |
| `{a,b}` | Brace expansion (multiple patterns) |

---

# Wildcard Examples

| Command | Description |
|---------|-------------|
| `ls *.v` | List all `.v` files |
| `ls test*` | List files starting with `test` |
| `ls module?.v` | List `module1.v`, `module2.v`, etc. (single character only) |
| `ls *.{v,sv}` | List all `.v` and `.sv` files |
| `cp tb_*.v backup/` | Copy all testbench files to `backup/` |
| `rm *.log` | Delete all `.log` files |

---

# Interview / Concept Questions

## 1. Difference between `ls *.v` and `ls "*.v"`

### `ls *.v`
- `*` is expanded by the **shell** before `ls` runs.
- `ls` receives the actual filenames.

Example:
```bash
ls *.v
# Shell expands to:
ls alu.v mux.v adder.v
```

### `ls "*.v"`
- Quotes prevent wildcard expansion.
- `ls` looks for a file literally named `*.v`.

Example:
```bash
ls "*.v"
# Looks for a file named *.v
# Usually returns:
ls: cannot access '*.v': No such file or directory
```

**Use quotes when you want to pass `*` as a literal character to a command (e.g., `find`, `grep`, or scripting).**

---

## 2. If you're in `/home/user/project/rtl` and run:

```bash
cd ../../
```

Path resolution:

```text
/home/user/project/rtl
        ↑
cd ..
        ↓
/home/user/project
        ↑
cd ..
        ↓
/home/user
```

Final directory:

```text
/home/user
```

---

## 3. Why are absolute paths bad in shared scripts?

Example:

```bash
/home/teekam/project/rtl/top.v
```

Problems:
- Works only on your computer.
- Fails if another user has a different username or directory.
- Breaks when the project is moved.
- Makes repositories less portable.

Better:

```bash
./rtl/top.v
../rtl/top.v
```

Relative paths work regardless of where the project is cloned, making them ideal for Git repositories, Makefiles, shell scripts, and EDA tool flows.

### Terminal Efficiency & Command History

# 1. Tab Completion

## Usage
```bash
cd lin<TAB>
```
- Automatically completes file/directory names.

## Rules

| Action | Function |
|---|---|
| `TAB` once | Auto-complete if only one match |
| `TAB TAB` | Show all possible matches |
| Works with | Commands, files, directories, paths |


## Examples

```bash
cd /ho<TAB>/tee<TAB>/lin<TAB>
```
- Completes long paths quickly.

```bash
real<TAB>
```
- Completes command name.

```bash
cd te<TAB><TAB>
```
- Shows all directories starting with `te`.


---

# 2. Command History

Linux stores previous commands.

## Commands

| Command | Function |
|---|---|
| `history` | Show command history |
| `history \| tail -20` | Show last 20 commands |
| `!123` | Run command number 123 |
| `!!` | Run previous command |
| `!cp` | Run last command starting with cp |
| `sudo !!` | Run previous command with sudo |


## Keyboard Navigation

| Shortcut | Function |
|---|---|
| `↑` | Previous command |
| `↓` | Next command |
| `Ctrl+R` | Search command history |


---

# 3. Reverse Search (Ctrl+R)

Search previous commands without scrolling.

Example:

```
Ctrl+R
grep
```

Finds previous command containing `grep`.

Useful for:
- Simulation commands
- Long synthesis commands
- Previous scripts


---

# 4. Command Line Shortcuts


## Cursor Movement

| Shortcut | Function |
|---|---|
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+←` | Move one word backward |
| `Ctrl+→` | Move one word forward |
| `Alt+B` | Move backward one word |
| `Alt+F` | Move forward one word |


## Editing

| Shortcut | Function |
|---|---|
| `Ctrl+U` | Delete from cursor to start |
| `Ctrl+K` | Delete from cursor to end |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |


## Control

| Shortcut | Function |
|---|---|
| `Ctrl+C` | Cancel command |
| `Ctrl+D` | Exit terminal/end input |
| `Ctrl+L` | Clear terminal |
| `Ctrl+R` | Search history |


---

# 5. Useful History Tricks


## Repeat Last Command

```bash
!!
```

Example:

```bash
sudo !!
```

Runs previous command with sudo.


## Run Previous Command Starting With Text

```bash
!cp
```

Runs latest command starting with `cp`.


## Replace Text in Previous Command

Syntax:

```bash
^old^new^
```

Example:

Previous command:

```bash
cp file.txt backup/
```

Fix:

```bash
^cp^mv^
```

Result:

```bash
mv file.txt backup/
```


---

# VLSI Usage Examples


## Simulation Re-run

First run:

```bash
iverilog -o sim.out rtl/adder.v testbench/tb.v
vvp sim.out
```

Modify and run again:

```bash
↑
```

Edit required part and execute.


## Finding Previous Commands

```bash
Ctrl+R
```

Search:

```text
grep
```

Finds previous grep commands.


---

# Assignment Commands


## Create Nested Directory

```bash
mkdir -p ~/linux_training/day1/synthesis/genus/reports/timing/setup/
```


## Navigation Practice

```bash
cd ~/linux_training/day1/scripts/
```


## History Practice

Run:

```bash
cd ~/linux_training/day1/rtl
ls -lh *.v
cp adder.v ../testbench/
realpath *.v > /tmp/rtl_paths.txt
```


Reuse:

```bash
!real
```

Run previous `realpath` command.


```bash
!5
```

Run command number 5 from history.


---

# Questions


## 1. What does double TAB do?

Command:

```bash
cd ch<TAB><TAB>
```

Answer:
- Single TAB completes automatically if only one option exists.
- Double TAB displays all possible matches.


---

## 2. Find previous grep ERROR command

Fastest method:

```bash
Ctrl+R
```

Type:

```text
grep
```

Searches command history for previous grep commands.


---

## 3. Fix error at beginning of long command

Move to start:

```bash
Ctrl+A
```

Move back/end:

```bash
Ctrl+E
```

or:

```bash
Ctrl+→
```

to move word by word.

### Text Processing Fundamentals (grep, wc, head, tail)

## Goal

* Search logs quickly
* Analyze simulation and synthesis reports
* Extract useful information from large files

# Text Processing Commands

| Command | Purpose                        |
| ------- | ------------------------------ |
| `grep`  | Search text patterns           |
| `wc`    | Count lines, words, characters |
| `head`  | Show beginning of file         |
| `tail`  | Show end of file               |
| `cat`   | Display or combine files       |
| `less`  | View large files page by page  |

# grep

## Syntax

```bash
grep "pattern" filename
grep "pattern" *.log
```

## Options

| Command     | Function                            |
| ----------- | ----------------------------------- |
| `grep -i`   | Case-insensitive search             |
| `grep -n`   | Show line numbers                   |
| `grep -c`   | Count matching lines                |
| `grep -v`   | Show lines NOT matching             |
| `grep -r`   | Search recursively in directories   |
| `grep -C 3` | Show 3 lines before and after match |
| `grep -E`   | Search multiple patterns            |

## Examples

```bash
grep "ERROR" simulation.log
```

Search ERROR messages.

```bash
grep -n "ERROR" build.log
```

Show ERROR messages with line numbers.

```bash
grep -c "PASSED" test.log
```

Count passed tests.

```bash
grep -v "INFO" simulation.log
```

Show lines that do not contain INFO.

```bash
grep -r "module adder" rtl/
```

Search inside a directory.

```bash
grep -E "ERROR|FATAL" simulation.log
```

Search multiple patterns.

# wc (Word Count)

## Syntax

```bash
wc filename
```

Output:

```
lines words characters filename
```

## Options

| Command | Function         |
| ------- | ---------------- |
| `wc -l` | Count lines      |
| `wc -w` | Count words      |
| `wc -c` | Count characters |

## Examples

```bash
wc -l synthesis_report.txt
```

Count lines in a file.

```bash
grep "ERROR" build.log | wc -l
```

Count number of errors.

```bash
ls *.v | wc -l
```

Count Verilog files.

# head

Shows the beginning of a file.

## Syntax

```bash
head filename
```

Default:

* Shows first 10 lines

Example:

```bash
head -20 file.txt
```

Shows first 20 lines.

# tail

Shows the end of a file.

## Syntax

```bash
tail filename
```

## Options

| Command      | Function                  |
| ------------ | ------------------------- |
| `tail -n 50` | Show last 50 lines        |
| `tail -f`    | Monitor file continuously |

Example:

```bash
tail -f simulation.log
```

Used for:

* Live simulation logs
* Compilation monitoring
* Long-running processes

Stop:

```
Ctrl+C
```

# cat

Display or combine files.

## Examples

```bash
cat file.txt
```

Display file contents.

```bash
cat file1.txt file2.txt > combined.txt
```

Combine multiple files.

Create a file:

```bash
cat > note.txt
```

Finish input:

```
Ctrl+D
```

# less

Used for viewing large files.

## Syntax

```bash
less large_file.log
```

## Navigation

| Key           | Function               |
| ------------- | ---------------------- |
| `Space` / `f` | Next page              |
| `b`           | Previous page          |
| `/pattern`    | Search                 |
| `n`           | Next search result     |
| `N`           | Previous search result |
| `g`           | Beginning of file      |
| `G`           | End of file            |
| `q`           | Quit                   |

# Pipes (`|`)

Connect output of one command to another command.

Example:

```bash
grep "ERROR" log.txt | wc -l
```

Flow:

```
grep output → wc input
```

Examples:

```bash
grep "ERROR" sim.log | head -10
```

Show first 10 errors.

```bash
grep "ERROR" sim.log | grep -v "WARNING"
```

Remove warning messages.

```bash
grep "slack" timing.txt | grep -v "MET"
```

Find timing violations.

# VLSI Usage Examples

## Find Simulation Errors

```bash
grep -n "ERROR\|FATAL" simulation.log
```

Find errors and fatal messages with line numbers.

## Regression Testing

```bash
grep -c "TEST PASSED" regression.log
grep -c "TEST FAILED" regression.log
```

Count passed and failed tests.

## Timing Report Analysis

```bash
grep "slack" timing_report.txt | grep -v "MET"
```

Extract timing violations.

Count violations:

```bash
grep "VIOLATED" timing_report.txt | wc -l
```

# File Redirection

Overwrite output:

```bash
command > file.txt
```

Append output:

```bash
command >> file.txt
```

Example:

```bash
wc -l simulation.log > summary.txt
grep -c ERROR simulation.log >> summary.txt
```

# Questions

## 1. Difference between:

```bash
grep "ERROR" file.log
```

and

```bash
grep -c "ERROR" file.log
```

Answer:

`grep "ERROR" file.log`

* Displays matching lines.

`grep -c "ERROR" file.log`

* Displays only the count of matching lines.

## 2. Check if a 100,000 line log finished with DONE

Command:

```bash
tail -1 simulation.log
```

Reason:

* Reads only the last line.
* Faster than searching the entire file.

## 3. Why use tail -f instead of tail?

```bash
tail -f logfile.log
```

`tail -f`:

* Continuously monitors new lines.
* Useful for live simulation, compilation, and synthesis logs.

`tail`:

* Shows current last lines and exits.

### Advanced Text Processing (sed, awk, cut, sort)


## Goal

* Transform text files
* Extract specific data
* Process structured reports
* Analyze synthesis and simulation logs

# Advanced Text Processing Tools

| Command | Purpose                                   |
| ------- | ----------------------------------------- |
| `sed`   | Find, replace, delete, modify text        |
| `awk`   | Extract columns, filter, calculate values |
| `cut`   | Extract specific fields/characters        |
| `sort`  | Sort data                                 |
| `uniq`  | Remove or count duplicates                |

---

# sed (Stream Editor)

Used for:

* Find and replace
* Delete lines
* Insert/append text

## Find and Replace

Replace first occurrence:

```bash
sed 's/old/new/' file.txt
```

Replace all occurrences:

```bash
sed 's/old/new/g' file.txt
```

Save output:

```bash
sed 's/ERROR/FIXED/g' input.log > output.log
```

Modify original file:

```bash
sed -i 's/old/new/g' file.txt
```

Replace only lines containing a pattern:

```bash
sed '/WARNING/s/LEVEL1/LEVEL2/g' file.txt
```

---

## Delete Lines

Delete lines containing text:

```bash
sed '/INFO/d' simulation.log
```

Delete empty lines:

```bash
sed '/^$/d' file.txt
```

Delete specific line range:

```bash
sed '5,10d' file.txt
```

Delete first line:

```bash
sed '1d' file.txt
```

---

## Insert and Append

Insert before line:

```bash
sed '3i\New line' file.txt
```

Append after line:

```bash
sed '5a\New line' file.txt
```

---

## VLSI Examples

Rename module:

```bash
sed 's/module old_cpu/module new_cpu/g' cpu.v
```

Remove INFO messages:

```bash
sed '/INFO/d' simulation.log > clean.log
```

Change clock name:

```bash
sed -i 's/clk_100/clk_main/g' *.sdc
```

---

# awk

Used for:

* Column extraction
* Filtering
* Calculations

## Print Columns

First column:

```bash
awk '{print $1}' file.txt
```

Multiple columns:

```bash
awk '{print $1,$3}' file.txt
```

Last column:

```bash
awk '{print $NF}' file.txt
```

Custom output:

```bash
awk '{print $1 " -> " $3}' file.txt
```

---

## Filtering

Column 3 greater than 100:

```bash
awk '$3 > 100' data.txt
```

Column 2 equals FAILED:

```bash
awk '$2 == "FAILED"' results.txt
```

---

## Calculations

Sum column:

```bash
awk '{sum += $2} END {print sum}' numbers.txt
```

Average:

```bash
awk '{sum += $3; count++} END {print sum/count}' data.txt
```

---

## Field Separator

Comma separated file:

```bash
awk -F',' '{print $1,$3}' data.csv
```

Colon separated file:

```bash
awk -F':' '{print $1}' /etc/passwd
```

---

## VLSI Examples

Extract path names:

```bash
awk '/Path/ {print $2}' timing.txt
```

Calculate total area:

```bash
awk '/Area/ {sum += $3} END {print sum}' synth.rpt
```

Find long runtime tests:

```bash
awk '$3 > 1000 {print $1,$3}' benchmark.txt
```

---

# cut

Used to extract columns or characters.

## Extract Fields

First field:

```bash
cut -f1 file.txt
```

Fields 1 and 3:

```bash
cut -f1,3 file.txt
```

Comma delimiter:

```bash
cut -d',' -f2 data.csv
```

Space delimiter:

```bash
cut -d' ' -f1,4 file.txt
```

---

## Character Extraction

Characters 1-10:

```bash
cut -c1-10 file.txt
```

Character 5 to end:

```bash
cut -c5- file.txt
```

---

## VLSI Examples

Extract filenames:

```bash
ls -l | cut -d' ' -f9
```

Extract usernames:

```bash
cut -d':' -f1 /etc/passwd
```

Extract slack values:

```bash
cut -d'=' -f2 timing.txt
```

---

# sort

Used for sorting data.

## Basic Sorting

Alphabetical:

```bash
sort file.txt
```

Reverse:

```bash
sort -r file.txt
```

Numeric:

```bash
sort -n numbers.txt
```

Sort by column:

```bash
sort -k2 file.txt
```

Numeric column sorting:

```bash
sort -k2 -n file.txt
```

---

## VLSI Examples

Worst timing violations:

```bash
sort -k3 -n violations.txt
```

Sort files by size:

```bash
ls -lh | sort -k5 -h
```

Top 10 longest tests:

```bash
sort -k2 -n -r runtime.txt | head -10
```

---

# uniq

Used for duplicate handling.

## Commands

Remove duplicates:

```bash
sort file.txt | uniq
```

Count duplicates:

```bash
sort file.txt | uniq -c
```

Show only duplicates:

```bash
sort file.txt | uniq -d
```

Show unique entries:

```bash
sort file.txt | uniq -u
```

---

## VLSI Examples

Count errors:

```bash
grep "ERROR" *.log | sort | uniq -c
```

Find duplicate modules:

```bash
grep "^module" *.v | cut -d' ' -f2 | sort | uniq -d
```

---

# Combining Commands

## Top 5 Common Errors

```bash
grep "ERROR" simulation.log | sort | uniq -c | sort -n -r | head -5
```

## Find Worst Timing Violations

```bash
grep "slack" timing.txt | awk '$4 < 0 {print $2,$4}' | sort -k2 -n
```

## Count Test Status

```bash
cut -d',' -f2 results.csv | sort | uniq -c
```

## Average Failed Test Runtime

```bash
grep "FAILED" results.txt | awk '{sum += $3; count++} END {print sum/count}'
```

---

# Important Questions

## 1. Difference between:

```bash
sed 's/old/new/'
```

and

```bash
sed 's/old/new/g'
```

Answer:

`sed 's/old/new/'`

* Replaces only the first occurrence in each line.

`sed 's/old/new/g'`

* Replaces all occurrences in each line.

---

## 2. What does `$NF` represent in awk?

Answer:

`$NF` represents the last column of the current line.

Example:

```bash
awk '{print $NF}' file.txt
```

Prints the last field.

---

## 3. Why use sort before uniq?

Answer:

`uniq` only removes adjacent duplicate lines.

Without sorting:

```
ERROR
PASS
ERROR
```

`uniq` will not remove both ERROR lines.

After sorting:

```
ERROR
ERROR
PASS
```

`uniq` removes duplicates correctly.

---

## 4. Difference between sort -n and normal sort?

Normal sort:

```bash
sort file.txt
```

* Sorts alphabetically.
* Treats numbers as characters.

Numeric sort:

```bash
sort -n file.txt
```

* Sorts according to numerical value.

Example:

Normal:

```
1
10
2
```

Numeric:

```
1
2
10
```

---

### File Permissions & Ownership

## Goal

* Understand Linux permission system
* Control file access
* Manage ownership and security
* Prepare for VLSI/Linux workflows

# Linux Permission Model

Every file and directory has:

1. Owner

* User who created the file

2. Group

* Users sharing access

3. Permissions

* Allowed actions

---

# Permission Types

| Permission | Meaning                        | Value |
| ---------- | ------------------------------ | ----- |
| `r`        | Read contents                  | 4     |
| `w`        | Write/modify contents          | 2     |
| `x`        | Execute file / enter directory | 1     |

---

# Permission Categories

| Symbol | Meaning    |
| ------ | ---------- |
| `u`    | User/Owner |
| `g`    | Group      |
| `o`    | Others     |
| `a`    | All users  |

---

# View Permissions

Command:

```bash
ls -l
```

Example:

```text
-rw-r--r-- 1 user group 1024 Jan 21 10:00 adder.v
drwxr-xr-x 2 user group 4096 Jan 21 10:00 testbenches/
```

## Permission Breakdown

Example:

```text
-rw-r--r--
```

| Part  | Meaning            |
| ----- | ------------------ |
| `-`   | Regular file       |
| `d`   | Directory          |
| `rw-` | Owner permissions  |
| `r--` | Group permissions  |
| `r--` | Others permissions |

Example:

```text
drwxr-xr-x
```

Meaning:

* `d` = directory
* Owner = read/write/execute
* Group = read/execute
* Others = read/execute

---

# chmod (Change Permissions)

## Numeric Method

Syntax:

```bash
chmod permission file
```

Values:

| Number | Permission |
| ------ | ---------- |
| 7      | rwx        |
| 6      | rw-        |
| 5      | r-x        |
| 4      | r--        |
| 0      | ---        |

Examples:

```bash
chmod 755 compile.sh
```

Result:

```text
rwxr-xr-x
```

Owner:

* Read
* Write
* Execute

Others:

* Read
* Execute

```bash
chmod 644 design.v
```

Result:

```text
rw-r--r--
```

```bash
chmod 600 secrets.txt
```

Result:

```text
rw-------
```

```bash
chmod 700 private/
```

Result:

```text
rwx------
```

---

# chmod Symbolic Method

Add permission:

```bash
chmod u+x script.sh
```

Add execute permission for owner.

Remove permission:

```bash
chmod g-w design.v
```

Remove write permission from group.

```bash
chmod o-r private.txt
```

Remove read permission from others.

Add permission for everyone:

```bash
chmod a+r readme.txt
```

Set exact permissions:

```bash
chmod u=rwx,g=rx,o=r file.txt
```

---

# chown (Change Ownership)

Change owner and group:

```bash
sudo chown user:group file.v
```

Change only owner:

```bash
sudo chown user file.v
```

Change only group:

```bash
sudo chown :group file.v
```

Change ownership recursively:

```bash
sudo chown -R user:group directory/
```

Used when:

* Sharing projects
* Managing server files
* Fixing permission problems

---

# umask (Default Permissions)

Check current umask:

```bash
umask
```

Set umask:

```bash
umask 022
```

Restrictive permissions:

```bash
umask 077
```

---

# How umask Works

Default permissions:

Files:

```text
666
```

Directories:

```text
777
```

Final permission:

```text
Default permission - umask
```

## Examples

### umask 022

Files:

```text
666 - 022 = 644
```

Result:

```text
rw-r--r--
```

Directories:

```text
777 - 022 = 755
```

Result:

```text
rwxr-xr-x
```

---

### umask 077

Files:

```text
666 - 077 = 600
```

Result:

```text
rw-------
```

Directories:

```text
777 - 077 = 700
```

Result:

```text
rwx------
```

---

# VLSI Usage Examples

## Make Simulation Script Executable

```bash
chmod +x run_sim.sh
```

Run:

```bash
./run_sim.sh
```

## Protect Confidential Files

```bash
chmod 600 timing_report.txt
```

Only owner can read/write.

## Share RTL Files With Team

```bash
chmod 644 *.v
```

Owner:

* Read/write

Others:

* Read only

---

### Process Management

## Goal

* Understand Linux processes
* Manage running programs
* Control foreground and background tasks
* Handle long-running simulations

# What is a Process?

A process is a running instance of a program.

Examples:

* Running a Verilog simulation
* Running a compiler
* Running a script

Every process has:

| Term       | Meaning                            |
| ---------- | ---------------------------------- |
| PID        | Process ID (unique process number) |
| PPID       | Parent Process ID                  |
| Foreground | Process using current terminal     |
| Background | Process running behind terminal    |

---

# Practice Setup

Create workspace:

```bash
cd ~/linux_training
mkdir -p day6
cd day6
```

Create simulation script:

```bash
cat > long_sim.sh << 'EOF'
#!/bin/bash
echo "Simulation started PID: $$"
echo "Running..."
sleep 60
echo "Simulation complete"
EOF
```

Make executable:

```bash
chmod 755 long_sim.sh
```

Create second simulation:

```bash
cat > another_sim.sh << 'EOF'
#!/bin/bash
echo "Second sim started PID: $$"
echo "Processing..."
sleep 120
echo "Second sim complete"
EOF
```

Make executable:

```bash
chmod 755 another_sim.sh
```

Create monitor:

```bash
cat > monitor.sh << 'EOF'
#!/bin/bash
echo "Monitor started PID: $$"
while true; do
    echo "Monitoring at $(date +%H:%M:%S)..."
    sleep 5
done
EOF
```

Make executable:

```bash
chmod 755 monitor.sh
```

---

# ps (Process Status)

Shows running processes.

## Basic Commands

Show current processes:

```bash
ps
```

Show all processes:

```bash
ps aux
```

Show process tree:

```bash
ps axf
```

Find specific process:

```bash
ps aux | grep iverilog
```

Show selected columns:

```bash
ps -eo pid,comm,%cpu,%mem
```

---

# ps Output Fields

Example:

```text
USER PID %CPU %MEM COMMAND
teekam 1234 0.0 0.5 bash
teekam 1235 5.2 2.1 iverilog
```

| Field   | Meaning         |
| ------- | --------------- |
| USER    | Process owner   |
| PID     | Process ID      |
| %CPU    | CPU usage       |
| %MEM    | Memory usage    |
| STAT    | Process state   |
| COMMAND | Running program |

STAT values:

| Value | Meaning  |
| ----- | -------- |
| S     | Sleeping |
| R     | Running  |
| T     | Stopped  |

---

# kill (Stop Processes)

## Normal kill

```bash
kill PID
```

Sends SIGTERM.

* Requests process to stop
* Allows cleanup

## Force kill

```bash
kill -9 PID
```

Sends SIGKILL.

* Immediately stops process
* No cleanup

## Specific signals

```bash
kill -15 PID
```

Same as normal kill.

---

# When to Use

| Command       | Usage                        |
| ------------- | ---------------------------- |
| `kill PID`    | First choice                 |
| `kill -9 PID` | Hung or unresponsive process |

---

# Background and Foreground Processes

Run in background:

```bash
./long_sim.sh &
```

View background jobs:

```bash
jobs
```

Bring job to foreground:

```bash
fg
```

Bring specific job:

```bash
fg %1
```

Resume stopped job in background:

```bash
bg
```

Resume specific job:

```bash
bg %1
```

---

# Keyboard Controls

| Shortcut | Function                      |
| -------- | ----------------------------- |
| `Ctrl+C` | Kill foreground process       |
| `Ctrl+Z` | Pause/stop foreground process |

Difference:

* `Ctrl+C` terminates the process.
* `Ctrl+Z` pauses the process and allows resume with `bg` or `fg`.

---

# top and htop

Live process monitoring.

## top

```bash
top
```

Quit:

```bash
q
```

## htop

```bash
htop
```

Better interactive process viewer.

Quit:

```bash
q
```

---

# VLSI Usage Examples

Run simulation:

```bash
./run_sim.sh &
```

Check simulation:

```bash
ps aux | grep run_sim
```

Continue working:

```bash
ls rtl/
grep "module" rtl/*.v
```

If simulation hangs:

Try:

```bash
kill %1
```

Force stop:

```bash
kill -9 %1
```

---

# Verification Questions

## 1. What does `&` do?

Answer:

`&` runs a command in the background.

Example:

```bash
./simulation.sh &
```

Terminal remains available while process runs.

---

## 2. Difference between `kill` and `kill -9`?

Answer:

`kill PID`

* Sends SIGTERM.
* Allows process cleanup.

`kill -9 PID`

* Sends SIGKILL.
* Immediately terminates process.

---

## 3. Difference between Ctrl+Z and Ctrl+C?

Answer:

`Ctrl+C`

* Terminates the running process.

`Ctrl+Z`

* Pauses the process.
* Can resume using `bg` or `fg`.

---

## 4. If `ps aux | grep iverilog` shows only grep itself?

Answer:

The iverilog process is not running.

The grep command appears because it is searching for the text `iverilog`.

---

## 5. What does `fg` do?

Answer:

Moves a background or stopped process to the foreground.

Example:

```bash
fg %1
```

---

