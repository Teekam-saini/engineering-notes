# Advanced I/O

## 1. Standard Streams

Every Linux process has three standard file descriptors:

```text
0 → stdin    Input
1 → stdout   Normal output
2 → stderr   Error output
```

Normally:

```text
Keyboard → stdin → Program → stdout → Terminal
                         → stderr → Terminal
```

---

## 2. Basic Redirection

### stdout

```bash
command > file.txt       # Overwrite
command >> file.txt      # Append
```

### stdin

```bash
command < file.txt
```

### stderr

```bash
command 2> error.log
command 2>> error.log
command 2>/dev/null
```

---

## 3. Redirect stdout and stderr

Separate them:

```bash
command > output.log 2> error.log
```

Send both to the same file:

```bash
command > all.log 2>&1
```

Shortcut:

```bash
command &> all.log
```

Pipe both:

```bash
command 2>&1 | grep "ERROR"
```

### `2>&1`

```bash
command > file.txt 2>&1
```

Read right to left:

```text
> file.txt
    ↓
stdout → file.txt

2>&1
    ↓
stderr → same destination as stdout
```

Order matters:

```bash
command > file.txt 2>&1    # Both → file
command 2>&1 > file.txt    # stderr → terminal, stdout → file
```

---

## 4. `/dev/null`

`/dev/null` discards data.

```bash
command > /dev/null       # Discard stdout
command 2>/dev/null       # Discard stderr
command > /dev/null 2>&1  # Discard everything
```

Useful for silently checking commands:

```bash
if which iverilog > /dev/null 2>&1; then
    echo "iverilog is installed"
fi
```

---

## 5. Writing to stderr

Normal output:

```bash
echo "[INFO] Compilation started"
```

Error output:

```bash
echo "[ERROR] File not found" >&2
```

This allows output to be separated:

```bash
./script.sh > output.log 2> errors.log
```

---

## 6. File Descriptors

File descriptors are numbers used by Linux to reference open streams/files.

```text
0 → stdin
1 → stdout
2 → stderr
3-9 → Custom descriptors
```

Create a custom descriptor:

```bash
exec 3> output.log
```

Write to it:

```bash
echo "Debug information" >&3
```

Close it:

```bash
exec 3>&-
```

Example:

```bash
exec 3>> build.log

echo "Build started"
echo "Build started" >&3

exec 3>&-
```

---

## 7. `tee`

`tee` sends output to the terminal and a file simultaneously.

```bash
command | tee output.log
```

Append instead of overwrite:

```bash
command | tee -a output.log
```

Include stderr:

```bash
command 2>&1 | tee all_output.log
```

Useful for VLSI compilation:

```bash
iverilog -o sim.out counter.v tb_counter.v 2>&1 | tee compile.log
```

You see the compilation output while also saving it.

---

## 8. Reading from stdin

`read` gets input from stdin:

```bash
read -p "Enter module name: " module
```

Input can also come from a file:

```bash
while read line; do
    echo "Processing: $line"
done < file.txt
```

---

## 9. Process Substitution

Process substitution makes command output behave like a file.

Syntax:

```bash
<(command)
```

Example:

```bash
diff <(ls rtl/) <(ls testbench/)
```

Compare two command outputs without creating temporary files.

Another example:

```bash
cat <(echo "Header") <(ls rtl/) <(echo "Footer")
```

---

## 10. Important VLSI Use

Separate compilation output and errors:

```bash
iverilog -o sim.out \
    rtl/counter.v \
    testbench/tb_counter.v \
    > compile.log \
    2> compile_errors.log
```

Check the result:

```bash
if [ $? -eq 0 ]; then
    echo "SUCCESS"
else
    echo "FAILED"
    cat compile_errors.log
fi
```

---

## Key Concepts

```bash
0                  # stdin
1                  # stdout
2                  # stderr

> file             # stdout → file
>> file            # stdout → file, append
< file             # file → stdin
2> file            # stderr → file
2>&1               # stderr → stdout destination
&> file            # stdout + stderr → file

/dev/null          # Discard output

>&2                # Write to stderr

tee file            # Terminal + file
tee -a file         # Terminal + append to file

exec 3> file       # Open custom fd
echo "x" >&3       # Write to fd 3
exec 3>&-          # Close fd 3

<(command)         # Process substitution
```

## Core Idea

```text
stdin  → data entering a program
stdout → normal program output
stderr → error/diagnostic output
```

File descriptors and redirection let you control exactly where each type of data goes. This is especially useful for build scripts, Verilog compilation, simulation logs, and automated VLSI workflows.
