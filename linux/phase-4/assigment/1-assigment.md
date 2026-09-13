Assignment 1: Personal Alias Collection

Add at least 15 aliases to your .bashrc:

5 navigation aliases
5 git aliases
5 VLSI/general aliases
Test each one works after source ~/.bashrc
Assignment 2: Function Library

Add these 5 functions to your .bashrc:

mkcd dirname — make directory and cd into it
gcm "message" — git add all and commit with message
backup filename — create timestamped backup
findv pattern — find .v files containing pattern (use grep -r)
newmodule name — create a new .v file with basic module template
Assignment 3: Custom Prompt

Set up a custom PS1 that shows:

Username in green
Current directory in blue
Git branch in yellow (when in a git repo)
$ in white
Test it by navigating to your git repo and a non-git directory
Assignment 4: Environment Setup

Add to .bashrc:

EDITOR=nano
HISTSIZE=10000
HISTCONTROL=ignoredups:erasedups
HISTTIMEFORMAT="%d/%m/%y %T "
Your scripts/ directory permanently in PATH
A variable VLSI_ROOT pointing to your project directory
