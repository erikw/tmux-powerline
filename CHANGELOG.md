# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Config options to set the status bar's initial visibility, refresh interval and justification: `TMUX_POWERLINE_STATUS_VISIBILITY`, `TMUX_POWERLINE_STATUS_INTERVAL` and `TMUX_POWERLINE_STATUS_JUSTIFICATION`.
- Allow setting the `default` tmux color in segment themes. [#296](https://github.com/erikw/tmux-powerline/issues/296).
- Allow truncation of VCS branch name with a new config `TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN`.
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
