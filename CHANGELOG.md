# Changelog

## [0.5.0]

### Changed
- Updated to work with Terraform >1.0
- Fixed `consul_tags` rendering of multiple tags
- Fixed `nomad_datacenters` rendering of multiple datacenters
- `nomad_datacenters` now defaults to the Nomad default of `["*"]`
- Port assignments are now done via the `network` stanza instead of `service` stanza
- Less extraneous whitespace in the generated Nomad job file

### Added
- Added `container_entrypoints`, `container_command`, and `container_command_args` to customize container launch
- Added `use_static_port` to make the `container_port` be a static port
- Added `use_connect` to make Consul Connect optional, default to `true` for backwards compatibility
- Added `pg_isready_path` to customize the path to `pg_isready` health check script

## [0.4.2]

## Changed
- Moved postgres secrets in Nomad to non-readable location #77

## [0.4.1]

### Changed
- Renamed file 01-create_vault_policy_to_read_secrets.yml → 100-create_vault_policy_to_read_secrets.yml #68 
- Consul tags support via input variable #72

## [0.4.0]

### Added
- Expand resources for side_car #56

### Changed
- Removed `failed_when` in `01-create_vault_policy_to_read_secrets.yml` & updated README [no issue]
- Changed to anothrNick/github-tag-action to get bumped version tags. Old action is deprecated [no issue]
- Updated variables for consistency #59

## [0.3.0]

### Added
- Added switch for canary deplyment #44
- Added resource variables #51

### Changed
- Removed box example [no issue]
- Updated README with intentions section #46
- Proper rendering of credentials #45
- Updated box version #49
- Removed `dev` target from makefile [no issue]

### Fixed
- 50% fixed role fatal error. Only works if `use_vault_provider=false` #15

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
