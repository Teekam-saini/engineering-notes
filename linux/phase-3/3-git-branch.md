# Day 11: Branching & Merging

## 1. What is a Git Branch?

A **branch** is a separate line of development that allows you to work on a feature or experiment without directly affecting `main`.

```text
main:     A → B → C →──────→ G
                    ↘      ↗
feature:              D → E → F
```

For VLSI projects, branches are useful for:

* Developing new RTL modules
* Trying different architectures
* Timing optimization experiments
* Bug fixes
* Keeping `main` stable

The basic idea:

```text
main = stable code
branch = work/experiment
```

---

## 2. Creating and Switching Branches

List branches:

```bash
git branch
```

Create a branch:

```bash
git branch feature-alu
```

Switch to a branch:

```bash
git switch feature-alu
```

Create and switch at the same time:

```bash
git switch -c feature-alu
```

Older equivalent:

```bash
git checkout -b feature-alu
```

### Recommended

Use `git switch` for branch operations because it is clearer than the older `checkout` command.

---

## 3. Basic Feature Branch Workflow

Suppose you want to add a multiplier without touching `main`:

```bash
git switch -c feature-multiplier
```

Make changes and commit:

```bash
git add multiplier.v
git commit -m "Add 8x8 multiplier"
```

Your branch now contains the new work while `main` remains unchanged.

Switch back:

```bash
git switch main
```

The multiplier changes will not be present in `main` until you merge the branch.

---

## 4. Merging

To merge a feature into `main`:

```bash
git switch main
git merge feature-multiplier
```

A merge combines the changes from the feature branch into the current branch.

### `--no-ff`

```bash
git merge --no-ff feature-multiplier
```

This forces a merge commit, making the feature branch visible in the history.

```text
main:     A → B → C ─────→ M
                    ↘     ↗
feature:              D → E
```

This can make project history easier to understand, especially for larger projects.

---

## 5. Deleting Branches

After successfully merging:

```bash
git branch -d feature-multiplier
```

This safely deletes the local branch.

To force-delete an unmerged branch:

```bash
git branch -D feature-multiplier
```

Use `-D` carefully because it can remove a branch containing work that hasn't been merged.

---

## 6. Experiment Branches

Branches are especially useful for trying risky RTL changes.

For example:

```bash
git switch -c experiment-pipelined-alu
```

Modify and test the ALU:

```bash
git add alu.v
git commit -m "Experiment with pipelined ALU"
```

If the experiment fails:

```bash
git switch main
git branch -D experiment-pipelined-alu
```

`main` remains unchanged.

If it works:

```bash
git switch main
git merge --no-ff experiment-pipelined-alu
git branch -d experiment-pipelined-alu
```

---

## 7. Merge Conflicts

A **merge conflict** occurs when Git cannot automatically combine changes.

For example:

```text
main:
    result = a + b;

feature:
    result = a - b;
```

If both branches changed the same section, Git may produce:

```text
<<<<<<< HEAD
result = a + b;
=======
result = a - b;
>>>>>>> feature
```

You must manually decide what the final code should contain.

After fixing the file:

```bash
git add alu.v
git commit -m "Resolve ALU merge conflict"
```

### Conflict resolution workflow

```text
Merge
  ↓
Conflict
  ↓
Edit conflicted files
  ↓
Remove conflict markers
  ↓
git add
  ↓
git commit
```

Do not blindly keep one side just because Git is yelling at you. In RTL, that can turn a merge conflict into a hardware bug.

---

## 8. Branches on GitHub

Push a feature branch:

```bash
git push -u origin feature-decoder
```

The branch will then appear on GitHub.

After merging into `main`:

```bash
git switch main
git push
```

Delete the remote branch:

```bash
git push origin -d feature-decoder
```

---

## 9. Viewing Branches and History

List local branches:

```bash
git branch
```

List local and remote branches:

```bash
git branch -a
```

View commit graph:

```bash
git log --oneline --graph --all
```

View branches associated with commits:

```bash
git log --oneline --decorate
```

The most useful command for understanding project history is:

```bash
git log --oneline --graph --all
```

---

## 10. Branch Naming

Use descriptive names.

Good:

```text
feature-uart
feature-register-file
fix-counter-overflow
experiment-pipelined-alu
hotfix-reset-logic
```

Bad:

```text
test
new
branch2
fix
abc
```

A branch name should tell you what the branch is for.

---

## 11. Git Branch Questions

### Q1. Does creating a branch copy the entire project?

Not in the simple sense of creating another independent folder full of duplicate files.

A branch is essentially a movable reference to commits in Git's history.

This makes branching lightweight and fast.

---

### Q2. Does a branch affect `main`?

No.

Changes committed to another branch do not affect `main` until you merge them.

```text
feature branch → changes stay there

main → remains unchanged
```

---

### Q3. What happens when I delete a branch?

Deleting a branch removes the branch reference. It does not automatically delete commits that are still reachable through other references.

If the branch contains unmerged commits and no other reference points to them, those commits can eventually become unreachable.

Therefore, don't use:

```bash
git branch -D
```

carelessly.

---

### Q4. Why keep `main` stable?

Because `main` should represent a known-good version of the project.

For an RTL project:

```text
main
 ↓
Known working RTL

feature branch
 ↓
Experimental/new RTL
```

This prevents unfinished experiments from breaking the main project.

---

## 12. Recommended VLSI Workflow

```text
main
 ↓
Create feature branch
 ↓
Develop RTL
 ↓
Simulate / verify
 ↓
Commit changes
 ↓
Review
 ↓
Merge into main
 ↓
Delete feature branch
```

Example:

```bash
git switch main
git pull

git switch -c feature-register-file

# Develop and test RTL

git add .
git commit -m "Add register file"

git switch main
git merge --no-ff feature-register-file

git push

git branch -d feature-register-file
```

---

## 13. Key Commands

```bash
# Branches
git branch
git switch branch-name
git switch -c branch-name

# Merge
git switch main
git merge branch-name
git merge --no-ff branch-name

# Delete
git branch -d branch-name
git branch -D branch-name

# History
git log --oneline --graph --all

# GitHub
git push -u origin branch-name
git push origin -d branch-name
```

## Golden Rule

> **Keep `main` stable. Develop features and experiments in separate branches, test them, then merge them into `main`.**

For your VLSI work, this becomes especially useful once you start building larger projects such as a RISC-V processor, where you might have separate branches for the ALU, register file, pipeline, hazard unit, cache, and verification work.
