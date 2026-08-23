# Day 13: `man`, `tldr`, and Help Commands

Today is about learning how to find information yourself instead of memorizing every command and flag.

## 1. Linux Help System

```text
Quick help       → command --help
Full reference   → man command
Examples         → tldr command
Find a command   → apropos keyword
Find binary      → which command
Find locations   → whereis command
Command type     → type command
Bash builtin     → help command
Deep docs        → info command
```

---

## 2. `man` Pages

`man` provides the complete manual for a command.

```bash
man ls
man grep
man chmod
man git
```

### Useful navigation

```text
↑ / ↓       Scroll
Space       Next page
b           Previous page
/pattern    Search
n           Next match
N           Previous match
g           Beginning
G           End
q           Quit
```

### Common sections

```text
1 → User commands
2 → System calls
3 → Library functions
5 → File formats
8 → System administration commands
```

Example:

```bash
man 1 printf
man 3 printf
```

---

## 3. `--help`

`--help` gives a quick summary of a command's options.

```bash
ls --help
grep --help
chmod --help
git --help
iverilog --help
```

You can search its output:

```bash
grep --help | grep count
ls --help | grep size
```

### `--help` vs `man`

```text
--help → Quick reference
man    → Complete documentation
```

Use `--help` when you remember the command but forgot a flag.

Use `man` when you need detailed information.

---

## 4. `tldr`

`tldr` provides short, practical examples instead of the huge wall of documentation that `man` sometimes throws at your face.

```bash
tldr ls
tldr grep
tldr chmod
tldr tar
tldr find
```

Typical examples might show:

```bash
grep "pattern" file
grep -r "pattern" directory
grep -n "pattern" file
```

### Difference

```text
man  → Complete reference
tldr → Common practical examples
```

---

## 5. `apropos`

Use `apropos` when you know what you want to do but don't know the command.

```bash
apropos permission
apropos compress
apropos network
apropos sorting
apropos verilog
```

Example:

```bash
apropos compress
```

It searches manual-page descriptions for matching keywords.

`man -k` does essentially the same thing:

```bash
man -k compress
```

---

## 6. `which`

`which` shows which executable will be found through your `PATH`.

```bash
which grep
which python3
which iverilog
```

Example:

```text
/usr/bin/grep
```

This is useful for checking whether a command is available.

---

## 7. `whereis`

`whereis` can locate several related files, such as the executable and manual page.

```bash
whereis grep
whereis git
```

Example:

```text
grep: /usr/bin/grep /usr/share/man/man1/grep.1.gz
```

### Difference

```text
which   → Which executable will my shell run?
whereis → Where are related files located?
```

---

## 8. `type`

`type` tells you what kind of command something is.

```bash
type ls
type cd
type echo
type if
type grep
```

Possible results include:

```text
ls     → external command
cd     → shell builtin
if     → shell keyword
```

This matters because shell builtins are handled by the shell itself.

For example:

```bash
help cd
help echo
help if
```

---

## 9. `help` for Bash Builtins

For Bash builtins:

```bash
help
help cd
help echo
help if
help for
help while
help read
```

You can also use:

```bash
man bash
```

for the larger Bash manual.

---

## 10. `info`

`info` provides detailed GNU documentation.

```bash
info grep
info bash
info coreutils
```

Basic navigation:

```text
Enter → Follow link
l     → Back
n     → Next
p     → Previous
q     → Quit
```

For most everyday command usage, `man` and `--help` are usually enough.

---

## 11. Reading a `man` Page

A typical manual page contains:

```text
NAME
→ Command name and description

SYNOPSIS
→ How the command is used

DESCRIPTION
→ What it does

OPTIONS
→ Available flags

EXAMPLES
→ Examples, when provided

SEE ALSO
→ Related commands
```

### Synopsis notation

Example:

```text
grep [OPTION]... PATTERN [FILE]...
```

Meaning:

```text
[ ] → Optional
... → Can occur multiple times
|  → OR
```

---

## 12. Useful `grep` Questions

You can find answers directly from:

```bash
man grep
```

For example:

```text
-v → Invert the match
-l → Print filenames containing matches
-A → Print lines after a matching line
-E → Extended regular expressions
-P → Perl-compatible regular expressions
```

The exact options available can depend on the implementation, so check the documentation on your system.

---

## 13. Self-Help Workflow

When you don't remember how to use a command:

```text
1. command --help
        ↓
2. tldr command
        ↓
3. man command
        ↓
4. apropos keyword
```

If it is a Bash builtin:

```bash
help command
```

If you don't know which command you need:

```bash
apropos keyword
```

---

## 14. VLSI Examples

Forgot an Icarus Verilog option?

```bash
iverilog --help
man iverilog
```

Need information about GTKWave:

```bash
gtkwave --help
```

Need a compression command:

```bash
apropos compress
```

Forgot a `grep` option:

```bash
man grep
```

Need common `tar` examples:

```bash
tldr tar
```

---

## 15. Important Questions

### `man` vs `tldr`?

```text
man  → Detailed and complete
tldr → Short and practical
```

### `which` vs `whereis`?

```text
which   → Executable found through PATH
whereis → Executable + related locations
```

### `apropos` vs `man`?

```text
apropos → Find which command might help
man     → Learn how a known command works
```

### What if `man cd` doesn't work properly?

`cd` is a Bash builtin, so use:

```bash
help cd
```

or:

```bash
man bash
```

---

## 16. Key Commands

```bash
man command
man -k keyword

command --help

tldr command

apropos keyword

which command
whereis command
type command

help builtin
info command
```

## Core Mental Model

```text
Know command, forgot flag
        ↓
    --help

Want practical examples
        ↓
       tldr

Need complete details
        ↓
       man

Don't know the command
        ↓
     apropos

Need to know what command is running
        ↓
       which / type
```

The important skill from this day isn't memorizing `man`, `tldr`, or `apropos. It's being able to answer, "I don't know this command yet, but I know how to find out."
