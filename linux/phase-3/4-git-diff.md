# Day 12: Git Utilities

These commands help you inspect changes, temporarily save unfinished work, undo mistakes, and manage Git history.

---

## 1. `git diff` — See Changes

Shows differences between versions of your files.

```bash
git diff                    # Unstaged changes
git diff --staged           # Staged changes
git diff HEAD               # All changes since last commit
git diff commit1 commit2    # Compare two commits
git diff branch1 branch2    # Compare branches
git diff filename           # Changes in one file
```

Example:

```diff
-    if (rst) count <= 0;
+    if (rst) count <= 8'b0;
```

`-` = removed
`+` = added

### Important

```text
git diff
      ↓
Working Directory vs Staging Area

git diff --staged
      ↓
Staging Area vs Last Commit
```

---

## 2. `git stash` — Temporarily Save Work

`git stash` temporarily stores uncommitted changes so your working directory becomes clean.

Useful when:

* You are halfway through a feature.
* You need to switch branches.
* You need to work on an urgent bug.
* You are not ready to commit your current changes.

### Commands

```bash
git stash                    # Save current changes
git stash list               # Show stashes
git stash pop                # Restore latest stash and remove it
git stash apply              # Restore latest stash but keep it
git stash apply stash@{2}    # Apply specific stash
git stash drop stash@{0}     # Delete a stash
git stash clear              # Delete all stashes
```

Add a description:

```bash
git stash push -m "ALU work in progress"
```

Include untracked files:

```bash
git stash -u
```

### Basic workflow

```text
Unfinished work
      ↓
git stash
      ↓
Clean working directory
      ↓
Do other work
      ↓
git stash pop
      ↓
Continue unfinished work
```

---

## 3. `git restore` — Undo Working Changes

`git restore` is mainly used to restore files or unstage changes.

### Unstage a file

```bash
git restore --staged filename
```

This removes the file from staging but **keeps your modifications**.

### Discard changes

```bash
git restore filename
```

This restores the file to its last committed version.

**Be careful:** your uncommitted changes are discarded.

Discard changes in all files:

```bash
git restore .
```

### Restore from a specific commit

```bash
git restore --source=HEAD~1 counter.v
```

---

## 4. `git reset` — Move the Branch Back

`git reset` moves the current branch/`HEAD` to another commit.

It can also affect the staging area and working directory depending on the option used.

### Three important modes

```bash
git reset --soft HEAD~1
git reset --mixed HEAD~1
git reset --hard HEAD~1
```

### `--soft`

```bash
git reset --soft HEAD~1
```

* Removes the last commit from the current branch history.
* Keeps its changes staged.

```text
Before:
A → B → C

After:
A → B
      ↑ HEAD

C's changes → Staged
```

Useful when you want to redo a commit.

### `--mixed`

```bash
git reset --mixed HEAD~1
```

* Removes the last commit.
* Keeps the changes.
* Changes become unstaged.

`--mixed` is the default mode.

### `--hard`

```bash
git reset --hard HEAD~1
```

* Removes the commit from the current branch history.
* Discards associated working/staging changes.

**Dangerous.**

```text
Before:
A → B → C

After:
A → B

C's changes → discarded
```

---

## 5. `restore` vs `reset` vs `revert`

This is the part worth actually remembering.

| Command       | Main purpose                                      |
| ------------- | ------------------------------------------------- |
| `git restore` | Restore files / unstage changes                   |
| `git reset`   | Move branch history backward                      |
| `git revert`  | Create a new commit that undoes an earlier commit |

### Example

Accidentally staged a file:

```bash
git restore --staged file.v
```

Bad commit that has **not been pushed**:

```bash
git reset --soft HEAD~1
```

Bad commit that has **already been pushed**:

```bash
git revert HEAD
git push
```

For shared/public branches, `git revert` is generally safer because it doesn't rewrite existing history.

---

## 6. Viewing History

Show details of a commit:

```bash
git show HEAD
git show a3f9c12
```

See a file from an earlier commit:

```bash
git show HEAD~1:counter.v
```

See who last changed each line:

```bash
git blame counter.v
```

Search commit messages:

```bash
git log --oneline --grep="counter"
git log --oneline --grep="fix"
```

See commits affecting a specific file:

```bash
git log --oneline -- counter.v
```

---

## 7. Recovery Scenario

If you accidentally break your working directory:

First inspect:

```bash
git status
git diff
git log --oneline
```

If you want to preserve your current work:

```bash
git stash
```

If you simply want to discard uncommitted changes:

```bash
git restore .
```

If you need to move the branch back to a known commit:

```bash
git reset --hard <commit>
```

Use the last option carefully. Git is very forgiving right up until you tell it to throw your work into the void.

---

## 8. Important Questions

### What is the difference between `git diff` and `git status`?

```text
git status
→ What files changed/staged/untracked?

git diff
→ Exactly what lines changed?
```

Use `status` for the overview and `diff` for the details.

---

### Does `git stash` create a commit?

Not a normal commit on your branch.

It stores your uncommitted changes in Git's stash mechanism so you can restore them later.

---

### Does `git restore file` delete my commit?

No.

It only changes the working file. Your committed history remains unchanged.

---

### Does `git reset` delete commits?

It moves the branch pointer backward, making commits after the target commit no longer part of that branch's current history.

The commits may still be recoverable for some time through Git's reflog, but don't treat that as a safety net.

---

### Which is safer: `reset` or `revert`?

For commits that are already shared/pushed:

```text
git revert → safer
git reset  → potentially disruptive
```

`reset` rewrites the branch history, while `revert` adds a new commit that reverses the old one.

---

## 9. Danger Levels

```text
git diff
    ↓
Safe: only inspects changes

git stash
    ↓
Generally safe and reversible

git restore
    ↓
Careful: can discard uncommitted work

git reset --soft
    ↓
Usually safe for local history

git reset --mixed
    ↓
Careful

git reset --hard
    ↓
DANGEROUS: can discard work
```

---

## 10. Key Commands

```bash
# Inspect
git diff
git diff --staged
git diff HEAD

# Stash
git stash
git stash list
git stash pop
git stash apply

# Restore
git restore file
git restore --staged file

# Reset
git reset --soft HEAD~1
git reset --mixed HEAD~1
git reset --hard HEAD~1

# Undo a pushed commit
git revert HEAD

# History
git show HEAD
git blame file
git log --oneline -- file
```

## Core Mental Model

```text
git diff
→ See what changed

git stash
→ Temporarily hide unfinished work

git restore
→ Restore files / unstage changes

git reset
→ Move local branch history

git revert
→ Safely undo a committed change with a new commit
```

**Rule to remember:** when you're unsure what to do, inspect first with `git status` and `git diff`. If the work is valuable but unfinished, `git stash` is usually safer than randomly throwing `reset --hard` at the problem.
