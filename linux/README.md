# Linux Notes

This directory contains my Linux notes and command references.

## Learning Roadmap

### Phase 1: Linux Foundations 

* File system basics
* File operations
* Wildcards, paths, and hidden files
* Text processing (`cat`, `less`, `head`, `tail`, `wc`, `sort`, `uniq`, `cut`)
* `grep`, pipes, and redirection
* File permissions and ownership (`chmod`, `chown`, `umask`)
* Review + Mini Project (Log Analyzer)

### Phase 2: Shell Scripting Basics 

* First shell script (variables, `echo`, shebang)
* User input and arguments
* Conditionals
* Loops
* Functions and return values
* Arrays and string manipulation
* Review + Project (Verilog File Organizer)

### Phase 3: Terminal & Git Essentials 
 
* Git basics (`init`, `status`, `add`, `commit`, `log`)
* GitHub workflow (`clone`, `push`, `pull`, `.gitignore`)
* Branching and merging (`branch`, `checkout`, `merge`)
* Git utilities (`diff`, `stash`, `restore`, `reset`)
* `man`, `tldr`, and help commands
* Review + Project (Version Control an RTL Project)


### Phase 4: Advanced Shell & Linux

* Environment variables (`$PATH`, `$HOME`, `export`, `printenv`)
* Shell configuration (`.bashrc`, aliases, functions)
* Exit codes and error handling (`$?`, `set -e`, `trap`, `&&`, `||`)
* Advanced I/O (`stdin`, `stdout`, `stderr`, file descriptors)
* Here documents, here strings, command substitution, and subshells
* Regular expressions (`grep -E`, `sed`, `awk`)
* Review + Project (Simulation Automation Script)

### Phase 5: Linux for RTL Engineers

* Makefiles
* Verilog automation with Bash
* Icarus Verilog workflow
* GTKWave automation and waveform handling
* Yosys basics
* Build a complete RTL workflow script
* Project (One-command compile → simulate → open GTKWave)

###Week 6: NixOS + Hyprland

* Nix concepts (declarative config, store, generations)
* NixOS installation (graphical ISO or minimal, UEFI, partitioning)
* First config: users, sudo, networking, flakes enabled
* Nix package management (nix-shell, nix search, nix profile, garbage collection)
* Hyprland on NixOS (programs.hyprland.enable, waybar, wofi, kitty)
* Home Manager (dotfiles like .bashrc managed declaratively)
* VLSI tools via Nix (iverilog, gtkwave, verilator, yosys) plus a per-project flake.nix dev shell
* Put your NixOS config on GitHub and rebuild it from a fresh clone

### Phase 7: Productivity & Real Workflow

* Vim / Neovim
* tmux
* SSH and remote development
* Cron jobs
* Archive and compression (`tar`, `gzip`, `zip`)
* Final Project (Complete Linux Automation Toolkit)

## Projects I'll Build

* Verilog File Organizer
* One-Command RTL Workflow (build → simulate → open GTKWave)
* system usage dashboard system
* backup tracker
* local llm

These notes are based on what I learn while using Linux and will continue to grow as I improve my workflow.
