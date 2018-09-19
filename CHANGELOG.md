# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Restructured module into a directory structure with one file per function separated per scope, public and private.
- Renamed Set-LineForward to Add-LineForward
- DirectoryCSS now optional in Add-LineForward
- Updated documentation

### Added
- This CHANGELOG file
- Added .gitignore
- Same directory precedence, use settings.xml or \*.cred in same directory if exists.
- Added Remove-LineForward function to toggle Voicemail forward or remove entire ForwardAll setting.

[Unreleased]: https://github.com/joshuanasiatka/CUCMPosh/compare/v0.0.1...HEAD
