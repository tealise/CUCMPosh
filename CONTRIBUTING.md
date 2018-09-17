# CUCMPosh Contributing Guide

Hi! I’m really excited that you are interested in contributing to CUCMPosh. Before submitting your contribution though, please make sure to take a moment and read through the following guidelines.

- [Issue Reporting Guidelines](#issue-reporting-guidelines)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Development Setup](#development-setup)

## Issue Reporting Guidelines

- Always use [http://github.com/joshuanasiatka/CUCMPosh/issues/](http://github.com/joshuanasiatka/CUCMPosh/issues/) to create new issues.

## Pull Request Guidelines

- The `master` branch is basically just a snapshot of the latest stable release. All development should be done in dedicated branches. **Do not submit PRs against the `master` branch.**

- Checkout a topic branch from the relevant branch, e.g. `dev`, and merge back against that branch.

- It's OK to have multiple small commits as you work on the PR - we will let GitHub automatically squash it before merging.

- If adding new feature:
  - Add accompanying test case.
  - Provide convincing reason to add this feature. Ideally you should open a suggestion issue first and have it greenlighted before working on it.


- If fixing a bug:
  - If you are resolving a special issue, add `(fix #xxxx[,#xxx])` (#xxxx is the issue id) in your PR title for a better release log, e.g. `update entities encoding/decoding (fix #3899)`.
  - Provide detailed description of the bug in the PR. Live demo preferred.
  - Add appropriate test coverage if applicable.

## Development Setup

I recommend having minimum version 3.0 of PowerShell, preferably 5.0 or later. Scripts and module should also be tested against CUCM 10.x or later.

Recommended Editor/IDE:
 - [Atom](https://atom.io/) with extensions:  
   - [editorconfig](https://atom.io/packages/editorconfig)
   - [language-powershell](https://atom.io/packages/language-powershell)
 - [VisualStudio Code](https://code.visualstudio.com/)

Atom extensions can be installed via `apm` commands:
```powershell
apm install editorconfig
apm install language-powershell
```

## Code Style

We use a different variant of Stroustrup's style in order to create clean and readable code.

Defining Variables, Loops, and Arrays:
```powershell
# Line up declarations at the top
$variable  = 'Correct'
$array     = @(
    'array_value_one',
    'array_value_two'
)
$dict      = @{
    'key1' = 'value1'
    'key2' = 'value2'
    'key3' = 'value3'
}
$variableCamelCase = 'Correct'

# For Loops
foreach ($item in $array) {
    Write-Host $item
}

$object | ?{ <# where condition #> }
        | %{ <# foreach item, do something #> }
```

### .editorconfig

```editorconfig
root = true

# Windows-style newlines with a newline ending every file
[*]
end_of_line = crlf
insert_final_newline = false

# Matches multiple files with brace expansion notation
# Set default charset
[*.{psm1,ps1,cs,cshtml}]
charset = utf-8
indent_style = tab
indent_size = 4
trim_trailing_whitespace = true
```

## Resources
- [Cisco AXL Developer Guide](https://developer.cisco.com/docs/axl/#!12-0-axl-developer-guide/overview)
- [Cisco AXL Schema Documentation](https://developer.cisco.com/docs/axl-schema-reference/)
