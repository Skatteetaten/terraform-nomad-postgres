# Changelog

## [0.3.0 UNRELEASED]

### Added
- Added switch for canary deplyment #44

### Changed
- Removed box example [no issue]
- Updated README with intentions section #46
- Proper rendering of credentials #45

## [0.2.0]

### Added
- Added github templates for issues and PR #35

### Changed
- Synced with template and updated box version #34
- Removed gen/password plugin, now using ansible to generate random username and password #27
- Removed unused intentions #32
- Removed `template_example` folder #41

## [0.1.0]

### Changed
- Renamed vars in `variables.tf` and where they are used #8

### Added
- Using Vault to generate username and password for postgres with kv #13
- Added host volume for postgres and dynamic variables #12
- Added switch for host volume #12
- Added 03_run_tests.yml #3
- Code to support successful execution of nomad mc job and tests when consul_acl_default_policy is deny #22
- Added documentation and LICENSE #2
- Added tests for host volumes #25

## [0.0.1]

### Added

- Initial draft
