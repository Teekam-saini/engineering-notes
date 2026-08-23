# Day 10: GitHub Workflow

## 1. Git vs GitHub

```text
Git     = Version control system that runs locally
GitHub  = Online platform for hosting Git repositories
```

Git works without GitHub. GitHub provides remote storage, collaboration, code review, and project hosting.

---

## 2. Local vs Remote Repository

```text
Local Repository  ←── pull ──  GitHub
       │
       └── push ─────────────→ GitHub
```

* `git push` → Send commits to GitHub
* `git pull` → Get changes from GitHub
* `git clone` → Download a repository for the first time

---

## 3. SSH Authentication

SSH lets Git connect to GitHub using SSH keys.

Generate a key:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

Files created:

```text
~/.ssh/id_ed25519       # Private key
~/.ssh/id_ed25519.pub   # Public key
```

Never share the private key.

View the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add the public key in:

```text
GitHub → Settings → SSH and GPG keys → New SSH key
```

Test the connection:

```bash
ssh -T git@github.com
```

---

## 4. Git Remotes

A remote connects your local repository to GitHub.

```bash
git remote add origin git@github.com:username/repo.git
```

Check remotes:

```bash
git remote -v
```

Remove a remote:

```bash
git remote remove origin
```

`origin` is simply the conventional name for the main remote.

---

## 5. `git push`

Send local commits to GitHub:

```bash
git push origin main
```

First push:

```bash
git push -u origin main
```

After setting the upstream:

```bash
git push
```

Remember:

```text
git commit → saves changes in local Git history
git push   → sends those commits to GitHub
```

---

## 6. `git pull`

Get changes from GitHub:

```bash
git pull
```

Or:

```bash
git pull origin main
```

A good habit is:

```text
git pull
↓
work
↓
commit
↓
git push
```

If GitHub contains commits that your local repository doesn't have, Git may reject your push until you integrate those changes.

---

## 7. `git clone`

Download an existing GitHub repository:

```bash
git clone git@github.com:username/repo.git
```

Using HTTPS:

```bash
git clone https://github.com/username/repo.git
```

Specify a directory:

```bash
git clone <url> my-project
```

### Clone vs Pull

```text
git clone
GitHub → New local repository

git pull
GitHub → Existing local repository
```

---

## 8. Connecting an Existing Repository to GitHub

If you already have a local Git repository:

```bash
git remote add origin git@github.com:username/vlsi-rtl-practice.git
git remote -v
git push -u origin main
```

Your existing commits will then be pushed to GitHub.

---

## 9. README.md

A good repository should have a `README.md`.

Example:

```md
# VLSI RTL Practice

Collection of RTL designs and verification projects.

## Modules

- `adder.v` - Basic adder
- `counter.v` - 8-bit counter
- `alu.v` - 32-bit ALU

## Tools

- Icarus Verilog
- GTKWave
- Yosys
```

Add and push it:

```bash
git add README.md
git commit -m "Add project README"
git push
```

---

## 10. `.gitignore`

Use `.gitignore` to prevent generated files from being tracked.

Example:

```gitignore
*.out
*.vcd
*.log
*.lxt
build/
sim_output/
```

Important: `.gitignore` only affects files that are not already tracked. If a file has already been committed, adding it to `.gitignore` does not stop tracking it.

---

## 11. Common Problems

### Push rejected

```bash
git push
```

If the remote has changes you don't have:

```bash
git pull
git push
```

You may need to resolve conflicts if both sides changed the same parts.

### Check current branch

```bash
git branch
```

Switch to `main`:

```bash
git switch main
```

---

## 12. GitHub Workflow for RTL Projects

```text
git pull
   ↓
Modify RTL
   ↓
Simulate / Test
   ↓
git status
   ↓
git diff
   ↓
git add
   ↓
git commit
   ↓
git push
```

For example:

```bash
git pull

# Modify and test your Verilog

git status
git diff

git add counter.v
git commit -m "Fix counter reset logic"

git push
```

---

## 13. GitHub for VLSI

GitHub is useful for storing and showcasing:

* Verilog/SystemVerilog RTL
* Testbenches
* RISC-V processors
* FPGA projects
* Verification projects
* Linux scripts
* Automation tools
* Documentation

It can also help you study real open-source projects.

For example:

```bash
git clone https://github.com/YosysHQ/yosys.git
```

Then inspect:

```bash
cd yosys
git log --oneline
git log --oneline --graph
```

---

## 14. Important Commands

```bash
# Remote
git remote add origin <url>
git remote -v

# GitHub
git push
git push -u origin main
git pull
git clone <url>

# SSH
ssh-keygen -t ed25519 -C "email"
ssh -T git@github.com
```

---

## 15. Key Takeaways

```text
Git      → Local version control
GitHub   → Remote hosting

clone    → Download repository for first time
pull     → Get remote changes
push     → Send local commits
commit   → Save changes in Git history
remote   → Connection to GitHub
```

### Daily workflow

```bash
git pull
git status
git diff
git add .
git commit -m "Meaningful message"
git push
```

**Core idea:**

```text
Working Directory
        ↓ git add
Staging Area
        ↓ git commit
Local Repository
        ↓ git push
GitHub
```

Next: **Git Branching & Merging**.
