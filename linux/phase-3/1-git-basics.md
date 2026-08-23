# Day 9: Git Basics

## 1. What is Git?

**Git** is a distributed version control system used to track changes in files and maintain the history of a project.

It allows you to:

* Track every important change made to a project.
* Restore previous versions of files.
* Experiment safely using branches.
* Compare changes between different versions.
* Collaborate with other developers.
* Maintain a clean history of an engineering project.
* Publish and manage projects through platforms such as GitHub.

For RTL/VLSI development, Git is particularly useful because projects contain many source files, testbenches, scripts, constraints, configuration files, and documentation.

### Why do engineers need Git?

Without version control, a project can quickly become a mess:

```text
design.v
design_v2.v
design_v2_final.v
design_v2_final_fixed.v
design_v2_final_fixed_REAL.v
```

Git eliminates this kind of file-management nonsense by keeping the versions in one repository.

### Git for RTL/VLSI projects

Git can be used to:

* Track RTL design changes.
* Revert a design when a modification introduces a bug.
* Maintain different design experiments using branches.
* Track changes to testbenches and verification environments.
* Maintain synthesis and simulation scripts.
* Collaborate with other engineers.
* Showcase projects on GitHub.

For example, if an ALU worked correctly yesterday but fails after today's modification, Git allows you to inspect the changes and restore the previous implementation.

---

## 2. How Git Works

The most important mental model is:

```text
Working Directory
       |
       | git add
       v
Staging Area
       |
       | git commit
       v
Repository
```

These are three different states.

### Working Directory

This is the actual directory containing the files you are currently editing.

For example:

```text
rtl_project/
├── alu.v
├── counter.v
└── tb_counter.v
```

If you modify `alu.v`, the change initially exists only in the working directory.

---

### Staging Area

The staging area contains changes that you have selected for the next commit.

```bash
git add alu.v
```

Now the changes in `alu.v` are staged.

The important point is that `git add` does **not** create a permanent save in Git history.

It only tells Git:

> "Include this version of the file in my next commit."

---

### Repository

The repository contains Git's recorded history.

```bash
git commit -m "Fix ALU subtraction logic"
```

The commit creates a permanent snapshot in the repository history.

A simplified workflow is:

```text
Edit file
   ↓
Working Directory
   ↓ git add
Staging Area
   ↓ git commit
Repository
```

This distinction between **working directory → staging area → repository** is one of the most important concepts in Git.

---

# 3. Basic Git Configuration

Git needs your identity so that commits can record who created them.

```bash
git config --global user.name "Teekam"
git config --global user.email "your@email.com"
```

You can check the configuration with:

```bash
git config --list
```

You can also configure the default text editor:

```bash
git config --global core.editor nano
```

These settings normally only need to be configured once per system.

---

# 4. `git init`

`git init` creates a new Git repository.

```bash
git init
```

This initializes Git in the current directory.

You can also initialize a repository in a new directory:

```bash
git init project_name
```

This creates the directory and initializes it as a Git repository.

### What does `git init` actually create?

Git creates a hidden directory:

```text
.git/
```

The `.git` directory contains the repository's internal information, including its history, references, configuration, and other metadata.

Do **not** manually modify the contents of `.git` unless you know exactly what you are doing. Git is surprisingly tolerant until it suddenly isn't.

---

# 5. `git status`

`git status` shows the current state of your working directory and staging area.

```bash
git status
```

It can tell you about:

* Untracked files
* Modified files
* Staged files
* The current branch
* Changes that are ready to commit

For example:

```text
Untracked files:
    counter.v

Changes not staged for commit:
    alu.v

Changes to be committed:
    regfile.v
```

These mean:

### Untracked

```text
counter.v
```

Git has detected the file, but it is not currently tracked.

### Modified but unstaged

```text
alu.v
```

Git already knows about the file, but its latest changes have not been staged.

### Staged

```text
regfile.v
```

The current changes have been added to the staging area and will be included in the next commit.

### Important rule

`git status` is one of the commands you should use constantly.

When you are unsure what Git thinks is happening:

```bash
git status
```

---

# 6. `git add`

`git add` moves changes from the working directory into the staging area.

### Stage one file

```bash
git add alu.v
```

### Stage multiple files

```bash
git add alu.v counter.v
```

### Stage all changes in the current directory

```bash
git add .
```

### Interactive staging

```bash
git add -p
```

This allows you to select individual portions of a file for staging.

This is useful when a file contains multiple unrelated changes and you want them separated into different commits.

### Important distinction

```bash
git add
```

does **not** mean:

> Save permanently.

It means:

> Prepare these changes for the next commit.

---

# 7. `git commit`

A commit records the staged changes in the repository history.

```bash
git commit -m "Add 8-bit counter"
```

A commit should represent a meaningful logical change.

### Good commit messages

```bash
git commit -m "Add 8-bit counter with synchronous reset"
```

```bash
git commit -m "Fix ALU subtraction logic"
```

```bash
git commit -m "Add testbench for register file"
```

### Bad commit messages

```bash
git commit -m "fix"
```

```bash
git commit -m "changes"
```

```bash
git commit -m "asdfgh"
```

The future version of you will eventually have to understand these commits. Future you deserves better than `asdfgh`.

---

# 8. What Makes a Good Commit?

A good commit should contain **one logical change**.

Good:

```text
Add 8-bit counter module
```

Then:

```text
Fix counter reset logic
```

Then:

```text
Add counter testbench
```

Bad:

```text
Add counter, modify ALU, fix testbench, change scripts, update README
```

The second approach makes debugging history much harder.

### Golden rule

> **Commit early, commit often, commit logically.**

A commit should ideally answer:

> "What changed in this commit?"

---

# 9. `git log`

`git log` displays commit history.

```bash
git log
```

This shows detailed information about commits, including:

* Commit hash
* Author
* Date
* Commit message

### Compact history

```bash
git log --oneline
```

Example:

```text
a3f9c12 Add counter testbench
7b21d88 Fix counter reset logic
42c8e11 Add 8-bit counter
```

The first part is the shortened commit hash.

### Graph view

```bash
git log --oneline --graph
```

This becomes especially useful when working with branches.

### Show only recent commits

```bash
git log -5
```

This displays the five most recent commits.

---

# 10. Git Commit Hash

Every commit receives a unique identifier called a **commit hash**.

Example:

```text
a3f9c12
```

The full hash is much longer, but Git often allows the shortened form when it is unambiguous.

A commit hash allows you to refer to a specific point in project history.

For example:

```bash
git show a3f9c12
```

---

# 11. Viewing Changes with `git diff`

`git diff` shows differences between versions of files.

### View unstaged changes

```bash
git diff
```

Or for one file:

```bash
git diff counter.v
```

This compares the working directory with the staged version.

### View staged changes

```bash
git diff --staged
```

This shows the changes that are currently staged and will be included in the next commit.

The distinction is:

```text
git diff
        ↓
Working Directory vs Staging Area

git diff --staged
        ↓
Staging Area vs Last Commit
```

This is extremely useful before committing.

---

# 12. Undoing Changes

Git provides several ways to undo changes, and the exact command matters.

## Unstage a file

```bash
git restore --staged filename.v
```

This removes the file from the staging area.

It does **not** delete the changes from your working directory.

Example:

```text
Before:

Working Directory
       ↓
Staging Area
       ↓
Repository

After git restore --staged:

Working Directory
       ↓
Staging Area
       ↓
Repository
```

The changes remain in the working directory.

---

## Discard unstaged changes

```bash
git restore filename.v
```

This restores the file to the version recorded in the index/last committed state, discarding its current unstaged changes.

This can permanently destroy work that has not been committed or otherwise saved.

Use it carefully.

---

# 13. Viewing an Older Version of a File

Suppose the repository contains:

```text
a3f9c12
```

You can inspect the contents of a specific file from that commit:

```bash
git show a3f9c12:counter.v
```

This **does not modify your current file**.

It simply displays what `counter.v` looked like at that commit.

This is useful when investigating when or how a design changed.

---

# 14. `.gitignore`

Not every file in a project should be tracked by Git.

For RTL projects, generated files such as simulation outputs, waveform files, logs, and build directories usually should not be committed.

A `.gitignore` file tells Git which files or directories to ignore.

Example:

```gitignore
# Simulation outputs
*.out
*.vcd
*.lxt

# Log files
*.log

# Editor temporary files
*.swp
*~
.DS_Store

# Build directories
build/
sim_output/
```

Then:

```bash
git add .gitignore
git commit -m "Add Git ignore rules for generated files"
```

### Why ignore generated files?

Consider an RTL project:

```text
rtl/
├── alu.v
├── counter.v
├── tb_counter.v
├── simulation.vcd
├── simulation.log
└── build/
```

The source files are important.

The generated waveform, log, and build files can usually be regenerated.

Therefore:

```text
Source code      → Track
Testbench        → Track
Scripts          → Track
Documentation    → Track
Generated output → Usually ignore
```

---

# 15. Git and RTL Project Structure

A typical RTL repository might look like:

```text
rtl-project/
├── rtl/
│   ├── alu.v
│   ├── counter.v
│   └── register_file.v
│
├── tb/
│   ├── tb_alu.v
│   └── tb_counter.v
│
├── scripts/
│   └── run_sim.sh
│
├── docs/
│   └── architecture.md
│
├── .gitignore
└── README.md
```

Git can track all of the important source material while ignoring generated files such as:

```text
*.vcd
*.log
*.out
build/
sim_output/
```

This keeps the repository clean.

---

# 16. Git Workflow

The basic workflow for normal development is:

```text
1. Modify files
       ↓
2. git status
       ↓
3. git diff
       ↓
4. git add
       ↓
5. git diff --staged
       ↓
6. git commit
       ↓
7. git log
```

In commands:

```bash
git status
git diff
git add filename.v
git diff --staged
git commit -m "Descriptive message"
git log --oneline
```

You do not necessarily need every command every time, but understanding this workflow prevents a lot of stupid mistakes.

---

# 17. Important Git Concepts

### Repository

A directory managed by Git.

### Working Directory

The files you are currently working on.

### Staging Area

The changes selected for the next commit.

### Commit

A recorded snapshot of staged changes.

### Commit Hash

The unique identifier of a commit.

### Branch

An independent line of development within a repository.

Branches become particularly useful when experimenting with different RTL implementations.

### `.gitignore`

A file containing patterns for files Git should ignore.

---

# 18. Common Questions

## Q1. Why do I need `git add` before `git commit`?

Because Git separates selecting changes from recording them.

```text
Working Directory
       ↓ git add
Staging Area
       ↓ git commit
Repository
```

This lets you choose exactly which changes belong in a commit.

For example, suppose you changed both:

```text
alu.v
counter.v
```

but only want to commit the ALU change:

```bash
git add alu.v
git commit -m "Fix ALU arithmetic logic"
```

The counter changes remain unstaged.

---

## Q2. Is `git commit` the same as saving a file?

No.

Saving a file with your editor changes the working directory.

```text
Ctrl + S
```

Git does not automatically record that change.

A Git commit is a recorded snapshot in the repository:

```bash
git add alu.v
git commit -m "Fix ALU logic"
```

So:

```text
Save file ≠ Git commit
```

---

## Q3. What is the difference between `git add` and `git commit`?

`git add`:

```text
Working Directory → Staging Area
```

`git commit`:

```text
Staging Area → Repository History
```

Therefore:

```bash
git add alu.v
```

prepares the change.

```bash
git commit -m "Fix ALU"
```

records it in Git history.

---

## Q4. Why should commits be small and logical?

Because Git history is also a debugging tool.

Suppose a processor worked correctly until commit:

```text
7f21abc
```

You can inspect that commit and determine what changed.

If one commit contains twenty unrelated modifications, identifying the problem becomes much harder.

Small logical commits make debugging, collaboration, review, and rollback easier.

---

## Q5. Can Git restore an old version of my project?

Yes.

Git stores the history of committed changes, so previous versions can be inspected and restored.

For example:

```bash
git log --oneline
```

Find a commit:

```text
a3f9c12 Add working ALU
```

Then inspect a file:

```bash
git show a3f9c12:alu.v
```

Git can also be used to restore older states, although commands such as `git restore`, `git reset`, and `git revert` have different purposes and should not be treated as interchangeable.

---

## Q6. What happens if I modify a file after committing it?

The repository still contains the committed version.

The new modification exists in the working directory.

For example:

```text
Repository:
    counter.v → old version

Working Directory:
    counter.v → modified version
```

You can see the difference with:

```bash
git diff counter.v
```

If you want the new version recorded:

```bash
git add counter.v
git commit -m "Update counter logic"
```

---

## Q7. What happens if I delete a file accidentally?

If the file was previously committed, Git can often recover it because the previous version exists in the repository history.

This is one of the major advantages of version control.

However, Git is not a magical backup system. Uncommitted work can still be lost, and deleted or corrupted repository history is not automatically recoverable.

---

## Q8. Why shouldn't generated files usually be committed?

Generated files can be recreated from the source code.

For example:

```text
counter.v
```

is source code and should normally be tracked.

A waveform:

```text
counter.vcd
```

is generated output and can normally be regenerated by simulation.

Tracking thousands of generated files makes repositories unnecessarily large and difficult to manage.

---

## Q9. Does GitHub replace Git?

No.

Git and GitHub are different things.

**Git** is the version control system.

**GitHub** is a platform that hosts Git repositories and provides additional collaboration features.

Conceptually:

```text
Git
 ↓
Version control on your computer

GitHub
 ↓
Remote hosting + collaboration
```

You can use Git without GitHub.

---

## Q10. Does Git automatically save every change?

No.

Git only records changes when you commit them.

The normal sequence is:

```bash
git add
git commit
```

If you modify a file but never commit it, that change is not part of the repository's permanent history.

---

# 19. Git Commands to Memorize

```bash
git init
```

Initialize a repository.

```bash
git status
```

Check the current state of the repository.

```bash
git add filename
```

Stage a file.

```bash
git add .
```

Stage changes in the current directory.

```bash
git commit -m "message"
```

Create a commit.

```bash
git log --oneline
```

View compact commit history.

```bash
git diff
```

View unstaged changes.

```bash
git diff --staged
```

View staged changes.

```bash
git restore --staged filename
```

Unstage a file.

```bash
git restore filename
```

Discard unstaged changes in a file.

```bash
git show <commit>:<file>
```

View a specific file from a particular commit.

---

# 20. Essential Mental Model

Remember Git as:

```text
                git add
Working -----------------> Staging
Directory                   Area
                              |
                              | git commit
                              v
                         Repository
                            History
```

And remember the purpose of each stage:

```text
Working Directory
    = What I am currently editing

Staging Area
    = What I want in my next commit

Repository
    = What I have permanently recorded
```

---

# 21. Key Takeaways

* Git is a version control system.
* A Git repository stores project history.
* `git init` creates a repository.
* `git status` shows the current state.
* `git add` stages changes.
* `git commit` records staged changes.
* `git log` shows commit history.
* `git diff` shows unstaged changes.
* `git diff --staged` shows staged changes.
* `git restore --staged` unstages changes.
* `git restore` can discard unstaged changes.
* `git show` can inspect files from previous commits.
* `.gitignore` prevents unwanted files from being tracked.
* Commits should represent logical changes.
* Git and GitHub are not the same thing.
* Git is especially valuable for RTL because design changes, experiments, testbenches, scripts, and verification code need a reliable history.

## Golden Rule

> **Commit early, commit often, commit logically.**
