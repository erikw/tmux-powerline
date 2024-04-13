<!-- markdownlint-disable no-duplicate-heading -->
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Dual status bar support [#379](https://github.com/erikw/tmux-powerline/issues/379)
- New segment date_week [#375](https://github.com/erikw/tmux-powerline/issues/375)
- New segment kubernetes_context [#377](https://github.com/erikw/tmux-powerline/issues/377)
- New segment vcs_rootpath [#373](https://github.com/erikw/tmux-powerline/issues/374)
- New segment vpn [#383](https://github.com/erikw/tmux-powerline/issues/383)
- Re-enable Linter [#414](https://github.com/erikw/tmux-powerline/pull/414)
### Changed
- Improved roll_text function [#390](https://github.com/erikw/tmux-powerline/issues/390)
- Improved segment ifstat [#402](https://github.com/erikw/tmux-powerline/issues/402)
- Minor improvements, cleanup & shellcheck compliance
  [#392](https://github.com/erikw/tmux-powerline/pull/392), [#395](https://github.com/erikw/tmux-powerline/pull/395), [#396](https://github.com/erikw/tmux-powerline/pull/396), [#400](https://github.com/erikw/tmux-powerline/pull/400),
  [#401](https://github.com/erikw/tmux-powerline/pull/401), [#403](https://github.com/erikw/tmux-powerline/pull/403), [#407](https://github.com/erikw/tmux-powerline/pull/407), [#406](https://github.com/erikw/tmux-powerline/pull/406),
  [#409](https://github.com/erikw/tmux-powerline/pull/409), [#408](https://github.com/erikw/tmux-powerline/pull/408), [#410](https://github.com/erikw/tmux-powerline/pull/410), [#411](https://github.com/erikw/tmux-powerline/pull/411),
  [#409](https://github.com/erikw/tmux-powerline/pull/412)
- Improve Linter [#418](https://github.com/erikw/tmux-powerline/pull/418)
### Fixed
- Fix vcs segments [#371](https://github.com/erikw/tmux-powerline/issues/371)
- Fix wrong session_info in nested tmux session [#359](https://github.com/erikw/tmux-powerline/issues/359)
- Fix air segment [#394](https://github.com/erikw/tmux-powerline/pull/394) & [#397](https://github.com/erikw/tmux-powerline/pull/397)


## [3.0.0] - 2023-10-02
### Added
- Config options to set the status bar's initial visibility, refresh interval and justification: `TMUX_POWERLINE_STATUS_VISIBILITY`, `TMUX_POWERLINE_STATUS_INTERVAL` and `TMUX_POWERLINE_STATUS_JUSTIFICATION`.
- Allow setting the `default` tmux color in segment themes. [#296](https://github.com/erikw/tmux-powerline/issues/296).
- Allow truncation of VCS branch name with a new config `TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN`.
### Changed
- Removed support for the deprecated config file `~/.tmux-powerlinerc`. [#330](https://github.com/erikw/tmux-powerline/issues/330)
### Fixed
- The now playing segment is fixed for Last.FM using their 2.0 API. [#307](https://github.com/erikw/tmux-powerline/issues/307)
- Correctly handle named colours when specifying theme colours. [#314](https://github.com/erikw/tmux-powerline/issues/314)

## [2.1.0] - 2023-04-16
### Added
- Config options to add keybindigns to mute the status bar added: `TMUX_POWERLINE_MUTE_LEFT_KEYBINDING` and `TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING`.
### Changed
- The old manual way is not supported for simplicity of maintaining the code.

## [2.0.0] - 2023-04-15
### Added
- tmux-powerline is now installable as a [tpm](https://github.com/tmux-plugins/tpm) plugin! Long requested feature. [#189](https://github.com/erikw/tmux-powerline/issues/189)
- Theme config: add ability to selectively disable spacing and segment characters. [#302](https://github.com/erikw/tmux-powerline/pull/302)
### Changed
- Improved the README with config instructions and include user segment instructions.
### Removed
- Dropped support for `$(tmux -V)` <2.2.

## [1.4.0] - 2022-05-04
### Fixed
- Weather segment now working with yr.no as weather provider. [#285](https://github.com/erikw/tmux-powerline/pull/285)

## [1.3.0] - 2022-04-05
### Changed
- Rename master branch to main.

## [1.2.0] - 2021-10-25
### Added
- Support for `$XDG_CONFIG_HOME` for config file.

## [1.1.0] - 2018-03-26

## [1.0.0] - 2015-05-07
- First tagged release.
