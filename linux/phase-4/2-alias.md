# Day 23: Shell Configuration

## 1. `.bashrc`

`.bashrc` is the main configuration file for Bash.

```bash
~/.bashrc
```

It is used to store:

* Aliases
* Functions
* Environment variables
* PATH changes
* Prompt customization

View/edit it:

```bash
cat ~/.bashrc
nano ~/.bashrc
```

Apply changes:

```bash
source ~/.bashrc
```

---

## 2. Aliases

Aliases are shortcuts for commands.

### Syntax

```bash
alias name='command'
```

Example:

```bash
alias ll='ls -lah'
alias gs='git status'
alias wave='gtkwave'
```

Aliases added directly to the terminal are temporary.

For permanent aliases, add them to `~/.bashrc`.

### Useful aliases

```bash
alias ll='ls -lah'
alias la='ls -A'
alias gs='git status'
alias gaa='git add .'
alias gp='git push'
alias gd='git diff'

alias ivlog='iverilog'
alias sim='vvp'
alias wave='gtkwave'
```

Remove an alias:

```bash
unalias ll
```

List aliases:

```bash
alias
```

---

## 3. Functions

Functions are used when a command needs arguments or multiple commands.

### Syntax

```bash
name() {
    commands
}
```

Arguments:

```bash
$1    # first argument
$2    # second argument
```

### Example: `mkcd`

Create a directory and enter it:

```bash
mkcd() {
    mkdir -p "$1" && cd "$1"
}
```

Usage:

```bash
mkcd project
```

### Example: Git commit

```bash
gcm() {
    git add .
    git commit -m "$1"
}
```

Usage:

```bash
gcm "Added ALU"
```

### Example: Backup

```bash
backup() {
    cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}
```

Usage:

```bash
backup design.v
```

---

## 4. Environment Variables

Environment variables store configuration values.

```bash
export EDITOR=nano
export HISTSIZE=10000
export HISTCONTROL=ignoredups
```

Check a variable:

```bash
echo $EDITOR
echo $HISTSIZE
```

---

## 5. PATH

`PATH` contains directories where Bash looks for executable commands.

Add a directory permanently:

```bash
export PATH=$PATH:~/linux_training/scripts
```

Then scripts inside that directory can be run without typing their full path.

---

## 6. Custom Prompt

`PS1` controls the Bash prompt.

Useful escape sequences:

```text
\u    username
\h    hostname
\w    current directory
\$    $ for normal user, # for root
```

Example:

```bash
PS1='\u@\h:\w\$ '
```

---

## 7. Backup and Restore `.bashrc`

Before making major changes:

```bash
cp ~/.bashrc ~/.bashrc.backup
```

Restore:

```bash
cp ~/.bashrc.backup ~/.bashrc
source ~/.bashrc
```

---

## 8. Alias vs Function

| Alias                   | Function                  |
| ----------------------- | ------------------------- |
| Simple shortcut         | More complex command      |
| Best for one command    | Can run multiple commands |
| No proper arguments     | Accepts arguments         |
| `alias gs='git status'` | `mkcd() { ... }`          |

### Remember

```text
.bashrc
   ↓
Personal Bash configuration

alias
   ↓
Shortcut

function
   ↓
Reusable command with arguments

export
   ↓
Environment variable

PATH
   ↓
Where Bash searches for commands

PS1
   ↓
Terminal prompt
```

## Essential Commands

```bash
nano ~/.bashrc
source ~/.bashrc

alias
alias ll='ls -lah'
unalias ll

export VAR="value"

echo $VAR
```
