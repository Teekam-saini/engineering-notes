# Verilog File Organizer

## Objective

Create **`organize_rtl.sh`**, a Bash utility that scans a Verilog project, classifies source files, validates them, generates a summary report, and optionally organizes valid files into separate directories.

This project simulates a simple automation tool commonly used in RTL design and verification workflows.

---

# Requirements

Implement **`organize_rtl.sh`** with the following functionality.

## 1. File Discovery

- Scan the current directory for all `.v` files.
- Store the filenames in an array.

---

## 2. File Classification

Implement the following helper functions:

### `is_testbench(filename)`

- Return success (`0`) if the filename begins with `tb_`.
- Otherwise return failure (`1`).

### `get_basename(filename)`

- Remove the `.v` extension from the filename.

Separate the discovered files into:

- `rtl_files`
- `testbench_files`

---

## 3. File Validation

Implement:

```bash
validate_file(filename)
```

The function should verify:

- The file is not empty (`-s`).
- The file contains the keyword `module`.

Return:

- `0` if the file is valid.
- `1` otherwise.

Maintain separate arrays for valid and invalid files.

---

## 4. Report Generation

Generate a formatted report similar to:

```text
=================================
VERILOG PROJECT ORGANIZER REPORT
=================================
Total files scanned: X

RTL Modules (N):
  - module1.v
  - module2.v

Testbenches (M):
  - tb_module1.v

INVALID FILES (K):
  - broken_module.v
  - notes.v

Validation Summary:
  Valid: X
  Invalid: Y
=================================
```

The report should include:

- Total files scanned
- RTL modules
- Testbench files
- Invalid files
- Validation summary

---

## 5. File Organization

Prompt the user:

```text
Move files into organized folders? (y/n)
```

If the answer is **yes**:

- Create `rtl/` and `testbench/` directories if they do not already exist.
- Move valid RTL files into `rtl/`.
- Move valid testbench files into `testbench/`.
- Leave invalid files in the current directory for manual review.

---

# Suggested Implementation Order

1. Implement the helper functions.
2. Discover all Verilog files.
3. Classify the files.
4. Validate each file.
5. Generate the report.
6. Add the interactive file organization feature.

---

# Edge Cases

Your script should correctly handle:

- Empty Verilog files.
- Files that do not contain the `module` keyword.
- Correct identification of RTL modules and testbenches.
- Existing `rtl/` and `testbench/` directories.
- Projects containing only RTL files or only testbench files.
```